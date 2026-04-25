# Trace Correlation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable end-to-end trace ID correlation between the Flutter App, Spring Boot backend, and Next.js Admin, so any request can be traced across all log outputs using a single trace ID.

**Architecture:** The Flutter App already sends `X-Trace-Id` headers. We add a `TraceFilter` on the backend that reads this header (or generates one if absent), places it into SLF4J MDC, and sets it as a response header. All backend log output (request logs, business logic, P6Spy SQL) automatically includes the trace ID via a logback pattern change. The Admin frontend transparently passes through the trace ID header.

**Tech Stack:** Java 8, Spring Boot 2.7.18, SLF4J + Logback 1.2.9, Flutter/Dart, Next.js 16

---

## File Structure

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `backend/grid-common/src/main/java/com/naon/grid/config/webConfig/TraceFilter.java` | Servlet filter: read/generate trace ID, set MDC, set response header |
| Create | `backend/grid-app/src/test/java/com/naon/grid/config/webConfig/TraceFilterTest.java` | Unit tests for TraceFilter |
| Create | `backend/grid-app/src/main/resources/logback-spring.xml` | Logback config with `%X{traceId}` in pattern |
| Modify | `admin/app/api/admin/[...path]/route.ts` | Pass through `X-Trace-Id` header to backend |

**No changes needed:**
- `RequestLoggingFilter.java` — already uses SLF4J, MDC propagates automatically
- `TraceService.dart` — already generates and sends `X-Trace-Id`
- `AppLogger.dart` — already logs traceId in every entry
- `HttpClient.dart` — already adds `X-Trace-Id` header to requests

---

### Task 1: Create TraceFilter

**Files:**
- Create: `backend/grid-common/src/main/java/com/naon/grid/config/webConfig/TraceFilter.java`
- Test: `backend/grid-app/src/test/java/com/naon/grid/config/webConfig/TraceFilterTest.java`

- [ ] **Step 1: Write the failing test**

Create `TraceFilterTest.java`:

```java
package com.naon.grid.config.webConfig;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.slf4j.MDC;
import org.springframework.mock.web.MockFilterChain;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import javax.servlet.ServletException;
import java.io.IOException;

import static org.junit.jupiter.api.Assertions.*;

class TraceFilterTest {

    private TraceFilter traceFilter;
    private MockFilterChain filterChain;
    private MockHttpServletRequest request;
    private MockHttpServletResponse response;

    @BeforeEach
    void setUp() {
        traceFilter = new TraceFilter();
        filterChain = new MockFilterChain();
        request = new MockHttpServletRequest();
        response = new MockHttpServletResponse();
        MDC.clear();
    }

    @AfterEach
    void tearDown() {
        MDC.clear();
    }

    @Test
    void shouldUseTraceIdFromHeader() throws ServletException, IOException {
        request.addHeader("X-Trace-Id", "test-trace-123");

        traceFilter.doFilter(request, response, filterChain);

        assertEquals("test-trace-123", response.getHeader("X-Trace-Id"));
    }

    @Test
    void shouldGenerateTraceIdWhenHeaderMissing() throws ServletException, IOException {
        traceFilter.doFilter(request, response, filterChain);

        String traceId = response.getHeader("X-Trace-Id");
        assertNotNull(traceId);
        assertFalse(traceId.isEmpty());
    }

    @Test
    void shouldGenerateTraceIdWhenHeaderEmpty() throws ServletException, IOException {
        request.addHeader("X-Trace-Id", "");

        traceFilter.doFilter(request, response, filterChain);

        String traceId = response.getHeader("X-Trace-Id");
        assertNotNull(traceId);
        assertFalse(traceId.isEmpty());
    }

    @Test
    void shouldClearMdcAfterFilter() throws ServletException, IOException {
        request.addHeader("X-Trace-Id", "test-trace-456");
        traceFilter.doFilter(request, response, filterChain);

        assertNull(MDC.get("traceId"));
    }

    @Test
    void shouldClearMdcEvenOnException() throws ServletException, IOException {
        request.addHeader("X-Trace-Id", "test-trace-789");
        MockFilterChain failingChain = new MockFilterChain() {
            @Override
            public void doFilter(javax.servlet.ServletRequest request, javax.servlet.ServletResponse response) {
                throw new RuntimeException("Simulated error");
            }
        };

        assertThrows(RuntimeException.class, () -> {
            traceFilter.doFilter(request, response, failingChain);
        });

        assertNull(MDC.get("traceId"));
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /home/nano/little-grid/backend && mvn test -pl grid-app -Dtest=TraceFilterTest -DfailIfNoTests=false 2>&1 | tail -20`
Expected: Compilation error — `TraceFilter` class does not exist

- [ ] **Step 3: Write TraceFilter implementation**

Create `backend/grid-common/src/main/java/com/naon/grid/config/webConfig/TraceFilter.java`:

```java
package com.naon.grid.config.webConfig;

import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.UUID;

/**
 * 链路追踪过滤器
 * 从请求头读取 X-Trace-Id 放入 MDC，使所有日志自动关联 traceId
 * 如果请求没有 X-Trace-Id，自动生成一个
 */
@Slf4j
@Component
@Order(org.springframework.core.Ordered.HIGHEST_PRECEDENCE)
public class TraceFilter implements Filter {

    private static final String TRACE_HEADER = "X-Trace-Id";
    private static final String MDC_KEY = "traceId";

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String traceId = request.getHeader(TRACE_HEADER);
        if (traceId == null || traceId.isEmpty()) {
            traceId = UUID.randomUUID().toString().replace("-", "");
        }

        MDC.put(MDC_KEY, traceId);
        response.setHeader(TRACE_HEADER, traceId);

        try {
            chain.doFilter(req, res);
        } finally {
            MDC.clear();
        }
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /home/nano/little-grid/backend && mvn test -pl grid-app -Dtest=TraceFilterTest 2>&1 | tail -20`
Expected: All 5 tests PASS

- [ ] **Step 5: Commit**

```bash
cd /home/nano/little-grid/backend
git add grid-common/src/main/java/com/naon/grid/config/webConfig/TraceFilter.java grid-app/src/test/java/com/naon/grid/config/webConfig/TraceFilterTest.java
git commit -m "feat: add TraceFilter for MDC-based trace ID correlation"
```

---

### Task 2: Add logback-spring.xml with traceId in log pattern

**Files:**
- Create: `backend/grid-app/src/main/resources/logback-spring.xml`

Currently the project has no logback config file — it uses Spring Boot defaults. We need to create one with `%X{traceId}` in the pattern.

- [ ] **Step 1: Create logback-spring.xml**

Create `backend/grid-app/src/main/resources/logback-spring.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <!-- Console appender -->
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{36} [traceId=%X{traceId}] - %msg%n</pattern>
            <charset>UTF-8</charset>
        </encoder>
    </appender>

    <!-- File appender -->
    <springProperty scope="context" name="LOG_PATH" source="logging.file.path" defaultValue="logs"/>
    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>${LOG_PATH}/grid-app.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedRollingPolicy">
            <fileNamePattern>${LOG_PATH}/grid-app.%d{yyyy-MM-dd}.%i.log</fileNamePattern>
            <maxFileSize>50MB</maxFileSize>
            <maxHistory>30</maxHistory>
            <totalSizeCap>1GB</totalSizeCap>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{36} [traceId=%X{traceId}] - %msg%n</pattern>
            <charset>UTF-8</charset>
        </encoder>
    </appender>

    <!-- P6Spy SQL log level -->
    <logger name="p6spy" level="INFO"/>

    <root level="INFO">
        <appender-ref ref="CONSOLE"/>
        <appender-ref ref="FILE"/>
    </root>
</configuration>
```

- [ ] **Step 2: Verify the app starts and logs include traceId format**

Run: `cd /home/nano/little-grid/backend && mvn spring-boot:run -pl grid-app 2>&1 | head -30`
Expected: Log output lines contain `[traceId=]` (empty for non-request startup logs, populated during HTTP requests)

Then stop the app.

- [ ] **Step 3: Commit**

```bash
cd /home/nano/little-grid
git add backend/grid-app/src/main/resources/logback-spring.xml
git commit -m "feat: add logback config with traceId in log pattern"
```

---

### Task 3: Update Admin API route to pass through X-Trace-Id

**Files:**
- Modify: `admin/app/api/admin/[...path]/route.ts`

- [ ] **Step 1: Add trace ID passthrough to POST handler**

In `admin/app/api/admin/[...path]/route.ts`, modify the `POST` function to read or generate `X-Trace-Id`:

```typescript
export async function POST(request: NextRequest, context: { params: Promise<{ path: string[] }> }) {
  const params = await context.params
  const path = params.path.join('/')
  const body = await request.json()
  const token = request.headers.get('authorization')
  const traceId = request.headers.get('x-trace-id') || crypto.randomUUID()

  const res = await fetch(`${BACKEND_URL}/api/admin/${path}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Trace-Id': traceId,
      ...(token ? { 'Authorization': token } : {}),
    },
    body: JSON.stringify(body),
  })

  const data = await res.json()
  const response = NextResponse.json(data, { status: res.status })
  response.headers.set('X-Trace-Id', res.headers.get('X-Trace-Id') || traceId)
  return response
}
```

- [ ] **Step 2: Add trace ID passthrough to GET handler**

Modify the `GET` function similarly:

```typescript
export async function GET(request: NextRequest, context: { params: Promise<{ path: string[] }> }) {
  const params = await context.params
  const path = params.path.join('/')
  const token = request.headers.get('authorization')
  const traceId = request.headers.get('x-trace-id') || crypto.randomUUID()

  const res = await fetch(`${BACKEND_URL}/api/admin/${path}`, {
    method: 'GET',
    headers: {
      'X-Trace-Id': traceId,
      ...(token ? { 'Authorization': token } : {}),
    },
  })

  const data = await res.json()
  const response = NextResponse.json(data, { status: res.status })
  response.headers.set('X-Trace-Id', res.headers.get('X-Trace-Id') || traceId)
  return response
}
```

- [ ] **Step 3: Verify Admin builds without errors**

Run: `cd /home/nano/little-grid/admin && npm run build 2>&1 | tail -10`
Expected: Build succeeds with no TypeScript errors

- [ ] **Step 4: Commit**

```bash
cd /home/nano/little-grid
git add admin/app/api/admin/\[...path\]/route.ts
git commit -m "feat: pass through X-Trace-Id header in Admin API proxy"
```

---

### Task 4: End-to-end verification

- [ ] **Step 1: Start the backend**

Run: `cd /home/nano/little-grid/backend && mvn spring-boot:run -pl grid-app`

Wait for startup to complete.

- [ ] **Step 2: Send request with X-Trace-Id header**

Run: `curl -s -D - -H "X-Trace-Id: test-e2e-123" http://localhost:8000/ -o /dev/null`
Expected: Response headers include `X-Trace-Id: test-e2e-123`

- [ ] **Step 3: Check backend log for traceId**

Run: `grep "traceId=test-e2e-123" /home/nano/little-grid/backend/grid-app/target/logs/grid-app.log 2>/dev/null || grep "traceId=test-e2e-123" /home/nano/little-grid/backend/logs/grid-app.log 2>/dev/null || echo "Check console output for traceId=test-e2e-123"`
Expected: Log lines contain `[traceId=test-e2e-123]`

- [ ] **Step 4: Send request without X-Trace-Id header**

Run: `curl -s -D - http://localhost:8000/ -o /dev/null`
Expected: Response headers include `X-Trace-Id` with an auto-generated value

- [ ] **Step 5: Verify MDC cleanup (no leakage)**

Run two sequential curl commands with different trace IDs and check the second request's log lines do NOT contain the first request's trace ID.

Stop the backend after verification.

---

## Spec Coverage Check

| Spec Requirement | Task |
|------------------|------|
| TraceFilter reads X-Trace-Id header | Task 1 |
| TraceFilter generates trace ID when missing | Task 1 |
| TraceFilter puts trace ID into MDC | Task 1 |
| TraceFilter sets X-Trace-Id response header | Task 1 |
| TraceFilter cleans up MDC in finally | Task 1 |
| Logback pattern includes `%X{traceId}` | Task 2 |
| P6Spy SQL logs include traceId | Task 2 (automatic via MDC propagation) |
| RequestLoggingFilter logs include traceId | Task 1 (automatic via MDC propagation) |
| Admin API passes through X-Trace-Id | Task 3 |
| End-to-end verification | Task 4 |

No placeholders, no TBDs, no ambiguous steps. All types and method signatures are consistent across tasks.

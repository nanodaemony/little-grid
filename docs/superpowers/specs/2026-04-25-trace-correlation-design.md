# Trace Correlation Design: Client-to-Server Request Tracing

## Overview

Introduce trace ID correlation across the Flutter App and Spring Boot backend so that any request can be traced end-to-end through client logs, server logs, and SQL logs using a single trace ID.

## Context

- **Backend**: Java 8 + Spring Boot 2.7.18, Maven multi-module (grid-common, grid-tools, grid-admin, grid-app), MySQL + Redis, deployed via Docker on a single server
- **App**: Flutter/Dart, already has `TraceService` generating trace IDs and sending `X-Trace-Id` request headers, logs stored in local SQLite
- **Admin**: Next.js 16, proxies API requests to backend
- **Current gap**: The App sends `X-Trace-Id` but the backend does not read it or correlate logs by trace ID

## Approach

**MDC + Trace Filter** — zero-infrastructure, code-only changes using SLF4J MDC (Mapped Diagnostic Context).

## Architecture

```
┌─────────────┐        X-Trace-Id: abc123        ┌──────────────────────┐
│  Flutter App │ ──────────────────────────────→  │  Spring Boot Backend │
│             │                                    │                      │
│ TraceService│ generates traceId                  │  TraceFilter         │
│ writes local│                                    │  reads → puts in MDC │
│ logs        │                                    │                      │
└─────────────┘                                    │  RequestLoggingFilter│
                                                   │  auto includes traceId│
                                                   │                      │
                                                   │  P6Spy SQL logging   │
                                                   │  auto includes traceId│
                                                   └──────────────────────┘
                                                          │
                                                          ▼
                                                   ┌──────────────┐
                                                   │  Local log    │
                                                   │  files with   │
                                                   │  traceId per  │
                                                   │  line         │
                                                   └──────────────┘
```

## Data Flow

1. App `TraceService` generates UUID trace ID, attaches to `X-Trace-Id` header, writes to App local log
2. Backend `TraceFilter` intercepts request, reads `X-Trace-Id`, puts into MDC
3. All subsequent SLF4J log output includes `traceId` via logback pattern `%X{traceId}`
4. On request completion, MDC is cleared to prevent thread-pool reuse pollution
5. If request has no `X-Trace-Id` header (e.g., from Admin frontend), backend auto-generates one

## Backend Changes

### 1. New: `TraceFilter.java` (grid-common)

Location: `grid-common/src/main/java/.../filter/TraceFilter.java`

```java
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class TraceFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        String traceId = request.getHeader("X-Trace-Id");
        if (traceId == null || traceId.isEmpty()) {
            traceId = UUID.randomUUID().toString().replace("-", "");
        }
        MDC.put("traceId", traceId);
        // Also set response header so frontend can read it on errors
        ((HttpServletResponse) res).setHeader("X-Trace-Id", traceId);
        try {
            chain.doFilter(req, res);
        } finally {
            MDC.clear();
        }
    }
}
```

Key design decisions:
- `@Order(Ordered.HIGHEST_PRECEDENCE)` ensures it runs before `RequestLoggingFilter`
- Auto-generates traceId if header is missing (for Admin and other non-App clients)
- Sets `X-Trace-Id` response header for frontend error reporting
- `finally { MDC.clear() }` prevents trace ID leakage in thread pool

### 2. Modified: logback-spring.xml (grid-app)

Add `%X{traceId}` to the log pattern:

```
%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{36} [traceId=%X{traceId}] - %msg%n
```

### 3. No change: RequestLoggingFilter, P6Spy

- `RequestLoggingFilter` already uses SLF4J and runs after `TraceFilter`, so it automatically picks up MDC traceId
- P6Spy SQL logging also goes through SLF4J, MDC propagates automatically

## App Changes

Minimal or no changes needed:
- `TraceService` already generates trace IDs and sends `X-Trace-Id` header
- `LogStorageService` already stores trace ID as a field in SQLite
- Verify `AppLogger` output includes traceId in log entries; adjust format if not

## Admin Changes

### Modified: API route handler

In `app/api/admin/[...path]/route.ts`, transparently pass through `X-Trace-Id` header, or generate one if absent:

```typescript
const traceId = req.headers.get('x-trace-id') || crypto.randomUUID();
fetchHeaders.set('X-Trace-Id', traceId);
```

## Usage: Troubleshooting Workflow

1. User reports an issue → find the traceId in App debug log screen
2. `grep "traceId=abc123" app.log` → see all backend logs for that request (request log, business logic, SQL)
3. Optionally query App SQLite logs by traceId for client-side context

## Verification Plan

- Send request with `X-Trace-Id` header → confirm backend log shows matching traceId
- Send request without `X-Trace-Id` → confirm backend auto-generates traceId
- Send request from App → confirm App log and backend log share the same traceId
- Send request from Admin → confirm traceId passthrough works
- Verify MDC cleanup: make two sequential requests with different traceIds, confirm no leakage

## Future Extension Path

When log volume grows and centralized search is needed:
- **Loki**: MDC format is compatible; add Loki4j appender to push logs to Loki
- **ELK**: Add Logstash JSON encoder to logback; ship to Elasticsearch
- **Custom search API**: Parse log files and build a simple index

All these are additive — no redesign needed, just new appenders/shippers.

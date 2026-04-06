# 统一日志模块实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立覆盖 App/Backend/Admin Web 三端的统一日志系统，支持 TraceId 跨端追踪、敏感信息脱敏、本地持久化。

**Architecture:** Backend 作为核心链路优先实现，App 通过 HTTP Header 传递 TraceId，各端统一日志 API 和结构化格式。

**Tech Stack:** Java/Spring (SLF4J + Logback), Flutter (logger + SQLite), Vue (Axios)

---

## 文件结构

### Backend 新增文件
- `backend/grid-common/src/main/java/me/zhengjie/logging/LogConstants.java`
- `backend/grid-common/src/main/java/me/zhengjie/logging/SensitiveDataMasker.java`
- `backend/grid-common/src/main/java/me/zhengjie/logging/TraceFilter.java`
- `backend/grid-common/src/main/java/me/zhengjie/logging/RequestLogFilter.java`

### Backend 修改文件
- `backend/grid-system/src/main/resources/logback.xml`
- `backend/grid-system/src/main/java/com/naon/grid/AppRun.java`

### App 新增文件
- `app/lib/core/services/trace_service.dart`
- `app/lib/core/services/log_storage_service.dart`
- `app/lib/core/interceptors/trace_interceptor.dart`

### App 修改文件
- `app/lib/core/utils/logger.dart`
- `app/lib/core/services/database_service.dart`
- `app/lib/core/constants/app_constants.dart`
- `app/lib/pages/debug_page.dart`

### Admin Web 新增文件
- `admin-web/src/utils/logger.js`

### Admin Web 修改文件
- `admin-web/src/utils/request.js`

---

## Task 1: Backend LogConstants

**Files:**
- Create: `backend/grid-common/src/main/java/me/zhengjie/logging/LogConstants.java`

- [ ] **Step 1: 创建 LogConstants.java**

```java
/*
 *  Copyright 2019-2025 Zheng Jie
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package me.zhengjie.logging;

import java.util.Set;

/**
 * 日志常量定义
 */
public final class LogConstants {

    /** TraceId HTTP Header 名称 */
    public static final String TRACE_ID_HEADER = "X-Trace-Id";

    /** MDC 中 TraceId 的 key */
    public static final String TRACE_ID_MDC_KEY = "traceId";

    /** TraceId 长度 */
    public static final int TRACE_ID_LENGTH = 8;

    /** 需要脱敏的字段名 */
    public static final Set<String> SENSITIVE_FIELDS = Set.of(
        "password", "pwd", "token", "accessToken", "refreshToken",
        "secret", "apiKey", "creditCard", "Authorization"
    );

    /** 需要打印详细日志的路径前缀 */
    public static final Set<String> LOG_PATH_PREFIXES = Set.of(
        "/api/app/auth",
        "/api/maint"
    );

    /** 需要跳过日志的路径前缀 */
    public static final Set<String> SKIP_PATH_PREFIXES = Set.of(
        "/actuator",
        "/static",
        "/favicon.ico",
        "/swagger-resources",
        "/v2/api-docs",
        "/webjars"
    );

    /** 日志保留天数 */
    public static final int LOG_MAX_HISTORY = 7;

    private LogConstants() {}
}
```

- [ ] **Step 2: 验证文件创建**

Run: `ls backend/grid-common/src/main/java/me/zhengjie/logging/`
Expected: `LogConstants.java`

- [ ] **Step 3: 提交**

```bash
git add backend/grid-common/src/main/java/me/zhengjie/logging/LogConstants.java
git commit -m "feat(backend): add logging constants"
```

---

## Task 2: Backend SensitiveDataMasker

**Files:**
- Create: `backend/grid-common/src/main/java/me/zhengjie/logging/SensitiveDataMasker.java`

- [ ] **Step 1: 创建 SensitiveDataMasker.java**

```java
/*
 *  Copyright 2019-2025 Zheng Jie
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package me.zhengjie.logging;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import lombok.extern.slf4j.Slf4j;

/**
 * 敏感数据脱敏工具
 */
@Slf4j
public final class SensitiveDataMasker {

    private static final ObjectMapper objectMapper = new ObjectMapper();
    private static final String MASK_VALUE = "******";

    /**
     * 对 JSON 字符串中的敏感字段进行脱敏
     * @param jsonStr JSON 字符串
     * @return 脱敏后的 JSON 字符串
     */
    public static String mask(String jsonStr) {
        if (jsonStr == null || jsonStr.isEmpty()) {
            return jsonStr;
        }

        try {
            JsonNode root = objectMapper.readTree(jsonStr);
            if (root.isObject()) {
                maskObjectNode((ObjectNode) root);
                return objectMapper.writeValueAsString(root);
            }
            return jsonStr;
        } catch (Exception e) {
            log.warn("Failed to mask sensitive data: {}", e.getMessage());
            return jsonStr;
        }
    }

    /**
     * 递归脱敏 ObjectNode
     */
    private static void maskObjectNode(ObjectNode node) {
        node.fields().forEachRemaining(entry -> {
            String fieldName = entry.getKey();
            JsonNode fieldValue = entry.getValue();

            if (LogConstants.SENSITIVE_FIELDS.contains(fieldName)) {
                node.put(fieldName, MASK_VALUE);
            } else if (fieldValue.isObject()) {
                maskObjectNode((ObjectNode) fieldValue);
            }
        });
    }

    /**
     * 手机号脱敏: 13812345678 -> 138****5678
     */
    public static String maskPhone(String phone) {
        if (phone == null || phone.length() < 7) {
            return phone;
        }
        return phone.substring(0, 3) + "****" + phone.substring(phone.length() - 4);
    }

    private SensitiveDataMasker() {}
}
```

- [ ] **Step 2: 验证文件创建**

Run: `ls backend/grid-common/src/main/java/me/zhengjie/logging/`
Expected: 包含 `SensitiveDataMasker.java`

- [ ] **Step 3: 提交**

```bash
git add backend/grid-common/src/main/java/me/zhengjie/logging/SensitiveDataMasker.java
git commit -m "feat(backend): add sensitive data masker for logging"
```

---

## Task 3: Backend TraceFilter

**Files:**
- Create: `backend/grid-common/src/main/java/me/zhengjie/logging/TraceFilter.java`

- [ ] **Step 1: 创建 TraceFilter.java**

```java
/*
 *  Copyright 2019-2025 Zheng Jie
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package me.zhengjie.logging;

import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.UUID;

/**
 * TraceId 过滤器
 * 从 HTTP Header 提取 TraceId 并放入 MDC，用于日志追踪
 */
@Slf4j
@Component
@Order(1)
public class TraceFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;

        String traceId = httpRequest.getHeader(LogConstants.TRACE_ID_HEADER);
        if (traceId == null || traceId.isEmpty()) {
            traceId = generateTraceId();
            log.debug("Generated new traceId: {}", traceId);
        }

        MDC.put(LogConstants.TRACE_ID_MDC_KEY, traceId);

        try {
            chain.doFilter(request, response);
        } finally {
            MDC.remove(LogConstants.TRACE_ID_MDC_KEY);
        }
    }

    /**
     * 生成 8 位 TraceId
     */
    private String generateTraceId() {
        return UUID.randomUUID().toString().replace("-", "").substring(0, LogConstants.TRACE_ID_LENGTH);
    }

    @Override
    public void init(FilterConfig filterConfig) {
        log.info("TraceFilter initialized");
    }

    @Override
    public void destroy() {
        log.info("TraceFilter destroyed");
    }
}
```

- [ ] **Step 2: 验证文件创建**

Run: `ls backend/grid-common/src/main/java/me/zhengjie/logging/`
Expected: 包含 `TraceFilter.java`

- [ ] **Step 3: 提交**

```bash
git add backend/grid-common/src/main/java/me/zhengjie/logging/TraceFilter.java
git commit -m "feat(backend): add trace filter for MDC traceId injection"
```

---

## Task 4: Backend RequestLogFilter

**Files:**
- Create: `backend/grid-common/src/main/java/me/zhengjie/logging/RequestLogFilter.java`

- [ ] **Step 1: 创建 RequestLogFilter.java**

```java
/*
 *  Copyright 2019-2025 Zheng Jie
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package me.zhengjie.logging;

import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.util.ContentCachingRequestWrapper;
import org.springframework.web.util.ContentCachingResponseWrapper;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Enumeration;
import java.util.stream.Collectors;

/**
 * 请求/响应日志过滤器
 * 打印完整的请求和响应信息，便于调试
 */
@Slf4j
@Component
@Order(2)
public class RequestLogFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // 跳过不需要记录的路径
        if (shouldSkip(httpRequest.getRequestURI())) {
            chain.doFilter(request, response);
            return;
        }

        // 包装请求和响应，以便多次读取内容
        ContentCachingRequestWrapper wrappedRequest = new ContentCachingRequestWrapper(httpRequest);
        ContentCachingResponseWrapper wrappedResponse = new ContentCachingResponseWrapper(httpResponse);

        long startTime = System.currentTimeMillis();
        String traceId = MDC.get(LogConstants.TRACE_ID_MDC_KEY);

        // 先执行请求，让内容被缓存
        chain.doFilter(wrappedRequest, wrappedResponse);

        long duration = System.currentTimeMillis() - startTime;

        // 打印请求日志
        logRequest(wrappedRequest, traceId);

        // 打印响应日志
        logResponse(wrappedResponse, traceId, duration);

        // 将缓存的内容写回原始响应
        wrappedResponse.copyBodyToResponse();
    }

    /**
     * 打印请求日志
     */
    private void logRequest(ContentCachingRequestWrapper request, String traceId) {
        String method = request.getMethod();
        String uri = request.getRequestURI();
        String headers = extractHeaders(request);
        String body = getRequestBody(request);

        log.info("=== 请求开始 [traceId: {}] ===\n{} {}\nHeaders: {}\nBody: {}",
            traceId, method, uri, headers, body);
    }

    /**
     * 打印响应日志
     */
    private void logResponse(ContentCachingResponseWrapper response, String traceId, long duration) {
        int status = response.getStatus();
        String body = getResponseBody(response);

        log.info("=== 响应 [traceId: {}] ===\nStatus: {}\nBody: {}\n耗时: {}ms\n=== 请求结束 ===",
            traceId, status, body, duration);
    }

    /**
     * 提取请求头
     */
    private String extractHeaders(HttpServletRequest request) {
        Enumeration<String> headerNames = request.getHeaderNames();
        return headerNames.stream()
            .map(name -> name + "=" + request.getHeader(name))
            .filter(header -> !header.toLowerCase().contains("authorization"))
            .collect(Collectors.joining(", "));
    }

    /**
     * 获取请求体（脱敏）
     */
    private String getRequestBody(ContentCachingRequestWrapper request) {
        byte[] content = request.getContentAsByteArray();
        if (content.length == 0) {
            return "";
        }
        String body = new String(content, StandardCharsets.UTF_8);
        return SensitiveDataMasker.mask(body);
    }

    /**
     * 获取响应体（脱敏）
     */
    private String getResponseBody(ContentCachingResponseWrapper response) {
        byte[] content = response.getContentAsByteArray();
        if (content.length == 0) {
            return "";
        }
        String body = new String(content, StandardCharsets.UTF_8);
        return SensitiveDataMasker.mask(body);
    }

    /**
     * 判断是否跳过日志记录
     */
    private boolean shouldSkip(String uri) {
        return LogConstants.SKIP_PATH_PREFIXES.stream()
            .anyMatch(uri::startsWith);
    }

    @Override
    public void init(FilterConfig filterConfig) {
        log.info("RequestLogFilter initialized");
    }

    @Override
    public void destroy() {
        log.info("RequestLogFilter destroyed");
    }
}
```

- [ ] **Step 2: 验证文件创建**

Run: `ls backend/grid-common/src/main/java/me/zhengjie/logging/`
Expected: 包含 `RequestLogFilter.java`

- [ ] **Step 3: 提交**

```bash
git add backend/grid-common/src/main/java/me/zhengjie/logging/RequestLogFilter.java
git commit -m "feat(backend): add request/response log filter with sensitive data masking"
```

---

## Task 5: Backend logback.xml 配置

**Files:**
- Modify: `backend/grid-system/src/main/resources/logback.xml`

- [ ] **Step 1: 修改 logback.xml，增加文件日志和 TraceId**

将整个文件替换为：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration scan="true" scanPeriod="30 seconds" debug="false">
    <contextName>grid</contextName>
    <property name="log.charset" value="utf-8" />
    <property name="log.pattern" value="%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level [%X{traceId}] %logger{36} - %msg%n" />

    <!--输出到控制台-->
    <appender name="console" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>${log.pattern}</pattern>
            <charset>${log.charset}</charset>
        </encoder>
    </appender>

    <!--普通日志输出到文件-->
    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>logs/grid-app.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>logs/grid-app.%d{yyyy-MM-dd}.log</fileNamePattern>
            <maxHistory>7</maxHistory>
        </rollingPolicy>
        <encoder>
            <pattern>${log.pattern}</pattern>
            <charset>${log.charset}</charset>
        </encoder>
    </appender>

    <!--ERROR日志单独输出到文件-->
    <appender name="ERROR_FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>logs/grid-app-error.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>logs/grid-app-error.%d{yyyy-MM-dd}.log</fileNamePattern>
            <maxHistory>7</maxHistory>
        </rollingPolicy>
        <encoder>
            <pattern>${log.pattern}</pattern>
            <charset>${log.charset}</charset>
        </encoder>
        <filter class="ch.qos.logback.classic.filter.LevelFilter">
            <level>ERROR</level>
            <onMatch>ACCEPT</onMatch>
            <onMismatch>DENY</onMismatch>
        </filter>
    </appender>

    <!--普通日志输出到控制台-->
    <root level="info">
        <appender-ref ref="console" />
        <appender-ref ref="FILE" />
        <appender-ref ref="ERROR_FILE" />
    </root>

    <!-- Spring 日志级别控制 -->
    <logger name="org.springframework" level="warn" />

    <!-- DnsServerAddressStreamProviders调整为ERROR -->
    <logger name="io.netty.resolver.dns.DnsServerAddressStreamProviders" level="ERROR"/>

    <!-- 设置其他类的日志级别为 ERROR -->
    <logger name="org.apache.catalina.core.ContainerBase.[Tomcat].[localhost].[/]" level="ERROR"/>
    <logger name="org.springframework.web.servlet.DispatcherServlet" level="ERROR"/>
</configuration>
```

- [ ] **Step 2: 验证修改**

Run: `cat backend/grid-system/src/main/resources/logback.xml | grep -A5 "appender name=\"FILE\""`
Expected: 包含 `<file>logs/grid-app.log</file>` 和 `<pattern>` 带 `%X{traceId}`

- [ ] **Step 3: 提交**

```bash
git add backend/grid-system/src/main/resources/logback.xml
git commit -m "feat(backend): add file logging and traceId to logback config"
```

---

## Task 6: Backend 编译验证

**Files:**
- 无文件修改，仅编译验证

- [ ] **Step 1: 编译 Backend 项目**

Run: `cd backend && mvn compile -q`
Expected: 编译成功，无错误

- [ ] **Step 2: 提交（如有自动生成文件）**

```bash
git status
# 如果有新的 target 文件被意外跟踪，忽略它们
```

---

## Task 7: App AppConstants 增加 DB 版本

**Files:**
- Modify: `app/lib/core/constants/app_constants.dart`

- [ ] **Step 1: 查找并读取 app_constants.dart**

Run: `cat app/lib/core/constants/app_constants.dart`

- [ ] **Step 2: 增加 dbVersion（当前版本 + 1）**

在文件中找到 `dbVersion` 定义，将其值增加 1。如果文件不存在则创建：

```dart
class AppConstants {
  static const String dbName = 'littlegrid.db';
  static const int dbVersion = 9;  // 从 8 增加到 9
  static const int logMaxCount = 1000;  // 日志最大保留数量
}
```

- [ ] **Step 3: 提交**

```bash
git add app/lib/core/constants/app_constants.dart
git commit -m "feat(app): increase db version for logs table"
```

---

## Task 8: App TraceService

**Files:**
- Create: `app/lib/core/services/trace_service.dart`

- [ ] **Step 1: 创建 trace_service.dart**

```dart
import 'package:flutter/foundation.dart';

/// TraceId 管理服务
/// 用于生成和管理跨端追踪的 TraceId
class TraceService extends ChangeNotifier {
  static final TraceService _instance = TraceService._internal();
  factory TraceService() => _instance;
  TraceService._internal();

  /// 当前活跃的 TraceId
  String? _currentTraceId;

  /// 获取当前 TraceId
  String? get currentTraceId => _currentTraceId;

  /// 生成新的 TraceId（8位随机字符串）
  String generate() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 1000000).toString().padLeft(6, '0');
    final prefix = (timestamp % 100).toString().padLeft(2, '0');
    _currentTraceId = '$prefix$random';
    notifyListeners();
    return _currentTraceId!;
  }

  /// 设置 TraceId（从 HTTP Header 获取）
  void setTraceId(String? traceId) {
    _currentTraceId = traceId;
    notifyListeners();
  }

  /// 清除 TraceId
  void clear() {
    _currentTraceId = null;
    notifyListeners();
  }
}
```

- [ ] **Step 2: 验证文件创建**

Run: `ls app/lib/core/services/trace_service.dart`
Expected: 文件存在

- [ ] **Step 3: 提交**

```bash
git add app/lib/core/services/trace_service.dart
git commit -m "feat(app): add trace service for traceId management"
```

---

## Task 9: App TraceInterceptor

**Files:**
- Create: `app/lib/core/interceptors/trace_interceptor.dart`

- [ ] **Step 1: 创建 interceptors 目录**

Run: `mkdir -p app/lib/core/interceptors`

- [ ] **Step 2: 创建 trace_interceptor.dart**

```dart
import 'package:http/http.dart' as http;
import '../services/trace_service.dart';

/// HTTP TraceId 拦截器
/// 自动在请求头中注入 TraceId
class TraceInterceptor {
  /// 拦截请求，添加 TraceId Header
  static http.BaseRequest intercept(http.BaseRequest request) {
    final traceService = TraceService();
    String traceId = traceService.currentTraceId ?? traceService.generate();
    
    request.headers['X-Trace-Id'] = traceId;
    return request;
  }

  /// 包装 HTTP Client，自动注入 TraceId
  static http.Client wrapClient(http.Client client) {
    return _TraceClient(client);
  }
}

/// 带 TraceId 的 HTTP Client 包装
class _TraceClient extends http.BaseClient {
  final http.Client _inner;

  _TraceClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    TraceInterceptor.intercept(request);
    return _inner.send(request);
  }
}
```

- [ ] **Step 3: 验证文件创建**

Run: `ls app/lib/core/interceptors/trace_interceptor.dart`
Expected: 文件存在

- [ ] **Step 4: 提交**

```bash
git add app/lib/core/interceptors/trace_interceptor.dart
git commit -m "feat(app): add trace interceptor for HTTP requests"
```

---

## Task 10: App LogStorageService

**Files:**
- Create: `app/lib/core/services/log_storage_service.dart`
- Modify: `app/lib/core/services/database_service.dart`

- [ ] **Step 1: 在 database_service.dart 的 _onUpgrade 中添加 logs 表**

在 `_onUpgrade` 方法末尾添加：

```dart
    if (oldVersion < 9) {
      // 日志表
      await db.execute('''
        CREATE TABLE logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp INTEGER NOT NULL,
          level TEXT NOT NULL,
          module TEXT,
          trace_id TEXT,
          message TEXT NOT NULL,
          error TEXT
        )
      ''');
      await db.execute('CREATE INDEX idx_logs_timestamp ON logs(timestamp)');
      await db.execute('CREATE INDEX idx_logs_trace_id ON logs(trace_id)');
      AppLogger.i('Added logs table');
    }
```

同时在 `_onCreate` 方法中添加相同的建表语句。

- [ ] **Step 2: 创建 log_storage_service.dart**

```dart
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../constants/app_constants.dart';

/// 日志存储服务
/// 将日志持久化到 SQLite，支持历史查询
class LogStorageService {
  static final LogStorageService _instance = LogStorageService._internal();
  factory LogStorageService() => _instance;
  LogStorageService._internal();

  /// 保存日志
  Future<void> save({
    required String level,
    required String message,
    String? module,
    String? traceId,
    String? error,
  }) async {
    final db = await DatabaseService.database;
    
    await db.insert('logs', {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'level': level,
      'module': module,
      'trace_id': traceId,
      'message': message,
      'error': error,
    });

    // 清理旧日志
    await _cleanupOldLogs(db);
  }

  /// 获取日志列表
  Future<List<Map<String, dynamic>>> getLogs({
    int limit = 100,
    String? level,
    String? module,
    String? traceId,
    String? search,
  }) async {
    final db = await DatabaseService.database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (level != null) {
      whereClause += 'level = ?';
      whereArgs.add(level);
    }
    if (module != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'module = ?';
      whereArgs.add(module);
    }
    if (traceId != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'trace_id = ?';
      whereArgs.add(traceId);
    }
    if (search != null && search.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'message LIKE ?';
      whereArgs.add('%$search%');
    }

    final results = await db.query(
      'logs',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return results;
  }

  /// 按 TraceId 获取关联日志
  Future<List<Map<String, dynamic>>> getLogsByTraceId(String traceId) async {
    return getLogs(traceId: traceId, limit: 500);
  }

  /// 清空所有日志
  Future<void> clearAll() async {
    final db = await DatabaseService.database;
    await db.delete('logs');
  }

  /// 清理超过最大数量的旧日志
  Future<void> _cleanupOldLogs(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM logs')
    ) ?? 0;

    if (count > AppConstants.logMaxCount) {
      final deleteCount = count - AppConstants.logMaxCount;
      await db.rawDelete(
        'DELETE FROM logs WHERE id IN (SELECT id FROM logs ORDER BY timestamp ASC LIMIT ?)',
        [deleteCount]
      );
    }
  }

  /// 导出日志为文本
  Future<String> exportLogs({int limit = 1000}) async {
    final logs = await getLogs(limit: limit);
    final buffer = StringBuffer();
    
    for (final log in logs) {
      final timestamp = DateTime.fromMillisecondsSinceEpoch(log['timestamp'] as int);
      final timeStr = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
          '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
      
      buffer.writeln('$timeStr ${log['level']} [${log['module'] ?? 'App'}] [${log['trace_id'] ?? 'no-trace'}] ${log['message']}');
      if (log['error'] != null) {
        buffer.writeln('  Error: ${log['error']}');
      }
    }
    
    return buffer.toString();
  }
}
```

- [ ] **Step 3: 验证文件创建和修改**

Run: `ls app/lib/core/services/log_storage_service.dart`
Expected: 文件存在

Run: `grep -n "oldVersion < 9" app/lib/core/services/database_service.dart`
Expected: 找到新增的代码块

- [ ] **Step 4: 提交**

```bash
git add app/lib/core/services/log_storage_service.dart app/lib/core/services/database_service.dart
git commit -m "feat(app): add log storage service with SQLite persistence"
```

---

## Task 11: App Logger 重构

**Files:**
- Modify: `app/lib/core/utils/logger.dart`

- [ ] **Step 1: 重构 logger.dart**

将文件替换为：

```dart
import 'package:logger/logger.dart';
import '../services/debug_log_service.dart';
import '../services/log_storage_service.dart';
import '../services/trace_service.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

/// 统一日志 API
/// 同时输出到控制台、实时日志服务、持久化存储
class AppLogger {
  static final LogStorageService _storage = LogStorageService();

  /// Debug 级别日志
  static void d(String message, {String? module, String? traceId}) {
    final tid = traceId ?? TraceService().currentTraceId;
    logger.d('[${module ?? 'App'}] [$tid] $message');
    DebugLogService().addLog('DEBUG', '[${module ?? 'App'}] $message');
    _storage.save(level: 'DEBUG', message: message, module: module, traceId: tid);
  }

  /// Info 级别日志
  static void i(String message, {String? module, String? traceId}) {
    final tid = traceId ?? TraceService().currentTraceId;
    logger.i('[${module ?? 'App'}] [$tid] $message');
    DebugLogService().addLog('INFO', '[${module ?? 'App'}] $message');
    _storage.save(level: 'INFO', message: message, module: module, traceId: tid);
  }

  /// Warning 级别日志
  static void w(String message, {String? module, String? traceId}) {
    final tid = traceId ?? TraceService().currentTraceId;
    logger.w('[${module ?? 'App'}] [$tid] $message');
    DebugLogService().addLog('WARNING', '[${module ?? 'App'}] $message');
    _storage.save(level: 'WARNING', message: message, module: module, traceId: tid);
  }

  /// Error 级别日志
  static void e(String message, {dynamic error, StackTrace? stackTrace, String? module, String? traceId}) {
    final tid = traceId ?? TraceService().currentTraceId;
    final errorStr = error != null ? error.toString() : null;
    logger.e('[${module ?? 'App'}] [$tid] $message', error: error, stackTrace: stackTrace);
    DebugLogService().addLog('ERROR', '[${module ?? 'App'}] $message');
    _storage.save(level: 'ERROR', message: message, module: module, traceId: tid, error: errorStr);
  }

  // ============ 便捷方法 ============

  /// Debug（自动获取 TraceId）
  static void logDebug(String module, String message) {
    d(message, module: module);
  }

  /// Info（自动获取 TraceId）
  static void logInfo(String module, String message) {
    i(message, module: module);
  }

  /// Warning（自动获取 TraceId）
  static void logWarn(String module, String message) {
    w(message, module: module);
  }

  /// Error（自动获取 TraceId）
  static void logError(String module, String message, {dynamic error, StackTrace? stackTrace}) {
    e(message, error: error, stackTrace: stackTrace, module: module);
  }
}
```

- [ ] **Step 2: 验证修改**

Run: `grep -n "LogStorageService" app/lib/core/utils/logger.dart`
Expected: 找到引用

- [ ] **Step 3: 提交**

```bash
git add app/lib/core/utils/logger.dart
git commit -m "feat(app): refactor logger to support traceId and persistence"
```

---

## Task 12: App DebugPage 重构

**Files:**
- Modify: `app/lib/pages/debug_page.dart`

- [ ] **Step 1: 重构 debug_page.dart，增加历史日志和搜索**

将文件替换为：

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/debug_log_service.dart';
import '../core/services/log_storage_service.dart';
import '../core/utils/logger.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LogStorageService _logStorage = LogStorageService();
  List<Map<String, dynamic>> _historyLogs = [];
  String _searchQuery = '';
  String? _selectedTraceId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistoryLogs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistoryLogs() async {
    final logs = await _logStorage.getLogs(limit: 200);
    setState(() {
      _historyLogs = logs;
    });
  }

  Future<void> _searchLogs(String query) async {
    setState(() {
      _searchQuery = query;
    });
    final logs = await _logStorage.getLogs(limit: 200, search: query);
    setState(() {
      _historyLogs = logs;
    });
  }

  Future<void> _filterByTraceId(String traceId) async {
    setState(() {
      _selectedTraceId = traceId;
    });
    final logs = await _logStorage.getLogsByTraceId(traceId);
    setState(() {
      _historyLogs = logs;
    });
  }

  Future<void> _clearAllLogs() async {
    await _logStorage.clearAll();
    context.read<DebugLogService>().clearLogs();
    await _loadHistoryLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '实时日志'),
            Tab(text: '历史日志'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRealTimeLogs(),
          _buildHistoryLogs(),
        ],
      ),
    );
  }

  Widget _buildRealTimeLogs() {
    return Column(
      children: [
        Expanded(
          child: Consumer<DebugLogService>(
            builder: (context, logService, child) {
              final logs = logService.logs;

              if (logs.isEmpty) {
                return const Center(
                  child: Text('暂无日志', style: TextStyle(color: Colors.grey)),
                );
              }

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16.0),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[logs.length - 1 - index];
                  return _buildRealTimeLogItem(log);
                },
              );
            },
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _clearAllLogs,
              icon: const Icon(Icons.clear_all),
              label: const Text('清空所有日志'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red.shade900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryLogs() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: '搜索 TraceId 或关键词',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: _searchLogs,
          ),
        ),
        if (_selectedTraceId != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
              label: Text('TraceId: $_selectedTraceId'),
              onDeleted: () {
                setState(() {
                  _selectedTraceId = null;
                });
                _loadHistoryLogs();
              },
            ),
          ),
        Expanded(
          child: _historyLogs.isEmpty
              ? const Center(child: Text('暂无历史日志', style: TextStyle(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: _loadHistoryLogs,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _historyLogs.length,
                    itemBuilder: (context, index) {
                      final log = _historyLogs[index];
                      return _buildHistoryLogItem(log);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildRealTimeLogItem(LogEntry log) {
    Color levelColor;
    switch (log.level) {
      case 'DEBUG': levelColor = Colors.grey; break;
      case 'INFO': levelColor = Colors.blue; break;
      case 'WARNING': levelColor = Colors.orange; break;
      case 'ERROR': levelColor = Colors.red; break;
      default: levelColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}]',
            style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'monospace'),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(color: levelColor.withOpacity(0.2), borderRadius: BorderRadius.circular(3)),
            child: Text(log.level, style: TextStyle(fontSize: 10, color: levelColor, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(log.message, style: const TextStyle(fontSize: 12, fontFamily: 'monospace'))),
        ],
      ),
    );
  }

  Widget _buildHistoryLogItem(Map<String, dynamic> log) {
    final timestamp = DateTime.fromMillisecondsSinceEpoch(log['timestamp'] as int);
    final level = log['level'] as String;
    final module = log['module'] as String?;
    final traceId = log['trace_id'] as String?;
    final message = log['message'] as String;

    Color levelColor;
    switch (level) {
      case 'DEBUG': levelColor = Colors.grey; break;
      case 'INFO': levelColor = Colors.blue; break;
      case 'WARNING': levelColor = Colors.orange; break;
      case 'ERROR': levelColor = Colors.red; break;
      default: levelColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'monospace'),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(color: levelColor.withOpacity(0.2), borderRadius: BorderRadius.circular(3)),
            child: Text(level, style: TextStyle(fontSize: 10, color: levelColor, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          ),
          const SizedBox(width: 4),
          if (traceId != null)
            GestureDetector(
              onTap: () => _filterByTraceId(traceId),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(color: Colors.purple.withOpacity(0.2), borderRadius: BorderRadius.circular(3)),
                child: Text(traceId, style: const TextStyle(fontSize: 10, color: Colors.purple, fontFamily: 'monospace')),
              ),
            ),
          const SizedBox(width: 4),
          if (module != null)
            Text('[${module}] ', style: const TextStyle(fontSize: 11, color: Colors.teal, fontFamily: 'monospace')),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 12, fontFamily: 'monospace'))),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 验证修改**

Run: `grep -n "TabController" app/lib/pages/debug_page.dart`
Expected: 找到 TabController 定义

- [ ] **Step 3: 提交**

```bash
git add app/lib/pages/debug_page.dart
git commit -m "feat(app): enhance debug page with history logs and traceId filter"
```

---

## Task 13: Admin Web Logger

**Files:**
- Create: `admin-web/src/utils/logger.js`

- [ ] **Step 1: 创建 logger.js**

```javascript
/**
 * 统一日志 API
 * 支持模块、TraceId、结构化格式
 */

const SENSITIVE_FIELDS = ['password', 'pwd', 'token', 'accessToken', 'refreshToken', 'secret', 'apiKey', 'creditCard', 'Authorization']
const MASK_VALUE = '******'

/**
 * 格式化时间戳
 */
function formatTime() {
  const now = new Date()
  return `${now.getHours().toString().padLeft(2, '0')}:${now.getMinutes().toString().padLeft(2, '0')}:${now.getSeconds().toString().padLeft(2, '0')}`
}

// 为 String 添加 padLeft 方法
if (!String.prototype.padLeft) {
  String.prototype.padLeft = function(length, char) {
    return this.length >= length ? this : char.repeat(length - this.length) + this
  }
}

/**
 * 脱敏 JSON 数据
 */
function maskSensitiveData(data) {
  if (!data) return data
  if (typeof data !== 'object') return data
  
  const masked = Array.isArray(data) ? [...data] : { ...data }
  
  if (Array.isArray(masked)) {
    return masked.map(item => maskSensitiveData(item))
  }
  
  SENSITIVE_FIELDS.forEach(field => {
    if (masked[field] !== undefined) {
      masked[field] = MASK_VALUE
    }
  })
  
  // 递归处理嵌套对象
  Object.keys(masked).forEach(key => {
    if (typeof masked[key] === 'object' && masked[key] !== null) {
      masked[key] = maskSensitiveData(masked[key])
    }
  })
  
  return masked
}

/**
 * 获取当前 TraceId
 */
function getTraceId() {
  return localStorage.getItem('currentTraceId') || 'no-trace'
}

/**
 * 统一日志对象
 */
const Logger = {
  debug(module, message, data = null) {
    const traceId = getTraceId()
    const logMsg = `[${formatTime()}] DEBUG [${module}] [${traceId}] ${message}`
    if (data) {
      console.debug(logMsg, maskSensitiveData(data))
    } else {
      console.debug(logMsg)
    }
  },

  info(module, message, data = null) {
    const traceId = getTraceId()
    const logMsg = `[${formatTime()}] INFO [${module}] [${traceId}] ${message}`
    if (data) {
      console.info(logMsg, maskSensitiveData(data))
    } else {
      console.info(logMsg)
    }
  },

  warn(module, message, data = null) {
    const traceId = getTraceId()
    const logMsg = `[${formatTime()}] WARN [${module}] [${traceId}] ${message}`
    if (data) {
      console.warn(logMsg, maskSensitiveData(data))
    } else {
      console.warn(logMsg)
    }
  },

  error(module, message, error = null) {
    const traceId = getTraceId()
    const logMsg = `[${formatTime()}] ERROR [${module}] [${traceId}] ${message}`
    if (error) {
      console.error(logMsg, error)
    } else {
      console.error(logMsg)
    }
  },

  /**
   * 生成 TraceId
   */
  generateTraceId() {
    const timestamp = Date.now()
    const random = (timestamp % 1000000).toString().padLeft(6, '0')
    const prefix = (timestamp % 100).toString().padLeft(2, '0')
    return `${prefix}${random}`
  },

  /**
   * 设置 TraceId
   */
  setTraceId(traceId) {
    localStorage.setItem('currentTraceId', traceId)
  },

  /**
   * 清除 TraceId
   */
  clearTraceId() {
    localStorage.removeItem('currentTraceId')
  }
}

export default Logger
```

- [ ] **Step 2: 验证文件创建**

Run: `ls admin-web/src/utils/logger.js`
Expected: 文件存在

- [ ] **Step 3: 提交**

```bash
git add admin-web/src/utils/logger.js
git commit -m "feat(admin-web): add unified logger with traceId support"
```

---

## Task 14: Admin Web Request 拦截器

**Files:**
- Modify: `admin-web/src/utils/request.js`

- [ ] **Step 1: 修改 request.js，添加 Logger 和 TraceId**

在文件顶部添加 import：

```javascript
import Logger from '@/utils/logger'
```

修改 request 拦截器：

```javascript
// request拦截器
service.interceptors.request.use(
  config => {
    // 生成 TraceId
    const traceId = Logger.generateTraceId()
    config.headers['X-Trace-Id'] = traceId
    Logger.setTraceId(traceId)

    if (getToken()) {
      config.headers['Authorization'] = getToken()
    }
    config.headers['Content-Type'] = 'application/json'

    // 打印请求日志
    Logger.info('HTTP', `${config.method?.toUpperCase() || 'GET'} ${config.url}`, {
      params: config.params,
      data: config.data
    })

    return config
  },
  error => {
    Logger.error('HTTP', '请求配置失败', error)
    return Promise.reject(error)
  }
)
```

修改 response 拦截器：

```javascript
// response 拦截器
service.interceptors.response.use(
  response => {
    // 打印响应日志
    Logger.info('HTTP', `响应 ${response.config?.url}`, {
      status: response.status,
      data: response.data
    })
    return response.data
  },
  error => {
    // 打印错误日志
    Logger.error('HTTP', `请求失败 ${error.config?.url}`, {
      status: error.response?.status,
      message: error.response?.data?.message || error.message
    })

    // 兼容blob下载出错json提示
    if (error.response?.data instanceof Blob && error.response?.data.type?.toLowerCase().indexOf('json') !== -1) {
      const reader = new FileReader()
      reader.readAsText(error.response.data, 'utf-8')
      reader.onload = function(e) {
        const errorMsg = JSON.parse(reader.result).message
        Notification.error({
          title: errorMsg,
          duration: 5000
        })
      }
    } else {
      let code = 0
      try {
        code = error.response?.data?.status
      } catch (e) {
        if (error.toString().indexOf('Error: timeout') !== -1) {
          Notification.error({
            title: '网络请求超时',
            duration: 5000
          })
          return Promise.reject(error)
        }
      }
      if (code) {
        if (code === 401) {
          store.dispatch('LogOut').then(() => {
            Cookies.set('point', 401)
            location.reload()
          })
        } else if (code === 403) {
          router.push({ path: '/401' })
        } else {
          const errorMsg = error.response?.data?.message
          if (errorMsg !== undefined) {
            Notification.error({
              title: errorMsg,
              duration: 5000
            })
          }
        }
      } else {
        Notification.error({
          title: '接口请求失败',
          duration: 5000
        })
      }
    }
    return Promise.reject(error)
  }
)
```

- [ ] **Step 2: 验证修改**

Run: `grep -n "Logger" admin-web/src/utils/request.js`
Expected: 找到 Logger import 和使用

- [ ] **Step 3: 提交**

```bash
git add admin-web/src/utils/request.js
git commit -m "feat(admin-web): add traceId and logging to axios interceptor"
```

---

## Task 15: App 编译验证

**Files:**
- 无文件修改，仅编译验证

- [ ] **Step 1: 检查 Flutter 分析**

Run: `cd app && flutter analyze`
Expected: 无错误，可能有少量 info/warning

- [ ] **Step 2: 提交所有剩余更改**

```bash
git status
git add -A
git commit -m "chore: ensure all logging changes are committed"
```

---

## Task 16: 集成测试验证

**Files:**
- 无文件修改，仅验证

- [ ] **Step 1: 启动 Backend 服务**

Run: `cd backend && mvn spring-boot:run -pl grid-system`
Expected: 服务启动成功，日志输出到 `logs/grid-app.log`

- [ ] **Step 2: 检查 Backend 日志文件**

Run: `ls backend/logs/`
Expected: 包含 `grid-app.log` 和 `grid-app-error.log`

- [ ] **Step 3: 发送测试请求验证 TraceId**

Run: `curl -X POST http://localhost:8080/api/app/auth/login -H "Content-Type: application/json" -H "X-Trace-Id: test123" -d '{"phone":"test","password":"test"}'`
Expected: Backend 日志中包含 `[test123]`

- [ ] **Step 4: 提交最终验证**

```bash
git log --oneline -10
# 确认所有日志相关 commit 都存在
```

---

## 验收清单

- [ ] Backend 日志包含 TraceId（格式：`[traceId]`）
- [ ] Backend 请求/响应日志打印完整信息
- [ ] Backend 敏感字段已脱敏
- [ ] Backend 日志文件存在：`logs/grid-app.log`, `logs/grid-app-error.log`
- [ ] App 日志支持 TraceId 和 module
- [ ] App 日志持久化到 SQLite
- [ ] App DebugPage 支持实时日志 + 历史日志 Tab
- [ ] App DebugPage 支持 TraceId 筛选
- [ ] Admin Web HTTP 请求自动生成 TraceId
- [ ] Admin Web 使用统一 Logger API
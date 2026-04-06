# 统一日志模块设计

## 背景

当前项目日志系统存在问题：
- **App 端**: 有 `AppLogger` 和 `DebugLogService`，但无持久化，无法回溯历史问题
- **Backend**: 只有控制台日志，无文件输出，无结构化格式，缺少请求/响应详细日志
- **Admin Web**: `console.log` 散落各处，无统一规范
- **跨端追踪**: 无法通过 TraceId 串联 App -> Backend 的请求链路

## 目标

- 覆盖范围：App + Backend + Admin Web
- 主要用途：开发调试
- 支持跨端追踪（TraceId）
- 敏感信息自动脱敏
- 本地持久化便于回溯

---

## 整体架构

```
┌─────────────────────────────────────────────────────────────────┐
│                        TraceId 传递链路                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌──────────┐    X-Trace-Id Header    ┌──────────┐            │
│   │  App     │ ──────────────────────▶ │ Backend  │            │
│   │ (Flutter)│                         │ (Java)   │            │
│   └──────────┘                         └──────────┘            │
│        │                                    │                  │
│        │                                    │                  │
│   ┌────┴────┐                           ┌────┴────┐           │
│   │ SQLite  │                           │ Log File│           │
│   │持久化日志 │                           │ 持久化  │           │
│   └──────────┘                           └──────────┘           │
│                                                                 │
│   ┌──────────┐                                              │
│   │Admin Web │  (console + optional localStorage)           │
│   │ (Vue)    │                                              │
│   └──────────┘                                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## App 端设计 (Flutter)

### 组件结构

```
app/lib/core/
├── utils/
│   └── logger.dart              # 统一日志 API (重构现有)
├── services/
│   ├── log_storage_service.dart # SQLite 持久化
│   └── trace_service.dart       # TraceId 管理
│   └── debug_log_service.dart   # 实时日志 (现有，保留)
├── interceptors/
│   └── trace_interceptor.dart   # HTTP 请求自动注入 TraceId
```

### 日志 API

```dart
class AppLogger {
  // 基础方法
  static void d(String message, {String? module, String? traceId});
  static void i(String message, {String? module, String? traceId});
  static void w(String message, {String? module, String? traceId});
  static void e(String message, {dynamic error, StackTrace? stackTrace, String? module, String? traceId});

  // 便捷方法 - 自动获取当前 TraceId
  static void logDebug(String module, String message);
  static void logInfo(String module, String message);
  static void logWarn(String module, String message);
  static void logError(String module, String message, {dynamic error, StackTrace? stackTrace});
}
```

### 日志格式

```
[时间戳] [级别] [模块] [TraceId] 消息
示例：
2024-04-06 14:30:15 INFO AuthService abc123 用户登录请求
2024-04-06 14:30:16 ERROR AuthService abc123 登录失败: 密码错误
```

### 持久化策略

- 使用现有 SQLite 数据库，新增 `logs` 表
- 表结构：`id, timestamp, level, module, trace_id, message, error`
- 保留最近 1000 条日志（可配置）
- 超过限制自动清理旧日志

### Debug 页面联动

- **实时日志**: 继续使用现有 `DebugLogService`
- **历史日志**: 新增 `LogStorageService` 从 SQLite 读取
- **双层展示**: 实时日志 Tab + 历史日志 Tab
- **TraceId 点击**: 点击任意 TraceId，自动筛选关联日志
- **功能增强**: 搜索、筛选（级别/模块）、导出

### 数据流

```
AppLogger.i(message)
    │
    ├─▶ DebugLogService.addLog()  ─▶ 实时日志展示 (现有)
    │
    └─▶ LogStorageService.save()  ─▶ SQLite 持久化 ─▶ 历史日志展示
```

### HTTP TraceId 拦截器

```dart
class TraceInterceptor implements http.Interceptor {
  @override
  Future<http.Request> intercept(http.Request request) async {
    String traceId = TraceService.currentTraceId ?? TraceService.generate();
    request.headers['X-Trace-Id'] = traceId;
    TraceService.currentTraceId = traceId;
    return request;
  }
}
```

---

## Backend 端设计 (Java/Spring)

### 组件结构

```
backend/grid-common/src/main/java/
├── logging/
│   ├── TraceFilter.java           # 从 HTTP Header 提取 TraceId，放入 MDC
│   ├── RequestLogFilter.java      # 请求/响应日志打印
│   ├── ContentCachingWrapper.java # 包装 Request/Response 支持多次读取
│   ├── SensitiveDataMasker.java   # 敏感信息脱敏
│   ├── LogConstants.java          # 常量定义
```

### TraceId 传递

```java
// TraceFilter.java
public class TraceFilter implements Filter {
    @Override
    public void doFilter(...) {
        String traceId = request.getHeader("X-Trace-Id");
        if (traceId == null) {
            traceId = UUID.randomUUID().toString().substring(0, 8);
        }
        MDC.put("traceId", traceId);

        chain.doFilter(request, response);

        MDC.remove("traceId");
    }
}
```

### 请求/响应日志格式

```log
=== 请求开始 [traceId: abc123] ===
POST /api/app/auth/login
Headers: Content-Type=application/json, X-Trace-Id=abc123
Body: {"phone":"138****1234","password":"******","deviceId":"device001"}

=== 响应 [traceId: abc123] ===
Status: 200
Body: {"code":0,"data":{"token":"xxx","user":{...}},"message":"success"}
耗时: 125ms
=== 请求结束 ===
```

### 敏感信息脱敏

脱敏字段：`password`, `pwd`, `token`, `accessToken`, `refreshToken`, `secret`, `apiKey`, `creditCard`

```java
// {"password":"abc123"} -> {"password":"******"}
```

### RequestLogFilter 实现

- 使用 `ContentCachingRequestWrapper` / `ContentCachingResponseWrapper` 包装请求/响应
- 请求前打印：Method、URI、Headers、Body（脱敏）
- 响应后打印：Status、Body（脱敏）、耗时
- 过滤规则：
  - 打印路径：`/api/app/auth/**`, `/api/maint/**`
  - 跳过路径：`/actuator/**`, `/static/**`, `/favicon.ico`

### 文件日志配置 (logback.xml)

```xml
<!-- 普通日志文件 -->
<appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>logs/grid-app.log</file>
    <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
        <fileNamePattern>logs/grid-app.%d{yyyy-MM-dd}.log</fileNamePattern>
        <maxHistory>7</maxHistory>
    </rollingPolicy>
    <encoder>
        <pattern>%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level [%X{traceId}] %logger{36} - %msg%n</pattern>
    </encoder>
</appender>

<!-- ERROR 日志单独文件 -->
<appender name="ERROR_FILE" class="...">
    <file>logs/grid-app-error.log</file>
    <filter class="ch.qos.logback.classic.filter.LevelFilter">
        <level>ERROR</level>
        <onMatch>ACCEPT</onMatch>
        <onMismatch>DENY</onMismatch>
    </filter>
</appender>

<root level="info">
    <appender-ref ref="console" />
    <appender-ref ref="FILE" />
    <appender-ref ref="ERROR_FILE" />
</root>
```

---

## Admin Web 端设计 (Vue)

### 组件结构

```
admin-web/src/
├── utils/
│   ├── logger.js           # 统一日志 API
│   └── request.js          # Axios 拦截器 (现有，扩展 TraceId)
```

### 日志 API

```javascript
// logger.js
const Logger = {
  debug(module, message, data = null),
  info(module, message, data = null),
  warn(module, message, data = null),
  error(module, message, error = null)
}

// 使用方式
import Logger from '@/utils/logger'
Logger.error('UserAPI', '获取用户列表失败', err)
```

### TraceId 拦截器

扩展现有 `request.js`：

```javascript
// 请求拦截器
service.interceptors.request.use(config => {
  const traceId = generateTraceId()
  config.headers['X-Trace-Id'] = traceId
  localStorage.setItem('currentTraceId', traceId)
  Logger.info('HTTP', `${config.method?.toUpperCase()} ${config.url}`, {
    params: config.params,
    data: maskSensitiveData(config.data)
  })
  return config
})

// 响应拦截器
service.interceptors.response.use(
  response => {
    Logger.info('HTTP', `响应 ${response.config.url}`, {
      status: response.status,
      data: maskSensitiveData(response.data)
    })
    return response
  },
  error => {
    Logger.error('HTTP', `请求失败 ${error.config?.url}`, error)
    return Promise.reject(error)
  }
)
```

### 敏感信息脱敏

与 Backend 保持一致的脱敏规则。

---

## 实现优先级

1. **Backend TraceFilter + RequestLogFilter** - 核心链路
2. **Backend logback.xml 文件日志** - 持久化基础
3. **App TraceService + HTTP 拦截器** - TraceId 传递
4. **App LogStorageService** - 持久化
5. **App Logger 重构 + DebugPage 联动** - UI 展示
6. **Admin Web Logger + 拦截器** - 统一规范
7. **替换现有散落的 console.log/log.error** - 统一使用新 API

---

## 验收标准

- App 发起请求，Backend 日志中能通过 TraceId 找到对应记录
- DebugPage 能查看实时日志 + 历史日志，支持 TraceId 筛选
- Backend 日志文件存在：`logs/grid-app.log`, `logs/grid-app-error.log`
- 请求/响应日志包含完整信息，敏感字段已脱敏
- Admin Web 使用统一 Logger API，不再有散落的 console.log
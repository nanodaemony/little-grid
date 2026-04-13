---
name: Little Grid 速查表
description: 三个子项目的关键规范，Claude 自动加载
type: reference
---

# Little Grid 项目速查表

## 项目概览

- **app/** - Flutter 移动端（小方格工具集合）
- **backend/** - Spring Boot 后端服务（基于 ELADMIN）
- **admin-web/** - Vue 2 管理前端（基于 Element UI）

---

## Flutter (app) 关键规范

**工具创建流程：**
1. 在 `app/lib/tools/<tool_name>/` 创建文件
2. 必须有 `<tool_name>_tool.dart` - 实现 ToolModule 接口
3. 必须有 `<tool_name>_page.dart` - 主页面 UI
4. 在 `main.dart` 中注册：`ToolRegistry.register(MyTool())`

**关键文件：**
- `app/lib/core/services/tool_registry.dart` - 工具注册表
- `app/lib/core/ui/app_colors.dart` - 颜色常量（必须使用，不要硬编码）
- `app/lib/core/constants/app_constants.dart` - 数据库版本在此升级

**颜色规范：**
使用 `AppColors.primary` 等，不要用 `Colors.red` 等硬编码

---

## Java (backend) 关键规范

**模块结构：**
- grid-common - 公共模块（BaseEntity, utils, config）
- grid-system - 系统核心（启动入口）
- grid-logging, grid-tools, grid-generator, grid-app

**分层架构：**
```
modules/<module>/
├── domain/       - Entity（继承 BaseEntity）
├── repository/   - JPA Repository
├── service/      - Service 接口 + impl/ 实现
│   ├── dto/      - Dto + QueryCriteria
│   └── mapstruct/- MapStruct Mapper
└── rest/         - REST Controller
```

**Entity 模板：**
- 继承 `BaseEntity`
- 使用 `@Getter @Setter` (Lombok)
- 使用 `@ApiModelProperty` 注解 (Swagger)
- 实现 equals/hashCode

---

## Vue (admin-web) 关键规范

**目录结构：**
- `src/api/` - API 接口模块
- `src/views/` - 页面组件
- `src/components/` - 公共组件
- `src/store/modules/` - Vuex 状态管理
- `src/utils/request.js` - axios 拦截器（必须用这个发请求）

**API 模块模板：**
```javascript
import request from '@/utils/request'
export function listXxx(query) {
  return request({ url: '/api/xxx', method: 'get', params: query })
}
```

**request.js 自动处理：**
- 添加 Authorization Token
- 添加 X-Trace-Id 链路追踪
- 请求/响应日志
- 统一错误处理

---

## 常用命令

**Flutter:**
```bash
flutter pub get    # 安装依赖
flutter run         # 运行
flutter analyze     # 代码检查
```

**Java:**
```bash
mvn clean package -Dmaven.test.skip=true    # 打包
mvn spring-boot:run -pl grid-system          # 运行
```

**Vue:**
```bash
npm install       # 安装依赖
npm run dev       # 开发 (localhost:8013)
npm run build:prod # 生产构建
```

# Vue 管理前端规范

## 技术栈版本

- Node.js: >= 12, <= 16
- Vue: 2.7.16
- Vue Router: 3.0.2
- Vuex: 3.1.0
- UI 框架: Element UI 2.15.14
- HTTP 客户端: axios 1.8.2
- 构建工具: Vue CLI 3

## 目录结构

```
admin-web/src/
├── api/                   # API 接口模块
│   ├── login.js
│   ├── system/
│   │   ├── user.js
│   │   ├── role.js
│   │   └── ...
│   └── ...
├── assets/                # 静态资源
├── components/            # 公共组件
│   ├── Crud/
│   ├── Dict/
│   └── ...
├── layout/                # 布局组件
├── router/                # 路由配置
├── store/                 # Vuex 状态管理
│   └── modules/
│       ├── user.js
│       ├── app.js
│       └── ...
├── utils/                 # 工具函数
│   ├── request.js         # axios 拦截器
│   ├── auth.js
│   └── ...
├── views/                 # 页面组件
│   ├── dashboard/
│   ├── system/
│   │   ├── user/
│   │   ├── role/
│   │   └── ...
│   └── ...
├── App.vue
└── main.js
```

## 命名规范

### 文件命名
- 组件: 大驼峰 `User.vue`, `RoleForm.vue`
- 工具/API: 小驼峰 `user.js`, `auth.js`

### 组件命名
- 组件名大驼峰: `export default { name: 'User' }`
- 私有组件: `_UserDetail.vue`

### 变量命名
- 小驼峰: `userName`, `isLoading`
- 常量: 全大写下划线: `MAX_COUNT`

## 代码规范

### API 模块定义

API 统一放在 `src/api/` 目录下，使用 `request.js` 封装的 axios 实例。

详见 [patterns/new_api.md](./patterns/new_api.md)

### HTTP 请求拦截器

`request.js` 自动处理：
- 添加 Authorization Token
- 添加 X-Trace-Id 链路追踪
- 请求/响应日志
- 统一错误处理

### Vuex Store 结构

按模块划分，每个模块包含 state, mutations, actions, getters。

### Element UI 使用

使用 Element UI 组件库，保持风格一致。

## 常用命令

```bash
# 安装依赖
npm install

# 开发环境运行 (localhost:8013)
npm run dev

# 生产环境构建
npm run build:prod

# 代码检查
npm run lint
```

## 检查清单

新增功能时确认：
- [ ] API 模块已创建在 `src/api/`
- [ ] 使用 `request.js` 发送请求
- [ ] 页面组件放在 `src/views/`
- [ ] 使用 Element UI 组件
- [ ] 错误处理已完善

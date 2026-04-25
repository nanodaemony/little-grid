# Admin 框架搭建设计

## 概述

为 LittleGrid Admin Web 搭建完整的框架结构，包括顶栏、侧栏菜单、内容区布局以及所有菜单对应的路由和占位页面。本次只做前端框架和页面占位，不开发实际功能。

## 布局

- **顶栏 (64px)**：左侧 Logo + 搜索框，右侧通知/设置/头像，无面包屑
- **侧栏 (256px 固定)**：不折叠，扁平菜单，中文，1 级菜单可展开 2 级子菜单
- **内容区**：剩余空间，浅灰背景 (#f8f9fa)，Material 风格卡片

## 视觉风格

- 淡色 Material Design 风格
- 主色：#1A73E8 (Google Blue)
- 背景：白色顶栏/侧栏，浅灰内容区
- 圆角 12px 卡片，elevation-1 阴影
- 图标：Material Icons Round
- 字体：Noto Sans SC
- 组件库：shadcn/ui + Tailwind CSS

## 菜单结构

扁平制，不硬分大类：

```
首页
用户管理 ─┬─ APP 用户
          └─ 管理员
内容管理 ─┬─ 树洞审核
          └─ 举报处理
支付管理 ─┬─ 交易记录
          └─ 支付宝配置
运维 ────┬─ 监控
         └─ 日志
工具 ────┬─ 文件上传
         ├─ 数据库管理
         ├─ 存储管理
         └─ 缓存管理
系统设置
API 文档
```

## 路由映射

| 菜单 | 路由 |
|------|------|
| 首页 | `/dashboard` |
| APP 用户 | `/dashboard/users/app` |
| 管理员 | `/dashboard/users/admin` |
| 树洞审核 | `/dashboard/content/treehole` |
| 举报处理 | `/dashboard/content/reports` |
| 交易记录 | `/dashboard/payments/transactions` |
| 支付宝配置 | `/dashboard/payments/alipay` |
| 监控 | `/dashboard/ops/monitor` |
| 日志 | `/dashboard/ops/logs` |
| 文件上传 | `/dashboard/tools/upload` |
| 数据库管理 | `/dashboard/tools/database` |
| 存储管理 | `/dashboard/tools/storage` |
| 缓存管理 | `/dashboard/tools/cache` |
| 系统设置 | `/dashboard/settings` |
| API 文档 | `/dashboard/api-docs` |

## 技术方案

- 沿用现有 Next.js 16 App Router + Tailwind CSS + shadcn/ui
- 侧栏为独立组件，当前页高亮通过路由路径判断
- 各菜单页先做占位页面（标题 + "功能开发中"提示）
- 顶栏搜索框为 UI 占位，暂不实现搜索逻辑

## 范围

- 本次只搭建前端框架和占位页面
- 不开发实际业务功能
- 不修改后端 API

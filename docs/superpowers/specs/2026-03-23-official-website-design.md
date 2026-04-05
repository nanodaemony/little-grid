# LittleGrid 官网设计文档

## 1. 项目概述

| 属性 | 内容 |
|------|------|
| **项目名称** | LittleGrid Official Website |
| **定位** | LittleGrid APP 产品展示官网 |
| **技术栈** | 纯静态 HTML + CSS + JavaScript |
| **目标平台** | 桌面浏览器、移动端浏览器 |

## 2. 项目结构

```
officialwebsite/
├── index.html          # 单页面入口
├── css/
│   └── style.css       # 样式文件
├── js/
│   └── main.js         # 交互脚本
└── assets/
    └── images/         # 图片资源
```

## 3. 技术选型

| 项目 | 选择 | 理由 |
|------|------|------|
| **HTML** | HTML5 | 语义化标签，SEO友好 |
| **CSS** | 原生 CSS3 | 无需构建，直接部署 |
| **JavaScript** | 原生 ES6+ | 最小化使用，轻量级 |
| **部署** | Nginx / Docker | 静态资源托管 |

## 4. 响应式设计

### 4.1 断点定义

| 设备类型 | 宽度范围 | 布局 |
|----------|----------|------|
| **桌面** | ≥768px | 多列网格布局 |
| **手机** | <768px | 单列布局 |

### 4.2 移动端适配要点

- 导航栏固定顶部
- Hero 区垂直居中，按钮全宽
- 功能卡片单列堆叠
- 下载区二维码居中放大
- 使用相对单位（rem/vw）
- 触摸友好的点击区域（最小 44px）

## 5. 页面板块设计

### 5.1 Hero 区（首屏）

- 应用 Logo + 名称 "小方格 LittleGrid"
- 一句话简介："一个优雅的模块化工具集合"
- GitHub 链接按钮
- 淡蓝色渐变背景

### 5.2 功能展示区

展示 5 个内置工具：

| 工具 | 图标 | 描述 |
|------|------|------|
| 🪙 投硬币 | coin | 正反面随机，快速决策 |
| 🎲 掷骰子 | dice | 支持1-6个骰子，动画效果 |
| 🃏 抽卡 | card | 随机抽取，趣味十足 |
| ✅ 待办事项 | todo | 简洁的任务管理 |
| 🔢 计算器 | calculator | 支持复杂表达式计算 |

布局：
- 桌面：3列网格
- 手机：单列堆叠

### 5.3 下载区

- 标题："立即下载"
- 下载二维码占位图（160x160px）
- 提示文字："扫码下载 APP"

### 5.4 更新日志

时间线形式展示版本历史：

```
v1.0.0 (2024-xx-xx)
- 首次发布
- 包含投硬币、掷骰子、抽卡、待办事项、计算器
```

### 5.5 用户反馈

- 简单的反馈入口
- 可选：GitHub Issues 链接

### 5.6 页脚

- 版权信息："© 2024 LittleGrid Team"
- GitHub 仓库链接

## 6. 设计风格

### 6.1 配色方案

| 用途 | 颜色值 | 说明 |
|------|--------|------|
| **主色** | #5B9BD5 | APP 主题蓝 |
| **背景** | #FFFFFF | 纯白背景 |
| **次背景** | #F5F8FC | 淡蓝灰背景 |
| **文字** | #333333 | 主文字 |
| **次文字** | #666666 | 次要文字 |
| **边框** | #E0E0E0 | 卡片边框 |

### 6.2 设计原则

- **扁平化设计**：无阴影、无渐变（除 Hero 区背景）
- **圆角卡片**：8px 圆角
- **简洁排版**：充足留白
- **一致性**：与 APP 风格统一

## 7. 部署方案

### 方案一：Nginx 直接托管

```nginx
server {
    listen 80;
    server_name littlegrid.example.com;

    root /var/www/officialwebsite;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

### 方案二：Docker 容器化部署

```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
```

```bash
docker build -t littlegrid-web .
docker run -d -p 80:80 littlegrid-web
```

**推荐**：Nginx 直接托管，简单高效。

## 8. 文件清单

### 8.1 HTML 结构 (index.html)

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>小方格 - LittleGrid</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <header>导航栏</header>
    <main>
        <section class="hero">Hero区</section>
        <section class="features">功能展示</section>
        <section class="download">下载区</section>
        <section class="changelog">更新日志</section>
        <section class="feedback">用户反馈</section>
    </main>
    <footer>页脚</footer>
    <script src="js/main.js"></script>
</body>
</html>
```

### 8.2 CSS 模块 (style.css)

- CSS 变量定义
- 基础样式重置
- 响应式布局
- 组件样式

### 8.3 JavaScript (main.js)

- 平滑滚动
- 移动端菜单切换
- 简单交互效果

## 9. 约束与约定

- 使用语义化 HTML 标签
- CSS 使用 BEM 命名规范
- 图片使用占位图，预留替换接口
- 代码注释使用中文
- 文件编码统一 UTF-8

---

**文档版本**：v1.0
**创建日期**：2026-03-23
**状态**：待用户审核
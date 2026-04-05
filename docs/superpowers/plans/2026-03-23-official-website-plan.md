# LittleGrid 官网实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 创建 LittleGrid APP 的产品展示官网，包含功能介绍、下载入口、更新日志等内容。

**Architecture:** 单页面静态网站，使用语义化 HTML 结构，CSS 实现响应式布局（768px 断点），原生 JavaScript 处理简单交互。

**Tech Stack:** HTML5 + CSS3 + 原生 JavaScript (ES6+)

---

## 文件结构

```
officialwebsite/
├── index.html          # 单页面入口
├── css/
│   └── style.css       # 样式文件（含响应式）
├── js/
│   └── main.js         # 交互脚本
└── assets/
    └── images/         # 图片资源目录
```

---

## Task 1: 创建项目目录结构

**Files:**
- Create: `officialwebsite/`
- Create: `officialwebsite/css/`
- Create: `officialwebsite/js/`
- Create: `officialwebsite/assets/images/`

- [ ] **Step 1: 创建目录结构**

```bash
mkdir -p officialwebsite/css officialwebsite/js officialwebsite/assets/images
```

- [ ] **Step 2: 验证目录创建成功**

Run: `ls -la officialwebsite/`
Expected: 显示 css/, js/, assets/ 目录

---

## Task 2: 创建 CSS 样式文件

**Files:**
- Create: `officialwebsite/css/style.css`

- [ ] **Step 1: 创建 CSS 文件，包含变量定义和重置样式**

```css
/* ========================================
   LittleGrid 官网样式
   扁平化设计 · 淡蓝色主题 · 响应式布局
   ======================================== */

/* CSS 变量 */
:root {
  --color-primary: #5B9BD5;
  --color-primary-dark: #4A89C4;
  --color-bg: #FFFFFF;
  --color-bg-alt: #F5F8FC;
  --color-text: #333333;
  --color-text-secondary: #666666;
  --color-border: #E0E0E0;

  --radius-card: 8px;
  --spacing-section: 80px;
  --spacing-section-mobile: 48px;

  --font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
}

/* 重置样式 */
*, *::before, *::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

html {
  scroll-behavior: smooth;
  font-size: 16px;
}

body {
  font-family: var(--font-family);
  color: var(--color-text);
  background-color: var(--color-bg);
  line-height: 1.6;
}

a {
  color: var(--color-primary);
  text-decoration: none;
  transition: color 0.2s ease;
}

a:hover {
  color: var(--color-primary-dark);
}

ul {
  list-style: none;
}

img {
  max-width: 100%;
  height: auto;
}
```

- [ ] **Step 2: 添加通用组件样式**

```css
/* 通用组件 */
.container {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px;
}

.section {
  padding: var(--spacing-section) 0;
}

.section--alt {
  background-color: var(--color-bg-alt);
}

.section__title {
  font-size: 2rem;
  font-weight: 600;
  text-align: center;
  margin-bottom: 48px;
  color: var(--color-text);
}

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px 28px;
  border-radius: var(--radius-card);
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  border: none;
}

.btn--primary {
  background-color: var(--color-primary);
  color: #FFFFFF;
}

.btn--primary:hover {
  background-color: var(--color-primary-dark);
  color: #FFFFFF;
}

.btn--outline {
  background-color: transparent;
  color: var(--color-primary);
  border: 2px solid var(--color-primary);
}

.btn--outline:hover {
  background-color: var(--color-primary);
  color: #FFFFFF;
}

/* 卡片 */
.card {
  background-color: var(--color-bg);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-card);
  padding: 24px;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}
```

- [ ] **Step 3: 添加 Header 导航样式**

```css
/* Header 导航 */
.header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  background-color: var(--color-bg);
  border-bottom: 1px solid var(--color-border);
  z-index: 1000;
}

.header__inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 64px;
}

.header__logo {
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--color-text);
}

.header__nav {
  display: flex;
  gap: 32px;
}

.header__link {
  font-size: 0.95rem;
  color: var(--color-text-secondary);
  transition: color 0.2s ease;
}

.header__link:hover {
  color: var(--color-primary);
}

/* 移动端菜单按钮 */
.header__menu-btn {
  display: none;
  width: 44px;
  height: 44px;
  align-items: center;
  justify-content: center;
  background: none;
  border: none;
  cursor: pointer;
  font-size: 1.5rem;
}
```

- [ ] **Step 4: 添加 Hero 区样式**

```css
/* Hero 区 */
.hero {
  padding-top: 64px; /* 补偿固定导航高度 */
  min-height: 100vh;
  display: flex;
  align-items: center;
  background: linear-gradient(135deg, #E8F4FD 0%, #FFFFFF 100%);
}

.hero__inner {
  text-align: center;
  padding: 48px 0;
}

.hero__logo {
  font-size: 3rem;
  margin-bottom: 16px;
}

.hero__title {
  font-size: 2.5rem;
  font-weight: 700;
  color: var(--color-text);
  margin-bottom: 16px;
}

.hero__subtitle {
  font-size: 1.25rem;
  color: var(--color-text-secondary);
  margin-bottom: 32px;
}

.hero__actions {
  display: flex;
  gap: 16px;
  justify-content: center;
  flex-wrap: wrap;
}
```

- [ ] **Step 5: 添加功能展示区样式**

```css
/* 功能展示区 */
.features__grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}

.feature-card {
  text-align: center;
  padding: 32px 24px;
}

.feature-card__icon {
  font-size: 2.5rem;
  margin-bottom: 16px;
}

.feature-card__name {
  font-size: 1.125rem;
  font-weight: 600;
  color: var(--color-text);
  margin-bottom: 8px;
}

.feature-card__desc {
  font-size: 0.95rem;
  color: var(--color-text-secondary);
}
```

- [ ] **Step 6: 添加下载区样式**

```css
/* 下载区 */
.download {
  text-align: center;
}

.download__qrcode {
  width: 160px;
  height: 160px;
  background-color: var(--color-bg-alt);
  border: 2px dashed var(--color-border);
  border-radius: var(--radius-card);
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 16px;
  color: var(--color-text-secondary);
  font-size: 0.875rem;
}

.download__tip {
  font-size: 0.95rem;
  color: var(--color-text-secondary);
}
```

- [ ] **Step 7: 添加更新日志样式**

```css
/* 更新日志 */
.changelog__list {
  max-width: 600px;
  margin: 0 auto;
}

.changelog__item {
  position: relative;
  padding-left: 32px;
  padding-bottom: 32px;
  border-left: 2px solid var(--color-border);
}

.changelog__item:last-child {
  border-left-color: transparent;
  padding-bottom: 0;
}

.changelog__item::before {
  content: '';
  position: absolute;
  left: -7px;
  top: 4px;
  width: 12px;
  height: 12px;
  background-color: var(--color-primary);
  border-radius: 50%;
}

.changelog__version {
  font-size: 1.125rem;
  font-weight: 600;
  color: var(--color-text);
  margin-bottom: 8px;
}

.changelog__date {
  font-size: 0.875rem;
  color: var(--color-text-secondary);
  margin-bottom: 12px;
}

.changelog__changes {
  font-size: 0.95rem;
  color: var(--color-text-secondary);
  line-height: 1.8;
}

.changelog__changes li {
  margin-bottom: 4px;
}
```

- [ ] **Step 8: 添加用户反馈区样式**

```css
/* 用户反馈 */
.feedback {
  text-align: center;
}

.feedback__desc {
  font-size: 1rem;
  color: var(--color-text-secondary);
  margin-bottom: 24px;
}

.feedback__actions {
  display: flex;
  gap: 16px;
  justify-content: center;
  flex-wrap: wrap;
}
```

- [ ] **Step 9: 添加 Footer 样式**

```css
/* Footer */
.footer {
  background-color: var(--color-bg-alt);
  padding: 32px 0;
  text-align: center;
}

.footer__copyright {
  font-size: 0.875rem;
  color: var(--color-text-secondary);
  margin-bottom: 12px;
}

.footer__links {
  display: flex;
  gap: 24px;
  justify-content: center;
}

.footer__link {
  font-size: 0.875rem;
  color: var(--color-text-secondary);
}

.footer__link:hover {
  color: var(--color-primary);
}
```

- [ ] **Step 10: 添加响应式样式（移动端适配）**

```css
/* ========================================
   响应式设计 - 移动端适配
   断点: 768px
   ======================================== */

@media (max-width: 767px) {
  :root {
    font-size: 14px;
  }

  .container {
    padding: 0 16px;
  }

  .section {
    padding: var(--spacing-section-mobile) 0;
  }

  .section__title {
    font-size: 1.5rem;
    margin-bottom: 32px;
  }

  /* Header 移动端 */
  .header__nav {
    display: none;
    position: absolute;
    top: 64px;
    left: 0;
    right: 0;
    background-color: var(--color-bg);
    flex-direction: column;
    padding: 16px;
    gap: 16px;
    border-bottom: 1px solid var(--color-border);
  }

  .header__nav.active {
    display: flex;
  }

  .header__menu-btn {
    display: flex;
  }

  /* Hero 移动端 */
  .hero__title {
    font-size: 1.75rem;
  }

  .hero__subtitle {
    font-size: 1rem;
  }

  .hero__actions {
    flex-direction: column;
    align-items: stretch;
  }

  .hero__actions .btn {
    width: 100%;
  }

  /* 功能卡片移动端 */
  .features__grid {
    grid-template-columns: 1fr;
  }

  /* 下载区移动端 */
  .download__qrcode {
    width: 200px;
    height: 200px;
  }
}
```

- [ ] **Step 11: 提交 CSS 文件**

```bash
git add officialwebsite/css/style.css
git commit -m "feat(website): 添加官网样式文件

- 定义CSS变量（配色、间距等）
- 实现Header、Hero、功能卡片等组件样式
- 添加响应式布局支持移动端

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 3: 创建 HTML 页面

**Files:**
- Create: `officialwebsite/index.html`

- [ ] **Step 1: 创建 HTML 文件基础结构和 Header**

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="小方格 LittleGrid - 一个优雅的模块化工具集合，包含投硬币、掷骰子、抽卡、待办事项、计算器等实用工具。">
  <meta name="keywords" content="小方格, LittleGrid, 工具集合, 投硬币, 掷骰子, 待办事项">
  <title>小方格 - LittleGrid | 模块化工具集合</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
  <!-- Header 导航 -->
  <header class="header">
    <div class="container header__inner">
      <a href="#" class="header__logo">🧩 小方格</a>
      <nav class="header__nav" id="nav">
        <a href="#features" class="header__link">功能</a>
        <a href="#download" class="header__link">下载</a>
        <a href="#changelog" class="header__link">更新日志</a>
        <a href="https://github.com/yourusername/littlegrid" class="header__link" target="_blank" rel="noopener">GitHub</a>
      </nav>
      <button class="header__menu-btn" id="menuBtn" aria-label="菜单">☰</button>
    </div>
  </header>
```

- [ ] **Step 2: 添加 Hero 区**

```html
  <!-- Hero 区 -->
  <section class="hero">
    <div class="container hero__inner">
      <div class="hero__logo">🧩</div>
      <h1 class="hero__title">小方格 LittleGrid</h1>
      <p class="hero__subtitle">一个优雅的模块化工具集合</p>
      <div class="hero__actions">
        <a href="https://github.com/yourusername/littlegrid" class="btn btn--primary" target="_blank" rel="noopener">
          <span>⭐</span> GitHub
        </a>
        <a href="#download" class="btn btn--outline">立即下载</a>
      </div>
    </div>
  </section>
```

- [ ] **Step 3: 添加功能展示区**

```html
  <!-- 功能展示区 -->
  <section class="section section--alt" id="features">
    <div class="container">
      <h2 class="section__title">内置工具</h2>
      <div class="features__grid">
        <div class="card feature-card">
          <div class="feature-card__icon">🪙</div>
          <h3 class="feature-card__name">投硬币</h3>
          <p class="feature-card__desc">正反面随机，快速决策</p>
        </div>
        <div class="card feature-card">
          <div class="feature-card__icon">🎲</div>
          <h3 class="feature-card__name">掷骰子</h3>
          <p class="feature-card__desc">支持1-6个骰子，动画效果</p>
        </div>
        <div class="card feature-card">
          <div class="feature-card__icon">🃏</div>
          <h3 class="feature-card__name">抽卡</h3>
          <p class="feature-card__desc">随机抽取，趣味十足</p>
        </div>
        <div class="card feature-card">
          <div class="feature-card__icon">✅</div>
          <h3 class="feature-card__name">待办事项</h3>
          <p class="feature-card__desc">简洁的任务管理</p>
        </div>
        <div class="card feature-card">
          <div class="feature-card__icon">🔢</div>
          <h3 class="feature-card__name">计算器</h3>
          <p class="feature-card__desc">支持复杂表达式计算</p>
        </div>
      </div>
    </div>
  </section>
```

- [ ] **Step 4: 添加下载区**

```html
  <!-- 下载区 -->
  <section class="section download" id="download">
    <div class="container">
      <h2 class="section__title">立即下载</h2>
      <div class="download__qrcode">
        <span>二维码占位图<br>160×160</span>
      </div>
      <p class="download__tip">扫码下载 APP</p>
    </div>
  </section>
```

- [ ] **Step 5: 添加更新日志区**

```html
  <!-- 更新日志 -->
  <section class="section section--alt" id="changelog">
    <div class="container">
      <h2 class="section__title">更新日志</h2>
      <div class="changelog__list">
        <div class="changelog__item">
          <h3 class="changelog__version">v1.0.0</h3>
          <p class="changelog__date">2024-03-20</p>
          <ul class="changelog__changes">
            <li>首次发布</li>
            <li>包含投硬币、掷骰子、抽卡、待办事项、计算器</li>
            <li>支持 Android 和 iOS 平台</li>
          </ul>
        </div>
      </div>
    </div>
  </section>
```

- [ ] **Step 6: 添加用户反馈区和 Footer**

```html
  <!-- 用户反馈 -->
  <section class="section feedback" id="feedback">
    <div class="container">
      <h2 class="section__title">用户反馈</h2>
      <p class="feedback__desc">遇到问题或有功能建议？欢迎联系我们！</p>
      <div class="feedback__actions">
        <a href="https://github.com/yourusername/littlegrid/issues" class="btn btn--primary" target="_blank" rel="noopener">
          提交 Issue
        </a>
        <a href="https://github.com/yourusername/littlegrid/discussions" class="btn btn--outline" target="_blank" rel="noopener">
          功能建议
        </a>
      </div>
    </div>
  </section>

  <!-- Footer -->
  <footer class="footer">
    <div class="container">
      <p class="footer__copyright">© 2024 LittleGrid Team. All rights reserved.</p>
      <div class="footer__links">
        <a href="https://github.com/yourusername/littlegrid" class="footer__link" target="_blank" rel="noopener">GitHub</a>
        <a href="https://github.com/yourusername/littlegrid/blob/master/LICENSE" class="footer__link" target="_blank" rel="noopener">MIT License</a>
      </div>
    </div>
  </footer>

  <script src="js/main.js"></script>
</body>
</html>
```

- [ ] **Step 7: 提交 HTML 文件**

```bash
git add officialwebsite/index.html
git commit -m "feat(website): 创建官网HTML页面

- 实现Header导航、Hero区、功能展示、下载区、更新日志、反馈区、Footer
- 添加SEO元数据
- 响应式布局支持

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 4: 创建 JavaScript 交互脚本

**Files:**
- Create: `officialwebsite/js/main.js`

- [ ] **Step 1: 创建 JavaScript 文件**

```javascript
/**
 * LittleGrid 官网交互脚本
 * - 移动端菜单切换
 * - 平滑滚动
 */

(function() {
  'use strict';

  // 移动端菜单切换
  const menuBtn = document.getElementById('menuBtn');
  const nav = document.getElementById('nav');

  if (menuBtn && nav) {
    menuBtn.addEventListener('click', function() {
      nav.classList.toggle('active');
      // 切换菜单图标
      this.textContent = nav.classList.contains('active') ? '✕' : '☰';
    });

    // 点击导航链接后关闭菜单
    nav.querySelectorAll('.header__link').forEach(function(link) {
      link.addEventListener('click', function() {
        nav.classList.remove('active');
        menuBtn.textContent = '☰';
      });
    });
  }

  // 平滑滚动到锚点（兼容旧浏览器）
  document.querySelectorAll('a[href^="#"]').forEach(function(anchor) {
    anchor.addEventListener('click', function(e) {
      const targetId = this.getAttribute('href');
      if (targetId === '#') return;

      const target = document.querySelector(targetId);
      if (target) {
        e.preventDefault();
        const headerHeight = 64;
        const targetPosition = target.getBoundingClientRect().top + window.pageYOffset - headerHeight;

        window.scrollTo({
          top: targetPosition,
          behavior: 'smooth'
        });
      }
    });
  });

  // 滚动时添加导航栏阴影
  let lastScrollY = 0;
  const header = document.querySelector('.header');

  window.addEventListener('scroll', function() {
    const currentScrollY = window.scrollY;

    if (currentScrollY > 10) {
      header.style.boxShadow = '0 2px 8px rgba(0, 0, 0, 0.08)';
    } else {
      header.style.boxShadow = 'none';
    }

    lastScrollY = currentScrollY;
  });

})();
```

- [ ] **Step 2: 提交 JavaScript 文件**

```bash
git add officialwebsite/js/main.js
git commit -m "feat(website): 添加交互脚本

- 实现移动端菜单切换
- 平滑滚动到锚点
- 滚动时导航栏阴影效果

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 5: 创建占位图片资源

**Files:**
- Create: `officialwebsite/assets/images/.gitkeep`

- [ ] **Step 1: 创建图片目录占位文件**

```bash
touch officialwebsite/assets/images/.gitkeep
```

- [ ] **Step 2: 提交**

```bash
git add officialwebsite/assets/images/.gitkeep
git commit -m "chore(website): 创建图片资源目录

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 6: 验证和最终提交

- [ ] **Step 1: 验证文件结构**

Run: `ls -laR officialwebsite/`
Expected: 显示所有创建的文件

- [ ] **Step 2: 验证 HTML 语法**

Run: `cat officialwebsite/index.html | head -20`
Expected: 显示 HTML 文件头部内容

- [ ] **Step 3: 最终提交（如有遗漏）**

```bash
git status
# 如有未提交文件，添加并提交
```

---

## 部署说明

### 方式一：Nginx 直接托管

1. 将 `officialwebsite/` 目录复制到服务器
2. 配置 Nginx：

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

3. 重启 Nginx：`nginx -s reload`

### 方式二：Docker 部署

1. 在 `officialwebsite/` 目录创建 `Dockerfile`：

```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
```

2. 构建并运行：

```bash
docker build -t littlegrid-web .
docker run -d -p 80:80 littlegrid-web
```

**推荐**：Nginx 直接托管，简单高效。
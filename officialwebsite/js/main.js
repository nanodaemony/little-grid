/**
 * LittleGrid 官网交互脚本
 * 使用原生 JavaScript (ES6+)，无框架依赖
 */

(function() {
  'use strict';

  // ========================================
  // 1. 移动端菜单切换
  // ========================================
  (function initMobileMenu() {
    const menuBtn = document.querySelector('.header__menu-btn');
    const nav = document.querySelector('.header__nav');
    const menuIcon = document.querySelector('.header__menu-icon');

    // 如果元素不存在，直接返回
    if (!menuBtn || !nav) return;

    // 点击切换菜单显示/隐藏
    menuBtn.addEventListener('click', function() {
      nav.classList.toggle('active');
      menuBtn.classList.toggle('active');

      // 切换菜单图标：☰ ↔ ✕
      if (nav.classList.contains('active')) {
        menuIcon.textContent = '✕';
        menuBtn.setAttribute('aria-expanded', 'true');
      } else {
        menuIcon.textContent = '☰';
        menuBtn.setAttribute('aria-expanded', 'false');
      }
    });

    // 点击导航链接后关闭菜单
    nav.querySelectorAll('.header__nav-link').forEach(function(link) {
      link.addEventListener('click', function() {
        nav.classList.remove('active');
        menuBtn.classList.remove('active');
        menuIcon.textContent = '☰';
        menuBtn.setAttribute('aria-expanded', 'false');
      });
    });
  })();

  // ========================================
  // 2. 平滑滚动到锚点
  // ========================================
  (function initSmoothScroll() {
    // 处理所有 # 开头的链接
    document.querySelectorAll('a[href^="#"]').forEach(function(anchor) {
      anchor.addEventListener('click', function(e) {
        const targetId = this.getAttribute('href');

        // 忽略仅为 # 的链接
        if (targetId === '#') return;

        const target = document.querySelector(targetId);

        if (target) {
          e.preventDefault();

          // 固定导航高度
          const headerHeight = 64;
          const targetPosition = target.getBoundingClientRect().top + window.pageYOffset - headerHeight;

          window.scrollTo({
            top: targetPosition,
            behavior: 'smooth'
          });
        }
      });
    });
  })();

  // ========================================
  // 3. 滚动时导航栏阴影
  // ========================================
  (function initHeaderShadow() {
    const header = document.querySelector('.header');

    if (!header) return;

    // 使用节流函数优化滚动性能
    let ticking = false;

    window.addEventListener('scroll', function() {
      if (!ticking) {
        window.requestAnimationFrame(function() {
          if (window.scrollY > 10) {
            header.style.boxShadow = '0 2px 8px rgba(0, 0, 0, 0.08)';
          } else {
            header.style.boxShadow = 'none';
          }
          ticking = false;
        });
        ticking = true;
      }
    });
  })();

})();
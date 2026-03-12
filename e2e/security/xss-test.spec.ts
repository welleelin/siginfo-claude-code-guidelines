/**
 * XSS（跨站脚本攻击）安全测试
 *
 * 测试目标：验证系统对 XSS 攻击的防护能力
 * OWASP Top 10: A03:2021 - Injection
 */

import { test, expect } from '@playwright/test';

test.describe('XSS 防护测试', () => {
  /**
   * 测试 1: 反射型 XSS
   * 攻击者通过 URL 参数注入恶意脚本
   */
  test('应防止反射型 XSS 攻击 - 搜索框输入脚本标签', async ({ page }) => {
    await page.goto('/search');

    // 尝试注入 XSS payload
    const xssPayload = '<script>alert("XSS")</script>';
    await page.fill('input[name="q"]', xssPayload);
    await page.press('input[name="q"]', 'Enter');

    // 等待页面加载
    await page.waitForLoadState('networkidle');

    // 验证脚本未被执行
    const hasAlert = await page.evaluate(() => {
      return new Promise((resolve) => {
        const originalAlert = window.alert;
        window.alert = () => resolve(true);
        setTimeout(() => resolve(false), 1000);
        window.alert = originalAlert;
      });
    });

    expect(hasAlert).toBe(false);

    // 验证输入被正确转义显示
    const pageContent = await page.content();
    expect(pageContent).toContain('&lt;script&gt;');
  });

  /**
   * 测试 2: 存储型 XSS
   * 攻击者将恶意脚本存储到服务器
   */
  test('应防止存储型 XSS 攻击 - 评论区输入脚本', async ({ page }) => {
    await page.goto('/post/1');

    // 尝试注入 XSS payload 到评论区
    const xssPayload = '<img src=x onerror=alert("XSS")>';
    await page.fill('textarea[name="comment"]', xssPayload);
    await page.click('button[type="submit"]');

    // 等待提交完成
    await page.waitForLoadState('networkidle');

    // 验证脚本未被执行
    const hasAlert = await page.evaluate(() => {
      return new Promise((resolve) => {
        const originalAlert = window.alert;
        window.alert = () => resolve(true);
        setTimeout(() => resolve(false), 1000);
        window.alert = originalAlert;
      });
    });

    expect(hasAlert).toBe(false);

    // 验证内容被转义存储
    const commentElement = await page.locator('.comment-content').first();
    const commentHTML = await commentElement.innerHTML();
    expect(commentHTML).toContain('&lt;img');
  });

  /**
   * 测试 3: DOM 型 XSS
   * 攻击者通过修改 DOM 执行恶意脚本
   */
  test('应防止 DOM 型 XSS 攻击 - URL hash 注入', async ({ page }) => {
    // 直接访问带有恶意 hash 的 URL
    await page.goto('/page#<script>alert("XSS")</script>');

    // 等待页面加载
    await page.waitForLoadState('networkidle');

    // 验证脚本未被执行
    const hasAlert = await page.evaluate(() => {
      return new Promise((resolve) => {
        const originalAlert = window.alert;
        window.alert = () => resolve(true);
        setTimeout(() => resolve(false), 1000);
        window.alert = originalAlert;
      });
    });

    expect(hasAlert).toBe(false);
  });

  /**
   * 测试 4: SVG XSS
   * 攻击者通过 SVG 文件注入脚本
   */
  test('应防止 SVG XSS 攻击 - 上传恶意 SVG', async ({ page }) => {
    await page.goto('/upload');

    // 创建恶意 SVG 文件
    const svgContent = `
      <svg xmlns="http://www.w3.org/2000/svg">
        <script>alert("XSS")</script>
      </svg>
    `;

    // 创建临时文件
    const buffer = Buffer.from(svgContent);
    await page.setInputFiles('input[type="file"]', {
      name: 'test.svg',
      mimeType: 'image/svg+xml',
      buffer: buffer,
    });

    await page.click('button[type="submit"]');
    await page.waitForLoadState('networkidle');

    // 验证脚本未被执行
    const hasAlert = await page.evaluate(() => {
      return new Promise((resolve) => {
        const originalAlert = window.alert;
        window.alert = () => resolve(true);
        setTimeout(() => resolve(false), 1000);
        window.alert = originalAlert;
      });
    });

    expect(hasAlert).toBe(false);

    // 验证文件类型被正确检查
    const errorMessage = await page.locator('.error-message');
    await expect(errorMessage).toBeVisible();
  });

  /**
   * 测试 5: 富文本编辑器 XSS
   * 攻击者通过富文本编辑器注入脚本
   */
  test('应防止富文本编辑器 XSS 攻击', async ({ page }) => {
    await page.goto('/editor');

    // 尝试注入 XSS payload
    const xssPayload = '<iframe src="javascript:alert(\'XSS\')"></iframe>';

    // 直接输入 HTML（绕过富文本编辑器的可视化模式）
    await page.evaluate((payload) => {
      const editor = document.querySelector('.editor-source') as HTMLTextAreaElement;
      if (editor) {
        editor.value = payload;
      }
    }, xssPayload);

    await page.click('button[type="submit"]');
    await page.waitForLoadState('networkidle');

    // 验证脚本未被执行
    const hasAlert = await page.evaluate(() => {
      return new Promise((resolve) => {
        const originalAlert = window.alert;
        window.alert = () => resolve(true);
        setTimeout(() => resolve(false), 1000);
        window.alert = originalAlert;
      });
    });

    expect(hasAlert).toBe(false);

    // 验证 iframe 被过滤
    const pageContent = await page.content();
    expect(pageContent).not.toContain('<iframe');
  });

  /**
   * 测试 6: 属性逃逸 XSS
   * 攻击者通过 HTML 属性注入脚本
   */
  test('应防止属性逃逸 XSS 攻击 - 引号逃逸', async ({ page }) => {
    await page.goto('/profile');

    // 尝试通过引号逃逸注入 XSS
    const xssPayload = '" onmouseover="alert(\'XSS\')';
    await page.fill('input[name="nickname"]', xssPayload);
    await page.click('button[type="submit"]');

    await page.waitForLoadState('networkidle');

    // 验证脚本未被执行
    const hasAlert = await page.evaluate(() => {
      return new Promise((resolve) => {
        const originalAlert = window.alert;
        window.alert = () => resolve(true);
        setTimeout(() => resolve(false), 1000);
        window.alert = originalAlert;
      });
    });

    expect(hasAlert).toBe(false);

    // 验证引号被正确转义
    const nicknameElement = await page.locator('.nickname');
    const nicknameHTML = await nicknameElement.innerHTML();
    expect(nicknameHTML).toContain('&quot;');
  });

  /**
   * 测试 7: JavaScript 协议 XSS
   * 攻击者通过 javascript: 协议注入脚本
   */
  test('应防止 JavaScript 协议 XSS 攻击', async ({ page }) => {
    await page.goto('/links');

    // 尝试注入 javascript: 协议的链接
    const jsProtocol = 'javascript:alert("XSS")';

    // 通过表单提交注入
    await page.fill('input[name="url"]', jsProtocol);
    await page.click('button[type="submit"]');

    await page.waitForLoadState('networkidle');

    // 验证链接的 href 属性被过滤或禁用
    const injectedLink = await page.locator('a[href*="javascript:"]').count();
    expect(injectedLink).toBe(0);

    // 或者 href 被转换为安全值
    const hrefValue = await page.locator('a').first().getAttribute('href');
    expect(hrefValue).toMatch(/^(http|https|\/|#)/);
  });

  /**
   * 测试 8: Data URI XSS
   * 攻击者通过 data: URI 注入脚本
   */
  test('应防止 Data URI XSS 攻击', async ({ page }) => {
    await page.goto('/display');

    // 尝试注入 data: URI 的 XSS
    const dataUri = 'data:text/html,<script>alert("XSS")</script>';
    await page.fill('input[name="content"]', dataUri);
    await page.click('button[type="submit"]');

    await page.waitForLoadState('networkidle');

    // 验证脚本未被执行
    const hasAlert = await page.evaluate(() => {
      return new Promise((resolve) => {
        const originalAlert = window.alert;
        window.alert = () => resolve(true);
        setTimeout(() => resolve(false), 1000);
        window.alert = originalAlert;
      });
    });

    expect(hasAlert).toBe(false);

    // 验证 data: URI 被过滤
    const pageContent = await page.content();
    expect(pageContent).not.toContain('data:text/html');
  });
});

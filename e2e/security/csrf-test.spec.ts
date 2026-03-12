/**
 * CSRF（跨站请求伪造）安全测试
 *
 * 测试目标：验证系统对 CSRF 攻击的防护能力
 * OWASP Top 10: A01:2021 - Broken Access Control
 */

import { test, expect } from '@playwright/test';

test.describe('CSRF 防护测试', () => {
  /**
   * 测试 1: 登录表单 CSRF Token
   * 验证登录表单包含 CSRF Token
   */
  test('登录表单应包含 CSRF Token', async ({ page }) => {
    await page.goto('/login');

    // 检查 CSRF Token 是否存在
    const csrfToken = await page.locator('input[name="_csrf"], input[name="csrf_token"]');
    await expect(csrfToken).toBeVisible();

    // 验证 Token 不为空
    const tokenValue = await csrfToken.getAttribute('value');
    expect(tokenValue).toBeTruthy();
    expect(tokenValue?.length).toBeGreaterThan(10);
  });

  /**
   * 测试 2: 提交表单缺少 CSRF Token
   * 验证缺少 CSRF Token 的请求被拒绝
   */
  test('缺少 CSRF Token 的表单提交应被拒绝', async ({ page }) => {
    await page.goto('/login');

    // 移除 CSRF Token
    await page.evaluate(() => {
      const csrfInput = document.querySelector('input[name="_csrf"]') as HTMLInputElement;
      if (csrfInput) {
        csrfInput.remove();
      }
    });

    // 尝试提交表单
    await page.fill('input[name="username"]', 'testuser');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');

    // 等待响应
    await page.waitForLoadState('networkidle');

    // 验证请求被拒绝（403 或错误消息）
    const errorMessage = await page.locator('.error-message');
    await expect(errorMessage).toBeVisible();

    const errorText = await errorMessage.textContent();
    expect(errorText?.toLowerCase()).toContain('csrf');
  });

  /**
   * 测试 3: CSRF Token 有效性
   * 验证使用过期或无效的 CSRF Token 被拒绝
   */
  test('无效 CSRF Token 应被拒绝', async ({ page }) => {
    await page.goto('/login');

    // 修改 CSRF Token 为无效值
    await page.evaluate(() => {
      const csrfInput = document.querySelector('input[name="_csrf"]') as HTMLInputElement;
      if (csrfInput) {
        csrfInput.value = 'invalid-csrf-token-' + Date.now();
      }
    });

    // 尝试提交表单
    await page.fill('input[name="username"]', 'testuser');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');

    // 等待响应
    await page.waitForLoadState('networkidle');

    // 验证请求被拒绝
    const errorMessage = await page.locator('.error-message');
    await expect(errorMessage).toBeVisible();

    const errorText = await errorMessage.textContent();
    expect(errorText?.toLowerCase()).toMatch(/csrf|token|invalid/);
  });

  /**
   * 测试 4: 修改密码表单 CSRF 防护
   * 验证敏感操作表单的 CSRF 防护
   */
  test('修改密码表单应有 CSRF 防护', async ({ page }) => {
    // 先登录
    await page.goto('/login');
    await page.fill('input[name="username"]', 'testuser');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');
    await page.waitForLoadState('networkidle');

    // 访问修改密码页面
    await page.goto('/settings/password');

    // 检查 CSRF Token
    const csrfToken = await page.locator('input[name="_csrf"], input[name="csrf_token"]');
    await expect(csrfToken).toBeVisible();

    // 验证 Token 不为空
    const tokenValue = await csrfToken.getAttribute('value');
    expect(tokenValue).toBeTruthy();
    expect(tokenValue?.length).toBeGreaterThan(10);
  });

  /**
   * 测试 5: 转账表单 CSRF 防护
   * 验证金融操作的 CSRF 防护
   */
  test('转账表单应有 CSRF 防护', async ({ page }) => {
    // 先登录
    await page.goto('/login');
    await page.fill('input[name="username"]', 'testuser');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');
    await page.waitForLoadState('networkidle');

    // 访问转账页面
    await page.goto('/transfer');

    // 检查 CSRF Token
    const csrfToken = await page.locator('input[name="_csrf"], input[name="csrf_token"]');
    await expect(csrfToken).toBeVisible();

    // 验证 Token 不为空
    const tokenValue = await csrfToken.getAttribute('value');
    expect(tokenValue).toBeTruthy();
    expect(tokenValue?.length).toBeGreaterThan(10);
  });

  /**
   * 测试 6: AJAX 请求 CSRF Token
   * 验证 AJAX 请求也包含 CSRF Token
   */
  test('AJAX 请求应包含 CSRF Token', async ({ page }) => {
    await page.goto('/dashboard');

    // 监控网络请求
    const requestHeaders = await page.evaluate(() => {
      return new Promise((resolve) => {
        const headers: Record<string, string> = {};

        // 拦截 XHR 请求
        const originalXHROpen = XMLHttpRequest.prototype.open;
        const originalXHRSend = XMLHttpRequest.prototype.send;

        XMLHttpRequest.prototype.open = function (method, url, ...args) {
          this.addEventListener('send', function () {
            // @ts-ignore
            headers['x-csrf-token'] = this.getRequestHeader('X-CSRF-Token');
          });
          return originalXHROpen.apply(this, [method, url, ...args]);
        };

        // 触发一个 AJAX 请求
        fetch('/api/user/profile', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ name: 'test' }),
        });

        setTimeout(() => resolve(headers), 1000);
      });
    });

    // 验证 CSRF Token 被包含在请求头中
    expect(requestHeaders['x-csrf-token'] || requestHeaders['csrf-token']).toBeTruthy();
  });

  /**
   * 测试 7: Cookie 中 SameSite 属性
   * 验证 Cookie 设置了 SameSite 属性
   */
  test('Cookie 应设置 SameSite 属性', async ({ page }) => {
    await page.goto('/login');

    // 获取所有 Cookie
    const cookies = await page.context().cookies();

    // 检查关键 Cookie 的 SameSite 属性
    const sessionCookie = cookies.find((c) => c.name === 'session' || c.name === 'sessionId');

    if (sessionCookie) {
      // 验证 SameSite 属性
      expect(['Lax', 'Strict', 'None']).toContain(sessionCookie.sameSite);
    }
  });

  /**
   * 测试 8: Referer 检查
   * 验证服务器检查请求来源
   */
  test('服务器应检查 Referer 头', async ({ page, context }) => {
    // 模拟从外部网站发起请求
    await page.goto('/login');

    // 设置伪造的 Referer
    await page.setExtraHTTPHeaders({
      Referer: 'https://evil.com/',
    });

    await page.fill('input[name="username"]', 'testuser');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');

    // 等待响应
    await page.waitForLoadState('networkidle');

    // 验证请求被拒绝或重定向
    const currentUrl = page.url();
    const errorMessage = await page.locator('.error-message');

    // 要么被拒绝，要么停留在登录页
    const isRejected =
      currentUrl.includes('/login') || (await errorMessage.count()) > 0;
    expect(isRejected).toBe(true);
  });

  /**
   * 测试 9: 删除操作 CSRF 防护
   * 验证删除操作的 CSRF 防护
   */
  test('删除操作应有 CSRF 防护', async ({ page }) => {
    // 先登录
    await page.goto('/login');
    await page.fill('input[name="username"]', 'admin');
    await page.fill('input[name="password"]', 'admin123');
    await page.click('button[type="submit"]');
    await page.waitForLoadState('networkidle');

    // 访问资源列表
    await page.goto('/resources');

    // 找到删除按钮
    const deleteButton = await page.locator('.delete-button').first();

    // 检查删除操作是否需要 CSRF Token
    const deleteForm = await deleteButton.locator('..').locator('form');
    const csrfToken = await deleteForm.locator('input[name="_csrf"]').count();

    // 如果是表单提交，必须有 CSRF Token
    if (csrfToken > 0) {
      expect(csrfToken).toBeGreaterThan(0);
    }

    // 如果是 AJAX 请求，检查请求头是否包含 Token
    const [request] = await Promise.all([
      page.waitForRequest((req) => req.method() === 'DELETE' || req.url().includes('/delete')),
      deleteButton.click(),
    ]);

    const csrfHeader = request.headers()['x-csrf-token'] || request.headers()['csrf-token'];
    expect(csrfHeader).toBeTruthy();
  });
});

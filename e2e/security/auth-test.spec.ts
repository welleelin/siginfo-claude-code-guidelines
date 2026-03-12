/**
 * 认证安全测试
 *
 * 测试目标：验证认证系统的安全性
 * OWASP Top 10: A02:2021 - Cryptographic Failures
 *            A07:2021 - Identification and Authentication Failures
 */

import { test, expect } from '@playwright/test';

test.describe('认证安全测试', () => {
  /**
   * 测试 1: Token 过期后应拒绝访问
   * 验证过期的 JWT Token 不能用于访问受保护资源
   */
  test('Token 过期后应拒绝访问', async ({ page, context }) => {
    // 设置过期的 Token
    await context.addCookies([
      {
        name: 'auth_token',
        value: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.expired',
        domain: 'localhost',
        path: '/',
        expires: 1000, // 已过期的时间戳
      },
    ]);

    // 尝试访问受保护页面
    await page.goto('/profile');

    // 应被重定向到登录页
    await expect(page).toHaveURL(/login/);

    // 或者显示未授权错误
    const errorMessage = await page.locator('.error-message');
    if (await errorMessage.count() > 0) {
      const errorText = await errorMessage.textContent();
      expect(errorText?.toLowerCase()).toMatch(/unauthorized|login|token.*expired/);
    }
  });

  /**
   * 测试 2: Token 被截获后重用防护
   * 验证 Token 是否有 IP 绑定或其他防重用机制
   */
  test('应防止 Token 重用攻击', async ({ context }) => {
    // 创建两个不同的浏览器上下文（模拟不同设备）
    const context1 = await context.browser().newContext();
    const context2 = await context.browser().newContext();

    const page1 = await context1.newPage();
    const page2 = await context2.newPage();

    // 在 context1 中登录
    await page1.goto('/login');
    await page1.fill('input[name="username"]', 'testuser');
    await page1.fill('input[name="password"]', 'password123');
    await page1.click('button[type="submit"]');
    await page1.waitForLoadState('networkidle');

    // 获取 Token
    const cookies = await context1.cookies();
    const authToken = cookies.find((c) => c.name === 'auth_token');

    if (authToken) {
      // 在 context2 中使用相同的 Token
      await context2.addCookies([
        {
          name: authToken.name,
          value: authToken.value,
          domain: authToken.domain,
          path: authToken.path,
        },
      ]);

      // 尝试访问受保护资源
      await page2.goto('/profile');
      await page2.waitForLoadState('networkidle');

      // 验证是否被拒绝（取决于系统策略）
      // 理想情况下应该检测到异常登录行为
      const url = page2.url();
      expect(url).toMatch(/login|unauthorized|suspicious/);
    }

    await context1.close();
    await context2.close();
  });

  /**
   * 测试 3: 会话固定攻击防护
   * 验证登录后会话 ID 是否更新
   */
  test('应防止会话固定攻击', async ({ page, context }) => {
    // 访问登录页前获取 Session ID
    await page.goto('/');
    const preLoginCookies = await context.cookies();
    const preLoginSession = preLoginCookies.find((c) => c.name === 'sessionId');

    // 执行登录
    await page.goto('/login');
    await page.fill('input[name="username"]', 'testuser');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');
    await page.waitForLoadState('networkidle');

    // 获取登录后的 Session ID
    const postLoginCookies = await context.cookies();
    const postLoginSession = postLoginCookies.find((c) => c.name === 'sessionId');

    // 验证 Session ID 已更新
    if (preLoginSession && postLoginSession) {
      expect(preLoginSession.value).not.toBe(postLoginSession.value);
    }
  });

  /**
   * 测试 4: 暴力破解防护
   * 验证登录接口有速率限制
   */
  test('应防止暴力破解攻击', async ({ page, request }) => {
    const loginEndpoint = '/api/auth/login';
    const credentials = {
      username: 'admin',
      password: 'wrongpassword',
    };

    let successCount = 0;
    let rateLimitedCount = 0;

    // 连续尝试登录 10 次
    for (let i = 0; i < 10; i++) {
      const response = await request.post(loginEndpoint, {
        data: credentials,
      });

      if (response.status() === 429) {
        rateLimitedCount++;
      } else if (response.status() === 401) {
        // 正常的认证失败
      } else if (response.status() === 200) {
        successCount++;
      }
    }

    // 验证有速率限制
    expect(rateLimitedCount).toBeGreaterThan(0);

    // 或者验证连续失败后账户被锁定
    const lockoutResponse = await request.post(loginEndpoint, {
      data: credentials,
    });
    const body = await lockoutResponse.json();

    expect(body.accountLocked || body.tooManyAttempts || rateLimitedCount > 0).toBe(true);
  });

  /**
   * 测试 5: 密码策略验证
   * 验证系统要求强密码
   */
  test('应强制要求强密码', async ({ page }) => {
    await page.goto('/register');

    // 尝试使用弱密码注册
    const weakPasswords = [
      '123456',
      'password',
      'admin123',
      'qwerty',
      'abc123',
    ];

    for (const password of weakPasswords) {
      await page.fill('input[name="email"]', `test${password}@example.com`);
      await page.fill('input[name="password"]', password);
      await page.fill('input[name="confirm_password"]', password);
      await page.click('button[type="submit"]');

      // 等待响应
      await page.waitForLoadState('networkidle');

      // 验证弱密码被拒绝
      const errorMessage = await page.locator('.error-message');
      if (await errorMessage.count() > 0) {
        const errorText = await errorMessage.textContent();
        expect(errorText?.toLowerCase()).toMatch(/weak|password.*strength|too.*simple/);
      }

      // 重置表单
      await page.goto('/register');
    }
  });

  /**
   * 测试 6: 多设备登录检测
   * 验证系统是否检测并通知异常登录
   */
  test('应检测并通知异常登录', async ({ context }) => {
    // 创建两个不同的浏览器上下文（模拟不同地理位置）
    const context1 = await context.browser().newContext({
      userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
    });
    const context2 = await context.browser().newContext({
      userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0)',
    });

    const page1 = await context1.newPage();
    const page2 = await context2.newPage();

    // 在两个不同设备上用相同账号登录
    await page1.goto('/login');
    await page1.fill('input[name="username"]', 'testuser');
    await page1.fill('input[name="password"]', 'password123');
    await page1.click('button[type="submit"]');
    await page1.waitForLoadState('networkidle');

    await page2.goto('/login');
    await page2.fill('input[name="username"]', 'testuser');
    await page2.fill('input[name="password"]', 'password123');
    await page2.click('button[type="submit"]');
    await page2.waitForLoadState('networkidle');

    // 验证系统是否检测到异常登录
    // 检查是否有安全通知
    const securityNotice1 = await page1.locator('.security-notice, .alert');
    const securityNotice2 = await page2.locator('.security-notice, .alert');

    // 至少有一个设备收到通知
    const hasNotice =
      (await securityNotice1.count()) > 0 || (await securityNotice2.count()) > 0;
    expect(hasNotice).toBe(true);

    await context1.close();
    await context2.close();
  });

  /**
   * 测试 7: 登出后会话失效
   * 验证登出后 Token 被作废
   */
  test('登出后会话应完全失效', async ({ page, context }) => {
    // 登录
    await page.goto('/login');
    await page.fill('input[name="username"]', 'testuser');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');
    await page.waitForLoadState('networkidle');

    // 验证已登录
    await expect(page).toHaveURL(/profile|dashboard/);

    // 获取当前 Cookie
    const cookiesBeforeLogout = await context.cookies();

    // 登出
    await page.click('button:has-text("登出"), button:has-text("Logout")');
    await page.waitForLoadState('networkidle');

    // 验证已登出
    await expect(page).toHaveURL(/login/);

    // 获取登出后的 Cookie
    const cookiesAfterLogout = await context.cookies();

    // 验证认证 Cookie 已被清除或标记为无效
    const authTokenAfter = cookiesAfterLogout.find((c) => c.name === 'auth_token');
    if (authTokenAfter) {
      // 如果 Cookie 还存在，应该被标记为无效
      expect(authTokenAfter.value).toBe('')
    }

    // 尝试使用之前的 Token 访问受保护资源
    await context.addCookies(
      cookiesBeforeLogout.filter((c) => c.name === 'auth_token')
    );

    await page.goto('/profile');

    // 验证仍被拒绝访问（Token 已失效）
    await expect(page).toHaveURL(/login/);
  });

  /**
   * 测试 8: JWT Token 签名验证
   * 验证系统验证 JWT 签名
   */
  test('应验证 JWT Token 签名', async ({ page, context }) => {
    // 设置伪造的 Token（修改 payload）
    const forgedToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZXhwIjo5OTk5OTk5OTk5fQ.INVALID_SIGNATURE';

    await context.addCookies([
      {
        name: 'auth_token',
        value: forgedToken,
        domain: 'localhost',
        path: '/',
      },
    ]);

    // 尝试访问受保护资源
    await page.goto('/api/user/profile');

    // 验证被拒绝
    const response = await page.response();
    expect(response?.status()).toBe(401);
  });

  /**
   * 测试 9: 密码重置 Token 安全
   * 验证密码重置 Token 的有效性
   */
  test('密码重置 Token 应安全有效', async ({ page, request }) => {
    // 尝试使用无效的重置 Token
    const invalidToken = 'invalid-reset-token-' + Date.now();
    const resetResponse = await request.get(`/reset-password?token=${invalidToken}`);

    expect(resetResponse.status()).toMatch(/400|401|403/);

    // 尝试使用过期的 Token
    const expiredToken = 'expired-token';
    const expiredResponse = await request.get(`/reset-password?token=${expiredToken}`);

    expect(expiredResponse.status()).toMatch(/400|401|403/);
  });

  /**
   * 测试 10: 双因素认证（2FA）
   * 验证 2FA 的实施
   */
  test('敏感操作应要求 2FA 验证', async ({ page }) => {
    // 登录
    await page.goto('/login');
    await page.fill('input[name="username"]', 'testuser');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');
    await page.waitForLoadState('networkidle');

    // 尝试执行敏感操作（如修改密码）
    await page.goto('/settings/password');

    // 验证是否要求 2FA
    const twoFactorInput = await page.locator('input[name="2fa_code"], input[name="otp"]').count();
    expect(twoFactorInput).toBeGreaterThan(0);
  });
});

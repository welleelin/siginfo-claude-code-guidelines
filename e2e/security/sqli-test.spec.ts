/**
 * SQL/NoSQL 注入攻击安全测试
 *
 * 测试目标：验证系统对注入攻击的防护能力
 * OWASP Top 10: A03:2021 - Injection
 */

import { test, expect } from '@playwright/test';

test.describe('SQL 注入防护测试', () => {
  /**
   * 测试 1: 经典 SQL 注入 - 认证绕过
   * 验证登录接口防止 SQL 注入
   */
  test('登录接口应防止 SQL 注入认证绕过', async ({ page, request }) => {
    const loginEndpoint = '/api/auth/login';

    // 经典 SQL 注入 payload
    const sqliPayloads = [
      { username: "admin'--", password: 'anything' },
      { username: "admin' OR '1'='1", password: 'anything' },
      { username: "admin' OR 1=1--", password: 'anything' },
      { username: "' OR ''='", password: '' },
      { username: 'admin\' OR \'1\'=\'1', password: 'password' },
    ];

    for (const payload of sqliPayloads) {
      const response = await request.post(loginEndpoint, {
        data: payload,
      });

      // 验证所有注入尝试都被拒绝
      expect(response.status()).toBe(401);

      const body = await response.json();
      expect(body.success).toBeFalsy();
      expect(body.error).toMatch(/invalid|credentials|authentication/);
    }
  });

  /**
   * 测试 2: 联合查询注入
   * 验证搜索接口防止 UNION 注入
   */
  test('搜索接口应防止 UNION 注入', async ({ page }) => {
    await page.goto('/search');

    // UNION 注入 payload
    const unionPayloads = [
      "' UNION SELECT 1,2,3--",
      "' UNION SELECT NULL,NULL,NULL--",
      "' UNION SELECT username,password,email FROM users--",
    ];

    for (const payload of unionPayloads) {
      await page.fill('input[name="q"]', payload);
      await page.press('input[name="q"]', 'Enter');
      await page.waitForLoadState('networkidle');

      // 验证没有泄露敏感信息
      const pageContent = await page.content();
      expect(pageContent).not.toContain('password');
      expect(pageContent).not.toMatch(/UNION.*SELECT/i);

      // 验证显示错误或空结果
      const errorMessage = await page.locator('.error-message, .no-results');
      const hasErrorOrNoResults = await errorMessage.count() > 0;
      expect(hasErrorOrNoResults).toBe(true);
    }
  });

  /**
   * 测试 3: 盲注攻击
   * 验证系统防止基于时间的盲注
   */
  test('应防止基于时间的盲注', async ({ page, request }) => {
    const startTime = Date.now();

    // 基于时间的注入 payload
    const timeBasedPayloads = [
      "' OR SLEEP(5)--",
      "' OR WAITFOR DELAY '00:00:05'--",
      "' OR pg_sleep(5)--",
    ];

    for (const payload of timeBasedPayloads) {
      const response = await request.get(`/api/users?id=${payload}`);

      const endTime = Date.now();
      const elapsed = endTime - startTime;

      // 验证响应时间正常（没有延迟）
      expect(elapsed).toBeLessThan(2000); // 小于 2 秒

      expect(response.status()).toMatch(/400|401|403/);
    }
  });

  /**
   * 测试 4: 错误消息注入
   * 验证错误消息不泄露数据库信息
   */
  test('错误消息不应泄露数据库信息', async ({ request }) => {
    const maliciousPayload = "' AND 1=CONVERT(int,(SELECT TOP 1 table_name FROM information_schema.tables))--";

    const response = await request.get(`/api/users?id=${maliciousPayload}`);
    const body = await response.text();

    // 验证错误消息不泄露数据库结构
    expect(body).not.toContain('SQL');
    expect(body).not.toContain('database');
    expect(body).not.toContain('table');
    expect(body).not.toContain('syntax');
    expect(body).not.toContain('convert');
    expect(body).not.toContain('information_schema');
  });

  /**
   * 测试 5: NoSQL 注入 - MongoDB
   * 验证防止 NoSQL 注入
   */
  test('应防止 NoSQL 注入攻击', async ({ page, request }) => {
    const loginEndpoint = '/api/auth/login';

    // NoSQL 注入 payload
    const nosqlPayloads = [
      { username: { $ne: null }, password: { $ne: null } },
      { username: { $gt: '' }, password: { $gt: '' } },
      { $where: 'this.username == "admin"' },
      { username: { $regex: '.*' }, password: { $regex: '.*' } },
    ];

    for (const payload of nosqlPayloads) {
      const response = await request.post(loginEndpoint, {
        data: payload,
      });

      // 验证所有注入尝试都被拒绝
      expect(response.status()).toBe(401);

      const body = await response.json();
      expect(body.success).toBeFalsy();
    }
  });

  /**
   * 测试 6: 命令注入
   * 验证防止操作系统命令注入
   */
  test('应防止命令注入攻击', async ({ page }) => {
    await page.goto('/ping');

    // 命令注入 payload
    const commandPayloads = [
      '127.0.0.1; whoami',
      '127.0.0.1 | whoami',
      '127.0.0.1 && whoami',
      '127.0.0.1 `whoami`',
      '127.0.0.1 $(whoami)',
    ];

    for (const payload of commandPayloads) {
      await page.fill('input[name="host"]', payload);
      await page.click('button[type="submit"]');
      await page.waitForLoadState('networkidle');

      // 验证没有执行命令
      const pageContent = await page.content();
      expect(pageContent).not.toContain('root');
      expect(pageContent).not.toContain('www-data');
      expect(pageContent).not.toContain('administrator');

      // 验证显示错误或安全消息
      const errorMessage = await page.locator('.error-message');
      if (await errorMessage.count() > 0) {
        const errorText = await errorMessage.textContent();
        expect(errorText?.toLowerCase()).not.toMatch(/whoami|root|admin/);
      }
    }
  });

  /**
   * 测试 7: LDAP 注入
   * 验证防止 LDAP 注入
   */
  test('应防止 LDAP 注入攻击', async ({ request }) => {
    const ldapPayloads = [
      '*)(uid=*))(|(uid=*',
      'admin*)(uid=*))(|(uid=*',
      '*)(&(!uid=*))',
    ];

    for (const payload of ldapPayloads) {
      const response = await request.get(`/api/users?filter=${encodeURIComponent(payload)}`);

      // 验证请求被拒绝
      expect(response.status()).toMatch(/400|401|403/);
    }
  });

  /**
   * 测试 8: XXE 注入
   * 验证防止 XML 外部实体注入
   */
  test('应防止 XXE 注入攻击', async ({ request }) => {
    const xxePayload = `<?xml version="1.0"?>
      <!DOCTYPE foo [
        <!ENTITY xxe SYSTEM "file:///etc/passwd">
      ]>
      <user><name>&xxe;</name></user>`;

    const response = await request.post('/api/users', {
      data: xxePayload,
      headers: {
        'Content-Type': 'application/xml',
      },
    });

    // 验证请求被拒绝
    expect(response.status()).toMatch(/400|415/);

    // 验证响应不包含敏感文件内容
    const body = await response.text();
    expect(body).not.toContain('root:');
    expect(body).not.toContain('/bin/bash');
  });

  /**
   * 测试 9: SSTI 注入（服务端模板注入）
   * 验证防止 SSTI 注入
   */
  test('应防止 SSTI 注入攻击', async ({ page }) => {
    await page.goto('/search');

    // SSTI payloads
    const sstiPayloads = [
      '{{7*7}}',
      '${7*7}',
      '<%= 7*7 %>',
      '#{7*7}',
      '{{config}}',
      '{{self._app_ctx globals__}}',
    ];

    for (const payload of sstiPayloads) {
      await page.fill('input[name="q"]', payload);
      await page.press('input[name="q"]', 'Enter');
      await page.waitForLoadState('networkidle');

      const pageContent = await page.content();

      // 验证 payload 没有被执行
      expect(pageContent).not.toContain('49'); // 7*7 的结果
      expect(pageContent).not.toContain('config');
      expect(pageContent).not.toContain('_app_ctx');
    }
  });

  /**
   * 测试 10: 文件路径遍历注入
   * 验证防止路径遍历攻击
   */
  test('应防止路径遍历注入攻击', async ({ page, request }) => {
    const traversalPayloads = [
      '../../../etc/passwd',
      '..\\..\\..\\windows\\system32\\config\\sam',
      '....//....//etc/passwd',
      '%2e%2e%2fetc%2fpasswd',
      '..%252f..%252fetc%252fpasswd',
    ];

    for (const payload of traversalPayloads) {
      const response = await request.get(`/api/files?path=${encodeURIComponent(payload)}`);

      // 验证请求被拒绝
      expect(response.status()).toMatch(/400|403|404/);

      // 验证响应不包含敏感内容
      const body = await response.text();
      expect(body).not.toContain('root:');
      expect(body).not.toContain('[sam');
    }
  });
});

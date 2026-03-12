/**
 * Playwright 安全测试配置文件
 *
 * 用途：执行安全渗透测试，覆盖 OWASP Top 10 漏洞
 * 安装：npx playwright install
 * 运行：npx playwright test --config=playwright-security.config.ts
 *
 * 详细文档：https://github.com/KeygraphHQ/shannon
 */

import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e/security',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html', { outputFolder: 'playwright-report/security' }],
    ['json', { outputFile: 'test-results/security-results.json' }],
    ['junit', { outputFile: 'test-results/security-junit.xml' }],
  ],
  outputDir: 'test-results/security',

  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',

    // 安全测试特定的浏览器配置
    ...devices['Desktop Chrome'],
    securityHeaders: {
      'X-Security-Test': 'true',
    },
  },

  projects: [
    // 项目名称，用于 --project 参数
    {
      name: 'security',
      testMatch: /.*\.spec\.ts/,
      use: {
        ...devices['Desktop Chrome'],
      },
    },

    // XSS 攻击测试
    {
      name: 'xss',
      testMatch: /xss.*\.spec\.ts/,
      use: {
        ...devices['Desktop Chrome'],
      },
    },

    // CSRF 攻击测试
    {
      name: 'csrf',
      testMatch: /csrf.*\.spec\.ts/,
      use: {
        ...devices['Desktop Chrome'],
      },
    },

    // SQL 注入测试
    {
      name: 'sqli',
      testMatch: /sqli.*\.spec\.ts/,
      use: {
        ...devices['Desktop Chrome'],
      },
    },

    // 认证安全测试
    {
      name: 'auth',
      testMatch: /auth.*\.spec\.ts/,
      use: {
        ...devices['Desktop Chrome'],
      },
    },

    // 越权访问测试
    {
      name: 'bola',
      testMatch: /bola.*\.spec\.ts/,
      use: {
        ...devices['Desktop Chrome'],
      },
    },

    // SSRF 攻击测试
    {
      name: 'ssrf',
      testMatch: /ssrf.*\.spec\.ts/,
      use: {
        ...devices['Desktop Chrome'],
      },
    },

    // 数据泄露测试
    {
      name: 'data-leak',
      testMatch: /data-leak.*\.spec\.ts/,
      use: {
        ...devices['Desktop Chrome'],
      },
    },
  ],

  // Web 服务器配置（可选，用于自动启动被测应用）
  // webServer: {
  //   command: 'npm run dev',
  //   url: 'http://localhost:3000',
  //   reuseExistingServer: !process.env.CI,
  //   timeout: 120 * 1000,
  // },
});

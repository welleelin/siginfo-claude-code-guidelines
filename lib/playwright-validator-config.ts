/**
 * Playwright 配置扩展 - 集成截图审查工具
 *
 * 使用方法：
 * 1. 将此文件内容合并到项目的 playwright.config.ts
 * 2. 在测试文件中导入 useScreenshotValidator fixture
 *
 * @version 1.0.0
 * @since 2026-03-12
 */

import { defineConfig, devices } from '@playwright/test'

export const screenshotValidatorConfig = {
  // 全局截图审查配置
  use: {
    // 基础配置
    baseURL: process.env.BASE_URL || 'http://localhost:5173',
    trace: 'retain-on-failure',
    screenshot: 'on', // 失败时自动截图
    video: 'retain-on-failure',
    headless: true,

    // 超时配置（与生产环境一致）
    timeout: 30000, // 30 秒 - 与生产环境相同
    actionTimeout: 10000, // 10 秒
    navigationTimeout: 30000, // 30 秒

    // 视觉回归测试配置
    deviceScaleFactor: 1,

    // ⚠️ 重要：不自动重试，与生产环境一致
    // retries: 0, // 生产环境不重试，测试也不重试

    // ⚠️ 重要：启用所有中间件
    // 不要在测试中绕过鉴权、限流等中间件
  },

  // 视觉回归测试期望配置
  expect: {
    toHaveScreenshot: {
      maxDiffPixels: 50, // 允许最多 50 个像素差异
      threshold: 0.2, // 颜色相似度阈值 0-1
      fullPage: false, // 只截图可视区域
      maxDiffPixelRatio: 0.05, // 5% 像素差异容忍度
    },
  },
}

/**
 * 推荐的 Playwright 配置模板
 * 包含截图审查工具集成
 */
export function createConfigWithValidator(options: {
  testDir?: string
  baseURL?: string
  projects?: any[]
  webServer?: any
} = {}) {
  return defineConfig({
    testDir: options.testDir || './e2e',
    fullyParallel: false, // 按顺序执行，便于调试
    forbidOnly: !!process.env.CI,
    retries: process.env.CI ? 0 : 0, // 不自动重试
    workers: 1, // 单线程执行
    timeout: 120000, // 全局测试超时 120 秒

    reporter: [
      ['list'],
      ['html', { open: 'never' }],
      ['json', { outputFile: 'e2e/test-results.json' }],
      ['./reporters/bug-reporter.ts'], // 自定义 Bug 报告器
    ],

    ...screenshotValidatorConfig.use,

    projects: options.projects || [
      {
        name: 'chromium',
        use: {
          ...devices['Desktop Chrome'],
          viewport: { width: 1920, height: 1080 },
        },
      },
      {
        name: 'chromium-mobile',
        use: {
          ...devices['Pixel 5'],
        },
      },
    ],

    webServer: options.webServer || {
      command: 'npm run dev',
      url: process.env.BASE_URL || 'http://localhost:5173',
      reuseExistingServer: true,
      timeout: 60000,
    },
  })
}

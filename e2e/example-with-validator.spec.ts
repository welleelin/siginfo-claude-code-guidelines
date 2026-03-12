/**
 * Playwright 测试示例 - 集成截图审查工具
 *
 * 此示例展示了如何在实际测试中使用 ScreenshotValidator
 * 包含截图审查、Bug 自动上报、视觉验证等功能
 *
 * @version 1.0.0
 * @since 2026-03-12
 */

import { test, expect, type Page } from '@playwright/test'
import { ScreenshotValidator, type BugReport } from '../lib/screenshot-validator'

// ============================================================================
// 方式一：手动创建 Validator（推荐，灵活性高）
// ============================================================================

test.describe('登录功能 - 带截图审查', () => {
  let validator: ScreenshotValidator

  test.beforeEach(async ({ page }) => {
    // 为每个测试创建新的 validator
    validator = new ScreenshotValidator(page, {
      checkConsoleErrors: true,
      checkNetworkErrors: true,
      requireHttpStatusCheck: true,
      criticalSelectors: [], // 可以在每个测试中单独设置
    })
  })

  test('登录页面正确显示 - 完整验证', async ({ page }) => {
    // Step 1: 导航到登录页
    const response = await page.goto('/login')

    // Step 2: 验证 HTTP 状态
    expect(response?.status()).toBe(200)

    // Step 3: 使用 validator 进行完整验证
    const validationResult = await validator.validate({
      name: '登录页面',
      criticalSelectors: [
        'h1:has-text("登录")',
        'input[type="text"]',
        'input[type="password"]',
        'button[type="submit"]'
      ],
      skipScreenshot: false
    })

    // Step 4: 断言验证通过
    expect(validationResult.valid, `验证失败：${validationResult.issues.map(i => i.message).join('; ')}`).toBe(true)

    // Step 5: 如果验证失败，创建 Bug 报告
    if (!validationResult.valid) {
      const bug = await validator.createBugReport({
        title: '登录页面验证失败',
        severity: validationResult.issues[0].severity,
        description: validationResult.issues.map(i => i.message).join('; '),
        steps: [
          '1. 导航到 /login',
          '2. 验证 HTTP 状态',
          '3. 验证页面内容',
          '4. 验证关键元素'
        ],
        testInfo: test.info()
      })
      console.error('Bug 已创建:', bug.id)
    }
  })

  test('登录页面截图 - 带审查', async ({ page }) => {
    await page.goto('/login')

    // 传统方式：只验证元素存在（❌ 不够）
    await expect(page.locator('h1')).toBeVisible()

    // 新增：使用 validator 进行完整验证（✅ 推荐）
    const result = await validator.validate({
      name: '登录页面截图',
      criticalSelectors: ['h1', 'form'],
      skipScreenshot: false
    })

    // 验证必须通过
    expect(result.valid).toBe(true)

    // 额外：视觉回归测试
    await expect(page).toHaveScreenshot('login-baseline.png', {
      maxDiffPixelRatio: 0.05
    })
  })

  test('404 页面检测 - Bug 自动上报', async ({ page }) => {
    // 模拟访问一个不存在的页面
    await page.goto('/non-existent-page-12345')

    // 使用 validator 验证 - 应该会失败
    const result = await validator.validate({
      name: '404 页面检测',
      skipHttpStatus: false
    })

    // 验证应该失败（因为页面是 404）
    expect(result.valid).toBe(false)

    // 检查是否检测到 404 错误
    const has404Error = result.issues.some(i =>
      i.type === 'http-status' || i.type === 'error-content'
    )
    expect(has404Error).toBe(true)

    // 创建 Bug 报告
    const bug = await validator.createBugReport({
      title: '访问到 404 页面',
      severity: 'P0',
      description: `用户访问到 404 页面：/non-existent-page-12345`,
      steps: ['1. 导航到 /non-existent-page-12345', '2. 检测到 404 错误'],
      testInfo: test.info()
    })

    console.log('Bug 已创建:', bug.id, bug.title)
  })
})

// ============================================================================
// 方式二：使用 fixture 扩展（适合大规模使用）
// ============================================================================

// 在 playwright.config.ts 中定义 fixture：
// export default defineConfig({
//   ...
//   use: {
//     ...
//   },
// })

// 创建 test-with-validator.ts
/*
import { test as base } from '@playwright/test'
import { ScreenshotValidator } from '../lib/screenshot-validator'

export type ValidatorFixtures = {
  validator: ScreenshotValidator
}

export const test = base.extend<ValidatorFixtures>({
  validator: async ({ page }, use) => {
    const validator = new ScreenshotValidator(page, {
      checkConsoleErrors: true,
      checkNetworkErrors: true,
      requireHttpStatusCheck: true,
    })
    await use(validator)
  },
})
*/

// 然后在测试文件中使用：
/*
import { test } from './test-with-validator'

test('使用 fixture 的测试', async ({ page, validator }) => {
  await page.goto('/login')

  const result = await validator.validate({
    name: '登录页面',
    criticalSelectors: ['form']
  })

  expect(result.valid).toBe(true)
})
*/

// ============================================================================
// 方式三：视觉回归测试专用
// ============================================================================

test.describe('视觉回归测试', () => {
  test('首页视觉回归', async ({ page }) => {
    await page.goto('/')

    // 等待页面加载完成
    await page.waitForLoadState('networkidle')

    // 截图并与基准对比
    await expect(page).toHaveScreenshot('home-page-baseline.png', {
      maxDiffPixelRatio: 0.05,
      fullPage: false,
    })
  })

  test('登录页面视觉回归', async ({ page }) => {
    await page.goto('/login')

    // 等待动画完成
    await page.waitForTimeout(1000)

    await expect(page).toHaveScreenshot('login-page-baseline.png', {
      maxDiffPixelRatio: 0.05,
      fullPage: false,
    })
  })
})

// ============================================================================
// 最佳实践：测试 helpers 集成
// ============================================================================

/**
 * 登录辅助函数（带截图审查）
 */
export async function loginWithValidation(
  page: Page,
  validator: ScreenshotValidator,
  role: 'admin' | 'user' = 'admin'
) {
  const credentials = {
    admin: { username: 'admin', password: 'admin123' },
    user: { username: 'user', password: 'user123' },
  }

  const { username, password } = credentials[role]

  // 导航到登录页
  await page.goto('/login')

  // 验证登录页
  const loginPageResult = await validator.validate({
    name: `${role} 登录页面`,
    criticalSelectors: ['form', 'input[type="text"]', 'input[type="password"]']
  })

  if (!loginPageResult.valid) {
    throw new Error(`登录页面验证失败：${loginPageResult.issues.map(i => i.message).join('; ')}`)
  }

  // 填写表单
  await page.fill('input[type="text"]', username)
  await page.fill('input[type="password"]', password)
  await page.click('button[type="submit"]')

  // 等待跳转
  await page.waitForURL(/dashboard|home/)

  // 验证跳转成功
  const dashboardResult = await validator.validate({
    name: `${role} 仪表盘页面`,
    criticalSelectors: ['[role="menubar"]', '[role="banner"]']
  })

  if (!dashboardResult.valid) {
    await validator.createBugReport({
      title: `${role} 登录后跳转失败`,
      severity: 'P1',
      description: dashboardResult.issues.map(i => i.message).join('; '),
      steps: [
        `1. 使用 ${role} 账号登录`,
        '2. 等待页面跳转',
        '3. 验证仪表盘页面'
      ]
    })
    throw new Error(`仪表盘验证失败：${dashboardResult.issues.map(i => i.message).join('; ')}`)
  }

  return { username, role }
}

// 使用示例：
/*
test('完整登录流程 - 使用 helper', async ({ page }) => {
  const validator = new ScreenshotValidator(page)

  await loginWithValidation(page, validator, 'admin')

  // 继续其他操作...
})
*/

/**
 * Playwright 企业级测试框架 - 完整集成示例
 *
 * 本示例演示如何将 PRD 需求、功能点、用户故事与 Playwright 测试完整结合
 * 形成从需求→测试→验证→报告的闭环
 *
 * @version 1.0.0
 * @since 2026-03-12
 */

// ============================================================================
// 示例 1: 从 PRD 需求创建功能测试
// ============================================================================

/**
 * 场景：测试"用户登录认证"功能 (FR1)
 *
 * PRD 需求来源:
 * - FR1: 用户登录认证
 * - FR26: 角色权限管理
 *
 * 用户故事:
 * - story-001: 作为运营人员，我希望登录系统，以便开始工作
 *
 * 验收标准:
 * - AC1: 用户名密码正确时登录成功
 * - AC2: 用户名或密码错误时显示错误提示
 * - AC3: 登录后根据角色显示不同菜单
 */

import { test, expect, type Page } from '@playwright/test'
import { RequirementTracker } from './framework/core/RequirementTracker'
import { CoverageGenerator } from './framework/core/CoverageGenerator'
import { ScreenshotValidator } from './lib/screenshot-validator'

// Page Object
class LoginPage {
  constructor(private page: Page) {}

  async goto() {
    return this.page.goto('/login')
  }

  async login(username: string, password: string) {
    await this.page.fill('input[type="text"]', username)
    await this.page.fill('input[type="password"]', password)
    await this.page.click('button[type="submit"]')
  }

  async getErrorMessage() {
    return this.page.locator('.el-message--error').textContent()
  }

  async isSuccess() {
    await this.page.waitForURL(/dashboard/)
    return true
  }
}

// 测试套件
test.describe('FR1: 用户登录认证', () => {
  // 初始化需求追溯器
  const tracker = RequirementTracker.getInstance()
  let loginPage: LoginPage
  let validator: ScreenshotValidator

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page)
    validator = new ScreenshotValidator(page, {
      checkConsoleErrors: true,
      checkNetworkErrors: true,
    })

    // 注册需求（首次运行时）
    tracker.registerRequirement({
      id: 'FR1',
      title: '用户登录认证',
      source: 'PRD.md',
      priority: 'P0',
      status: 'implemented',
      acceptanceCriteria: [
        { id: 'AC1', description: '用户名密码正确时登录成功', passed: false },
        { id: 'AC2', description: '用户名或密码错误时显示错误提示', passed: false },
        { id: 'AC3', description: '登录后根据角色显示不同菜单', passed: false },
      ]
    })
  })

  /**
   * @requirement FR1
   * @requirement FR26
   * @story story-001
   * @acceptance AC1
   */
  test('AC1: 用户名密码正确时登录成功', async ({ page }) => {
    await loginPage.goto()
    await loginPage.login('admin', 'admin123')

    // 验证登录成功
    const success = await loginPage.isSuccess()
    expect(success).toBe(true)

    // 截图审查
    const result = await validator.validate({
      name: '登录成功 - 仪表盘页面',
      criticalSelectors: ['[role="menubar"]', '[role="banner"]']
    })

    // 报告测试结果
    tracker.reportTestResult('FR1', 'login-001', {
      status: result.valid ? 'passed' : 'failed',
      acceptanceCriteria: [{ id: 'AC1', passed: result.valid }]
    })

    expect(result.valid).toBe(true)
  })

  /**
   * @requirement FR1
   * @story story-001
   * @acceptance AC2
   */
  test('AC2: 用户名或密码错误时显示错误提示', async ({ page }) => {
    await loginPage.goto()
    await loginPage.login('invalid', 'wrong')

    // 验证错误提示
    const errorMessage = await loginPage.getErrorMessage()
    expect(errorMessage).toContain('用户名或密码错误')

    // 报告测试结果
    tracker.reportTestResult('FR1', 'login-002', {
      status: 'passed',
      acceptanceCriteria: [{ id: 'AC2', passed: true }]
    })
  })

  /**
   * @requirement FR1
   * @requirement FR26
   * @story story-001
   * @acceptance AC3
   */
  test('AC3: 登录后根据角色显示不同菜单', async ({ page }) => {
    // 运营人员登录
    await loginPage.goto()
    await loginPage.login('operator', 'operator123')
    await loginPage.isSuccess()

    // 验证运营人员菜单
    await expect(page.getByText('需求管理')).toBeVisible()
    await expect(page.getByText('客户管理')).toBeVisible()

    // 老板登录
    await loginPage.goto()
    await loginPage.login('boss', 'boss123')
    await loginPage.isSuccess()

    // 验证老板菜单（只有仪表盘）
    await expect(page.getByText('数据统计')).toBeVisible()
    await expect(page.getByText('需求管理')).not.toBeVisible()

    // 报告测试结果
    tracker.reportTestResult('FR1', 'login-003', {
      status: 'passed',
      acceptanceCriteria: [{ id: 'AC3', passed: true }]
    })
  })
})

// ============================================================================
// 示例 2: 使用测试模板创建标准化的功能测试
// ============================================================================

import { createFeatureTest } from './framework/templates/feature-test.template'

// 使用模板创建"需求管理"功能测试
export const DemandFeatureTest = createFeatureTest({
  featureId: 'FR7',
  featureName: '需求管理功能',
  requirements: ['FR7', 'FR8', 'FR9'],
  stories: ['story-007', 'story-008']
})

// ============================================================================
// 示例 3: 生成覆盖率报告和质量门禁
// ============================================================================

/**
 * 在 CI/CD 流程中运行测试并生成报告
 */
async function runTestsWithCoverage() {
  // 初始化追溯器
  const tracker = RequirementTracker.getInstance()

  // 从 task.json 导入需求
  tracker.importFromTaskJson('./task.json')

  // ... 运行测试 ...

  // 生成覆盖率报告
  const coverageGenerator = new CoverageGenerator(tracker, {
    minRequirementCoverage: 80,
    minP0Coverage: 100,
    minP1Coverage: 90,
    minTestPassRate: 95,
    blocking: true
  })

  const report = coverageGenerator.generate({
    project: '需求单管理系统',
    version: '1.0.0',
    taskJsonPath: './task.json',
    outputPath: './test-results/reports/coverage-report.json'
  })

  // 检查质量门禁
  const qualityGate = coverageGenerator.checkQualityGate(report)

  if (!qualityGate.passed) {
    console.error('❌ 质量门禁失败:')
    qualityGate.blockers.forEach(blocker => console.error(`  - ${blocker}`))
    process.exit(1)
  }

  // 生成 HTML 报告
  coverageGenerator.generateHtmlReport(
    report,
    './test-results/reports/coverage-report.html'
  )

  // 生成追溯报告
  tracker.generateReport('./test-results/reports/traceability-report.json')

  console.log('✅ 质量门禁通过')
  console.log(`📊 需求覆盖率：${report.overall.coverageRate}%`)
  console.log(`📈 测试通过率：${report.overall.passRate}%`)
}

// ============================================================================
// 示例 4: Playwright 配置集成
// ============================================================================

/**
 * playwright.config.ts 配置示例
 */
export const playwrightConfig = {
  testDir: './e2e/tests',
  timeout: 120000,
  retries: 0, // 不自动重试
  workers: 1,
  reporter: [
    ['list'],
    ['html', { open: 'never' }],
    ['./framework/reporters/coverage-reporter.ts'],
    ['./framework/reporters/traceability-reporter.ts'],
  ],
  use: {
    baseURL: 'http://localhost:5173',
    screenshot: 'on',
    trace: 'retain-on-failure',
  },
}

// ============================================================================
// 示例 5: 完整的业务闭环测试
// ============================================================================

test.describe('完整业务闭环：需求提交 → 审核 → 白名单推送', () => {
  const tracker = RequirementTracker.getInstance()

  /**
   * @story story-end-to-end-001
   * @description 验证从需求提交到白名单推送的完整业务流程
   */
  test('完整业务闭环测试', async ({ page }) => {
    const validator = new ScreenshotValidator(page)

    // Step 1: 客户登录并提交需求
    await page.goto('/login')
    await page.fill('input[type="text"]', 'customer1')
    await page.fill('input[type="password"]', 'customer123')
    await page.click('button[type="submit"]')

    // 验证登录成功
    const step1Result = await validator.validate({
      name: '客户登录成功',
      criticalSelectors: ['[role="banner"]']
    })

    // Step 2: 填写需求提交表单
    await page.goto('/demand/create')
    await page.fill('input[name="activityName"]', '618 大促活动')
    await page.selectOption('select[name="businessType"]', 'promotion')
    await page.fill('input[name="budget"]', '100000')
    await page.click('button:has-text("提交")')

    // 验证提交成功并获取需求编号
    const demandId = await page.locator('.demand-id').textContent()
    expect(demandId).toMatch(/DEM-\d+/)

    // Step 3: 运营人员审核需求
    await page.goto('/login')
    await page.fill('input[type="text"]', 'operator1')
    await page.fill('input[type="password"]', 'operator123')
    await page.click('button[type="submit"]')

    await page.goto(`/demand/${demandId}/audit`)
    await page.click('text=审核通过')
    await page.fill('textarea[name="comment"]', '同意')
    await page.click('text=确认提交')

    // Step 4: 验证白名单推送
    await page.goto('/whitelist/batches')
    await expect(page.getByText('618 大促活动')).toBeVisible()

    // 完整闭环验证
    const finalResult = await validator.validate({
      name: '完整业务闭环验证',
      criticalSelectors: ['[role="menubar"]', '.demand-status']
    })

    // 报告测试结果
    tracker.reportTestResult('FR7', 'e2e-001', {
      status: finalResult.valid ? 'passed' : 'failed'
    })

    expect(finalResult.valid).toBe(true)
  })
})

// ============================================================================
// 导出工具函数
// ============================================================================

/**
 * 在 package.json 中添加脚本:
 * {
 *   "scripts": {
 *     "test:e2e": "playwright test",
 *     "test:coverage": "playwright test && node scripts/generate-coverage.js",
 *     "test:traceability": "node scripts/generate-traceability.js"
 *   }
 * }
 */

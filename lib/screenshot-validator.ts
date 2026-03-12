/**
 * 截图审查工具 - Test Integrity Validator
 *
 * 用于 Playwright E2E 测试的截图完整性验证
 * 防止"为了通过而测试"的敷衍行为
 *
 * @version 1.0.0
 * @since 2026-03-12
 */

import { Page, Locator, TestInfo } from '@playwright/test'
import { writeFileSync, mkdirSync, existsSync } from 'fs'
import { join } from 'path'

/**
 * Bug 级别定义
 */
export type BugSeverity = 'P0' | 'P1' | 'P2' | 'P3'

/**
 * Bug 报告接口
 */
export interface BugReport {
  id: string
  title: string
  severity: BugSeverity
  description: string
  steps: string[]
  evidence: {
    screenshot?: string
    consoleLogs?: string
    networkLogs?: string
    html?: string
  }
  detectedAt: string
  testFile?: string
  testTitle?: string
  status: 'open' | 'fixed' | 'closed'
}

/**
 * 验证结果接口
 */
export interface ValidationResult {
  valid: boolean
  issues: Issue[]
  screenshotPath?: string
}

export interface Issue {
  type: 'http-status' | 'error-content' | 'missing-element' | 'visual' | 'console-error' | 'network-error'
  severity: BugSeverity
  message: string
  details?: string
}

/**
 * 截图审查配置
 */
export interface ScreenshotValidatorConfig {
  /** 关键元素选择器列表 */
  criticalSelectors?: string[]
  /** 自定义错误内容模式 */
  customErrorPatterns?: RegExp[]
  /** 是否检查控制台错误 */
  checkConsoleErrors?: boolean
  /** 是否检查网络请求错误 */
  checkNetworkErrors?: boolean
  /** HTTP 状态码验证是否必需 */
  requireHttpStatusCheck?: boolean
  /** 视觉回归基准图片目录 */
  baselineDir?: string
  /** 最大允许像素差异比例 */
  maxDiffPixelRatio?: number
}

/**
 * 截图审查器主类
 */
export class ScreenshotValidator {
  private page: Page
  private config: ScreenshotValidatorConfig
  private bugReports: BugReport[] = []
  private consoleMessages: string[] = []
  private networkErrors: string[] = []

  constructor(page: Page, config: ScreenshotValidatorConfig = {}) {
    this.page = page
    this.config = {
      checkConsoleErrors: true,
      checkNetworkErrors: true,
      requireHttpStatusCheck: true,
      maxDiffPixelRatio: 0.05,
      ...config
    }

    // 设置控制台监听
    if (this.config.checkConsoleErrors) {
      this.setupConsoleListener()
    }

    // 设置网络请求监听
    if (this.config.checkNetworkErrors) {
      this.setupNetworkListener()
    }
  }

  /**
   * 设置控制台监听
   */
  private setupConsoleListener(): void {
    this.page.on('console', (msg) => {
      const type = msg.type()
      const text = msg.text()

      // 只记录错误和警告
      if (type === 'error' || type === 'warning') {
        this.consoleMessages.push(`[${type}] ${text}`)
      }
    })
  }

  /**
   * 设置网络请求监听
   */
  private setupNetworkListener(): void {
    this.page.on('requestfailed', (request) => {
      const url = request.url()
      const failure = request.failure()
      this.networkErrors.push(`[FAILED] ${url}: ${failure?.errorText || 'Unknown error'}`)
    })

    this.page.on('response', async (response) => {
      const status = response.status()
      const url = response.url()

      // 记录 4xx 和 5xx 错误
      if (status >= 400) {
        this.networkErrors.push(`[HTTP ${status}] ${url}`)
      }
    })
  }

  /**
   * 验证 HTTP 状态码
   */
  async validateStatus(): Promise<{ valid: boolean; status?: number | null }> {
    try {
      const response = this.page.response()
      if (!response) {
        return { valid: false, status: null }
      }
      const status = await response.status()

      if (status >= 400) {
        return { valid: false, status }
      }
      return { valid: true, status }
    } catch (error) {
      return { valid: false, status: null }
    }
  }

  /**
   * 验证页面不包含错误内容
   */
  async validateNoErrorContent(): Promise<{ valid: boolean; errors: string[] }> {
    try {
      const bodyText = await this.page.locator('body').textContent()

      if (!bodyText || bodyText.trim().length === 0) {
        return {
          valid: false,
          errors: ['页面 body 内容为空']
        }
      }

      const defaultErrorPatterns = [
        { pattern: /404/i, message: '页面包含 404 错误' },
        { pattern: /not found/i, message: '页面包含 Not Found 错误' },
        { pattern: /页面不存在/i, message: '页面包含"页面不存在"错误' },
        { pattern: /服务器错误/i, message: '页面包含服务器错误' },
        { pattern: /500/i, message: '页面包含 500 错误' },
        { pattern: /internal server error/i, message: '页面包含内部服务器错误' },
        { pattern: /^[\s\n]*$/, message: '页面几乎为空' }
      ]

      const patterns = [
        ...defaultErrorPatterns,
        ...(this.config.customErrorPatterns || []).map(p => ({ pattern: p, message: `匹配自定义错误模式：${p}` }))
      ]

      const errors = patterns
        .filter(({ pattern }) => pattern.test(bodyText))
        .map(({ message }) => message)

      return { valid: errors.length === 0, errors }
    } catch (error) {
      return {
        valid: false,
        errors: [`验证页面内容失败：${error}`]
      }
    }
  }

  /**
   * 验证关键元素存在
   */
  async validateCriticalElements(selectors?: string[]): Promise<{ valid: boolean; missing: string[] }> {
    const selectorsToCheck = selectors || this.config.criticalSelectors || []
    const missing: string[] = []

    for (const selector of selectorsToCheck) {
      try {
        const locator = this.page.locator(selector)
        const isVisible = await locator.isVisible({ timeout: 5000 })

        if (!isVisible) {
          missing.push(selector)
        }
      } catch (error) {
        missing.push(`${selector} (error: ${error})`)
      }
    }

    return { valid: missing.length === 0, missing }
  }

  /**
   * 验证控制台无错误
   */
  async validateNoConsoleErrors(): Promise<{ valid: boolean; errors: string[] }> {
    if (!this.config.checkConsoleErrors) {
      return { valid: true, errors: [] }
    }

    return {
      valid: this.consoleMessages.length === 0,
      errors: this.consoleMessages
    }
  }

  /**
   * 验证网络请求无错误
   */
  async validateNoNetworkErrors(): Promise<{ valid: boolean; errors: string[] }> {
    if (!this.config.checkNetworkErrors) {
      return { valid: true, errors: [] }
    }

    // 过滤掉一些常见的可接受的网络错误（如 favicon、统计脚本等）
    const acceptableErrors = this.networkErrors.filter(err => {
      return !err.includes('favicon') &&
             !err.includes('analytics') &&
             !err.includes('statistical')
    })

    return {
      valid: acceptableErrors.length === 0,
      errors: acceptableErrors
    }
  }

  /**
   * 执行完整验证流程
   */
  async validate(options: {
    name?: string
    criticalSelectors?: string[]
    customErrorPatterns?: RegExp[]
    skipHttpStatus?: boolean
    skipScreenshot?: boolean
  } = {}): Promise<ValidationResult> {
    const issues: Issue[] = []
    const testName = options.name || 'Unnamed Test'

    // 1. 验证 HTTP 状态（可选跳过）
    if (!options.skipHttpStatus && this.config.requireHttpStatusCheck) {
      const statusResult = await this.validateStatus()
      if (!statusResult.valid) {
        issues.push({
          type: 'http-status',
          severity: 'P0',
          message: `HTTP 状态码异常：${statusResult.status || '无法获取状态码'}`,
          details: `测试：${testName}`
        })
      }
    }

    // 2. 验证页面内容
    const errorContentResult = await this.validateNoErrorContent()
    if (!errorContentResult.valid) {
      issues.push({
        type: 'error-content',
        severity: 'P0',
        message: `页面包含错误内容：${errorContentResult.errors.join(', ')}`,
        details: `测试：${testName}`
      })
    }

    // 3. 验证关键元素
    const elementsResult = await this.validateCriticalElements(options.criticalSelectors)
    if (!elementsResult.valid) {
      issues.push({
        type: 'missing-element',
        severity: 'P1',
        message: `关键元素缺失：${elementsResult.missing.join(', ')}`,
        details: `测试：${testName}`
      })
    }

    // 4. 验证控制台错误
    const consoleResult = await this.validateNoConsoleErrors()
    if (!consoleResult.valid) {
      issues.push({
        type: 'console-error',
        severity: 'P2',
        message: `控制台存在 ${consoleResult.errors.length} 个错误`,
        details: consoleResult.errors.slice(0, 5).join('; ')
      })
    }

    // 5. 验证网络错误
    const networkResult = await this.validateNoNetworkErrors()
    if (!networkResult.valid) {
      issues.push({
        type: 'network-error',
        severity: 'P2',
        message: `网络请求存在 ${networkResult.errors.length} 个错误`,
        details: networkResult.errors.slice(0, 5).join('; ')
      })
    }

    // 6. 截图（可选跳过）
    let screenshotPath: string | undefined
    if (!options.skipScreenshot) {
      screenshotPath = await this.takeScreenshot(options.name)
    }

    return {
      valid: issues.length === 0,
      issues,
      screenshotPath
    }
  }

  /**
   * 截图并保存
   */
  async takeScreenshot(name?: string): Promise<string> {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-')
    const safeName = (name || 'screenshot').replace(/[^a-zA-Z0-9-_]/g, '_')
    const filename = `${safeName}-${timestamp}.png`

    // 确保目录存在
    const screenshotDir = 'test-results/screenshots'
    if (!existsSync(screenshotDir)) {
      mkdirSync(screenshotDir, { recursive: true })
    }

    const screenshotPath = join(screenshotDir, filename)

    await this.page.screenshot({
      path: screenshotPath,
      fullPage: false
    })

    return screenshotPath
  }

  /**
   * 创建 Bug 报告
   */
  async createBugReport(options: {
    title: string
    severity: BugSeverity
    description: string
    steps: string[]
    testInfo?: TestInfo
  }): Promise<BugReport> {
    const bug: BugReport = {
      id: `BUG-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      title: `[测试发现] ${options.title}`,
      severity: options.severity,
      description: options.description,
      steps: options.steps,
      evidence: {},
      detectedAt: new Date().toISOString(),
      testFile: options.testInfo?.titlePath[0],
      testTitle: options.testInfo?.title,
      status: 'open'
    }

    // 保存截图证据
    try {
      const screenshotPath = await this.takeScreenshot(`bug-${bug.id}`)
      bug.evidence.screenshot = screenshotPath
    } catch (e) {
      console.error('保存截图失败:', e)
    }

    // 保存控制台日志
    if (this.consoleMessages.length > 0) {
      bug.evidence.consoleLogs = this.consoleMessages.join('\n')
    }

    // 保存网络错误日志
    if (this.networkErrors.length > 0) {
      bug.evidence.networkLogs = this.networkErrors.join('\n')
    }

    // 保存页面 HTML
    try {
      bug.evidence.html = await this.page.content()
    } catch (e) {
      console.error('保存 HTML 失败:', e)
    }

    this.bugReports.push(bug)

    // 保存到文件
    this.saveBugReports()

    // P0/P1 Bug 立即通知
    if (bug.severity === 'P0' || bug.severity === 'P1') {
      this.notifyImmediate(bug)
    }

    return bug
  }

  /**
   * 保存 Bug 报告到文件
   */
  private saveBugReports(): void {
    const bugReportDir = 'test-results/bug-reports'
    if (!existsSync(bugReportDir)) {
      mkdirSync(bugReportDir, { recursive: true })
    }

    const reportPath = join(bugReportDir, 'bugs.json')
    writeFileSync(reportPath, JSON.stringify(this.bugReports, null, 2))
  }

  /**
   * P0/P1 Bug 立即通知
   */
  private notifyImmediate(bug: BugReport): void {
    const message = [
      `🚨 严重 Bug 发现!`,
      `标题：${bug.title}`,
      `级别：${bug.severity}`,
      `时间：${bug.detectedAt}`,
      `描述：${bug.description}`,
      `证据：${bug.evidence.screenshot || '无截图'}`
    ].join('\n')

    console.error(message)
  }

  /**
   * 获取所有 Bug 报告
   */
  getBugReports(): BugReport[] {
    return this.bugReports
  }

  /**
   * 生成验证摘要报告
   */
  generateSummaryReport(): {
    totalValidations: number
    passedValidations: number
    failedValidations: number
    totalBugs: { P0: number; P1: number; P2: number; P3: number }
    passRate: number
  } {
    const bugs = this.bugReports
    return {
      totalValidations: this.bugReports.length,
      passedValidations: bugs.filter(b => b.status === 'closed').length,
      failedValidations: bugs.filter(b => b.status === 'open').length,
      totalBugs: {
        P0: bugs.filter(b => b.severity === 'P0').length,
        P1: bugs.filter(b => b.severity === 'P1').length,
        P2: bugs.filter(b => b.severity === 'P2').length,
        P3: bugs.filter(b => b.severity === 'P3').length
      },
      passRate: bugs.length > 0
        ? (bugs.filter(b => b.status === 'closed').length / bugs.length) * 100
        : 100
    }
  }
}

/**
 * 创建带有截图审查的测试.fixture
 * 在 Playwright 配置文件中引入
 */
export function createTestWithScreenshotValidation(test: any) {
  return test.extend<{
    validator: ScreenshotValidator
  }>({
    validator: async ({ page }, use) => {
      const validator = new ScreenshotValidator(page, {
        checkConsoleErrors: true,
        checkNetworkErrors: true,
        requireHttpStatusCheck: true,
      })
      await use(validator)
    },
  })
}

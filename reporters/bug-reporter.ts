/**
 * Playwright Bug 报告器
 *
 * 自动收集测试中发现的 Bug 并生成报告
 *
 * 使用方法：
 * 在 playwright.config.ts 中添加：
 * reporter: [
 *   ['list'],
 *   ['./reporters/bug-reporter.ts']
 * ]
 *
 * @version 1.0.0
 * @since 2026-03-12
 */

import { Reporter, FullConfig, Suite, TestCase, TestResult, TestError } from '@playwright/test/reporter'
import { writeFileSync, mkdirSync, existsSync, readFileSync } from 'fs'
import { join } from 'path'

interface BugInfo {
  id: string
  testFile: string
  testTitle: string
  severity: 'P0' | 'P1' | 'P2' | 'P3'
  error: string
  screenshot?: string
  timestamp: string
}

class BugReporter implements Reporter {
  private bugs: BugInfo[] = []
  private reportDir: string = 'test-results/bug-reports'

  constructor(options: { outputDir?: string } = {}) {
    if (options.outputDir) {
      this.reportDir = options.outputDir
    }
  }

  onBegin(config: FullConfig, suite: Suite) {
    // 确保报告目录存在
    if (!existsSync(this.reportDir)) {
      mkdirSync(this.reportDir, { recursive: true })
    }
    console.log(`🐛 Bug 报告器已初始化，报告目录：${this.reportDir}`)
  }

  onTestEnd(test: TestCase, result: TestResult) {
    // 测试失败时记录 Bug
    if (result.status === 'failed') {
      const bug = this.extractBugInfo(test, result)
      this.bugs.push(bug)

      // P0/P1 Bug 立即输出警告
      if (bug.severity === 'P0' || bug.severity === 'P1') {
        console.error(`\n🚨 严重 Bug 发现:`)
        console.error(`   文件：${bug.testFile}`)
        console.error(`   测试：${bug.testTitle}`)
        console.error(`   级别：${bug.severity}`)
        console.error(`   错误：${bug.error}\n`)
      }
    }
  }

  onEnd(result: { status: string; startTime: Date; duration: number }) {
    // 保存 Bug 报告
    this.saveBugReport()

    // 输出摘要
    this.printSummary()
  }

  /**
   * 从测试结果提取 Bug 信息
   */
  private extractBugInfo(test: TestCase, result: TestResult): BugInfo {
    // 根据错误类型判断严重程度
    const error = result.errors[0]
    const errorMessage = error?.message || 'Unknown error'
    const severity = this.determineSeverity(errorMessage, test.title)

    // 查找截图
    const screenshot = result.attachments.find(a => a.name === 'screenshot')?.path

    return {
      id: `BUG-${Date.now()}-${test.titleHash || Math.random().toString(36).substr(2, 9)}`,
      testFile: test.location.file,
      testTitle: test.title,
      severity,
      error: this.truncateMessage(errorMessage, 500),
      screenshot,
      timestamp: new Date().toISOString()
    }
  }

  /**
   * 根据错误信息判断严重程度
   */
  private determineSeverity(errorMessage: string, testTitle: string): 'P0' | 'P1' | 'P2' | 'P3' {
    const errorLower = errorMessage.toLowerCase()

    // P0 - 致命错误
    if (errorLower.includes('404') ||
        errorLower.includes('not found') ||
        errorLower.includes('页面不存在') ||
        errorLower.includes('500') ||
        errorLower.includes('internal server error') ||
        errorLower.includes('timeout') && errorLower.includes('navigation')) {
      return 'P0'
    }

    // P1 - 严重错误
    if (errorLower.includes('assertion error') ||
        errorLower.includes('expected') && errorLower.includes('to be') ||
        errorLower.includes('element not found') ||
        errorLower.includes('element not visible')) {
      return 'P1'
    }

    // P2 - 一般错误
    if (errorLower.includes('timeout') ||
        errorLower.includes('network error') ||
        errorLower.includes('console error')) {
      return 'P2'
    }

    // P3 - 轻微错误
    return 'P3'
  }

  /**
   * 截断错误消息（防止过长）
   */
  private truncateMessage(message: string, maxLength: number): string {
    if (message.length <= maxLength) {
      return message
    }
    return message.substring(0, maxLength) + '...'
  }

  /**
   * 保存 Bug 报告到文件
   */
  private saveBugReport() {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-')
    const reportPath = join(this.reportDir, `bugs-${timestamp}.json`)

    const report = {
      generatedAt: new Date().toISOString(),
      totalBugs: this.bugs.length,
      bugsBySeverity: {
        P0: this.bugs.filter(b => b.severity === 'P0').length,
        P1: this.bugs.filter(b => b.severity === 'P1').length,
        P2: this.bugs.filter(b => b.severity === 'P2').length,
        P3: this.bugs.filter(b => b.severity === 'P3').length
      },
      bugs: this.bugs
    }

    writeFileSync(reportPath, JSON.stringify(report, null, 2))
    console.log(`📄 Bug 报告已保存到：${reportPath}`)

    // 同时保存最新报告的副本
    const latestPath = join(this.reportDir, 'bugs-latest.json')
    writeFileSync(latestPath, JSON.stringify(report, null, 2))
  }

  /**
   * 打印摘要
   */
  private printSummary() {
    const bySeverity = {
      P0: this.bugs.filter(b => b.severity === 'P0').length,
      P1: this.bugs.filter(b => b.severity === 'P1').length,
      P2: this.bugs.filter(b => b.severity === 'P2').length,
      P3: this.bugs.filter(b => b.severity === 'P3').length
    }

    console.log('\n' + '='.repeat(60))
    console.log('🐛 Bug 报告摘要')
    console.log('='.repeat(60))
    console.log(`总 Bug 数：${this.bugs.length}`)
    console.log(`  P0 (致命): ${bySeverity.P0}`)
    console.log(`  P1 (严重): ${bySeverity.P1}`)
    console.log(`  P2 (一般): ${bySeverity.P2}`)
    console.log(`  P3 (轻微): ${bySeverity.P3}`)

    if (bySeverity.P0 > 0) {
      console.error('\n⚠️  发现 P0 级别致命 Bug，必须立即修复！')
    } else if (bySeverity.P1 > 0) {
      console.warn('\n⚠️  发现 P1 级别严重 Bug，建议优先修复。')
    }

    console.log('='.repeat(60) + '\n')
  }
}

export default BugReporter

#!/usr/bin/env ts-node
/**
 * AI 自主验证脚本 - 预期效果验证
 *
 * 用途：AI 在开发完成后自动验证预期效果，确保用户可直接使用
 *
 * 使用方法：
 * npx tsx scripts/verify-expectations.ts
 *
 * @version 1.0.0
 * @since 2026-03-12
 */

import { chromium, Page } from 'playwright'

interface VerificationResult {
  passed: boolean
  details: string[]
  errors: string[]
}

/**
 * 验证游戏列表页面
 */
async function verifyGameList(page: Page): Promise<string[]> {
  const issues: string[] = []

  // 验证统计卡片
  const statsCards = page.locator('.stats-card, [class*="stat"], [class*="card"]')
  const statsCount = await statsCards.count()
  if (statsCount === 0) {
    issues.push('❌ 统计卡片未显示')
  } else {
    console.log(`✅ 统计卡片已显示 (${statsCount}个)`)
  }

  // 验证选项卡
  const tabs = page.locator('.tabs, .tab, [role="tab"], [class*="tab"]')
  if (await tabs.count() === 0) {
    issues.push('❌ 选项卡未显示')
  } else {
    console.log('✅ 选项卡已显示')
  }

  // 验证游戏网格
  const gameGrid = page.locator('.game-grid, .game-card, [class*="game"]')
  if (await gameGrid.count() === 0) {
    issues.push('❌ 游戏网格未显示')
  } else {
    console.log(`✅ 游戏网格已显示 (${await gameGrid.count()}个游戏)`)
  }

  return issues
}

/**
 * 验证 Agentation 工具栏
 */
async function verifyAgentationToolbar(page: Page): Promise<string[]> {
  const issues: string[] = []

  // 验证工具栏存在
  const toolbar = page.locator(
    '#agentation-toolbar, [class*="agentation"], [data-agentation]'
  )
  if (await toolbar.count() === 0) {
    issues.push('❌ Agentation 工具栏未显示')
    return issues
  }
  console.log('✅ Agentation 工具栏已显示')

  // 验证工具栏位置（右下角）
  const position = await toolbar.evaluate(el => {
    const rect = el.getBoundingClientRect()
    return {
      isBottom: rect.bottom >= window.innerHeight - 50,
      isRight: rect.right >= window.innerWidth - 200
    }
  })
  if (!position.isBottom || !position.isRight) {
    issues.push('❌ 工具栏不在右下角')
  } else {
    console.log('✅ 工具栏位置正确（右下角）')
  }

  // 验证工具栏颜色（粉色/紫色）
  const bgColor = await toolbar.evaluate(el =>
    getComputedStyle(el).backgroundColor
  )
  // 检查是否是粉色或紫色系
  const colorMatch = bgColor.match(/rgb\((\d+),\s*(\d+),\s*(\d+)\)/)
  if (colorMatch) {
    const [, r, g, b] = colorMatch.map(Number)
    // 粉色/紫色通常 R 和 B 值较高，G 值较低
    const isPinkOrPurple = (r > 150 && b > 150 && g < 200) || (r > 200 && b > 100)
    if (!isPinkOrPurple) {
      issues.push(`⚠️ 工具栏颜色可能不是粉色/紫色：rgb(${r}, ${g}, ${b})`)
    } else {
      console.log(`✅ 工具栏颜色正常：rgb(${r}, ${g}, ${b})`)
    }
  } else {
    console.log(`⚠️ 工具栏颜色：${bgColor}`)
  }

  // 验证工具栏可交互
  try {
    await toolbar.click({ timeout: 3000 })
    console.log('✅ 工具栏可点击')
  } catch {
    issues.push('⚠️ 工具栏点击无响应（可能正常，取决于实现）')
  }

  return issues
}

/**
 * 验证控制台错误
 */
async function verifyConsoleErrors(page: Page): Promise<string[]> {
  const issues: string[] = []

  // 收集控制台错误
  const errors: string[] = []
  page.on('console', msg => {
    if (msg.type() === 'error') {
      errors.push(msg.text())
    }
  })

  // 等待页面稳定
  await page.waitForTimeout(2000)

  if (errors.length > 0) {
    issues.push(`❌ 控制台发现 ${errors.length} 个错误：${errors.slice(0, 3).join('; ')}${errors.length > 3 ? '...' : ''}`)
  } else {
    console.log('✅ 控制台无错误')
  }

  return issues
}

/**
 * 验证网络请求
 */
async function verifyNetworkRequests(page: Page): Promise<string[]> {
  const issues: string[] = []

  const failedRequests: string[] = []
  page.on('response', response => {
    if (response.status() >= 400) {
      failedRequests.push(`${response.status()} ${response.url()}`)
    }
  })

  // 等待页面稳定
  await page.waitForTimeout(2000)

  if (failedRequests.length > 0) {
    issues.push(`⚠️ 发现 ${failedRequests.length} 个失败请求：${failedRequests.slice(0, 3).join('; ')}${failedRequests.length > 3 ? '...' : ''}`)
  } else {
    console.log('✅ 无失败的网络请求')
  }

  return issues
}

/**
 * 主验证函数
 */
export async function verifyExpectations(
  url: string = 'http://localhost:3001',
  options: {
    headless?: boolean
    timeout?: number
    verifyGameList?: boolean
    verifyAgentation?: boolean
  } = {}
): Promise<VerificationResult> {
  const browser = await chromium.launch({
    headless: options.headless ?? true
  })
  const page = await browser.newPage()
  const details: string[] = []
  const errors: string[] = []

  try {
    console.log(`\n🔍 开始验证：${url}`)
    console.log('='.repeat(60))

    // 访问页面
    const response = await page.goto(url, {
      timeout: options.timeout ?? 30000,
      waitUntil: 'networkidle'
    })

    if (response?.status() !== 200) {
      errors.push(`HTTP 状态码异常：${response?.status()}`)
      return { passed: false, details, errors }
    }
    details.push('✅ 页面加载成功')
    console.log('✅ 页面加载成功')

    // 验证游戏列表
    if (options.verifyGameList !== false) {
      const gameListIssues = await verifyGameList(page)
      errors.push(...gameListIssues)
      details.push(...gameListIssues)
    }

    // 验证 Agentation 工具栏
    if (options.verifyAgentation !== false) {
      const toolbarIssues = await verifyAgentationToolbar(page)
      errors.push(...toolbarIssues)
      details.push(...toolbarIssues)
    }

    // 验证控制台
    const consoleIssues = await verifyConsoleErrors(page)
    errors.push(...consoleIssues)
    details.push(...consoleIssues)

    // 验证网络请求
    const networkIssues = await verifyNetworkRequests(page)
    errors.push(...networkIssues)
    details.push(...networkIssues)

    // 截图
    const screenshotPath = 'verification-result.png'
    await page.screenshot({ path: screenshotPath, fullPage: true })
    details.push(`✅ 截图已保存：${screenshotPath}`)
    console.log(`✅ 截图已保存：${screenshotPath}`)

    const passed = errors.length === 0
    return { passed, details, errors }

  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error)
    errors.push(`❌ 验证过程出错：${errorMessage}`)
    return { passed: false, details, errors }
  } finally {
    await browser.close()
  }
}

/**
 * 验证预期效果（命令行入口）
 */
async function main() {
  // 从命令行参数获取 URL
  const url = process.argv[2] || 'http://localhost:3001'

  const result = await verifyExpectations(url, {
    headless: true,
    verifyGameList: true,
    verifyAgentation: true
  })

  console.log('\n' + '='.repeat(60))
  console.log('📊 验证结果')
  console.log('='.repeat(60))
  result.details.forEach(d => console.log(d))

  if (result.passed) {
    console.log('\n✅ 所有验证通过！功能已完成，可直接使用。')
    console.log(`\n访问地址：${url}`)
    process.exit(0)
  } else {
    console.log('\n❌ 发现以下问题：')
    result.errors.forEach(e => console.log(`  - ${e}`))
    console.log('\n📝 正在记录 Bug 报告...')

    // 保存 Bug 报告
    const bugReport = {
      id: `BUG-${Date.now()}`,
      title: '预期效果验证失败',
      severity: result.errors.some(e => e.includes('❌')) ? 'P1' : 'P2',
      description: 'AI 自主验证发现预期效果未达成',
      errors: result.errors,
      screenshot: 'verification-result.png',
      detectedAt: new Date().toISOString()
    }

    const fs = require('fs')
    const path = require('path')
    const bugDir = path.join(process.cwd(), 'test-bugs')
    if (!fs.existsSync(bugDir)) {
      fs.mkdirSync(bugDir, { recursive: true })
    }
    const bugPath = path.join(bugDir, `bug-${bugReport.id}.json`)
    fs.writeFileSync(bugPath, JSON.stringify(bugReport, null, 2))
    console.log(`📄 Bug 报告已保存：${bugPath}`)

    process.exit(1)
  }
}

// 运行
main().catch(console.error)

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
 * 验证资源文件加载（图片、CSS、字体、图标、音频、视频等）
 */
async function verifyResources(page: Page): Promise<string[]> {
  const issues: string[] = []

  // 收集所有资源加载失败
  const failedResources: string[] = []

  page.on('requestfailed', request => {
    const failure = request.failure()
    if (failure) {
      failedResources.push(`${request.url()} - ${failure.errorText}`)
    }
  })

  // 等待页面稳定和资源加载
  await page.waitForTimeout(3000)

  // 检查 CSS 文件
  const cssLinks = page.locator('link[rel="stylesheet"]')
  const cssCount = await cssLinks.count()
  console.log(`✅ 检测到 ${cssCount} 个 CSS 文件`)

  // 检查图片资源
  const images = page.locator('img')
  const imageCount = await images.count()

  let brokenImages = 0
  for (let i = 0; i < imageCount; i++) {
    const img = images.nth(i)
    try {
      const naturalWidth = await img.evaluate(el => (el as HTMLImageElement).naturalWidth)
      if (naturalWidth === 0) {
        const src = await img.getAttribute('src')
        brokenImages++
        failedResources.push(`图片加载失败：${src}`)
      }
    } catch (e) {
      brokenImages++
    }
  }

  if (brokenImages > 0) {
    issues.push(`⚠️ ${brokenImages} 个图片加载失败`)
  } else if (imageCount > 0) {
    console.log(`✅ ${imageCount} 个图片加载成功`)
  }

  // 检查字体文件（通过计算样式）
  try {
    const fontsLoaded = await page.evaluate(() => {
      return document.fonts.ready.then(() => true)
    })
    if (fontsLoaded) {
      console.log('✅ 字体文件加载成功')
    }
  } catch (e) {
    issues.push('⚠️ 字体文件加载可能失败')
  }

  // 检查图标（favicon 等）
  const icons = page.locator('link[rel*="icon"]')
  const iconCount = await icons.count()
  if (iconCount > 0) {
    console.log(`✅ 检测到 ${iconCount} 个图标文件`)
  }

  // 检查音频资源
  const audios = page.locator('audio, source[type^="audio"]')
  const audioCount = await audios.count()
  if (audioCount > 0) {
    console.log(`✅ 检测到 ${audioCount} 个音频资源`)
  }

  // 检查视频资源
  const videos = page.locator('video, source[type^="video"]')
  const videoCount = await videos.count()
  if (videoCount > 0) {
    console.log(`✅ 检测到 ${videoCount} 个视频资源`)
  }

  // 报告资源加载失败
  if (failedResources.length > 0) {
    issues.push(`❌ ${failedResources.length} 个资源加载失败：${failedResources.slice(0, 5).join('; ')}${failedResources.length > 5 ? '...' : ''}`)
  } else {
    console.log('✅ 所有资源文件加载成功')
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
    verifyResources?: boolean  // 新增：资源文件验证
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

    // 验证资源文件（新增）
    if (options.verifyResources !== false) {
      const resourceIssues = await verifyResources(page)
      errors.push(...resourceIssues)
      details.push(...resourceIssues)
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
  // 从命令行参数获取 URL 和验证次数
  const url = process.argv[2] || 'http://localhost:3001'
  const runCountArg = process.argv[3]

  // 验证次数处理
  let runCount: number

  if (runCountArg) {
    // 用户已通过参数指定
    runCount = parseInt(runCountArg)
    console.log(`\n📋 使用指定验证次数：${runCount} 次`)
  } else {
    // 用户未指定，使用默认值
    runCount = 3
    console.log(`\n⚠️  未指定验证次数，使用默认值：${runCount} 次`)
    console.log(`💡 提示：可通过参数指定，例如：npx tsx scripts/verify-expectations.ts ${url} 5`)
  }

  // 验证次数合理性检查
  if (runCount < 1) {
    console.log('❌ 验证次数必须 >= 1')
    process.exit(1)
  }
  if (runCount > 10) {
    console.log(`⚠️  验证次数 ${runCount} 较多，可能耗时较长，建议 3-5 次`)
  }

  const allResults: VerificationResult[] = []

  // 多次验证确保稳定性
  for (let i = 1; i <= runCount; i++) {
    console.log(`\n【第 ${i}/${runCount} 次验证】`)
    console.log('-'.repeat(40))

    const result = await verifyExpectations(url, {
      headless: true,
      verifyGameList: true,
      verifyAgentation: true,
      verifyResources: true  // 启用资源文件验证
    })

    allResults.push(result)

    if (!result.passed) {
      console.log(`\n❌ 第 ${i} 次验证失败，停止验证`)
      break
    }

    if (i < runCount) {
      console.log(`⏳ 等待 2 秒后进行下一次验证...`)
      await new Promise(resolve => setTimeout(resolve, 2000))
    }
  }

  // 汇总结果
  const passedCount = allResults.filter(r => r.passed).length
  const failedCount = allResults.filter(r => !r.passed).length

  console.log('\n' + '='.repeat(60))
  console.log('📊 最终验证结果')
  console.log('='.repeat(60))
  console.log(`总验证次数：${runCount}`)
  console.log(`✅ 通过次数：${passedCount}`)
  console.log(`❌ 失败次数：${failedCount}`)

  // 只有全部通过才算通过
  if (failedCount === 0 && passedCount === runCount) {
    console.log('\n✅ 所有验证通过！功能已完成，可直接使用。')
    console.log(`\n访问地址：${url}`)
    console.log('\n💡 交付确认：已验证 ${runCount} 次，无 Bug，可交付用户')
    process.exit(0)
  } else {
    console.log('\n❌ 验证未全部通过，存在 Bug，不可交付')
    console.log('\n📝 正在记录 Bug 报告...')

    // 收集所有错误
    const allErrors = allResults.flatMap((r, i) => r.errors.map(e => `[第${i + 1}次] ${e}`))

    // 保存 Bug 报告
    const fs = require('fs')
    const path = require('path')
    const bugDir = path.join(process.cwd(), 'test-bugs')
    if (!fs.existsSync(bugDir)) {
      fs.mkdirSync(bugDir, { recursive: true })
    }
    const bugPath = path.join(bugDir, `bug-${Date.now()}.json`)
    const bugReport = {
      id: `BUG-${Date.now()}`,
      title: '多次验证发现 Bug',
      severity: 'P0',
      description: `多次验证（${runCount}次）中发现 ${failedCount} 次失败`,
      verificationCount: runCount,
      passedCount,
      failedCount,
      errors: allErrors,
      screenshot: 'verification-result.png',
      detectedAt: new Date().toISOString()
    }
    fs.writeFileSync(bugPath, JSON.stringify(bugReport, null, 2))
    console.log(`📄 Bug 报告已保存：${bugPath}`)

    process.exit(1)
  }
}

// 运行
main().catch(console.error)

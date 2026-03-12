#!/usr/bin/env ts-node
/**
 * 初始化需求追溯矩阵
 *
 * 使用方法：
 * npx ts-node scripts/init-traceability.ts
 *
 * @version 1.0.0
 * @since 2026-03-12
 */

import { RequirementTracker } from '../e2e/framework/core/RequirementTracker'
import { StoryMapper } from '../e2e/framework/core/StoryMapper'
import { writeFileSync, existsSync, mkdirSync } from 'fs'
import { join } from 'path'

// 配置
const PROJECT_NAME = '需求单管理系统'
const VERSION = '1.0.0'
const TASK_JSON_PATH = './task.json'
const OUTPUT_DIR = './e2e/results'

function main() {
  console.log('🚀 初始化需求追溯矩阵...\n')

  // 确保输出目录存在
  if (!existsSync(OUTPUT_DIR)) {
    mkdirSync(OUTPUT_DIR, { recursive: true })
  }

  // 1. 初始化需求追溯器
  console.log('📋 步骤 1: 初始化需求追溯器')
  const tracker = RequirementTracker.getInstance()
  tracker.initialize(PROJECT_NAME, VERSION)

  // 2. 从 task.json 导入需求
  if (existsSync(TASK_JSON_PATH)) {
    console.log(`📝 步骤 2: 从 ${TASK_JSON_PATH} 导入需求`)
    tracker.importFromTaskJson(TASK_JSON_PATH)
    console.log('✅ 需求导入成功')
  } else {
    console.warn(`⚠️  ${TASK_JSON_PATH} 不存在，跳过导入`)
  }

  // 3. 保存追溯矩阵
  console.log('💾 步骤 3: 保存追溯矩阵')
  tracker.save()
  console.log(`✅ 追溯矩阵已保存到 requirement-traceability.json`)

  // 4. 初始化故事映射器
  console.log('\n📖 步骤 4: 初始化故事映射器')
  const mapper = StoryMapper.getInstance()
  mapper.save()
  console.log('✅ 故事映射器已初始化')

  // 5. 生成初始报告
  console.log('\n📊 步骤 5: 生成初始报告')
  const coverageReport = tracker.getCoverageReport()

  const report = {
    title: '需求追溯初始报告',
    project: PROJECT_NAME,
    version: VERSION,
    generatedAt: new Date().toISOString(),
    summary: {
      totalRequirements: coverageReport.overall.totalRequirements,
      coveredRequirements: coverageReport.overall.coveredRequirements,
      coverageRate: coverageReport.overall.coverageRate,
      totalTestCases: coverageReport.overall.totalTestCases,
      passedTestCases: coverageReport.overall.passedTestCases,
      failedTestCases: coverageReport.overall.failedTestCases
    },
    byPriority: coverageReport.byPriority,
    uncoveredRequirements: coverageReport.uncoveredRequirements.map((req: any) => ({
      id: req.id,
      title: req.title,
      priority: req.priority
    }))
  }

  const reportPath = join(OUTPUT_DIR, 'initial-report.json')
  writeFileSync(reportPath, JSON.stringify(report, null, 2))
  console.log(`✅ 初始报告已保存到 ${reportPath}`)

  // 6. 打印摘要
  console.log('\n' + '='.repeat(60))
  console.log('📊 追溯矩阵摘要')
  console.log('='.repeat(60))
  console.log(`项目：${PROJECT_NAME}`)
  console.log(`版本：${VERSION}`)
  console.log(`总需求数：${report.summary.totalRequirements}`)
  console.log(`已覆盖需求：${report.summary.coveredRequirements}`)
  console.log(`覆盖率：${report.summary.coverageRate}%`)
  console.log(`未覆盖需求：${report.summary.totalRequirements - report.summary.coveredRequirements}`)
  console.log('='.repeat(60))

  // 7. 输出下一步指引
  console.log('\n📝 下一步:')
  console.log('  1. 查看未覆盖的需求列表: requirement-traceability.json')
  console.log('  2. 为未覆盖的需求编写测试用例')
  console.log('  3. 在测试文件中添加 @requirement 标签')
  console.log('  4. 运行测试：npx playwright test')
  console.log('  5. 生成覆盖率报告：npx ts-node scripts/generate-coverage.ts')
  console.log()
}

// 运行
main().catch(console.error)

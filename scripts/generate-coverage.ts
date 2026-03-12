#!/usr/bin/env ts-node
/**
 * 生成测试覆盖率报告
 *
 * 使用方法：
 * npx ts-node scripts/generate-coverage.ts
 *
 * @version 1.0.0
 * @since 2026-03-12
 */

import { RequirementTracker } from '../e2e/framework/core/RequirementTracker'
import { CoverageGenerator } from '../e2e/framework/core/CoverageGenerator'
import { join } from 'path'

// 配置
const PROJECT_NAME = '需求单管理系统'
const VERSION = '1.0.0'
const TASK_JSON_PATH = './task.json'
const OUTPUT_DIR = './test-results/reports'

async function main() {
  console.log('🚀 生成测试覆盖率报告...\n')

  // 1. 初始化追溯器
  console.log('📋 步骤 1: 加载需求追溯矩阵')
  const tracker = RequirementTracker.getInstance()

  try {
    tracker.load()
    console.log('✅ 追溯矩阵加载成功')
  } catch (error) {
    console.error('❌ 追溯矩阵未初始化，请先运行：npx ts-node scripts/init-traceability.ts')
    process.exit(1)
  }

  // 2. 创建覆盖率生成器
  console.log('\n📊 步骤 2: 创建覆盖率生成器')
  const generator = new CoverageGenerator(tracker, {
    minRequirementCoverage: 80,
    minP0Coverage: 100,
    minP1Coverage: 90,
    minTestPassRate: 95,
    blocking: true
  })

  // 3. 生成覆盖率报告
  console.log('\n📈 步骤 3: 生成覆盖率报告')
  const report = generator.generate({
    project: PROJECT_NAME,
    version: VERSION,
    taskJsonPath: TASK_JSON_PATH,
    outputPath: join(OUTPUT_DIR, 'coverage-report.json')
  })

  console.log('✅ 覆盖率报告已生成')

  // 4. 生成 HTML 报告
  console.log('\n🎨 步骤 4: 生成 HTML 报告')
  const htmlPath = join(OUTPUT_DIR, 'coverage-report.html')
  generator.generateHtmlReport(report, htmlPath)
  console.log(`✅ HTML 报告已保存到 ${htmlPath}`)

  // 5. 检查质量门禁
  console.log('\n🚪 步骤 5: 检查质量门禁')
  const qualityGate = generator.checkQualityGate(report)

  if (qualityGate.passed) {
    console.log('✅ 质量门禁通过')
  } else {
    console.error('❌ 质量门禁失败')
    qualityGate.blockers.forEach(blocker => {
      console.error(`  - ${blocker}`)
    })
  }

  // 6. 打印摘要
  console.log('\n' + '='.repeat(60))
  console.log('📊 覆盖率报告摘要')
  console.log('='.repeat(60))
  console.log(`项目：${report.project}`)
  console.log(`版本：${report.version}`)
  console.log(`总需求数：${report.overall.totalRequirements}`)
  console.log(`已覆盖需求：${report.overall.coveredRequirements}`)
  console.log(`需求覆盖率：${report.overall.coverageRate}%`)
  console.log(`测试总数：${report.overall.totalTestCases}`)
  console.log(`通过测试：${report.overall.passedTestCases}`)
  console.log(`失败测试：${report.overall.failedTestCases}`)
  console.log(`测试通过率：${report.overall.passRate}%`)
  console.log(`质量门禁状态：${report.overall.qualityGateStatus === 'passed' ? '✅ 通过' : '❌ 失败'}`)
  console.log('='.repeat(60))

  // 7. 按优先级统计
  console.log('\n📊 按优先级覆盖率:')
  report.byPriority.forEach(p => {
    const icon = p.priority === 'P0' ? '🔴' : p.priority === 'P1' ? '🟠' : '🟡'
    console.log(`  ${icon} ${p.priority}: ${p.rate}% (测试通过率：${p.testPassRate}%)`)
  })

  // 8. 按阶段统计
  if (report.byPhase.length > 0) {
    console.log('\n📊 按阶段覆盖率:')
    report.byPhase.forEach(phase => {
      const icon = phase.status === 'passed' ? '✅' : phase.status === 'warning' ? '⚠️' : '❌'
      console.log(`  ${icon} ${phase.phase}: ${phase.coverageRate}%`)
    })
  }

  // 9. 未覆盖需求
  if (report.uncoveredRequirements.length > 0) {
    console.log(`\n⚠️  未覆盖的需求 (${report.uncoveredRequirements.length}):`)
    report.uncoveredRequirements.slice(0, 10).forEach(req => {
      console.log(`  - ${req.id}: ${req.title} [${req.priority}]`)
    })
    if (report.uncoveredRequirements.length > 10) {
      console.log(`  ... 还有 ${report.uncoveredRequirements.length - 10} 个未覆盖需求`)
    }
  }

  console.log()

  // 10. 退出码
  if (!qualityGate.passed) {
    process.exit(1)
  }
}

// 运行
main().catch(console.error)

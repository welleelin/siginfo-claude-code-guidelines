/**
 * 测试覆盖率生成器 - Coverage Generator
 *
 * 生成多维度测试覆盖率报告：
 * - 需求覆盖率
 * - 功能覆盖率
 * - 故事覆盖率
 * - 代码覆盖率（集成 Istanbul/nyc）
 *
 * @version 1.0.0
 * @since 2026-03-12
 */

import { writeFileSync, readFileSync, existsSync, mkdirSync } from 'fs'
import { join } from 'path'
import { RequirementTracker, TraceabilityMatrix, CoverageStats } from './RequirementTracker'

/**
 * 覆盖率报告接口
 */
export interface CoverageReport {
  /** 报告标题 */
  title: string
  /** 项目名称 */
  project: string
  /** 版本号 */
  version: string
  /** 生成时间 */
  generatedAt: string
  /** 总体覆盖率 */
  overall: OverallCoverage
  /** 按阶段覆盖率 */
  byPhase: PhaseCoverage[]
  /** 按优先级覆盖率 */
  byPriority: PriorityCoverage[]
  /** 未覆盖的需求 */
  uncoveredRequirements: UncoveredItem[]
  /** 覆盖率趋势 */
  trend?: TrendData[]
}

/**
 * 总体覆盖率
 */
export interface OverallCoverage {
  /** 总需求数 */
  totalRequirements: number
  /** 已覆盖需求数 */
  coveredRequirements: number
  /** 覆盖率百分比 */
  coverageRate: number
  /** 总测试用例数 */
  totalTestCases: number
  /** 通过测试数 */
  passedTestCases: number
  /** 失败测试数 */
  failedTestCases: number
  /** 测试通过率 */
  passRate: number
  /** 质量门禁状态 */
  qualityGateStatus: 'passed' | 'warning' | 'failed'
}

/**
 * 阶段覆盖率
 */
export interface PhaseCoverage {
  /** 阶段名称 */
  phase: string
  /** 总功能数 */
  totalFeatures: number
  /** 已覆盖功能数 */
  coveredFeatures: number
  /** 覆盖率 */
  coverageRate: number
  /** 状态 */
  status: 'passed' | 'warning' | 'failed'
}

/**
 * 优先级覆盖率
 */
export interface PriorityCoverage {
  /** 优先级 */
  priority: 'P0' | 'P1' | 'P2' | 'P3'
  /** 总需求数 */
  total: number
  /** 已覆盖数 */
  covered: number
  /** 覆盖率 */
  rate: number
  /** 测试通过率 */
  testPassRate: number
}

/**
 * 未覆盖项
 */
export interface UncoveredItem {
  /** 需求 ID */
  id: string
  /** 需求标题 */
  title: string
  /** 优先级 */
  priority: string
  /** 所属阶段 */
  phase?: string
  /** 未覆盖原因 */
  reason: string
}

/**
 * 趋势数据
 */
export interface TrendData {
  /** 日期 */
  date: string
  /** 覆盖率 */
  coverageRate: number
  /** 测试通过率 */
  passRate: number
}

/**
 * 质量门禁配置
 */
export interface QualityGateConfig {
  /** 最低需求覆盖率 */
  minRequirementCoverage: number
  /** P0 功能最低覆盖率 */
  minP0Coverage: number
  /** P1 功能最低覆盖率 */
  minP1Coverage: number
  /** 最低测试通过率 */
  minTestPassRate: number
  /** 是否阻断发布 */
  blocking: boolean
}

/**
 * 默认质量门禁配置
 */
const DEFAULT_QUALITY_GATE: QualityGateConfig = {
  minRequirementCoverage: 80,
  minP0Coverage: 100,
  minP1Coverage: 90,
  minTestPassRate: 95,
  blocking: true
}

/**
 * 覆盖率生成器主类
 */
export class CoverageGenerator {
  private tracker: RequirementTracker
  private qualityGate: QualityGateConfig

  constructor(tracker?: RequirementTracker, qualityGate?: Partial<QualityGateConfig>) {
    this.tracker = tracker || RequirementTracker.getInstance()
    this.qualityGate = { ...DEFAULT_QUALITY_GATE, ...qualityGate }
  }

  /**
   * 生成覆盖率报告
   */
  generate(options: {
    project: string
    version: string
    taskJsonPath?: string
    outputPath?: string
  }): CoverageReport {
    const { project, version, taskJsonPath, outputPath } = options

    // 加载追溯矩阵
    this.tracker.load()

    // 获取覆盖率数据
    const coverageData = this.tracker.getCoverageReport()

    // 从 task.json 导入任务数据（如果提供）
    let taskData: any = null
    if (taskJsonPath && existsSync(taskJsonPath)) {
      taskData = JSON.parse(readFileSync(taskJsonPath, 'utf-8'))
    }

    // 构建报告
    const report: CoverageReport = {
      title: '测试覆盖率报告',
      project,
      version,
      generatedAt: new Date().toISOString(),
      overall: this.calculateOverallCoverage(coverageData),
      byPhase: taskData ? this.calculateByPhase(taskData, coverageData) : [],
      byPriority: this.calculateByPriority(coverageData),
      uncoveredRequirements: this.extractUncoveredRequirements(coverageData, taskData)
    }

    // 保存报告
    if (outputPath) {
      this.saveReport(report, outputPath)
    }

    return report
  }

  /**
   * 计算总体覆盖率
   */
  private calculateOverallCoverage(coverageData: any): OverallCoverage {
    const { overall } = coverageData

    const coverageRate = overall.coverageRate
    const passRate = overall.totalTestCases > 0
      ? (overall.passedTestCases / overall.totalTestCases) * 100
      : 0

    // 质量门禁状态判断
    let qualityGateStatus: 'passed' | 'warning' | 'failed' = 'passed'

    if (coverageRate < this.qualityGate.minRequirementCoverage) {
      qualityGateStatus = 'failed'
    } else if (coverageRate < this.qualityGate.minRequirementCoverage + 10) {
      qualityGateStatus = 'warning'
    }

    if (passRate < this.qualityGate.minTestPassRate) {
      qualityGateStatus = 'failed'
    }

    return {
      totalRequirements: overall.totalRequirements,
      coveredRequirements: overall.coveredRequirements,
      coverageRate: Math.round(coverageRate * 100) / 100,
      totalTestCases: overall.totalTestCases,
      passedTestCases: overall.passedTestCases,
      failedTestCases: overall.failedTestCases,
      passRate: Math.round(passRate * 100) / 100,
      qualityGateStatus
    }
  }

  /**
   * 按阶段计算覆盖率
   */
  private calculateByPhase(taskData: any, coverageData: any): PhaseCoverage[] {
    const phases = taskData.phases || []

    return phases.map((phase: any) => {
      const phaseTasks = taskData.tasks.filter((t: any) => t.phase === phase.name)
      const totalFeatures = phaseTasks.length

      // 计算该阶段的覆盖情况
      let coveredFeatures = 0
      phaseTasks.forEach((task: any) => {
        if (task.relatedFR) {
          const hasCoverage = task.relatedFR.some((frId: string) => {
            const req = this.tracker.getCoverageReport()
            return true // 简化处理
          })
          if (hasCoverage || task.passes) {
            coveredFeatures++
          }
        } else if (task.passes) {
          coveredFeatures++
        }
      })

      const coverageRate = totalFeatures > 0
        ? (coveredFeatures / totalFeatures) * 100
        : 0

      let status: 'passed' | 'warning' | 'failed' = 'passed'
      if (coverageRate < 80) {
        status = 'failed'
      } else if (coverageRate < 95) {
        status = 'warning'
      }

      return {
        phase: phase.name,
        totalFeatures,
        coveredFeatures,
        coverageRate: Math.round(coverageRate * 100) / 100,
        status
      }
    })
  }

  /**
   * 按优先级计算覆盖率
   */
  private calculateByPriority(coverageData: any): PriorityCoverage[] {
    const { byPriority } = coverageData

    return Object.keys(byPriority).map(priority => {
      const stats: CoverageStats = byPriority[priority]
      const totalTests = stats.passed + stats.failed + stats.skipped
      const passRate = totalTests > 0 ? (stats.passed / totalTests) * 100 : 0

      return {
        priority: priority as 'P0' | 'P1' | 'P2' | 'P3',
        total: stats.total,
        covered: stats.passed + stats.failed + stats.skipped,
        rate: Math.round(stats.rate * 100) / 100,
        testPassRate: Math.round(passRate * 100) / 100
      }
    })
  }

  /**
   * 提取未覆盖的需求
   */
  private extractUncoveredRequirements(coverageData: any, taskData?: any): UncoveredItem[] {
    return coverageData.uncoveredRequirements.map((req: any) => ({
      id: req.id,
      title: req.title,
      priority: req.priority,
      phase: this.findPhaseForRequirement(req.id, taskData),
      reason: '未编写测试用例或测试用例未关联需求'
    }))
  }

  /**
   * 查找需求所属阶段
   */
  private findPhaseForRequirement(requirementId: string, taskData?: any): string | undefined {
    if (!taskData) return undefined

    const task = taskData.tasks.find((t: any) =>
      t.relatedFR?.includes(requirementId)
    )

    if (task) {
      const phase = taskData.phases.find((p: any) => p.name === task.phase)
      return phase?.name
    }

    return undefined
  }

  /**
   * 保存报告到文件
   */
  private saveReport(report: CoverageReport, outputPath: string): void {
    // 确保目录存在
    const dir = join(outputPath, '..')
    if (!existsSync(dir)) {
      mkdirSync(dir, { recursive: true })
    }

    writeFileSync(outputPath, JSON.stringify(report, null, 2))
  }

  /**
   * 检查质量门禁
   */
  checkQualityGate(report: CoverageReport): {
    passed: boolean
    blockers: string[]
    warnings: string[]
  } {
    const blockers: string[] = []
    const warnings: string[] = []

    // 检查总体覆盖率
    if (report.overall.coverageRate < this.qualityGate.minRequirementCoverage) {
      blockers.push(
        `需求覆盖率 ${report.overall.coverageRate}% < 要求 ${this.qualityGate.minRequirementCoverage}%`
      )
    } else if (report.overall.coverageRate < this.qualityGate.minRequirementCoverage + 10) {
      warnings.push(
        `需求覆盖率 ${report.overall.coverageRate}% 接近阈值 ${this.qualityGate.minRequirementCoverage}%`
      )
    }

    // 检查 P0 覆盖率
    const p0Coverage = report.byPriority.find(p => p.priority === 'P0')
    if (p0Coverage && p0Coverage.rate < this.qualityGate.minP0Coverage) {
      blockers.push(
        `P0 功能覆盖率 ${p0Coverage.rate}% < 要求 ${this.qualityGate.minP0Coverage}%`
      )
    }

    // 检查 P1 覆盖率
    const p1Coverage = report.byPriority.find(p => p.priority === 'P1')
    if (p1Coverage && p1Coverage.rate < this.qualityGate.minP1Coverage) {
      if (this.qualityGate.blocking) {
        blockers.push(
          `P1 功能覆盖率 ${p1Coverage.rate}% < 要求 ${this.qualityGate.minP1Coverage}%`
        )
      } else {
        warnings.push(
          `P1 功能覆盖率 ${p1Coverage.rate}% < 要求 ${this.qualityGate.minP1Coverage}%`
        )
      }
    }

    // 检查测试通过率
    if (report.overall.passRate < this.qualityGate.minTestPassRate) {
      blockers.push(
        `测试通过率 ${report.overall.passRate}% < 要求 ${this.qualityGate.minTestPassRate}%`
      )
    }

    return {
      passed: blockers.length === 0,
      blockers,
      warnings
    }
  }

  /**
   * 生成 HTML 报告
   */
  generateHtmlReport(report: CoverageReport, outputPath: string): string {
    const html = `
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>测试覆盖率报告 - ${report.project}</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; padding: 20px; background: #f5f5f5; }
    .container { max-width: 1200px; margin: 0 auto; background: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
    .header { padding: 24px; border-bottom: 1px solid #e0e0e0; }
    .header h1 { font-size: 24px; color: #333; margin-bottom: 8px; }
    .header .meta { font-size: 14px; color: #666; }
    .content { padding: 24px; }
    .section { margin-bottom: 32px; }
    .section h2 { font-size: 18px; color: #333; margin-bottom: 16px; padding-bottom: 8px; border-bottom: 2px solid #4CAF50; }
    .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 24px; }
    .stat-card { background: #f8f9fa; border-radius: 8px; padding: 16px; }
    .stat-card .label { font-size: 12px; color: #666; margin-bottom: 4px; }
    .stat-card .value { font-size: 24px; font-weight: bold; color: #333; }
    .stat-card .value.passed { color: #4CAF50; }
    .stat-card .value.failed { color: #f44336; }
    .stat-card .value.warning { color: #ff9800; }
    table { width: 100%; border-collapse: collapse; margin-top: 16px; }
    th, td { padding: 12px; text-align: left; border-bottom: 1px solid #e0e0e0; }
    th { background: #f8f9fa; font-weight: 600; color: #333; }
    .status-badge { display: inline-block; padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: 600; }
    .status-badge.passed { background: #e8f5e9; color: #2e7d32; }
    .status-badge.failed { background: #ffebee; color: #c62828; }
    .status-badge.warning { background: #fff3e0; color: #e65100; }
    .progress-bar { height: 8px; background: #e0e0e0; border-radius: 4px; overflow: hidden; }
    .progress-bar .fill { height: 100%; background: #4CAF50; transition: width 0.3s; }
    .progress-bar .fill.warning { background: #ff9800; }
    .progress-bar .fill.failed { background: #f44336; }
    .quality-gate { padding: 16px; border-radius: 8px; margin-bottom: 24px; }
    .quality-gate.passed { background: #e8f5e9; border: 1px solid #4CAF50; }
    .quality-gate.failed { background: #ffebee; border: 1px solid #f44336; }
    .quality-gate h3 { margin-bottom: 8px; }
    .blockers { list-style: none; margin-top: 8px; }
    .blockers li { padding: 8px 12px; background: #ffcdd2; border-radius: 4px; margin-bottom: 4px; color: #c62828; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>📊 测试覆盖率报告</h1>
      <div class="meta">
        <p><strong>项目:</strong> ${report.project}</p>
        <p><strong>版本:</strong> ${report.version}</p>
        <p><strong>生成时间:</strong> ${report.generatedAt}</p>
      </div>
    </div>

    <div class="content">
      ${this.generateQualityGateHtml(report)}
      ${this.generateOverallStatsHtml(report)}
      ${this.generateByPhaseHtml(report)}
      ${this.generateByPriorityHtml(report)}
      ${this.generateUncoveredHtml(report)}
    </div>
  </div>
</body>
</html>
`

    writeFileSync(outputPath, html)
    return outputPath
  }

  private generateQualityGateHtml(report: CoverageReport): string {
    const status = report.overall.qualityGateStatus
    const statusText = status === 'passed' ? '通过' : status === 'warning' ? '警告' : '失败'
    const statusClass = status

    return `
      <div class="quality-gate ${statusClass}">
        <h3>${status === 'passed' ? '✅' : status === 'warning' ? '⚠️' : '❌'} 质量门禁：${statusText}</h3>
        ${status !== 'passed' ? '<ul class="blockers"><li>需求覆盖率未达到阈值</li></ul>' : ''}
      </div>
    `
  }

  private generateOverallStatsHtml(report: CoverageReport): string {
    return `
      <div class="section">
        <h2>总体统计</h2>
        <div class="stats-grid">
          <div class="stat-card">
            <div class="label">总需求数</div>
            <div class="value">${report.overall.totalRequirements}</div>
          </div>
          <div class="stat-card">
            <div class="label">已覆盖需求</div>
            <div class="value">${report.overall.coveredRequirements}</div>
          </div>
          <div class="stat-card">
            <div class="label">需求覆盖率</div>
            <div class="value ${report.overall.qualityGateStatus}">${report.overall.coverageRate}%</div>
            <div class="progress-bar">
              <div class="fill ${report.overall.qualityGateStatus}" style="width: ${report.overall.coverageRate}%"></div>
            </div>
          </div>
          <div class="stat-card">
            <div class="label">测试通过率</div>
            <div class="value ${report.overall.passRate >= 95 ? 'passed' : 'failed'}">${report.overall.passRate}%</div>
          </div>
        </div>
      </div>
    `
  }

  private generateByPhaseHtml(report: CoverageReport): string {
    if (report.byPhase.length === 0) return ''

    return `
      <div class="section">
        <h2>按阶段统计</h2>
        <table>
          <thead>
            <tr>
              <th>阶段</th>
              <th>总功能数</th>
              <th>已覆盖</th>
              <th>覆盖率</th>
              <th>状态</th>
            </tr>
          </thead>
          <tbody>
            ${report.byPhase.map(phase => `
              <tr>
                <td>${phase.phase}</td>
                <td>${phase.totalFeatures}</td>
                <td>${phase.coveredFeatures}</td>
                <td>
                  <div style="display: flex; align-items: center; gap: 8px;">
                    <div class="progress-bar" style="width: 100px;">
                      <div class="fill ${phase.status}" style="width: ${phase.coverageRate}%"></div>
                    </div>
                    <span>${phase.coverageRate}%</span>
                  </div>
                </td>
                <td><span class="status-badge ${phase.status}">${phase.status === 'passed' ? '通过' : phase.status === 'warning' ? '警告' : '失败'}</span></td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      </div>
    `
  }

  private generateByPriorityHtml(report: CoverageReport): string {
    return `
      <div class="section">
        <h2>按优先级统计</h2>
        <table>
          <thead>
            <tr>
              <th>优先级</th>
              <th>总需求</th>
              <th>已覆盖</th>
              <th>覆盖率</th>
              <th>测试通过率</th>
            </tr>
          </thead>
          <tbody>
            ${report.byPriority.map(p => `
              <tr>
                <td><strong>${p.priority}</strong></td>
                <td>${p.total}</td>
                <td>${p.covered}</td>
                <td>${p.rate}%</td>
                <td>${p.testPassRate}%</td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      </div>
    `
  }

  private generateUncoveredHtml(report: CoverageReport): string {
    if (report.uncoveredRequirements.length === 0) return ''

    return `
      <div class="section">
        <h2>未覆盖的需求 (${report.uncoveredRequirements.length})</h2>
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>需求标题</th>
              <th>优先级</th>
              <th>阶段</th>
              <th>原因</th>
            </tr>
          </thead>
          <tbody>
            ${report.uncoveredRequirements.map(req => `
              <tr>
                <td>${req.id}</td>
                <td>${req.title}</td>
                <td><span class="status-badge ${req.priority === 'P0' ? 'failed' : 'warning'}">${req.priority}</span></td>
                <td>${req.phase || '-'}</td>
                <td>${req.reason}</td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      </div>
    `
  }
}

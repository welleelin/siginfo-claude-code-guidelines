/**
 * 需求追溯器 - Requirement Tracker
 *
 * 实现测试用例与 PRD 需求的双向追溯
 * 支持：测试→需求、需求→测试 的正反向查询
 * 生成：需求覆盖率报告、测试完整性报告
 *
 * @version 1.0.0
 * @since 2026-03-12
 */

import { writeFileSync, readFileSync, existsSync, mkdirSync } from 'fs'
import { join } from 'path'

/**
 * 需求接口
 */
export interface Requirement {
  /** 需求 ID（如：FR1, FR26） */
  id: string
  /** 需求标题 */
  title: string
  /** 需求来源文档 */
  source: string
  /** 优先级 */
  priority: 'P0' | 'P1' | 'P2' | 'P3'
  /** 需求状态 */
  status: 'pending' | 'implemented' | 'testing' | 'verified' | 'rejected'
  /** 关联的测试用例 */
  testCases: TestCaseLink[]
  /** 覆盖率统计 */
  coverage?: CoverageStats
  /** 验收标准 */
  acceptanceCriteria?: AcceptanceCriteria[]
}

/**
 * 测试用例链接
 */
export interface TestCaseLink {
  /** 测试用例 ID */
  testCaseId: string
  /** 测试文件路径 */
  testFile: string
  /** 测试标题 */
  testTitle: string
  /** 测试状态 */
  status: 'passed' | 'failed' | 'skipped' | 'pending'
  /** 最后运行时间 */
  lastRun?: string
  /** 关联的验收标准 */
  acceptanceCriteria?: string[]
}

/**
 * 验收标准
 */
export interface AcceptanceCriteria {
  /** 验收标准 ID（如：AC1, AC2） */
  id: string
  /** 验收标准描述 */
  description: string
  /** 是否通过 */
  passed: boolean
}

/**
 * 覆盖率统计
 */
export interface CoverageStats {
  total: number
  passed: number
  failed: number
  skipped: number
  rate: number
}

/**
 * 追溯矩阵接口
 */
export interface TraceabilityMatrix {
  /** 项目名称 */
  project: string
  /** 版本号 */
  version: string
  /** 生成时间 */
  generatedAt: string
  /** 需求列表 */
  requirements: Requirement[]
  /** 汇总统计 */
  summary: SummaryStats
  /** 用户故事映射 */
  stories?: StoryMapping[]
}

/**
 * 汇总统计
 */
export interface SummaryStats {
  /** 总需求数 */
  totalRequirements: number
  /** 已覆盖需求数 */
  coveredRequirements: number
  /** 覆盖率 */
  coverageRate: number
  /** 总测试用例数 */
  totalTestCases: number
  /** 通过测试数 */
  passedTestCases: number
  /** 失败测试数 */
  failedTestCases: number
  /** 跳过测试数 */
  skippedTestCases: number
}

/**
 * 用户故事映射
 */
export interface StoryMapping {
  /** 故事 ID */
  id: string
  /** 故事标题 */
  title: string
  /** 作为... */
  asA: string
  /** 我希望... */
  iWantTo: string
  /** 以便... */
  soThat: string
  /** 关联的需求 ID */
  requirementIds: string[]
  /** 关联的测试用例 */
  testCases: TestCaseLink[]
  /** 验收标准 */
  acceptanceCriteria: StoryAcceptanceCriteria[]
}

/**
 * 故事验收标准
 */
export interface StoryAcceptanceCriteria {
  id: string
  description: string
  passed: boolean
  testResult?: string
}

/**
 * 需求追溯器单例类
 */
export class RequirementTracker {
  private static instance: RequirementTracker | null = null
  private matrix: TraceabilityMatrix | null = null
  private matrixPath: string

  private constructor(matrixPath?: string) {
    this.matrixPath = matrixPath || 'requirement-traceability.json'
  }

  /**
   * 获取单例实例
   */
  static getInstance(matrixPath?: string): RequirementTracker {
    if (!RequirementTracker.instance) {
      RequirementTracker.instance = new RequirementTracker(matrixPath)
    }
    return RequirementTracker.instance
  }

  /**
   * 初始化或加载追溯矩阵
   */
  initialize(project: string, version: string): void {
    if (existsSync(this.matrixPath)) {
      this.load()
    } else {
      this.matrix = {
        project,
        version,
        generatedAt: new Date().toISOString(),
        requirements: [],
        summary: {
          totalRequirements: 0,
          coveredRequirements: 0,
          coverageRate: 0,
          totalTestCases: 0,
          passedTestCases: 0,
          failedTestCases: 0,
          skippedTestCases: 0
        }
      }
    }
  }

  /**
   * 从文件加载追溯矩阵
   */
  load(): void {
    if (!existsSync(this.matrixPath)) {
      throw new Error(`追溯矩阵文件不存在：${this.matrixPath}`)
    }

    const content = readFileSync(this.matrixPath, 'utf-8')
    this.matrix = JSON.parse(content)
  }

  /**
   * 保存追溯矩阵到文件
   */
  save(): void {
    if (!this.matrix) {
      throw new Error('追溯矩阵未初始化')
    }

    // 更新汇总统计
    this.updateSummary()

    // 更新生成时间
    this.matrix.generatedAt = new Date().toISOString()

    // 确保目录存在
    const dir = join(this.matrixPath, '..')
    if (!existsSync(dir)) {
      mkdirSync(dir, { recursive: true })
    }

    writeFileSync(this.matrixPath, JSON.stringify(this.matrix, null, 2))
  }

  /**
   * 注册需求
   */
  registerRequirement(requirement: Partial<Requirement>): Requirement {
    if (!this.matrix) {
      throw new Error('追溯矩阵未初始化')
    }

    if (!requirement.id) {
      throw new Error('需求 ID 是必需的')
    }

    // 检查是否已存在
    const existing = this.matrix.requirements.find(r => r.id === requirement.id)

    if (existing) {
      // 更新现有需求
      Object.assign(existing, requirement)
      return existing
    } else {
      // 创建新需求
      const newReq: Requirement = {
        id: requirement.id!,
        title: requirement.title || '',
        source: requirement.source || 'PRD.md',
        priority: requirement.priority || 'P2',
        status: requirement.status || 'pending',
        testCases: requirement.testCases || [],
        acceptanceCriteria: requirement.acceptanceCriteria || [],
        coverage: requirement.coverage || {
          total: 0,
          passed: 0,
          failed: 0,
          skipped: 0,
          rate: 0
        }
      }

      this.matrix.requirements.push(newReq)
      return newReq
    }
  }

  /**
   * 批量注册需求（从 task.json 导入）
   */
  importFromTaskJson(taskJsonPath: string): void {
    if (!existsSync(taskJsonPath)) {
      throw new Error(`task.json 文件不存在：${taskJsonPath}`)
    }

    const content = readFileSync(taskJsonPath, 'utf-8')
    const taskData = JSON.parse(content)

    // 从任务中提取需求
    taskData.tasks?.forEach((task: any) => {
      if (task.relatedFR && Array.isArray(task.relatedFR)) {
        task.relatedFR.forEach((frId: string) => {
          this.registerRequirement({
            id: frId,
            title: task.title,
            source: 'task.json',
            priority: task.priority,
            status: task.passes ? 'verified' : 'testing'
          })
        })
      }
    })
  }

  /**
   * 注册测试用例到需求
   */
  linkTestCaseToRequirement(
    requirementId: string,
    testCase: Omit<TestCaseLink, 'status' | 'lastRun'>
  ): void {
    if (!this.matrix) {
      throw new Error('追溯矩阵未初始化')
    }

    const requirement = this.matrix.requirements.find(r => r.id === requirementId)
    if (!requirement) {
      throw new Error(`需求不存在：${requirementId}`)
    }

    // 检查测试用例是否已存在
    const existing = requirement.testCases.find(tc => tc.testCaseId === testCase.testCaseId)

    if (existing) {
      Object.assign(existing, testCase)
    } else {
      requirement.testCases.push({
        ...testCase,
        status: 'pending',
        lastRun: undefined
      })
    }
  }

  /**
   * 报告测试结果
   */
  reportTestResult(
    requirementId: string,
    testCaseId: string,
    result: {
      status: 'passed' | 'failed' | 'skipped'
      acceptanceCriteria?: { id: string; passed: boolean }[]
    }
  ): void {
    if (!this.matrix) {
      throw new Error('追溯矩阵未初始化')
    }

    const requirement = this.matrix.requirements.find(r => r.id === requirementId)
    if (!requirement) {
      throw new Error(`需求不存在：${requirementId}`)
    }

    const testCase = requirement.testCases.find(tc => tc.testCaseId === testCaseId)
    if (!testCase) {
      throw new Error(`测试用例不存在：${testCaseId}`)
    }

    // 更新测试状态
    testCase.status = result.status
    testCase.lastRun = new Date().toISOString()

    // 更新验收标准状态
    if (result.acceptanceCriteria && requirement.acceptanceCriteria) {
      result.acceptanceCriteria.forEach(acResult => {
        const ac = requirement.acceptanceCriteria!.find(ac => ac.id === acResult.id)
        if (ac) {
          ac.passed = acResult.passed
        }
      })
    }

    // 更新覆盖率统计
    this.updateCoverageStats(requirement)
  }

  /**
   * 更新需求覆盖率统计
   */
  private updateCoverageStats(requirement: Requirement): void {
    const total = requirement.testCases.length
    const passed = requirement.testCases.filter(tc => tc.status === 'passed').length
    const failed = requirement.testCases.filter(tc => tc.status === 'failed').length
    const skipped = requirement.testCases.filter(tc => tc.status === 'skipped').length

    requirement.coverage = {
      total,
      passed,
      failed,
      skipped,
      rate: total > 0 ? (passed / total) * 100 : 0
    }
  }

  /**
   * 更新汇总统计
   */
  private updateSummary(): void {
    if (!this.matrix) {
      throw new Error('追溯矩阵未初始化')
    }

    const requirements = this.matrix.requirements
    const coveredRequirements = requirements.filter(r => r.testCases.length > 0).length

    let totalTestCases = 0
    let passedTestCases = 0
    let failedTestCases = 0
    let skippedTestCases = 0

    requirements.forEach(req => {
      req.testCases.forEach(tc => {
        totalTestCases++
        if (tc.status === 'passed') passedTestCases++
        if (tc.status === 'failed') failedTestCases++
        if (tc.status === 'skipped') skippedTestCases++
      })
    })

    this.matrix.summary = {
      totalRequirements: requirements.length,
      coveredRequirements,
      coverageRate: requirements.length > 0 ? (coveredRequirements / requirements.length) * 100 : 0,
      totalTestCases,
      passedTestCases,
      failedTestCases,
      skippedTestCases
    }
  }

  /**
   * 获取需求覆盖率报告
   */
  getCoverageReport(): {
    overall: SummaryStats
    byPriority: Record<string, CoverageStats>
    byStatus: Record<string, number>
    uncoveredRequirements: Requirement[]
  } {
    if (!this.matrix) {
      throw new Error('追溯矩阵未初始化')
    }

    const byPriority: Record<string, CoverageStats> = {}
    const byStatus: Record<string, number> = {}
    const uncoveredRequirements: Requirement[] = []

    // 按优先级分组
    this.matrix.requirements.forEach(req => {
      const priority = req.priority

      if (!byPriority[priority]) {
        byPriority[priority] = { total: 0, passed: 0, failed: 0, skipped: 0, rate: 0 }
      }

      const stats = byPriority[priority]
      stats.total++
      if (req.coverage) {
        stats.passed += req.coverage.passed
        stats.failed += req.coverage.failed
        stats.skipped += req.coverage.skipped
      }

      // 计算该优先级的覆盖率
      const totalTests = stats.passed + stats.failed + stats.skipped
      stats.rate = totalTests > 0 ? (stats.passed / totalTests) * 100 : 0

      // 未覆盖的需求
      if (!req.coverage || req.coverage.total === 0) {
        uncoveredRequirements.push(req)
      }

      // 按状态分组
      const status = req.status
      byStatus[status] = (byStatus[status] || 0) + 1
    })

    return {
      overall: this.matrix.summary,
      byPriority,
      byStatus,
      uncoveredRequirements
    }
  }

  /**
   * 查询需求关联的测试用例
   */
  getTestCasesForRequirement(requirementId: string): TestCaseLink[] {
    if (!this.matrix) {
      throw new Error('追溯矩阵未初始化')
    }

    const requirement = this.matrix.requirements.find(r => r.id === requirementId)
    if (!requirement) {
      throw new Error(`需求不存在：${requirementId}`)
    }

    return requirement.testCases
  }

  /**
   * 查询测试用例关联的需求
   */
  getRequirementsForTestCase(testCaseId: string): Requirement[] {
    if (!this.matrix) {
      throw new Error('追溯矩阵未初始化')
    }

    return this.matrix.requirements.filter(req =>
      req.testCases.some(tc => tc.testCaseId === testCaseId)
    )
  }

  /**
   * 注册用户故事
   */
  registerStory(story: Partial<StoryMapping>): StoryMapping {
    if (!this.matrix) {
      throw new Error('追溯矩阵未初始化')
    }

    if (!story.id) {
      throw new Error('故事 ID 是必需的')
    }

    // 检查 stories 数组是否存在
    if (!this.matrix.stories) {
      this.matrix.stories = []
    }

    // 检查是否已存在
    const existing = this.matrix.stories.find(s => s.id === story.id)

    if (existing) {
      Object.assign(existing, story)
      return existing
    } else {
      const newStory: StoryMapping = {
        id: story.id!,
        title: story.title || '',
        asA: story.asA || '',
        iWantTo: story.iWantTo || '',
        soThat: story.soThat || '',
        requirementIds: story.requirementIds || [],
        testCases: story.testCases || [],
        acceptanceCriteria: story.acceptanceCriteria || []
      }

      this.matrix.stories.push(newStory)
      return newStory
    }
  }

  /**
   * 生成追溯报告
   */
  generateReport(outputPath?: string): string {
    if (!this.matrix) {
      throw new Error('追溯矩阵未初始化')
    }

    const report = {
      title: '需求追溯报告',
      project: this.matrix.project,
      version: this.matrix.version,
      generatedAt: this.matrix.generatedAt,
      summary: this.matrix.summary,
      requirements: this.matrix.requirements.map(req => ({
        ...req,
        coverage: req.coverage
      })),
      stories: this.matrix.stories,
      coverageReport: this.getCoverageReport()
    }

    const reportPath = outputPath || 'test-results/reports/traceability-report.json'

    // 确保目录存在
    const dir = join(reportPath, '..')
    if (!existsSync(dir)) {
      mkdirSync(dir, { recursive: true })
    }

    writeFileSync(reportPath, JSON.stringify(report, null, 2))

    return reportPath
  }

  /**
   * 重置追溯矩阵
   */
  reset(): void {
    this.matrix = null
  }
}

/**
 * Playwright 测试注释解析器
 * 解析测试文件中的 @requirement 和 @story 标签
 */
export function parseTestAnnotations(testContent: string): {
  requirements: string[]
  stories: string[]
  acceptanceCriteria: string[]
} {
  const requirements: string[] = []
  const stories: string[] = []
  const acceptanceCriteria: string[] = []

  // 解析 @requirement 标签
  const reqMatches = testContent.matchAll(/@requirement\s+(\w+)/g)
  for (const match of reqMatches) {
    requirements.push(match[1])
  }

  // 解析 @story 标签
  const storyMatches = testContent.matchAll(/@story\s+([\w-]+)/g)
  for (const match of storyMatches) {
    stories.push(match[1])
  }

  // 解析 @acceptance 标签
  const acMatches = testContent.matchAll(/@acceptance\s+(\w+)/g)
  for (const match of acMatches) {
    acceptanceCriteria.push(match[1])
  }

  return { requirements, stories, acceptanceCriteria }
}

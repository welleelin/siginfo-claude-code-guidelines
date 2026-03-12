/**
 * 故事映射器 - Story Mapper
 *
 * 管理用户故事与测试用例的映射关系
 * 支持 BDD 风格的验收标准验证
 *
 * @version 1.0.0
 * @since 2026-03-12
 */

import { writeFileSync, existsSync, mkdirSync } from 'fs'
import { join } from 'path'

/**
 * 用户故事接口
 */
export interface UserStory {
  /** 故事 ID */
  id: string
  /** 故事标题 */
  title: string
  /** 作为... (角色) */
  asA: string
  /** 我希望... (功能) */
  iWantTo: string
  /** 以便... (价值) */
  soThat: string
  /** 关联的需求 ID 列表 */
  requirementIds: string[]
  /** 验收标准 */
  acceptanceCriteria: AcceptanceCriteria[]
  /** 关联的测试用例 */
  testCases: StoryTestCase[]
  /** 状态 */
  status: 'draft' | 'ready' | 'in-progress' | 'verified' | 'rejected'
}

/**
 * 验收标准接口
 */
export interface AcceptanceCriteria {
  /** 验收标准 ID */
  id: string
  /** 描述 */
  description: string
  /** BDD 格式：Given */
  given?: string
  /** BDD 格式：When */
  when?: string
  /** BDD 格式：Then */
  then?: string
  /** 测试用例 ID */
  testCaseId?: string
  /** 是否通过 */
  passed: boolean
  /** 测试结果 */
  testResult?: string
}

/**
 * 故事测试用例
 */
export interface StoryTestCase {
  /** 测试用例 ID */
  id: string
  /** 测试标题 */
  title: string
  /** 关联的验收标准 ID */
  acceptanceCriteriaId: string
  /** 测试文件路径 */
  testFile: string
  /** 测试状态 */
  status: 'passed' | 'failed' | 'skipped' | 'pending'
  /** 最后运行时间 */
  lastRun?: string
}

/**
 * 故事映射器单例类
 */
export class StoryMapper {
  private static instance: StoryMapper | null = null
  private stories: Map<string, UserStory> = new Map()
  private storiesPath: string

  private constructor(storiesPath?: string) {
    this.storiesPath = storiesPath || 'stories/stories.json'
  }

  /**
   * 获取单例实例
   */
  static getInstance(storiesPath?: string): StoryMapper {
    if (!StoryMapper.instance) {
      StoryMapper.instance = new StoryMapper(storiesPath)
    }
    return StoryMapper.instance
  }

  /**
   * 注册用户故事
   */
  registerStory(story: Partial<UserStory>): UserStory {
    if (!story.id) {
      throw new Error('故事 ID 是必需的')
    }

    const existing = this.stories.get(story.id)

    if (existing) {
      // 更新现有故事
      const updated = { ...existing, ...story }
      this.stories.set(story.id, updated)
      return updated
    } else {
      // 创建新故事
      const newStory: UserStory = {
        id: story.id!,
        title: story.title || '',
        asA: story.asA || '',
        iWantTo: story.iWantTo || '',
        soThat: story.soThat || '',
        requirementIds: story.requirementIds || [],
        acceptanceCriteria: story.acceptanceCriteria || [],
        testCases: story.testCases || [],
        status: story.status || 'draft'
      }

      this.stories.set(story.id, newStory)
      return newStory
    }
  }

  /**
   * 从 Markdown 文件导入用户故事
   */
  importFromMarkdown(markdownPath: string): UserStory[] {
    if (!existsSync(markdownPath)) {
      throw new Error(`Markdown 文件不存在：${markdownPath}`)
    }

    const fs = require('fs')
    const content = fs.readFileSync(markdownPath, 'utf-8')

    // 解析 Markdown 格式的故事
    const stories: UserStory[] = []
    const storyBlocks = content.split(/(?=^#\s)/m)

    storyBlocks.forEach((block: string) => {
      if (block.trim().startsWith('#')) {
        const story = this.parseStoryBlock(block)
        if (story) {
          stories.push(story)
          this.registerStory(story)
        }
      }
    })

    return stories
  }

  /**
   * 解析故事 Markdown 块
   */
  private parseStoryBlock(block: string): Partial<UserStory> | null {
    const lines = block.split('\n')
    const story: Partial<UserStory> = {}

    // 提取标题
    const titleMatch = lines[0]?.match(/^#\s+(.+)$/)
    if (titleMatch) {
      story.title = titleMatch[1].trim()
      // 从标题提取 ID
      const idMatch = story.title.match(/^(\w+-\d+):\s*(.+)$/)
      if (idMatch) {
        story.id = idMatch[1]
        story.title = idMatch[2]
      }
    }

    // 提取故事要素
    lines.forEach(line => {
      const trimmed = line.trim()

      if (trimmed.startsWith('作为')) {
        story.asA = trimmed.replace(/^作为\s*/, '')
      } else if (trimmed.startsWith('我希望')) {
        story.iWantTo = trimmed.replace(/^我希望\s*/, '')
      } else if (trimmed.startsWith('以便')) {
        story.soThat = trimmed.replace(/^以便\s*/, '')
      }
    })

    // 提取验收标准
    const acceptanceCriteria = this.parseAcceptanceCriteria(block)
    if (acceptanceCriteria.length > 0) {
      story.acceptanceCriteria = acceptanceCriteria
    }

    return story.id ? story : null
  }

  /**
   * 解析验收标准
   */
  private parseAcceptanceCriteria(block: string): AcceptanceCriteria[] {
    const criteria: AcceptanceCriteria[] = []
    const acBlocks = block.split(/(?=^##\s*AC\d+)/m)

    acBlocks.forEach((acBlock: string) => {
      if (acBlock.includes('AC')) {
        const lines = acBlock.split('\n')
        const ac: Partial<AcceptanceCriteria> = {}

        // 提取 AC ID 和描述
        const acMatch = lines.find(l => l.match(/^##\s*AC\d+/))
        if (acMatch) {
          const idMatch = acMatch.match(/(AC\d+)/)
          if (idMatch) {
            ac.id = idMatch[1]
            ac.description = acMatch.replace(/##\s*AC\d+:\s*/, '').trim()
          }
        }

        // 提取 BDD 要素
        acBlock.split('\n').forEach(line => {
          const trimmed = line.trim()
          if (trimmed.startsWith('Given')) {
            ac.given = trimmed
          } else if (trimmed.startsWith('When')) {
            ac.when = trimmed
          } else if (trimmed.startsWith('Then')) {
            ac.then = trimmed
          }
        })

        if (ac.id) {
          criteria.push({
            id: ac.id!,
            description: ac.description || '',
            given: ac.given,
            when: ac.when,
            then: ac.then,
            passed: false
          })
        }
      }
    })

    return criteria
  }

  /**
   * 关联测试用例到验收标准
   */
  linkTestCase(storyId: string, acId: string, testCase: Omit<StoryTestCase, 'id'>): void {
    const story = this.stories.get(storyId)
    if (!story) {
      throw new Error(`故事不存在：${storyId}`)
    }

    // 找到对应的验收标准
    const ac = story.acceptanceCriteria.find(c => c.id === acId)
    if (!ac) {
      throw new Error(`验收标准不存在：${acId}`)
    }

    // 创建测试用例
    const newTestCase: StoryTestCase = {
      ...testCase,
      id: `${storyId}-${acId}-test`
    }

    // 更新验收标准
    ac.testCaseId = newTestCase.id

    // 添加测试用例
    story.testCases.push(newTestCase)
    this.stories.set(storyId, story)
  }

  /**
   * 报告验收测试结果
   */
  reportAcceptanceResult(
    storyId: string,
    acId: string,
    result: {
      passed: boolean
      testResult?: string
    }
  ): void {
    const story = this.stories.get(storyId)
    if (!story) {
      throw new Error(`故事不存在：${storyId}`)
    }

    const ac = story.acceptanceCriteria.find(c => c.id === acId)
    if (!ac) {
      throw new Error(`验收标准不存在：${acId}`)
    }

    ac.passed = result.passed
    ac.testResult = result.testResult

    // 更新测试用例状态
    if (ac.testCaseId) {
      const testCase = story.testCases.find(tc => tc.id === ac.testCaseId)
      if (testCase) {
        testCase.status = result.passed ? 'passed' : 'failed'
        testCase.lastRun = new Date().toISOString()
      }
    }

    // 更新故事状态
    this.updateStoryStatus(story)

    this.stories.set(storyId, story)
  }

  /**
   * 更新故事状态
   */
  private updateStoryStatus(story: UserStory): void {
    const totalAC = story.acceptanceCriteria.length
    const passedAC = story.acceptanceCriteria.filter(ac => ac.passed).length

    if (passedAC === totalAC && totalAC > 0) {
      story.status = 'verified'
    } else if (passedAC > 0) {
      story.status = 'in-progress'
    } else {
      story.status = 'ready'
    }
  }

  /**
   * 获取故事详情
   */
  getStory(storyId: string): UserStory | undefined {
    return this.stories.get(storyId)
  }

  /**
   * 获取所有故事
   */
  getAllStories(): UserStory[] {
    return Array.from(this.stories.values())
  }

  /**
   * 生成故事地图报告
   */
  generateStoryMapReport(outputPath?: string): {
    totalStories: number
    byStatus: Record<string, number>
    totalAcceptanceCriteria: number
    passedAcceptanceCriteria: number
    stories: UserStory[]
  } {
    const stories = this.getAllStories()
    const byStatus: Record<string, number> = {}

    let totalAC = 0
    let passedAC = 0

    stories.forEach(story => {
      // 统计状态
      byStatus[story.status] = (byStatus[story.status] || 0) + 1

      // 统计验收标准
      totalAC += story.acceptanceCriteria.length
      passedAC += story.acceptanceCriteria.filter(ac => ac.passed).length
    })

    const report = {
      totalStories: stories.length,
      byStatus,
      totalAcceptanceCriteria: totalAC,
      passedAcceptanceCriteria: passedAC,
      acceptanceRate: totalAC > 0 ? (passedAC / totalAC) * 100 : 0,
      stories
    }

    if (outputPath) {
      // 确保目录存在
      const dir = join(outputPath, '..')
      if (!existsSync(dir)) {
        mkdirSync(dir, { recursive: true })
      }
      writeFileSync(outputPath, JSON.stringify(report, null, 2))
    }

    return report
  }

  /**
   * 保存故事到文件
   */
  save(): void {
    const report = this.generateStoryMapReport()

    // 确保目录存在
    const dir = join(this.storiesPath, '..')
    if (!existsSync(dir)) {
      mkdirSync(dir, { recursive: true })
    }

    writeFileSync(this.storiesPath, JSON.stringify(report, null, 2))
  }

  /**
   * 从文件加载故事
   */
  load(): void {
    if (!existsSync(this.storiesPath)) {
      throw new Error(`故事文件不存在：${this.storiesPath}`)
    }

    const fs = require('fs')
    const content = fs.readFileSync(this.storiesPath, 'utf-8')
    const data = JSON.parse(content)

    data.stories?.forEach((story: UserStory) => {
      this.stories.set(story.id, story)
    })
  }

  /**
   * 重置故事映射器
   */
  reset(): void {
    this.stories.clear()
  }
}

/**
 * BDD 风格的验收标准构建器
 */
export class AcceptanceCriteriaBuilder {
  private ac: Partial<AcceptanceCriteria> = {}

  id(id: string): this {
    this.ac.id = id
    return this
  }

  description(desc: string): this {
    this.ac.description = desc
    return this
  }

  given(given: string): this {
    this.ac.given = given
    return this
  }

  when(when: string): this {
    this.ac.when = when
    return this
  }

  then(then: string): this {
    this.ac.then = then
    return this
  }

  build(): AcceptanceCriteria {
    return {
      id: this.ac.id!,
      description: this.ac.description!,
      given: this.ac.given,
      when: this.ac.when,
      then: this.ac.then,
      passed: false
    }
  }
}

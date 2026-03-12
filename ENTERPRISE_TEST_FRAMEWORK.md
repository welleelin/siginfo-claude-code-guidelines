# Playwright 企业级测试框架设计

> **版本**：1.0.0
> **最后更新**：2026-03-12
> **状态**：核心规范
>
> **定位**：以 Playwright 为核心的企业级测试解决方案，实现 PRD→功能点→故事→测试的完整闭环

---

## 📋 概述

### 问题背景

传统测试框架存在以下核心问题：

| 问题 | 表现 | 后果 |
|------|------|------|
| **需求脱节** | 测试用例与 PRD 无关联 | 不知道测的是不是需求要求的 |
| **覆盖盲区** | 没有需求覆盖率统计 | 不知道哪些功能没测到 |
| **追溯断裂** | Bug 无法回溯到需求 | 修复后不知道影响哪些功能 |
| **验收主观** | 验收标准不量化 | 不同人验收结果不同 |
| **文档分离** | 测试文档与需求文档分离 | 维护成本高，容易过时 |

### 解决方案

**Playwright 企业级测试框架** = Playwright + 需求追溯 + 自动化验证 + 质量门禁

```
┌─────────────────────────────────────────────────────────────────┐
│                    Playwright 企业级测试框架                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  PRD 需求 ──▶ 功能点 ──▶ 用户故事 ──▶ 测试用例 ──▶ 验证报告   │
│    │           │           │           │           │            │
│    ▼           ▼           ▼           ▼           ▼            │
│  需求追溯    功能覆盖    故事映射    自动执行    质量门禁       │
│    │           │           │           │           │            │
│    └───────────────────────────────────────────────────┘        │
│                        闭环验证                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🏗️ 框架架构

### 整体架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                        企业级测试解决方案                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                    需求追溯层                                ││
│  │  ┌───────────┐  ┌───────────┐  ┌───────────┐               ││
│  │  │  PRD.md   │  │task.json  │  │ stories/  │               ││
│  │  │ 需求文档   │  │ 任务列表  │  │  用户故事  │               ││
│  │  └─────┬─────┘  └─────┬─────┘  └─────┬─────┘               ││
│  │        │              │              │                      ││
│  │        └──────────────┴──────────────┘                      ││
│  │                       │                                     ││
│  │                       ▼                                     ││
│  │              ┌─────────────────┐                            ││
│  │              │  需求追溯矩阵    │                            ││
│  │              │ requirement-traceability.json │              ││
│  │              └────────┬────────┘                            ││
│  └───────────────────────┼─────────────────────────────────────┘│
│                          │                                      │
│  ┌───────────────────────▼─────────────────────────────────────┐│
│  │                    测试设计层                                ││
│  │  ┌───────────┐  ┌───────────┐  ┌───────────┐               ││
│  │  │ 测试模板   │  │ Page Object │  │ 测试数据   │              ││
│  │  │templates/ │  │  pages/    │  │  data/     │              ││
│  │  └───────────┘  └───────────┘  └───────────┘               ││
│  └───────────────────────┬─────────────────────────────────────┘│
│                          │                                      │
│  ┌───────────────────────▼─────────────────────────────────────┐│
│  │                    执行引擎层                                ││
│  │  ┌───────────────────────────────────────────────────────┐  ││
│  │  │              Playwright Test Runner                    │  ││
│  │  │  ┌───────────┐  ┌───────────┐  ┌───────────┐          │  ││
│  │  │  │ 截图审查   │  │ Bug 上报   │  │ 视觉回归   │          │  ││
│  │  │  │ Validator │  │ Reporter  │  │  Baseline │          │  ││
│  │  │  └───────────┘  └───────────┘  └───────────┘          │  ││
│  │  └───────────────────────────────────────────────────────┘  ││
│  └───────────────────────┬─────────────────────────────────────┘│
│                          │                                      │
│  ┌───────────────────────▼─────────────────────────────────────┐│
│  │                    质量门禁层                                ││
│  │  ┌───────────┐  ┌───────────┐  ┌───────────┐               ││
│  │  │ 覆盖率报告 │  │ 需求覆盖率 │  │ 质量报告   │               ││
│  │  │ coverage/ │  │  trace/    │  │  report/   │               ││
│  │  └───────────┘  └───────────┘  └───────────┘               ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 核心能力

| 能力 | 说明 | 实现方式 |
|------|------|---------|
| **需求追溯** | 测试用例追溯到 PRD 功能点 | `@requirement` 标签 + 追溯矩阵 |
| **功能覆盖** | 统计需求覆盖率 | 覆盖率报告生成器 |
| **故事映射** | 用户故事映射到测试 | 故事 - 测试映射文件 |
| **自动验证** | 截图审查、Bug 上报 | ScreenshotValidator |
| **视觉回归** | UI 变化检测 | 基准图片对比 |
| **质量门禁** | 测试通过率门槛 | 质量报告 + 阻断机制 |
| **闭环验证** | 需求→测试→Bug→修复闭环 | 全链路追溯 |

---

## 📁 目录结构

```
project/
├── PRD/
│   ├── PRD.md                          # 产品需求文档
│   └── features/                       # 功能点分解
│       ├── feature-001-login.md
│       └── feature-002-demand.md
│
├── stories/
│   ├── user-stories.md                 # 用户故事集合
│   └── acceptance-criteria/            # 验收标准
│       ├── story-001.md
│       └── story-002.md
│
├── e2e/
│   ├── playwright.config.ts            # Playwright 配置
│   │
│   ├── framework/                      # 框架核心
│   │   ├── core/
│   │   │   ├── ScreenshotValidator.ts  # 截图审查器
│   │   │   ├── BugReporter.ts          # Bug 报告器
│   │   │   ├── RequirementTracker.ts   # 需求追溯器
│   │   │   └── CoverageGenerator.ts    # 覆盖率生成器
│   │   │
│   │   ├── pages/                      # Page Object
│   │   │   ├── LoginPage.ts
│   │   │   ├── DashboardPage.ts
│   │   │   └── DemandPage.ts
│   │   │
│   │   ├── data/                       # 测试数据
│   │   │   ├── users.ts
│   │   │   ├── demands.ts
│   │   │   └── generators.ts
│   │   │
│   │   └── templates/                  # 测试模板
│   │       ├── feature-test.template.ts
│   │       └── story-test.template.ts
│   │
│   ├── tests/                          # 测试用例
│   │   ├── features/                   # 按功能组织
│   │   │   ├── login.spec.ts
│   │   │   ├── demand.spec.ts
│   │   │   └── whitelist.spec.ts
│   │   │
│   │   ├── stories/                    # 按故事组织
│   │   │   ├── story-001.spec.ts
│   │   │   └── story-002.spec.ts
│   │   │
│   │   └── regression/                 # 回归测试
│   │       └── full-suite.spec.ts
│   │
│   ├── fixtures/                       # 测试夹具
│   │   ├── test-fixtures.ts
│   │   └── api-fixtures.ts
│   │
│   ├── helpers/                        # 辅助工具
│   │   ├── login-helper.ts
│   │   └── data-helper.ts
│   │
│   ├── reporters/                      # 报告器
│   │   ├── bug-reporter.ts
│   │   ├── coverage-reporter.ts
│   │   └── traceability-reporter.ts
│   │
│   └── results/                        # 测试结果
│       ├── screenshots/
│       ├── videos/
│       ├── traces/
│       └── reports/
│
├── requirement-traceability.json       # 需求追溯矩阵
├── test-coverage-report.json           # 测试覆盖率报告
└── quality-gate-report.json            # 质量门禁报告
```

---

## 🔗 需求追溯机制

### 追溯矩阵格式

```json
{
  "project": "需求单管理系统",
  "version": "1.0.0",
  "generatedAt": "2026-03-12T10:00:00Z",
  "requirements": [
    {
      "id": "FR1",
      "title": "用户登录认证",
      "source": "PRD.md",
      "priority": "P0",
      "status": "implemented",
      "testCases": [
        {
          "testCaseId": "login-001",
          "testFile": "e2e/tests/features/login.spec.ts",
          "testTitle": "登录页面正确显示",
          "status": "passed",
          "lastRun": "2026-03-12T09:00:00Z"
        },
        {
          "testCaseId": "login-002",
          "testFile": "e2e/tests/features/login.spec.ts",
          "testTitle": "admin 登录成功并跳转首页",
          "status": "passed",
          "lastRun": "2026-03-12T09:00:00Z"
        }
      ],
      "coverage": {
        "total": 5,
        "passed": 5,
        "failed": 0,
        "rate": 100
      }
    }
  ],
  "summary": {
    "totalRequirements": 73,
    "coveredRequirements": 15,
    "coverageRate": 20.5,
    "totalTestCases": 156,
    "passedTestCases": 150,
    "failedTestCases": 6
  }
}
```

### 测试用例标注规范

```typescript
import { test, expect } from '@playwright/test'

/**
 * @requirement FR1 - 用户登录认证
 * @requirement FR26 - 角色权限管理
 * @story story-001 - 作为运营人员，我希望登录系统，以便开始工作
 * @acceptance AC1 - 用户名密码正确时登录成功
 * @acceptance AC2 - 用户名或密码错误时显示错误提示
 */
test.describe('登录功能', () => {
  test('登录页面正确显示', async ({ page }) => {
    // 测试代码
  })

  test('admin 登录成功并跳转首页', async ({ page }) => {
    // 测试代码
  })
})
```

---

## 🧪 测试设计模式

### 1. 功能测试模板

```typescript
// e2e/framework/templates/feature-test.template.ts
import { test, expect } from '@playwright/test'
import { RequirementTracker } from '../core/RequirementTracker'
import { ScreenshotValidator } from '../core/ScreenshotValidator'

interface FeatureTestConfig {
  featureId: string
  featureName: string
  requirements: string[]
  stories: string[]
}

export function createFeatureTest(config: FeatureTestConfig) {
  const tracker = RequirementTracker.getInstance()

  test.describe(config.featureName, () => {
    // 注册需求关联
    tracker.registerRequirements(config.requirements)

    test.beforeEach(async ({ page }) => {
      // 前置准备
    })

    test('核心流程验证', async ({ page }) => {
      const validator = new ScreenshotValidator(page)

      // 执行测试...

      // 验证并上报
      const result = await validator.validate()
      tracker.reportTestResult(config.requirements[0], result)
    })
  })
}
```

### 2. 故事测试模板

```typescript
// e2e/framework/templates/story-test.template.ts
import { test, expect } from '@playwright/test'
import { StoryMapper } from '../core/StoryMapper'

interface StoryTestConfig {
  storyId: string
  storyTitle: string
  asA: string       // 作为...
  iWantTo: string   // 我希望...
  soThat: string    // 以便...
  acceptanceCriteria: Array<{
    id: string
    description: string
    testFn: () => Promise<void>
  }>
}

export function createStoryTest(config: StoryTestConfig) {
  const mapper = StoryMapper.getInstance()

  test.describe(`故事：${config.storyTitle}`, () => {
    mapper.registerStory(config)

    config.acceptanceCriteria.forEach(ac => {
      test(`验收标准 ${ac.id}: ${ac.description}`, async () => {
        await ac.testFn()
        mapper.reportAcceptanceResult(config.storyId, ac.id, true)
      })
    })
  })
}
```

### 3. Page Object 模式

```typescript
// e2e/framework/pages/LoginPage.ts
import { Page, Locator } from '@playwright/test'

export class LoginPage {
  readonly page: Page
  readonly usernameInput: Locator
  readonly passwordInput: Locator
  readonly loginButton: Locator
  readonly errorMessage: Locator

  constructor(page: Page) {
    this.page = page
    this.usernameInput = page.locator('input[type="text"]')
    this.passwordInput = page.locator('input[type="password"]')
    this.loginButton = page.locator('button[type="submit"]')
    this.errorMessage = page.locator('.el-message--error')
  }

  async goto() {
    await this.page.goto('/login')
  }

  async login(username: string, password: string) {
    await this.usernameInput.fill(username)
    await this.passwordInput.fill(password)
    await this.loginButton.click()
  }

  async getErrorMessage(): Promise<string> {
    return this.errorMessage.textContent() || ''
  }
}
```

---

## 📊 覆盖率统计

### 需求覆盖率报告

```json
{
  "project": "需求单管理系统",
  "generatedAt": "2026-03-12T10:00:00Z",
  "overallCoverage": {
    "totalRequirements": 73,
    "coveredRequirements": 15,
    "coverageRate": 20.5,
    "status": "warning"
  },
  "coverageByPhase": [
    {
      "phase": "Phase 1: 前端 Mock 开发",
      "totalFeatures": 25,
      "coveredFeatures": 25,
      "coverageRate": 100,
      "status": "passed"
    },
    {
      "phase": "Phase 2: 前端 Mock 完善",
      "totalFeatures": 10,
      "coveredFeatures": 8,
      "coverageRate": 80,
      "status": "warning"
    }
  ],
  "coverageByPriority": [
    {
      "priority": "P0",
      "total": 25,
      "covered": 25,
      "rate": 100
    },
    {
      "priority": "P1",
      "total": 30,
      "covered": 20,
      "rate": 66.7
    }
  ],
  "uncoveredRequirements": [
    {
      "id": "FR50",
      "title": "保存常用筛选条件",
      "priority": "P1",
      "reason": "测试用例开发中"
    }
  ]
}
```

---

## 🚪 质量门禁

### 门禁检查清单

```json
{
  "qualityGate": {
    "version": "1.0.0",
    "timestamp": "2026-03-12T10:00:00Z",
    "checks": [
      {
        "name": "需求覆盖率",
        "threshold": ">=80%",
        "actual": "20.5%",
        "status": "failed",
        "blocking": true
      },
      {
        "name": "P0 功能测试通过率",
        "threshold": "100%",
        "actual": "100%",
        "status": "passed",
        "blocking": true
      },
      {
        "name": "P1 功能测试通过率",
        "threshold": ">=90%",
        "actual": "85%",
        "status": "failed",
        "blocking": false
      },
      {
        "name": "截图审查通过率",
        "threshold": "100%",
        "actual": "98%",
        "status": "warning",
        "blocking": false
      },
      {
        "name": "Bug 修复率",
        "threshold": ">=95%",
        "actual": "90%",
        "status": "warning",
        "blocking": false
      }
    ],
    "overallStatus": "failed",
    "canRelease": false,
    "blockers": ["需求覆盖率不足 80%"]
  }
}
```

---

## 🔄 闭环验证流程

### 完整流程

```
需求分析 ──▶ 测试设计 ──▶ 测试执行 ──▶ 问题发现
   ▲                                      │
   │                                      ▼
   │◀─────── 修复验证 ◀─────── Bug 跟踪 ◀──┘
   │
   ▼
验收通过
```

### 追溯链

```
PRD.md (FR1: 用户登录)
    │
    ├──▶ stories/story-001.md (登录故事)
    │         │
    │         ├──▶ acceptance-criteria/AC1.md
    │         └──▶ acceptance-criteria/AC2.md
    │                   │
    │                   ▼
    └───────▶ e2e/tests/features/login.spec.ts
                      │
                      ├──▶ test-001 (passed)
                      ├──▶ test-002 (passed)
                      └──▶ test-003 (failed)
                                │
                                ▼
                          bug-reports/BUG-001
                                │
                                ▼
                          fixed & verified
```

---

## 📖 使用指南

### 快速开始

1. **创建需求追溯矩阵**

```bash
npx playwright create-traceability-matrix
```

2. **编写功能测试**

```typescript
// e2e/tests/features/login.spec.ts
import { test } from '@playwright/test'
import { createFeatureTest } from '../../framework/templates/feature-test.template'
import { LoginPage } from '../../framework/pages/LoginPage'

export default createFeatureTest({
  featureId: 'FR1',
  featureName: '用户登录认证',
  requirements: ['FR1', 'FR26'],
  stories: ['story-001']
})
```

3. **运行测试并生成报告**

```bash
# 运行测试
npx playwright test

# 生成覆盖率报告
npx playwright generate-coverage

# 生成追溯报告
npx playwright generate-traceability
```

---

## 🔗 相关文档

- [截图审查工具](./lib/README.md) - ScreenshotValidator 使用
- [测试真实性验证规范](./guidelines/15-TEST-INTEGRITY.md) - 测试完整性要求
- [E2E 测试流程](./guidelines/04-E2E_TESTING_FLOW.md) - 15 层测试金字塔

---

*版本：1.0.0*
*最后更新：2026-03-12*

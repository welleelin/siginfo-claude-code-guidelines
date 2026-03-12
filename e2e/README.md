# Playwright 企业级测试框架使用指南

> **版本**：1.0.0
> **最后更新**：2026-03-12
> **状态**：核心规范

---

## 📋 概述

本指南介绍如何使用 Playwright 企业级测试框架，将 PRD 需求、功能点、用户故事与测试用例完整结合，形成确定性、可追溯、闭环验证的测试解决方案。

### 核心能力

| 能力 | 说明 | 使用场景 |
|------|------|---------|
| **需求追溯** | 测试用例追溯到 PRD 功能点 | 确保测试覆盖所有需求 |
| **故事映射** | 用户故事与测试双向关联 | BDD 风格验收测试 |
| **覆盖率统计** | 多维度覆盖率报告 | 了解测试覆盖情况 |
| **质量门禁** | 测试通过门槛检查 | 发布前质量把关 |
| **截图审查** | 自动检测 404/空白页 | 防止敷衍测试 |
| **Bug 上报** | 自动创建 Bug 报告 | 问题追踪与管理 |
| **视觉回归** | UI 变化检测 | 防止 UI 退化 |

---

## 🚀 快速开始

### Step 1: 安装依赖

```bash
# 安装 Playwright
npm install -D @playwright/test

# 安装框架核心
# (将 framework 目录复制到项目中)
cp -r sig-claude-code-guidelines/e2e/framework ./e2e/
cp -r sig-claude-code-guidelines/lib ./
cp -r sig-claude-code-guidelines/reporters ./
```

### Step 2: 配置 Playwright

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e/tests',
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: 0, // 不自动重试，与生产环境一致
  workers: 1,
  timeout: 120000,

  reporter: [
    ['list'],
    ['html', { open: 'never' }],
    ['./reporters/bug-reporter.ts'],
    ['./reporters/coverage-reporter.ts'],
  ],

  use: {
    baseURL: 'http://localhost:5173',
    trace: 'retain-on-failure',
    screenshot: 'on',
    video: 'retain-on-failure',
    headless: true,
    actionTimeout: 10000,
    navigationTimeout: 30000,
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'], viewport: { width: 1920, height: 1080 } },
    },
  ],
})
```

### Step 3: 创建需求追溯矩阵

```bash
# 初始化追溯矩阵
npx ts-node scripts/init-traceability.ts
```

或使用代码初始化：

```typescript
// scripts/init-traceability.ts
import { RequirementTracker } from './e2e/framework/core/RequirementTracker'

const tracker = RequirementTracker.getInstance()

// 初始化并导入需求
tracker.initialize('需求单管理系统', '1.0.0')
tracker.importFromTaskJson('./task.json')
tracker.save()

console.log('✅ 需求追溯矩阵已创建')
```

### Step 4: 编写功能测试

```typescript
// e2e/tests/features/login.spec.ts
import { test, expect } from '@playwright/test'
import { RequirementTracker } from '../../framework/core/RequirementTracker'
import { ScreenshotValidator } from '../../lib/screenshot-validator'
import { LoginPage } from '../../framework/pages/LoginPage'

test.describe('FR1: 用户登录认证', () => {
  const tracker = RequirementTracker.getInstance()
  let loginPage: LoginPage
  let validator: ScreenshotValidator

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page)
    validator = new ScreenshotValidator(page)

    // 注册需求
    tracker.registerRequirement({
      id: 'FR1',
      title: '用户登录认证',
      source: 'PRD.md',
      priority: 'P0',
      status: 'implemented'
    })
  })

  /**
   * @requirement FR1
   * @story story-001
   * @acceptance AC1
   */
  test('AC1: 用户名密码正确时登录成功', async ({ page }) => {
    await loginPage.goto()
    await loginPage.login('admin', 'admin123')

    // 验证登录成功
    await expect(page).toHaveURL(/dashboard/)

    // 截图审查
    const result = await validator.validate({
      name: '登录成功 - 仪表盘',
      criticalSelectors: ['[role="menubar"]']
    })

    // 报告测试结果
    tracker.reportTestResult('FR1', 'login-001', {
      status: result.valid ? 'passed' : 'failed'
    })

    expect(result.valid).toBe(true)
  })
})
```

### Step 5: 运行测试并生成报告

```bash
# 运行测试
npx playwright test

# 生成覆盖率报告
npx ts-node scripts/generate-coverage.ts

# 生成追溯报告
npx ts-node scripts/generate-traceability.ts

# 查看 HTML 报告
open test-results/reports/coverage-report.html
```

---

## 📖 核心概念

### 需求追溯矩阵

需求追溯矩阵是测试框架的核心，它建立了 PRD 需求与测试用例之间的关联：

```json
{
  "requirements": [
    {
      "id": "FR1",
      "title": "用户登录认证",
      "testCases": [
        {
          "testCaseId": "login-001",
          "testFile": "e2e/tests/features/login.spec.ts",
          "status": "passed"
        }
      ],
      "coverage": {
        "total": 3,
        "passed": 3,
        "rate": 100
      }
    }
  ]
}
```

### 用户故事映射

用户故事采用 BDD 格式，包含验收标准：

```markdown
# story-001: 运营人员登录

**作为** 运营人员
**我希望** 登录系统
**以便** 开始工作

## AC1: 登录成功
**Given** 用户在登录页面
**When** 输入正确的用户名和密码
**Then** 登录成功并跳转到仪表盘

## AC2: 登录失败
**Given** 用户在登录页面
**When** 输入错误的用户名或密码
**Then** 显示错误提示
```

### 测试注释规范

在测试文件中使用注释标签关联需求和故事：

```typescript
/**
 * @requirement FR1 - 用户登录认证
 * @requirement FR26 - 角色权限管理
 * @story story-001 - 运营人员登录
 * @acceptance AC1 - 登录成功
 * @acceptance AC2 - 登录失败
 */
test.describe('登录功能', () => {
  // ...
})
```

---

## 🔧 核心组件

### 1. RequirementTracker - 需求追溯器

负责管理需求与测试用例的关联：

```typescript
import { RequirementTracker } from './framework/core/RequirementTracker'

const tracker = RequirementTracker.getInstance()

// 注册需求
tracker.registerRequirement({
  id: 'FR1',
  title: '用户登录认证',
  priority: 'P0'
})

// 报告测试结果
tracker.reportTestResult('FR1', 'login-001', {
  status: 'passed'
})

// 生成追溯报告
tracker.generateReport()
```

### 2. StoryMapper - 故事映射器

负责管理用户故事和验收标准：

```typescript
import { StoryMapper } from './framework/core/StoryMapper'

const mapper = StoryMapper.getInstance()

// 注册故事
mapper.registerStory({
  id: 'story-001',
  asA: '运营人员',
  iWantTo: '登录系统',
  soThat: '开始工作'
})

// 报告验收结果
mapper.reportAcceptanceResult('story-001', 'AC1', {
  passed: true
})
```

### 3. CoverageGenerator - 覆盖率生成器

负责生成多维度覆盖率报告：

```typescript
import { CoverageGenerator } from './framework/core/CoverageGenerator'

const generator = new CoverageGenerator(tracker)

const report = generator.generate({
  project: '需求单管理系统',
  version: '1.0.0',
  taskJsonPath: './task.json'
})

// 检查质量门禁
const qualityGate = generator.checkQualityGate(report)
if (!qualityGate.passed) {
  console.error('质量门禁失败:', qualityGate.blockers)
  process.exit(1)
}
```

### 4. ScreenshotValidator - 截图审查器

负责截图完整性验证：

```typescript
import { ScreenshotValidator } from './lib/screenshot-validator'

const validator = new ScreenshotValidator(page)

const result = await validator.validate({
  name: '登录页面',
  criticalSelectors: ['form', 'h1']
})

if (!result.valid) {
  // 创建 Bug 报告
  await validator.createBugReport({
    title: '登录页面验证失败',
    severity: 'P1',
    description: result.issues.map(i => i.message).join('; ')
  })
}
```

---

## 📊 报告类型

### 覆盖率报告

包含以下维度：

- **总体覆盖率** - 需求覆盖百分比
- **按阶段覆盖率** - 各开发阶段覆盖情况
- **按优先级覆盖率** - P0/P1/P2/P3 覆盖情况
- **未覆盖需求** - 列出未测试的需求

### 追溯报告

包含以下信息：

- **需求→测试映射** - 每个需求关联的测试用例
- **测试→需求映射** - 每个测试覆盖的需求
- **故事→测试映射** - 用户故事的验收情况

### 质量门禁报告

包含以下检查：

- **需求覆盖率** - 必须 ≥80%
- **P0 覆盖率** - 必须 100%
- **P1 覆盖率** - 必须 ≥90%
- **测试通过率** - 必须 ≥95%

---

## 🔄 完整工作流

```
┌─────────────────────────────────────────────────────────────────┐
│                    企业级测试工作流                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. 需求分析                                                    │
│     ├── 读取 PRD.md                                             │
│     ├── 识别功能点 (FR1, FR2, ...)                              │
│     └── 创建需求追溯矩阵                                         │
│                                                                 │
│  2. 故事设计                                                    │
│     ├── 编写用户故事 (story-001, ...)                           │
│     ├── 定义验收标准 (AC1, AC2, ...)                            │
│     └── 注册到 StoryMapper                                      │
│                                                                 │
│  3. 测试开发                                                    │
│     ├── 创建 Page Object                                        │
│     ├── 编写测试用例                                            │
│     ├── 添加 @requirement 标签                                  │
│     └── 关联需求和故事                                          │
│                                                                 │
│  4. 测试执行                                                    │
│     ├── 运行 Playwright 测试                                     │
│     ├── 截图审查验证                                            │
│     └── 自动上报 Bug                                            │
│                                                                 │
│  5. 报告生成                                                    │
│     ├── 生成覆盖率报告                                          │
│     ├── 生成追溯报告                                            │
│     └── 检查质量门禁                                            │
│                                                                 │
│  6. 持续改进                                                    │
│     ├── 分析未覆盖需求                                          │
│     ├── 补充测试用例                                            │
│     └── 更新追溯矩阵                                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 项目结构

```
project/
├── PRD/
│   └── PRD.md                          # 产品需求文档
├── stories/
│   ├── user-stories.md                 # 用户故事集合
│   └── acceptance-criteria/            # 验收标准详情
├── e2e/
│   ├── framework/
│   │   ├── core/
│   │   │   ├── RequirementTracker.ts   # 需求追溯器
│   │   │   ├── StoryMapper.ts          # 故事映射器
│   │   │   └── CoverageGenerator.ts    # 覆盖率生成器
│   │   ├── pages/                      # Page Object
│   │   ├── data/                       # 测试数据
│   │   └── templates/                  # 测试模板
│   ├── tests/
│   │   ├── features/                   # 功能测试
│   │   ├── stories/                    # 故事测试
│   │   └── regression/                 # 回归测试
│   ├── fixtures/                       # 测试夹具
│   ├── helpers/                        # 辅助工具
│   ├── reporters/                      # 报告器
│   └── results/                        # 测试结果
├── requirement-traceability.json       # 需求追溯矩阵
├── coverage-report.json                # 覆盖率报告
└── playwright.config.ts                # Playwright 配置
```

---

## ✅ 最佳实践

### 1. 测试命名规范

```typescript
// 好的命名：清晰表达需求和验收标准
test('AC1: 用户名密码正确时登录成功', async ({ page }) => {})
test('AC2: 用户名或密码错误时显示错误提示', async ({ page }) => {})

// 坏的命名：过于笼统
test('登录测试', async ({ page }) => {})
```

### 2. 需求关联

```typescript
// 每个测试都必须关联需求
/**
 * @requirement FR1
 * @story story-001
 * @acceptance AC1
 */
test('...', async ({ page }) => {})
```

### 3. 截图审查

```typescript
// 每个重要页面都要进行截图审查
const result = await validator.validate({
  name: '页面名称',
  criticalSelectors: ['关键元素']
})
expect(result.valid).toBe(true)
```

### 4. Bug 上报

```typescript
// 发现问题立即上报
if (!result.valid) {
  await validator.createBugReport({
    title: '问题描述',
    severity: 'P1',
    description: result.issues.map(i => i.message).join('; ')
  })
}
```

---

## 🔗 相关文档

- [企业级测试框架设计](./ENTERPRISE_TEST_FRAMEWORK.md) - 架构设计
- [截图审查工具](./lib/README.md) - ScreenshotValidator 使用
- [测试真实性验证规范](./guidelines/15-TEST-INTEGRITY.md) - 测试完整性要求

---

*版本：1.0.0*
*最后更新：2026-03-12*

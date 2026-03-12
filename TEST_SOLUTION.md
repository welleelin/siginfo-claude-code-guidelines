# Playwright 企业级测试解决方案

> **版本**：1.0.0
> **最后更新**：2026-03-12
> **状态**：核心规范
>
> **定位**：以 Playwright 为核心的完整测试解决方案，实现 PRD→功能点→故事→测试的确定性闭环

---

## 📋 执行摘要

### 问题背景

传统测试方法存在以下核心问题：

| 问题 | 表现 | 后果 |
|------|------|------|
| **需求脱节** | 测试用例与 PRD 无关联 | 不知道测的是不是需求要求的 |
| **覆盖盲区** | 没有覆盖率统计 | 不知道哪些功能没测到 |
| **追溯断裂** | Bug 无法回溯到需求 | 修复后不知道影响哪些功能 |
| **验收主观** | 验收标准不量化 | 不同人验收结果不同 |
| **文档分离** | 测试文档与需求文档分离 | 维护成本高，容易过时 |
| **敷衍测试** | 为通过而测试 | 生产环境问题未被发现 |

### 解决方案

**Playwright 企业级测试解决方案** =

```
Playwright (执行引擎)
    +
需求追溯 (RequirementTracker)
    +
故事映射 (StoryMapper)
    +
覆盖率统计 (CoverageGenerator)
    +
截图审查 (ScreenshotValidator)
    +
质量门禁 (QualityGate)
    +
Bug 上报 (BugReporter)
    =
确定性、可追溯、闭环验证的企业级测试解决方案
```

---

## 🏗️ 架构设计

### 整体架构图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Playwright 企业级测试解决方案                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    需求层 (Requirement Layer)                    │    │
│  │  ┌───────────┐  ┌───────────┐  ┌───────────┐                    │    │
│  │  │  PRD.md   │  │task.json  │  │ stories/  │                    │    │
│  │  │ 需求文档   │  │ 任务列表  │  │  用户故事  │                    │    │
│  │  └─────┬─────┘  └─────┬─────┘  └─────┬─────┘                    │    │
│  │        │              │              │                            │    │
│  │        └──────────────┴──────────────┘                            │    │
│  │                        │                                          │    │
│  │                        ▼                                          │    │
│  │              ┌─────────────────┐                                  │    │
│  │              │  Requirement    │                                  │    │
│  │              │    Tracker      │  需求追溯器                       │    │
│  │              └────────┬────────┘                                  │    │
│  └───────────────────────┼───────────────────────────────────────────┘    │
│                          │                                                 │
│  ┌───────────────────────▼───────────────────────────────────────────┐    │
│  │                    设计层 (Design Layer)                           │    │
│  │  ┌─────────────────────────────────────────────────────────────┐  │    │
│  │  │                    StoryMapper                              │  │    │
│  │  │                   故事映射器                                 │  │    │
│  │  └─────────────────────────────────────────────────────────────┘  │    │
│  │                                                                    │    │
│  │  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐          │    │
│  │  │ 测试模板       │  │ Page Object   │  │ 测试数据       │          │    │
│  │  │ templates/    │  │  pages/       │  │  data/        │          │    │
│  │  └───────────────┘  └───────────────┘  └───────────────┘          │    │
│  └───────────────────────┬───────────────────────────────────────────┘    │
│                          │                                                 │
│  ┌───────────────────────▼───────────────────────────────────────────┐    │
│  │                    执行层 (Execution Layer)                        │    │
│  │  ┌─────────────────────────────────────────────────────────────┐  │    │
│  │  │              Playwright Test Runner                         │  │    │
│  │  │  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐    │  │    │
│  │  │  │ Screenshot    │  │ Bug           │  │ Visual        │    │  │    │
│  │  │  │ Validator     │  │ Reporter      │  │ Regression    │    │  │    │
│  │  │  └───────────────┘  └───────────────┘  └───────────────┘    │  │    │
│  │  └─────────────────────────────────────────────────────────────┘  │    │
│  └───────────────────────┬───────────────────────────────────────────┘    │
│                          │                                                 │
│  ┌───────────────────────▼───────────────────────────────────────────┐    │
│  │                    报告层 (Reporting Layer)                        │    │
│  │  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐          │    │
│  │  │ Coverage      │  │ Traceability  │  │ Quality       │          │    │
│  │  │ Generator     │  │ Report        │  │ Gate          │          │    │
│  │  └───────────────┘  └───────────────┘  └───────────────┘          │    │
│  └────────────────────────────────────────────────────────────────────┘    │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

### 核心组件

| 组件 | 文件 | 功能 |
|------|------|------|
| **RequirementTracker** | `e2e/framework/core/RequirementTracker.ts` | 需求追溯管理 |
| **StoryMapper** | `e2e/framework/core/StoryMapper.ts` | 用户故事映射 |
| **CoverageGenerator** | `e2e/framework/core/CoverageGenerator.ts` | 覆盖率生成 |
| **ScreenshotValidator** | `lib/screenshot-validator.ts` | 截图审查 |
| **BugReporter** | `reporters/bug-reporter.ts` | Bug 自动上报 |

---

## 🔄 完整工作流

### 从需求到测试的闭环

```
┌─────────────────────────────────────────────────────────────────┐
│                    完整测试工作流                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1️⃣  需求分析                                                   │
│     ┌─────────────────────────────────────────────────────┐    │
│     │ • 读取 PRD.md 获取功能需求 (FR1, FR2, ...)            │    │
│     │ • 读取 task.json 获取任务列表                         │    │
│     │ • 初始化 RequirementTracker                           │    │
│     │ • 创建需求追溯矩阵                                    │    │
│     └─────────────────────────────────────────────────────┘    │
│                        │                                        │
│                        ▼                                        │
│  2️⃣  故事设计                                                   │
│     ┌─────────────────────────────────────────────────────┐    │
│     │ • 编写用户故事 (story-001, story-002, ...)           │    │
│     │ • 定义验收标准 (AC1, AC2, ...)                       │    │
│     │ • 使用 StoryMapper 注册故事                           │    │
│     │ • 建立故事与需求的关联                                │    │
│     └─────────────────────────────────────────────────────┘    │
│                        │                                        │
│                        ▼                                        │
│  3️⃣  测试开发                                                   │
│     ┌─────────────────────────────────────────────────────┐    │
│     │ • 创建 Page Object (LoginPage, DashboardPage, ...)   │    │
│     │ • 编写测试用例                                        │    │
│     │ • 添加 @requirement @story @acceptance 标签          │    │
│     │ • 使用 ScreenshotValidator 进行截图审查              │    │
│     └─────────────────────────────────────────────────────┘    │
│                        │                                        │
│                        ▼                                        │
│  4️⃣  测试执行                                                   │
│     ┌─────────────────────────────────────────────────────┐    │
│     │ • 运行 Playwright 测试                                 │    │
│     │ • 自动截图审查 (检测 404/空白页)                      │    │
│     │ • 自动上报 Bug                                        │    │
│     │ • 记录测试结果到 RequirementTracker                   │    │
│     └─────────────────────────────────────────────────────┘    │
│                        │                                        │
│                        ▼                                        │
│  5️⃣  报告生成                                                   │
│     ┌─────────────────────────────────────────────────────┐    │
│     │ • 生成覆盖率报告 (JSON + HTML)                       │    │
│     │ • 生成追溯报告                                        │    │
│     │ • 检查质量门禁                                        │    │
│     │ • 列出未覆盖需求                                      │    │
│     └─────────────────────────────────────────────────────┘    │
│                        │                                        │
│                        ▼                                        │
│  6️⃣  持续改进                                                   │
│     ┌─────────────────────────────────────────────────────┐    │
│     │ • 分析未覆盖需求                                      │    │
│     │ • 补充测试用例                                        │    │
│     │ • 更新追溯矩阵                                        │    │
│     │ • 重新运行测试验证                                    │    │
│     └─────────────────────────────────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 目录结构

```
project/
├── 📄 PRD/
│   └── PRD.md                          # 产品需求文档
│
├── 📖 stories/
│   ├── user-stories.md                 # 用户故事集合
│   └── acceptance-criteria/            # 验收标准详情
│
├── 🧪 e2e/
│   ├── 📦 framework/
│   │   ├── 🔧 core/
│   │   │   ├── RequirementTracker.ts   # ⭐ 需求追溯器
│   │   │   ├── StoryMapper.ts          # ⭐ 故事映射器
│   │   │   └── CoverageGenerator.ts    # ⭐ 覆盖率生成器
│   │   │
│   │   ├── 📄 pages/                   # Page Object
│   │   │   ├── LoginPage.ts
│   │   │   ├── DashboardPage.ts
│   │   │   └── DemandPage.ts
│   │   │
│   │   ├── 📊 data/                    # 测试数据
│   │   │   ├── users.ts
│   │   │   └── demands.ts
│   │   │
│   │   └── 📝 templates/               # 测试模板
│   │       ├── feature-test.template.ts
│   │       └── story-test.template.ts
│   │
│   ├── 🧪 tests/
│   │   ├── features/                   # 功能测试
│   │   │   ├── login.spec.ts
│   │   │   ├── demand.spec.ts
│   │   │   └── whitelist.spec.ts
│   │   │
│   │   ├── stories/                    # 故事测试
│   │   │   ├── story-001.spec.ts
│   │   │   └── story-002.spec.ts
│   │   │
│   │   └── regression/                 # 回归测试
│   │       └── full-suite.spec.ts
│   │
│   ├── 🔩 fixtures/                    # 测试夹具
│   ├── 🛠️ helpers/                     # 辅助工具
│   ├── 📊 reporters/                   # 报告器
│   │   ├── bug-reporter.ts
│   │   ├── coverage-reporter.ts
│   │   └── traceability-reporter.ts
│   │
│   └── 📁 results/                     # 测试结果
│       ├── screenshots/
│       ├── videos/
│       ├── traces/
│       └── reports/
│
├── 📜 lib/
│   └── screenshot-validator.ts         # ⭐ 截图审查器
│
├── 📊 reporters/
│   └── bug-reporter.ts                 # ⭐ Bug 报告器
│
├── 📜 scripts/
│   ├── init-traceability.ts            # 初始化追溯矩阵
│   ├── generate-coverage.ts            # 生成覆盖率报告
│   └── generate-traceability.ts        # 生成追溯报告
│
├── 📄 requirement-traceability.json    # 需求追溯矩阵
├── 📄 coverage-report.json             # 覆盖率报告
└── 📄 playwright.config.ts             # Playwright 配置
```

---

## 🚀 快速开始

### Step 1: 安装依赖

```bash
# 安装 Playwright
npm install -D @playwright/test

# 复制框架文件
cp -r sig-claude-code-guidelines/e2e/framework ./e2e/
cp -r sig-claude-code-guidelines/lib ./
cp -r sig-claude-code-guidelines/reporters ./
cp -r sig-claude-code-guidelines/scripts ./
```

### Step 2: 初始化追溯矩阵

```bash
npx ts-node scripts/init-traceability.ts
```

### Step 3: 编写测试

```typescript
// e2e/tests/features/login.spec.ts
import { test, expect } from '@playwright/test'
import { RequirementTracker } from '../../framework/core/RequirementTracker'
import { ScreenshotValidator } from '../../lib/screenshot-validator'

test.describe('FR1: 用户登录认证', () => {
  const tracker = RequirementTracker.getInstance()
  let validator: ScreenshotValidator

  test.beforeEach(async ({ page }) => {
    validator = new ScreenshotValidator(page)

    tracker.registerRequirement({
      id: 'FR1',
      title: '用户登录认证',
      source: 'PRD.md',
      priority: 'P0'
    })
  })

  /**
   * @requirement FR1
   * @story story-001
   * @acceptance AC1
   */
  test('AC1: 用户名密码正确时登录成功', async ({ page }) => {
    await page.goto('/login')
    await page.fill('input[type="text"]', 'admin')
    await page.fill('input[type="password"]', 'admin123')
    await page.click('button[type="submit"]')

    // 验证跳转
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

### Step 4: 运行测试并生成报告

```bash
# 运行测试
npx playwright test

# 生成覆盖率报告
npx ts-node scripts/generate-coverage.ts

# 查看 HTML 报告
open test-results/reports/coverage-report.html
```

---

## 📊 报告示例

### 覆盖率报告摘要

```
============================================================
📊 覆盖率报告摘要
============================================================
项目：需求单管理系统
版本：1.0.0
总需求数：73
已覆盖需求：15
需求覆盖率：20.5%
测试总数：156
通过测试：150
失败测试：6
测试通过率：96.2%
质量门禁状态：❌ 失败
============================================================

📊 按优先级覆盖率:
  🔴 P0: 100% (测试通过率：100%)
  🟠 P1: 66.7% (测试通过率：95%)
  🟡 P2: 10% (测试通过率：90%)

⚠️  未覆盖的需求 (58):
  - FR50: 保存常用筛选条件 [P1]
  - FR51: 通知中心页面 [P1]
  - FR52: 客户分配管理 [P1]
  ... 还有 55 个未覆盖需求
```

### 质量门禁检查

```
🚪 质量门禁检查
============================================================
❌ 质量门禁失败
  - 需求覆盖率 20.5% < 要求 80%
  - P1 功能覆盖率 66.7% < 要求 90%
```

---

## ✅ 核心价值

### 1. 需求可追溯

- 每个测试用例都关联到 PRD 需求
- 可以查询每个需求有哪些测试覆盖
- 可以查询每个测试验证了哪些需求

### 2. 覆盖可量化

- 需求覆盖率统计
- 功能覆盖率统计
- 故事覆盖率统计

### 3. 验收标准化

- BDD 风格验收标准
- Given-When-Then 格式
- 量化通过标准

### 4. 测试真实性

- 截图自动审查
- 404/空白页自动检测
- Bug 自动上报

### 5. 质量可门禁

- 发布前质量检查
- 覆盖率门槛
- 通过率门槛

---

## 🔗 相关文档

| 文档 | 用途 |
|------|------|
| [企业级测试框架设计](./ENTERPRISE_TEST_FRAMEWORK.md) | 架构设计详解 |
| [使用指南](./e2e/README.md) | 快速开始指南 |
| [截图审查工具](./lib/README.md) | ScreenshotValidator 使用 |
| [测试真实性验证规范](./guidelines/15-TEST-INTEGRITY.md) | 测试完整性要求 |

---

*版本：1.0.0*
*最后更新：2026-03-12*

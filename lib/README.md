# Playwright 截图审查工具集成指南

> **版本**：1.0.0
> **最后更新**：2026-03-12
> **用途**：将测试真实性验证工具集成到 Playwright E2E 测试中

---

## 📋 概述

本指南说明如何将 `ScreenshotValidator` 集成到现有的 Playwright 测试项目中，防止"为了通过而测试"的敷衍行为。

### 核心功能

| 功能 | 说明 |
|------|------|
| **HTTP 状态验证** | 自动检测 404/500 等错误状态码 |
| **页面内容验证** | 检测页面是否包含错误文本、空白内容 |
| **关键元素验证** | 验证页面关键元素是否存在且可见 |
| **控制台错误监控** | 捕获并报告 JavaScript 错误 |
| **网络错误监控** | 捕获 API 请求失败 |
| **Bug 自动上报** | 发现 P0/P1 Bug 时自动创建报告 |
| **视觉回归测试** | 与基准图片对比，检测视觉变化 |

---

## 📦 安装步骤

### Step 1: 复制工具文件

将以下文件复制到项目中：

```bash
# 创建目录结构
mkdir -p lib reporters

# 复制核心文件
cp sig-claude-code-guidelines/lib/screenshot-validator.ts lib/
cp sig-claude-code-guidelines/lib/playwright-validator-config.ts lib/
cp sig-claude-code-guidelines/reporters/bug-reporter.ts reporters/
```

### Step 2: 更新 Playwright 配置

在 `playwright.config.ts` 中添加 Bug 报告器：

```typescript
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: 0,  // ⚠️ 不自动重试，与生产环境一致
  workers: 1,
  timeout: 120000,

  reporter: [
    ['list'],
    ['html', { open: 'never' }],
    ['json', { outputFile: 'e2e/test-results.json' }],
    ['./reporters/bug-reporter.ts'],  // ✅ 添加 Bug 报告器
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

### Step 3: 创建测试辅助文件（可选）

创建 `e2e/helpers/validator-fixture.ts`：

```typescript
import { test as base } from '@playwright/test'
import { ScreenshotValidator } from '../../lib/screenshot-validator'

export type ValidatorFixtures = {
  validator: ScreenshotValidator
}

export const test = base.extend<ValidatorFixtures>({
  validator: async ({ page }, use) => {
    const validator = new ScreenshotValidator(page, {
      checkConsoleErrors: true,
      checkNetworkErrors: true,
      requireHttpStatusCheck: true,
    })
    await use(validator)
  },
})
```

---

## 📖 使用方法

### 方式一：手动创建 Validator（推荐）

```typescript
import { test, expect } from '@playwright/test'
import { ScreenshotValidator } from '../lib/screenshot-validator'

test.describe('登录功能', () => {
  let validator: ScreenshotValidator

  test.beforeEach(async ({ page }) => {
    validator = new ScreenshotValidator(page, {
      checkConsoleErrors: true,
      checkNetworkErrors: true,
      requireHttpStatusCheck: true,
    })
  })

  test('登录页面验证', async ({ page }) => {
    await page.goto('/login')

    // 完整验证
    const result = await validator.validate({
      name: '登录页面',
      criticalSelectors: [
        'h1:has-text("登录")',
        'input[type="text"]',
        'input[type="password"]',
        'button[type="submit"]'
      ]
    })

    // 断言验证通过
    expect(result.valid).toBe(true)
  })
})
```

### 方式二：使用 Fixture

```typescript
import { test } from './helpers/validator-fixture'

test('使用 fixture 的测试', async ({ page, validator }) => {
  await page.goto('/login')

  const result = await validator.validate({
    name: '登录页面',
    criticalSelectors: ['form']
  })

  expect(result.valid).toBe(true)
})
```

### 方式三：集成到现有 Helper

```typescript
// e2e/helpers/login.ts
import { Page } from '@playwright/test'
import { ScreenshotValidator } from '../../lib/screenshot-validator'

export async function loginWithValidation(
  page: Page,
  validator: ScreenshotValidator,
  username: string,
  password: string
) {
  await page.goto('/login')

  // 验证登录页
  const result = await validator.validate({
    name: '登录页面',
    criticalSelectors: ['form', 'input[type="text"]', 'input[type="password"]']
  })

  if (!result.valid) {
    throw new Error(`登录页面验证失败：${result.issues.map(i => i.message).join('; ')}`)
  }

  await page.fill('input[type="text"]', username)
  await page.fill('input[type="password"]', password)
  await page.click('button[type="submit"]')
  await page.waitForURL(/dashboard/)
}
```

---

## 🔍 验证选项详解

### validate() 方法选项

```typescript
await validator.validate({
  // 测试名称（用于日志和 Bug 报告）
  name: '登录页面',

  // 关键元素选择器列表
  criticalSelectors: [
    'h1',
    'form',
    '[role="menubar"]'
  ],

  // 自定义错误内容模式（可选）
  customErrorPatterns: [
    /系统维护/i,
    /服务暂不可用/i
  ],

  // 是否跳过 HTTP 状态验证（默认 false）
  skipHttpStatus: false,

  // 是否跳过截图（默认 false）
  skipScreenshot: false,
})
```

### ScreenshotValidator 配置

```typescript
const validator = new ScreenshotValidator(page, {
  // 关键元素选择器列表
  criticalSelectors: ['header', 'footer'],

  // 是否检查控制台错误（默认 true）
  checkConsoleErrors: true,

  // 是否检查网络请求错误（默认 true）
  checkNetworkErrors: true,

  // HTTP 状态码验证是否必需（默认 true）
  requireHttpStatusCheck: true,

  // 视觉回归基准图片目录
  baselineDir: 'e2e/baseline',

  // 最大允许像素差异比例（默认 0.05 = 5%）
  maxDiffPixelRatio: 0.05,
})
```

---

## 🐛 Bug 报告

### Bug 级别定义

| 级别 | 类型 | 处理方式 |
|------|------|---------|
| **P0** | 404/500 错误、页面空白、Not Found | 立即修复，阻塞测试 |
| **P1** | 关键元素缺失、断言失败 | 优先修复 |
| **P2** | 控制台错误、网络请求失败 | 排期修复 |
| **P3** | 视觉差异、轻微 UI 问题 | 可后续修复 |

### 创建 Bug 报告

```typescript
const bug = await validator.createBugReport({
  title: '登录页面 404 错误',
  severity: 'P0',
  description: '访问登录页面返回 404 错误',
  steps: [
    '1. 导航到 /login',
    '2. 检测到 HTTP 404 错误',
    '3. 页面包含"Not Found"文本'
  ],
  testInfo: test.info()
})

console.log('Bug 已创建:', bug.id)
```

### Bug 报告输出

测试完成后，Bug 报告会保存到：

```
test-results/
└── bug-reports/
    ├── bugs-latest.json      # 最新报告
    └── bugs-2026-03-12T...   # 带时间戳的报告
```

---

## 📊 输出示例

### 测试运行输出

```
🐛 Bug 报告器已初始化，报告目录：test-results/bug-reports

Running 5 tests using 1 worker

  ✓  1 login.spec.ts:10:3 › 登录功能 › 登录页面验证 (1.2s)
  ✓  2 login.spec.ts:20:3 › 登录功能 › 登录成功跳转 (1.5s)

🚨 严重 Bug 发现:
   文件：e2e/home.spec.ts
   测试：首页 › 首页元素显示
   级别：P0
   错误：Error: HTTP 404 错误...

  ✘  3 home.spec.ts:5:3 › 首页 › 首页元素显示 (2.1s)

============================================================
🐛 Bug 报告摘要
============================================================
总 Bug 数：1
  P0 (致命): 1
  P1 (严重): 0
  P2 (一般): 0
  P3 (轻微): 0

⚠️  发现 P0 级别致命 Bug，必须立即修复！
============================================================

📄 Bug 报告已保存到：test-results/bug-reports/bugs-2026-03-12T...
```

---

## ✅ 最佳实践

### 1. 每个测试都进行验证

```typescript
// ❌ 坏做法：只验证元素存在
test('页面显示', async ({ page }) => {
  await page.goto('/login')
  await expect(page.locator('h1')).toBeVisible()
})

// ✅ 好做法：完整验证
test('页面显示', async ({ page }) => {
  await page.goto('/login')
  const result = await validator.validate({
    name: '登录页面',
    criticalSelectors: ['h1', 'form']
  })
  expect(result.valid).toBe(true)
})
```

### 2. 发现 Bug 立即上报

```typescript
const result = await validator.validate(...)

if (!result.valid) {
  // 创建 Bug 报告
  await validator.createBugReport({
    title: '验证失败',
    severity: result.issues[0].severity,
    description: result.issues.map(i => i.message).join('; '),
    steps: ['1. ...', '2. ...']
  })

  // 抛出错误，阻断测试
  throw new Error(`验证失败：${result.issues.map(i => i.message).join('; ')}`)
}
```

### 3. 合理设置关键元素

```typescript
// ❌ 太少：无法验证页面完整性
criticalSelectors: ['body']

// ✅ 合理：覆盖核心功能元素
criticalSelectors: [
  'h1',              // 页面标题
  'form',            // 表单容器
  'input[type="text"]',   // 输入框
  'button[type="submit"]' // 提交按钮
]
```

---

## 🔗 相关文档

- [测试真实性验证规范](../guidelines/15-TEST-INTEGRITY.md) - 规范定义
- [系统总则](../guidelines/00-SYSTEM_OVERVIEW.md) - 核心理念
- [E2E 测试流程](../guidelines/04-E2E_TESTING_FLOW.md) - 15 层测试金字塔

---

*版本：1.0.0*
*最后更新：2026-03-12*

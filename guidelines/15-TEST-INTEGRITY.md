# 测试真实性验证规范

> **版本**：1.0.0
> **最后更新**：2026-03-12
> **级别**：核心规范
> **变更**：新增测试完整性验证，防止"为了通过而测试"的敷衍行为

---

## 📋 概述

### 为什么需要测试真实性验证？

**问题背景**：测试过程中为了"通过测试而测试"，回避了真实生产环境应该暴露的问题。

| 问题类型 | 表现 | 后果 |
|---------|------|------|
| **截图敷衍** | Playwright 截图到 404 页面，但控制台无报错 | 误报测试通过，生产环境实际不可用 |
| **元素假验证** | 只验证元素存在，不验证内容正确性 | UI 显示错误但测试显示通过 |
| **绕过关键路径** | 测试用例避开复杂业务逻辑 | 核心功能未真正验证 |
| **Mock 滥用** | 应该用真实 API 的场景使用 Mock | 集成问题在测试阶段未被发现 |
| **视觉盲区** | 不检查截图中的视觉错误（404/空白/错位） | 用户体验问题被忽略 |

### 核心原则

```
┌─────────────────────────────────────────────────────────────────┐
│                    测试真实性三原则                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. 视觉验证原则                                                │
│     截图必须审查，404/空白/错位必须报 Bug                        │
│                                                                 │
│  2. 数据验证原则                                                │
│     必须验证内容的正确性，不能只验证元素存在                      │
│                                                                 │
│  3. 环境对等原则                                                │
│     测试环境必须模拟生产环境条件，不能特殊对待                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎯 视觉验证规范

### 1. Playwright 截图审查

#### 问题场景

```
❌ 错误做法：
test('登录页面截图', async ({ page }) => {
  await page.goto('/login');
  await page.screenshot({ path: 'login.png' });
  // ❌ 问题：没有验证截图内容
  // ❌ 问题：页面返回 404 但测试通过
});
```

#### 正确做法

```typescript
✅ 正确做法：
test('登录页面截图验证', async ({ page }) => {
  // Step 1: 验证 HTTP 状态
  const response = await page.goto('/login');
  expect(response?.status()).toBe(200);

  // Step 2: 检查页面是否包含 404 特征
  const bodyText = await page.locator('body').textContent();
  expect(bodyText).not.toContain('404');
  expect(bodyText).not.toContain('Not Found');
  expect(bodyText).not.toContain('页面不存在');

  // Step 3: 检查关键元素是否存在（验证页面内容正确）
  await expect(page.locator('#username')).toBeVisible();
  await expect(page.locator('#password')).toBeVisible();
  await expect(page.getByText('登录')).toBeVisible();

  // Step 4: 截图并验证截图有效性
  const screenshot = await page.screenshot({ path: 'login.png' });
  expect(screenshot.length).toBeGreaterThan(0);

  // Step 5: 可选 - 使用视觉回归测试
  await expect(page).toHaveScreenshot('login-baseline.png', {
    maxDiffPixelRatio: 0.05  // 允许 5% 差异
  });
});
```

#### 截图审查检查清单

```
┌─────────────────────────────────────────────────────────────────┐
│                    截图审查检查清单                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  □ 1. HTTP 状态码检查                                           │
│     - response?.status() === 200                               │
│     - 无 4xx/5xx 错误                                           │
│                                                                 │
│  □ 2. 页面内容检查                                              │
│     - 不包含 "404" / "Not Found" / "页面不存在"                 │
│     - 不包含空白内容（bodyText.length > 0）                     │
│     - 包含预期的关键内容                                        │
│                                                                 │
│  □ 3. 关键元素检查                                              │
│     - 核心功能元素可见                                          │
│     - 元素位置正确（无严重错位）                                │
│     - 元素内容正确（非占位符文本）                              │
│                                                                 │
│  □ 4. 截图有效性检查                                            │
│     - 截图文件大小合理（> 1KB）                                 │
│     - 截图尺寸符合预期                                          │
│                                                                 │
│  □ 5. 视觉回归检查（可选）                                      │
│     - 与基准图片对比差异 < 5%                                   │
│     - 关键区域无变化                                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔍 数据验证规范

### 2. 内容正确性验证

#### 问题场景

```
❌ 错误做法：
test('用户信息展示', async ({ page }) => {
  await page.goto('/profile');
  // ❌ 问题：只验证元素存在，不验证内容
  await expect(page.locator('.username')).toBeVisible();
  await expect(page.locator('.email')).toBeVisible();
});
```

#### 正确做法

```typescript
✅ 正确做法：
test('用户信息展示验证', async ({ page }) => {
  await page.goto('/profile');

  // Step 1: 验证用户名内容正确
  const usernameElement = page.locator('.username');
  const usernameText = await usernameElement.textContent();
  expect(usernameText).toBe('expected_username');  // 验证具体值
  expect(usernameText.trim().length).toBeGreaterThan(0);  // 非空

  // Step 2: 验证邮箱格式正确
  const emailElement = page.locator('.email');
  const emailText = await emailElement.textContent();
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  expect(emailRegex.test(emailText.trim())).toBe(true);  // 格式验证

  // Step 3: 验证不是占位符数据
  expect(usernameText).not.toContain('xxx');
  expect(usernameText).not.toContain('test');
  expect(emailText).not.toContain('example.com');

  // Step 4: 验证数据一致性（与 API 返回对比）
  const apiResponse = await page.request.get('/api/profile');
  const apiData = await apiResponse.json();
  expect(usernameText).toBe(apiData.username);
  expect(emailText).toBe(apiData.email);
});
```

---

## 🌐 环境对等规范

### 3. 生产环境模拟

#### 问题场景

```
❌ 错误做法：
- 测试环境使用特殊配置（超时时间超长、重试次数超多）
- 测试环境使用简化数据（数据量太小、边界条件缺失）
- 测试环境关闭了生产环境的中间件（鉴权、限流、日志）
```

#### 正确做法

```typescript
// test.config.ts - 测试环境配置
export const testConfig = {
  // ✅ 超时时间与生产环境一致
  timeout: 30000,  // 30 秒，与生产环境相同

  // ✅ 重试次数与生产环境一致
  retries: 0,  // 生产环境不重试，测试也不重试

  // ✅ 使用真实 API（禁止 Mock，除非明确标记）
  apiBaseUrl: process.env.TEST_ENV === 'mock'
    ? 'http://localhost:3001/mock'  // 仅前端开发测试
    : 'http://localhost:8000',      // 联调/E2E测试必须用真实 API

  // ✅ 启用所有中间件
  enableAuth: true,     // 启用鉴权
  enableRateLimit: true, // 启用限流
  enableLogging: true,   // 启用日志
};
```

#### 环境配置检查清单

```
┌─────────────────────────────────────────────────────────────────┐
│                    生产环境对等检查清单                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  □ 超时时间                                                     │
│     - 测试环境超时 = 生产环境超时                                │
│     - 不因测试而延长超时                                        │
│                                                                 │
│  □ 重试策略                                                     │
│     - 测试环境重试次数 ≤ 生产环境                                │
│     - 不依赖无限重试通过测试                                     │
│                                                                 │
│  □ 数据规模                                                     │
│     - 测试数据量级 ≈ 生产环境                                    │
│     - 包含边界条件数据                                          │
│     - 包含异常数据                                              │
│                                                                 │
│  □ 中间件配置                                                   │
│     - 鉴权中间件启用状态一致                                     │
│     - 限流中间件启用状态一致                                     │
│     - 日志中间件启用状态一致                                     │
│                                                                 │
│  □ 网络条件                                                     │
│     - 不假设网络永远高速                                        │
│     - 模拟真实网络延迟                                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚨 Bug 认定标准

### 4. 测试中发现的问题必须认定为 Bug

#### Bug 认定矩阵

| 问题类型 | 表现 | Bug 级别 | 处理方式 |
|---------|------|---------|---------|
| **404 页面** | 截图包含 404/Not Found | P0-致命 | 立即修复 |
| **空白页面** | body 内容为空或只有骨架 | P1-严重 | 优先修复 |
| **元素错位** | 核心元素严重偏移 | P2-一般 | 排期修复 |
| **内容错误** | 显示占位符/测试数据 | P2-一般 | 排期修复 |
| **控制台报错** | JS 错误/API 失败 | P1-严重 | 优先修复 |
| **网络失败** | 关键 API 返回非 200 | P1-严重 | 优先修复 |

#### Bug 报告流程

```
┌─────────────────────────────────────────────────────────────────┐
│                    Bug 认定与报告流程                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. 发现问题                                                    │
│     - 测试中检测到 404/空白/错误                                │
│     - 截图审查发现视觉问题                                      │
│                                                                 │
│  2. 记录证据                                                    │
│     - 保存截图（包含问题）                                      │
│     - 保存控制台日志                                            │
│     - 保存网络请求记录                                          │
│                                                                 │
│  3. 创建 Bug 报告                                               │
│     - Bug 标题：[测试发现] + 问题描述                           │
│     - Bug 级别：根据矩阵判定                                    │
│     - 复现步骤：测试用例路径                                     │
│     - 证据附件：截图 + 日志                                     │
│                                                                 │
│  4. 阻断处理                                                    │
│     - P0/P1 Bug：阻塞测试通过，必须修复                         │
│     - P2/P3 Bug：记录到待办，可后续修复                          │
│                                                                 │
│  5. 验证修复                                                    │
│     - 修复后重新运行测试                                        │
│     - 确认问题已解决                                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 测试质量指标

### 质量度量体系

| 指标 | 计算方式 | 目标值 | 说明 |
|------|---------|--------|------|
| **截图审查率** | (审查截图数 / 总截图数) × 100% | 100% | 所有截图必须审查 |
| **内容验证率** | (验证内容的测试数 / 总测试数) × 100% | 100% | 不能只验证元素存在 |
| **真实 API 使用率** | (使用真实 API 的测试数 / 总测试数) × 100% | ≥90% | 联调/E2E 必须用真实 API |
| **Bug 发现率** | (测试发现 Bug 数 / 总 Bug 数) × 100% | ≥80% | 测试应发现大部分问题 |
| **环境对等符合率** | (符合生产配置的测试数 / 总测试数) × 100% | 100% | 测试环境不能特殊化 |

### 质量报告模板

```markdown
## 测试质量报告

### 基础指标
- 总测试用例数：XX
- 通过用例数：XX
- 失败用例数：XX
- 跳过用例数：XX

### 质量指标
- 截图审查率：XX% (目标：100%)
- 内容验证率：XX% (目标：100%)
- 真实 API 使用率：XX% (目标：≥90%)

### 问题发现
- 发现 Bug 总数：XX
  - P0 致命：XX
  - P1 严重：XX
  - P2 一般：XX
  - P3 轻微：XX

### 环境对等检查
- [ ] 超时时间一致
- [ ] 重试策略一致
- [ ] 中间件配置一致
- [ ] 数据规模合理

### 改进建议
1. ...
2. ...
```

---

## 🤖 AI Agent 自主验证规范

### 5. AI 必须自动验证预期效果

#### 问题场景

```
❌ 错误做法：
AI 完成开发后，不验证就让用户体验：
"功能已开发完成，请查看效果"

→ 问题：用户访问后发现页面空白、工具栏不显示、控制台报错
→ 后果：用户成为测试者，体验极差
```

#### 正确做法

```
✅ 正确做法：
AI 在开发完成后，必须自动执行验证：

1. **启动验证**：确认服务已启动，端口可访问
2. **视觉验证**：访问页面，检查预期 UI 元素是否显示
3. **功能验证**：点击交互元素，验证功能是否正常
4. **日志验证**：检查控制台是否有报错
5. **截图验证**：截图并审查是否有视觉问题

只有所有验证通过，AI 才能告知用户"功能已完成，可直接使用"
```

### 预期效果验证检查清单

以"Agentation 工具栏集成"为例：

```
┌─────────────────────────────────────────────────────────────────┐
│                    预期效果验证检查清单                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  预期效果描述：                                                 │
│  在浏览器中访问 http://localhost:3001 应该显示：                 │
│  1. 游戏列表页面（统计卡片、选项卡、游戏网格）                   │
│  2. Agentation 标注工具 - 浮在页面右下角的粉色/紫色工具栏        │
│                                                                 │
│  验证步骤：                                                     │
│  □ 1. 服务启动验证                                              │
│     - 检查端口 3001 是否可访问                                   │
│     - curl http://localhost:3001 返回 200                       │
│                                                                 │
│  □ 2. 页面加载验证                                              │
│     - 访问 http://localhost:3001                                │
│     - HTTP 状态码 = 200                                         │
│     - 页面加载时间 < 3 秒                                        │
│                                                                 │
│  □ 3. 游戏列表页面验证                                          │
│     - 统计卡片可见 (selector: .stats-card)                      │
│     - 选项卡可见 (selector: .tabs / .tab)                       │
│     - 游戏网格可见 (selector: .game-grid / .game-card)          │
│     - 至少显示 N 个游戏卡片                                     │
│                                                                 │
│  □ 4. Agentation 工具栏验证                                     │
│     - 工具栏容器可见 (selector: #agentation-toolbar)            │
│     - 工具栏位置正确 (右下角，fixed 定位)                        │
│     - 工具栏颜色正确 (粉色/紫色，检查 background-color)          │
│     - 工具栏按钮可点击                                          │
│                                                                 │
│  □ 5. 控制台日志验证                                            │
│     - 无 JavaScript 错误                                        │
│     - 无 404 资源请求                                           │
│     - 无 API 调用失败                                           │
│                                                                 │
│  □ 6. 截图审查                                                  │
│     - 截取完整页面                                              │
│     - 审查截图是否包含预期元素                                   │
│     - 审查截图是否无 404/空白/错位                              │
│                                                                 │
│  □ 7. 功能交互验证（可选）                                      │
│     - 点击选项卡，页面正确切换                                   │
│     - 点击工具栏按钮，工具栏正确响应                             │
│                                                                 │
│  通过标准：                                                     │
│  - 所有 □ 检查通过                                              │
│  - 控制台无错误                                                 │
│  - 截图审查通过                                                 │
│                                                                 │
│  失败处理：                                                     │
│  - 发现任何问题，立即记录为 Bug                                 │
│  - 分析原因并修复                                               │
│  - 重新验证直到通过                                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### AI 自主验证流程

```
┌─────────────────────────────────────────────────────────────────┐
│                    AI 自主验证流程                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Step 1: 定义预期效果                                           │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ 访问 http://localhost:3001 应该显示：                     │   │
│  │ 1. 游戏列表页面（统计卡片、选项卡、游戏网格）             │   │
│  │ 2. Agentation 工具栏（粉色/紫色，右下角）                │   │
│  └─────────────────────────────────────────────────────────┘   │
│                        │                                        │
│                        ▼                                        │
│  Step 2: 启动服务并等待就绪                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ $ npm run dev                                            │   │
│  │ $ wait-for-localhost --port 3001 --timeout 60           │   │
│  │ ✅ 服务已启动：http://localhost:3001                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                        │                                        │
│                        ▼                                        │
│  Step 3: 使用 Playwright 验证                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ const page = await browser.newPage();                   │   │
│  │ await page.goto('http://localhost:3001');               │   │
│  │                                                          │   │
│  │ // 验证游戏列表页面                                      │   │
│  │ await expect(page.locator('.stats-card')).toBeVisible();│   │
│  │ await expect(page.locator('.tabs')).toBeVisible();      │   │
│  │ await expect(page.locator('.game-grid')).toBeVisible(); │   │
│  │                                                          │   │
│  │ // 验证 Agentation 工具栏                                 │   │
│  │ const toolbar = page.locator('#agentation-toolbar');    │   │
│  │ await expect(toolbar).toBeVisible();                    │   │
│  │ const bgColor = await toolbar.evaluate(el =>            │   │
│  │   getComputedStyle(el).backgroundColor);                │   │
│  │ expect(bgColor).toMatch(/rgb\(\d+, \d+, \d+\)/);        │   │
│  │                                                          │   │
│  │ // 检查控制台                                            │   │
│  │ const errors = await page.evaluate(() =>                │   │
│  │   window.__errors || []);                               │   │
│  │ expect(errors.length).toBe(0);                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                        │                                        │
│                        ▼                                        │
│  Step 4: 截图审查                                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ await page.screenshot({ path: 'verification.png' });    │   │
│  │ const result = await validator.validate({               │   │
│  │   name: '游戏列表页面验证',                              │   │
│  │   criticalSelectors: ['.stats-card', '#agentation-toolbar']│ │
│  │ });                                                      │   │
│  │ if (!result.valid) {                                     │   │
│  │   // 创建 Bug 报告                                        │   │
│  │   await reporter.report({ ... });                       │   │
│  │ }                                                        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                        │                                        │
│                        ▼                                        │
│  Step 5: 验证结论                                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ ✅ 所有验证通过                                         │   │
│  │ 功能已完成，可直接访问：http://localhost:3001            │   │
│  │                                                          │   │
│  │ 或 ❌ 发现问题                                           │   │
│  │ 发现问题：Agentation 工具栏未显示                        │   │
│  │ 已创建 Bug 报告：BUG-20260312-001                        │   │
│  │ 正在修复...                                              │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### AI 自主验证脚本示例

```typescript
// scripts/verify-expectations.ts
import { chromium, Page } from 'playwright';

interface VerificationResult {
  passed: boolean;
  details: string[];
  errors: string[];
}

async function verifyGameList(page: Page): Promise<string[]> {
  const issues: string[] = [];

  // 验证统计卡片
  const statsCards = page.locator('.stats-card');
  const statsCount = await statsCards.count();
  if (statsCount === 0) {
    issues.push('❌ 统计卡片未显示');
  } else {
    console.log(`✅ 统计卡片已显示 (${statsCount}个)`);
  }

  // 验证选项卡
  const tabs = page.locator('.tabs, .tab');
  if (await tabs.count() === 0) {
    issues.push('❌ 选项卡未显示');
  } else {
    console.log('✅ 选项卡已显示');
  }

  // 验证游戏网格
  const gameGrid = page.locator('.game-grid, .game-card');
  if (await gameGrid.count() === 0) {
    issues.push('❌ 游戏网格未显示');
  } else {
    console.log(`✅ 游戏网格已显示 (${await gameGrid.count()}个游戏)`);
  }

  return issues;
}

async function verifyAgentationToolbar(page: Page): Promise<string[]> {
  const issues: string[] = [];

  // 验证工具栏存在
  const toolbar = page.locator('#agentation-toolbar, [class*="agentation"]');
  if (await toolbar.count() === 0) {
    issues.push('❌ Agentation 工具栏未显示');
    return issues;
  }
  console.log('✅ Agentation 工具栏已显示');

  // 验证工具栏位置（右下角）
  const position = await toolbar.evaluate(el => {
    const rect = el.getBoundingClientRect();
    return {
      isBottom: rect.bottom >= window.innerHeight - 50,
      isRight: rect.right >= window.innerWidth - 200
    };
  });
  if (!position.isBottom || !position.isRight) {
    issues.push('❌ 工具栏不在右下角');
  } else {
    console.log('✅ 工具栏位置正确（右下角）');
  }

  // 验证工具栏颜色（粉色/紫色）
  const bgColor = await toolbar.evaluate(el =>
    getComputedStyle(el).backgroundColor
  );
  const isPinkOrPurple = /rgb\(\d+, \d+, \d+\)/.test(bgColor);
  if (!isPinkOrPurple) {
    issues.push(`⚠️ 工具栏颜色可能不是粉色/紫色：${bgColor}`);
  } else {
    console.log(`✅ 工具栏颜色正常：${bgColor}`);
  }

  return issues;
}

async function verifyConsoleErrors(page: Page): Promise<string[]> {
  const issues: string[] = [];

  // 收集控制台错误
  const errors: string[] = [];
  page.on('console', msg => {
    if (msg.type() === 'error') {
      errors.push(msg.text());
    }
  });

  // 等待页面稳定
  await page.waitForTimeout(2000);

  if (errors.length > 0) {
    issues.push(`❌ 控制台发现 ${errors.length} 个错误：${errors.join('; ')}`);
  } else {
    console.log('✅ 控制台无错误');
  }

  return issues;
}

export async function verifyExpectations(
  url: string = 'http://localhost:3001'
): Promise<VerificationResult> {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  const details: string[] = [];
  const errors: string[] = [];

  try {
    console.log(`\n🔍 开始验证：${url}`);

    // 访问页面
    const response = await page.goto(url, { timeout: 30000 });
    if (response?.status() !== 200) {
      errors.push(`HTTP 状态码异常：${response?.status()}`);
      return { passed: false, details, errors };
    }
    details.push('✅ 页面加载成功');

    // 验证游戏列表
    const gameListIssues = await verifyGameList(page);
    errors.push(...gameListIssues);
    details.push(...gameListIssues);

    // 验证 Agentation 工具栏
    const toolbarIssues = await verifyAgentationToolbar(page);
    errors.push(...toolbarIssues);
    details.push(...toolbarIssues);

    // 验证控制台
    const consoleIssues = await verifyConsoleErrors(page);
    errors.push(...consoleIssues);
    details.push(...consoleIssues);

    // 截图
    await page.screenshot({ path: 'verification-result.png', fullPage: true });
    details.push('✅ 截图已保存：verification-result.png');

    const passed = errors.length === 0;
    return { passed, details, errors };

  } finally {
    await browser.close();
  }
}

// 运行验证
(async () => {
  const result = await verifyExpectations();

  console.log('\n' + '='.repeat(60));
  console.log('📊 验证结果');
  console.log('='.repeat(60));
  result.details.forEach(d => console.log(d));

  if (result.passed) {
    console.log('\n✅ 所有验证通过！功能已完成，可直接使用。');
    process.exit(0);
  } else {
    console.log('\n❌ 发现以下问题：');
    result.errors.forEach(e => console.log(`  - ${e}`));
    console.log('\n正在记录 Bug 报告...');
    process.exit(1);
  }
})();
```

### 验证脚本使用方式

```bash
# 运行预期效果验证
npx tsx scripts/verify-expectations.ts

# 输出示例：
🔍 开始验证：http://localhost:3001
✅ 页面加载成功
✅ 统计卡片已显示 (3 个)
✅ 选项卡已显示
✅ 游戏网格已显示 (12 个游戏)
✅ Agentation 工具栏已显示
✅ 工具栏位置正确（右下角）
✅ 工具栏颜色正常：rgb(186, 104, 200)
✅ 控制台无错误
✅ 截图已保存：verification-result.png

============================================================
📊 验证结果
============================================================
✅ 所有验证通过！功能已完成，可直接使用。
```

---

## 🔧 自动化工具

### 1. 截图审查工具

```typescript
// utils/screenshot-validator.ts
import { Page } from '@playwright/test';

export class ScreenshotValidator {
  constructor(private page: Page) {}

  // 验证 HTTP 状态
  async validateStatus(): Promise<{ valid: boolean; status?: number }> {
    const response = this.page.response();
    const status = response ? await response.status() : null;

    if (!status || status >= 400) {
      return { valid: false, status: status || undefined };
    }
    return { valid: true, status };
  }

  // 验证页面不包含错误内容
  async validateNoErrorContent(): Promise<{ valid: boolean; errors: string[] }> {
    const bodyText = await this.page.locator('body').textContent();
    const errorPatterns = [
      /404/i,
      /not found/i,
      /页面不存在/i,
      /服务器错误/i,
      /500/i,
      /^[\s\n]*$/  // 空白页面
    ];

    const errors = errorPatterns
      .filter(pattern => pattern.test(bodyText))
      .map(pattern => pattern.toString());

    return { valid: errors.length === 0, errors };
  }

  // 验证关键元素存在
  async validateCriticalElements(selectors: string[]): Promise<{ valid: boolean; missing: string[] }> {
    const missing: string[] = [];

    for (const selector of selectors) {
      const isVisible = await this.page.locator(selector).isVisible();
      if (!isVisible) {
        missing.push(selector);
      }
    }

    return { valid: missing.length === 0, missing };
  }

  // 完整验证流程
  async validate(options: {
    criticalSelectors?: string[];
    customErrorPatterns?: RegExp[];
  } = {}): Promise<{ valid: boolean; issues: string[] }> {
    const issues: string[] = [];

    // 1. 验证 HTTP 状态
    const statusResult = await this.validateStatus();
    if (!statusResult.valid) {
      issues.push(`HTTP 状态码异常：${statusResult.status}`);
    }

    // 2. 验证页面内容
    const errorResult = await this.validateNoErrorContent();
    if (!errorResult.valid) {
      issues.push(`页面包含错误内容：${errorResult.errors.join(', ')}`);
    }

    // 3. 验证关键元素
    if (options.criticalSelectors) {
      const elementsResult = await this.validateCriticalElements(options.criticalSelectors);
      if (!elementsResult.valid) {
        issues.push(`关键元素缺失：${elementsResult.missing.join(', ')}`);
      }
    }

    return { valid: issues.length === 0, issues };
  }
}

// 使用示例
test('登录页面验证', async ({ page }) => {
  await page.goto('/login');

  const validator = new ScreenshotValidator(page);
  const result = await validator.validate({
    criticalSelectors: ['#username', '#password', 'text=登录']
  });

  expect(result.valid).toBe(true);
  if (!result.valid) {
    console.error('验证失败:', result.issues);
  }

  await page.screenshot({ path: 'login.png' });
});
```

### 2. Bug 自动上报工具

```typescript
// utils/bug-reporter.ts
import { writeFileSync } from 'fs';

interface BugReport {
  id: string;
  title: string;
  severity: 'P0' | 'P1' | 'P2' | 'P3';
  description: string;
  steps: string[];
  evidence: {
    screenshot?: string;
    consoleLogs?: string;
    networkLogs?: string;
  };
  detectedAt: string;
  status: 'open' | 'fixed' | 'closed';
}

export class BugReporter {
  private bugs: BugReport[] = [];

  async report(options: {
    title: string;
    severity: BugReport['severity'];
    description: string;
    steps: string[];
    evidence?: BugReport['evidence'];
  }): Promise<BugReport> {
    const bug: BugReport = {
      id: `BUG-${Date.now()}`,
      title: `[测试发现] ${options.title}`,
      severity: options.severity,
      description: options.description,
      steps: options.steps,
      evidence: options.evidence || {},
      detectedAt: new Date().toISOString(),
      status: 'open'
    };

    this.bugs.push(bug);

    // 保存到 Bug 报告文件
    this.saveToFile();

    // P0/P1 Bug 立即通知
    if (bug.severity === 'P0' || bug.severity === 'P1') {
      await this.notifyImmediate(bug);
    }

    return bug;
  }

  private saveToFile(): void {
    const reportPath = 'test-bugs/report.json';
    writeFileSync(reportPath, JSON.stringify(this.bugs, null, 2));
  }

  private async notifyImmediate(bug: BugReport): Promise<void> {
    // 发送通知到即时通讯工具
    console.error(`🚨 严重 Bug 发现: ${bug.title}`);
    console.error(`级别：${bug.severity}`);
    console.error(`时间：${bug.detectedAt}`);
  }

  getReport(): BugReport[] {
    return this.bugs;
  }
}
```

---

## 📋 检查清单

### 测试执行前

- [ ] 已配置环境对等检查
- [ ] 已定义关键元素选择器列表
- [ ] 已准备截图审查工具
- [ ] 已配置 Bug 报告流程
- [ ] **已定义预期效果验证清单** ⭐
- [ ] **已准备 AI 自主验证脚本** ⭐

### 测试执行中

- [ ] 每个截图都经过审查
- [ ] 验证 HTTP 状态码
- [ ] 验证页面内容非空
- [ ] 验证关键元素存在且内容正确
- [ ] 发现问题立即记录为 Bug
- [ ] **AI 自动访问页面验证预期效果** ⭐
- [ ] **AI 自动检查控制台日志** ⭐
- [ ] **AI 自动截图并审查** ⭐

### 测试执行后

- [ ] 生成测试质量报告
- [ ] 统计质量指标
- [ ] 列出所有发现 Bug
- [ ] 提出改进建议
- [ ] **确认 AI 已完成自主验证** ⭐
- [ ] **确认所有预期效果已验证** ⭐

### AI 自主验证专项检查

在 AI 告知用户"功能已完成"之前，必须完成以下验证：

- [ ] **服务可访问性**：目标端口可访问，HTTP 返回 200
- [ ] **页面加载验证**：页面在 3 秒内完成加载
- [ ] **预期 UI 元素**：所有预期 UI 元素可见
- [ ] **视觉完整性**：无 404/空白/错位
- [ ] **控制台无错误**：无 JS 错误、无 404 请求
- [ ] **功能可交互**：关键按钮/链接可点击并响应
- [ ] **截图审查通过**：截图验证无视觉问题

---

## 🔗 相关文档

- [E2E 测试流程](04-E2E_TESTING_FLOW.md) - 15 层测试金字塔
- [质量门禁](05-QUALITY_GATE.md) - 测试通过标准
- [确定性开发规范](14-DETERMINISTIC_DEVELOPMENT.md) - Mock 模式控制

---

*版本：1.0.0*
*最后更新：2026-03-12*
*基于测试真实性验证最佳实践*

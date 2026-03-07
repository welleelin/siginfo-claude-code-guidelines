# E2E 测试流程

> 版本：1.0.0
> 最后更新：2026-03-07

---

## 📋 概述

端到端（E2E）测试验证完整的用户流程，确保系统各部分正确集成。

---

## 🎯 测试层次

### 第一层：前端 Mock 测试 ✅ 允许 Mock

**目标**：验证前端页面交互正确

**方法**：
- 使用 Mock 数据
- 不依赖后端
- 快速验证 UI 逻辑

**示例**：
```typescript
test('登录表单验证', async ({ page }) => {
  await page.goto('/login')
  
  // 使用 Mock 数据
  await page.route('**/api/login', route => {
    route.fulfill({
      status: 200,
      body: JSON.stringify({ success: true, token: 'mock-token' })
    })
  })
  
  await page.fill('[name="email"]', 'user@example.com')
  await page.fill('[name="password"]', 'password123')
  await page.click('button[type="submit"]')
  
  await expect(page).toHaveURL('/dashboard')
})
```

### 第二层：后端 API 测试 ❌ 禁止 Mock

**目标**：验证后端 API 功能正确

**方法**：
- 使用真实数据库
- 真实 API 调用
- 验证业务逻辑

**示例**：
```typescript
describe('登录 API', () => {
  it('应该成功登录有效用户', async () => {
    const response = await request(app)
      .post('/api/login')
      .send({
        email: 'user@example.com',
        password: 'password123'
      })
    
    expect(response.status).toBe(200)
    expect(response.body.success).toBe(true)
    expect(response.body.token).toBeDefined()
  })
})
```

### 第三层：前后端联调测试 ❌ 禁止 Mock

**目标**：验证前后端集成正常

**方法**：
- 真实前端 + 真实后端
- 完整数据流
- 验证集成点

**示例**：
```typescript
test('完整登录流程', async ({ page }) => {
  // 启动真实后端服务
  await page.goto('http://localhost:3000/login')
  
  // 真实 API 调用
  await page.fill('[name="email"]', 'user@example.com')
  await page.fill('[name="password"]', 'password123')
  await page.click('button[type="submit"]')
  
  // 验证真实响应
  await expect(page).toHaveURL('http://localhost:3000/dashboard')
  await expect(page.locator('.user-name')).toHaveText('User Name')
})
```

---

## 🔧 工具配置

### Playwright 配置

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  use: {
    baseURL: 'http://localhost:3000',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  webServer: {
    command: 'npm run dev',
    port: 3000,
    reuseExistingServer: true,
  },
})
```

### 运行测试

```bash
# 运行所有 E2E 测试
npx playwright test

# 运行特定测试
npx playwright test login.spec.ts

# UI 模式
npx playwright test --ui

# 调试模式
npx playwright test --debug
```

---

## 📊 测试报告

### 生成报告

```bash
# 运行测试并生成报告
npx playwright test --reporter=html

# 查看报告
npx playwright show-report
```

### 报告内容

- 测试通过率
- 失败截图
- 失败视频
- 执行时间
- 错误堆栈

---

## 🔗 相关文档

- [行动准则](01-ACTION_GUIDELINES.md)
- [TDD 开发流程](02-TDD_WORKFLOW.md)
- [质量门禁](05-QUALITY_GATE.md)

---

*版本：1.0.0 | 最后更新：2026-03-07*

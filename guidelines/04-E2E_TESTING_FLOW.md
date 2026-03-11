# E2E 测试流程

> 版本：1.0.0
> 最后更新：2026-03-10

---

## 📋 概述

端到端（E2E）测试验证完整的用户流程，确保系统各部分正确集成。

> **关键前提**：在进行 API 测试之前，务必确保所有 API 都已开发完整。未完整的 API 必须先开发完成，再进行下一步测试。

---

## 🎯 完整测试层次

```
┌─────────────────────────────────────────────────────────────────┐
│                    完整测试验证流程                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Phase 1: 前端 Mock 测试                                         │
│  ├── 组件单元测试                                               │
│  ├── UI 快照测试                                                  │
│  └── 状态：✅ 使用 Mock 数据                                        │
│                                                                 │
│  Phase 2: 后端 API 测试                                          │
│  ├── API 端点测试                                                  │
│  ├── 数据库集成测试                                             │
│  └── 状态：✅ 使用真实 API                                         │
│                                                                 │
│  Phase 3: 前后端联调测试                                         │
│  ├── 完整用户流程测试                                           │
│  ├── 跨系统集成测试                                             │
│  └── 状态：✅ 使用真实 API                                         │
│                                                                 │
│  Phase 4: E2E 端到端测试                                         │
│  ├── Playwright 自动化测试                                        │
│  ├── 关键用户路径验证                                           │
│  └── 状态：✅ 使用真实 API                                         │
│                                                                 │
│  Phase 5: Shannon 安全渗透测试 ⭐                                │
│  ├── 源代码漏洞扫描                                             │
│  ├── 自主攻击验证                                               │
│  ├── PoC 生成                                                      │
│  └── 状态：✅ 白盒测试 + 真实攻击                                   │
│                                                                 │
│  Phase 6: 人类介入测试                                           │
│  ├── 用户体验评审                                               │
│  ├── 设计标注反馈（Agentation）                                  │
│  └── 状态：⚠️ 需要人类参与                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

详见：[Shannon 集成指南](../docs/SHANNON_INTEGRATION.md)

---

## 🔍 前置检查：API 完整性验证

### 为什么需要 API 完整性检查？

在不完整的 API 上进行测试会导致：
- ❌ 测试结果不可信
- ❌ 浪费测试时间
- ❌ 难以定位问题根源
- ❌ 影响质量评估

### API 完整性检查流程

#### Step 1: 列出所有需要的 API

```bash
# 根据需求文档列出 API 清单
cat requirements.md | grep "API:"

# 或手动创建 API 清单
cat > api-checklist.md <<EOF
## 用户登录功能 API 清单

- [ ] POST /api/auth/login - 用户登录
- [ ] POST /api/auth/logout - 用户登出
- [ ] GET /api/auth/verify - 验证 Token
- [ ] GET /api/user/profile - 获取用户信息
- [ ] PUT /api/user/profile - 更新用户信息
EOF
```

#### Step 2: 检查 API 实现状态

```bash
# 检查路由定义
grep -r "POST.*\/api\/auth\/login" src/

# 检查控制器实现
ls -la src/controllers/auth.ts

# 检查测试文件
ls -la tests/api/auth.test.ts

# 运行 API 健康检查
curl http://localhost:8000/api/health
```

#### Step 3: 验证 API 功能

```bash
# 测试 API 是否可用
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'

# 预期响应：
# {
#   "success": true,
#   "token": "eyJhbGc...",
#   "user": { "id": "123", "email": "test@example.com" }
# }
```

#### Step 4: 生成完整性报告

```markdown
## API 完整性检查报告

**检查时间**：2026-03-07 10:00
**功能模块**：用户登录

### 已完成的 API（4/5）

| API | 路由 | 控制器 | 测试 | 状态 |
|-----|------|--------|------|------|
| 用户登录 | ✅ | ✅ | ✅ | ✅ 完成 |
| Token 验证 | ✅ | ✅ | ✅ | ✅ 完成 |
| 获取用户信息 | ✅ | ✅ | ✅ | ✅ 完成 |
| 更新用户信息 | ✅ | ✅ | ✅ | ✅ 完成 |

### 未完成的 API（1/5）

| API | 缺失项 | 预计完成 | 影响 |
|-----|--------|---------|------|
| 用户登出 | 控制器实现 | 2026-03-15 | 非核心功能 |

### 决策

✅ **可以继续测试**
- 核心 API 已完成（4/5）
- 登出功能暂时使用 Mock
- 后续替换为真实 API

⚠️ **需要标记 Mock**
```typescript
// ⚠️ MOCK: 登出 API 未完成，预计 2026-03-15 替换
await page.route('**/api/auth/logout', route => {
  route.fulfill({ status: 200, body: JSON.stringify({ success: true }) })
})
```
```

#### Step 5: 决策是否继续测试

```
API 完整性检查结果
       │
       ▼
所有核心 API 都已完成？
       │
       ├─ 是 ──▶ ✅ 继续进行 E2E 测试
       │
       └─ 否 ──▶ 评估影响
                  │
                  ├─ 核心 API 未完成
                  │   └─▶ ❌ 阻止测试
                  │        └─▶ 优先开发核心 API
                  │
                  └─ 非核心 API 未完成
                      └─▶ ⚠️ 标记 Mock
                           └─▶ 继续测试
                                └─▶ 后续替换
```

---

## 🎯 测试层次

> **核心原则**：前端和后端可以独立使用 Mock 测试，但前后端联调和 E2E 测试必须使用真实数据，确保生产环境 95% 无 Bug。

### 第一层：单元测试 ✅ 允许 Mock

#### 前端单元测试

**目标**：验证前端组件逻辑正确

**方法**：
- 使用 Mock 数据
- 不依赖后端
- 快速验证 UI 逻辑
- 覆盖率 ≥ 80%

**示例**：
```typescript
// ⚠️ MOCK: 前端单元测试，允许 Mock API
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

#### 后端单元测试

**目标**：验证后端服务逻辑正确

**方法**：
- Mock 外部依赖（数据库/第三方 API）
- 验证业务逻辑
- 覆盖率 ≥ 80%

**示例**：
```typescript
// ⚠️ MOCK: 后端单元测试，允许 Mock 数据库
describe('UserService', () => {
  it('应该创建新用户', async () => {
    // Mock 数据库
    const mockDb = {
      users: {
        create: jest.fn().mockResolvedValue({
          id: '123',
          email: 'user@example.com'
        })
      }
    }

    const userService = new UserService(mockDb)
    const user = await userService.createUser({
      email: 'user@example.com',
      password: 'password123'
    })

    expect(user.id).toBe('123')
    expect(mockDb.users.create).toHaveBeenCalled()
  })
})
```

### 第二层：集成测试 ⚠️ 部分 Mock

#### 后端 API 测试

**目标**：验证后端 API 功能正确

**方法**：
- ✅ 使用真实数据库
- ⚠️ 可 Mock 外部第三方 API
- ❌ 禁止 Mock 核心业务逻辑
- 验证 API 接口正确性

**示例**：
```typescript
describe('登录 API', () => {
  beforeAll(async () => {
    // 使用真实数据库
    await setupTestDatabase()
    await seedTestData()
  })

  it('应该成功登录有效用户', async () => {
    // 真实数据库 + 真实 API
    const response = await request(app)
      .post('/api/login')
      .send({
        email: 'user@example.com',
        password: 'password123'
      })

    expect(response.status).toBe(200)
    expect(response.body.success).toBe(true)
    expect(response.body.token).toBeDefined()

    // 验证数据库状态
    const user = await db.users.findOne({ email: 'user@example.com' })
    expect(user.lastLoginAt).toBeDefined()
  })

  it('应该拒绝无效密码', async () => {
    const response = await request(app)
      .post('/api/login')
      .send({
        email: 'user@example.com',
        password: 'wrong-password'
      })

    expect(response.status).toBe(401)
    expect(response.body.success).toBe(false)
  })

  afterAll(async () => {
    await cleanupTestDatabase()
  })
})
```

### 第三层：前后端联调测试 ❌ 严格禁止 Mock

**目标**：验证前后端集成正常，确保生产环境 95% 无 Bug

**强制要求**：
1. ✅ 真实前端 + 真实后端
2. ✅ 真实数据库 + 真实数据
3. ✅ 完整业务流程
4. ✅ 按需求规定的流程测试
5. ❌ 严格禁止任何 Mock

**方法**：
- 启动真实前端服务（如 http://localhost:3000）
- 启动真实后端服务（如 http://localhost:8000）
- 连接真实数据库
- 使用真实数据
- 验证完整数据流

**示例**：
```typescript
// ❌ 禁止 Mock：前后端联调测试必须使用真实环境
test('完整登录流程 - 联调测试', async ({ page }) => {
  // 1. 确保真实服务已启动
  const frontendUrl = 'http://localhost:3000'
  const backendUrl = 'http://localhost:8000'

  // 2. 验证服务可用
  const healthCheck = await fetch(`${backendUrl}/health`)
  expect(healthCheck.ok).toBe(true)

  // 3. 访问真实前端
  await page.goto(`${frontendUrl}/login`)

  // 4. 执行真实登录流程
  await page.fill('[name="email"]', 'test@example.com')
  await page.fill('[name="password"]', 'Test123456!')
  await page.click('button[type="submit"]')

  // 5. 验证真实响应
  await expect(page).toHaveURL(`${frontendUrl}/dashboard`)
  await expect(page.locator('.user-name')).toHaveText('Test User')

  // 6. 验证数据库状态
  const user = await db.users.findOne({ email: 'test@example.com' })
  expect(user.lastLoginAt).toBeDefined()
  expect(new Date(user.lastLoginAt).getTime()).toBeGreaterThan(Date.now() - 5000)

  // 7. 验证 Token 有效性
  const token = await page.evaluate(() => localStorage.getItem('token'))
  expect(token).toBeDefined()

  const verifyResponse = await fetch(`${backendUrl}/api/verify`, {
    headers: { Authorization: `Bearer ${token}` }
  })
  expect(verifyResponse.ok).toBe(true)
})

// 测试异常流程
test('登录失败流程 - 联调测试', async ({ page }) => {
  await page.goto('http://localhost:3000/login')

  // 使用错误密码
  await page.fill('[name="email"]', 'test@example.com')
  await page.fill('[name="password"]', 'wrong-password')
  await page.click('button[type="submit"]')

  // 验证错误提示
  await expect(page.locator('.error-message')).toHaveText('用户名或密码错误')

  // 验证未跳转
  await expect(page).toHaveURL('http://localhost:3000/login')

  // 验证数据库未更新
  const user = await db.users.findOne({ email: 'test@example.com' })
  const lastLoginBefore = user.lastLoginAt

  // 等待 1 秒确认没有更新
  await page.waitForTimeout(1000)
  const userAfter = await db.users.findOne({ email: 'test@example.com' })
  expect(userAfter.lastLoginAt).toEqual(lastLoginBefore)
})
```

### 第四层：E2E 端到端测试 ❌ 严格禁止 Mock

**目标**：验证完整用户流程，确保生产环境 95% 无 Bug

**浏览器模式配置**：

| 测试类型 | 浏览器模式 | 配置 | 用途 |
|---------|----------|------|------|
| **自动 E2E 测试** | 无头模式（headless） | `headless: true` | CI/CD、自动化验证、行为准则测试 |
| **人类介入测试** | 有头模式（headed） | `headless: false` | 人类观看、Agentation 标注 |
| **Self-Driving 评审** | 有头模式（headed） | `headless: false` | AI 自主标注、人类观看 |

**核心原则**：
- ✅ **自动 E2E 测试必须使用无头模式** - 行为准则测试环节中，自动 E2E 测试阶段使用 headless 模式
- ✅ **人类介入测试使用有头模式** - 需要人类观看或参与时使用 headed
- ✅ **资源配置优化** - 无头模式节省资源，适合 CI/CD 和自动化

**强制要求**：
1. ✅ 完整真实环境（前端 + 后端 + 数据库）
2. ✅ 真实用户操作流程
3. ✅ 真实数据和业务逻辑
4. ✅ 覆盖核心业务路径
5. ✅ 验证每个步骤的正确性
6. ❌ 严格禁止任何 Mock

**方法**：
- 模拟真实用户操作
- 从登录到业务完成的完整路径
- 验证每个步骤的数据正确性
- 检查最终结果的准确性

### 第五层：Shannon 安全渗透测试 ⭐ 新增

**目标**：AI 自主渗透测试，发现并验证安全漏洞

**强制要求**：
1. ✅ E2E 测试已通过
2. ✅ 真实环境（前端 + 后端 + 数据库）
3. ✅ 源代码可访问（白盒测试）
4. ✅ AI 凭证配置（Anthropic API Key）
5. ✅ Docker 环境运行
6. ❌ 严格禁止 Mock 模式

**方法**：
- Shannon 分析源代码识别攻击向量
- 自主执行真实攻击验证漏洞
- 生成可复现的 PoC（Proof-of-Concept）
- 输出精确到源代码位置的漏洞报告

**示例**：
```bash
# 启动 Shannon 渗透测试
cd /opt/shannon
./shannon start URL=http://localhost:3000 REPO=/path/to/project

# 监控进度
./shannon logs

# 查看报告
cat workspaces/pentest-*/reports/*.md
```

**漏洞覆盖**：
| 类型 | Shannon 能力 |
|------|------------|
| SQL 注入 | ✅ 检测 + 真实利用 |
| XSS | ✅ 检测 + 真实利用 |
| SSRF | ✅ 检测 + 真实利用 |
| 认证绕过 | ✅ 检测 + 真实利用 |
| 权限提升 | ✅ 检测 + 真实利用 |
| 命令注入 | ✅ 检测 + 真实利用 |

**与 E2E 测试的区别**：
| 维度 | E2E 测试 | Shannon 渗透测试 |
|------|---------|-----------------|
| **目的** | 功能正确性 | 安全性验证 |
| **测试内容** | 用户流程 | 攻击向量 |
| **数据** | 真实业务数据 | 攻击载荷（Payload） |
| **输出** | 测试通过/失败 | 漏洞报告 + PoC |
| **运行时机** | 每次提交 | 发布前/定期 |

详见：[Shannon 集成指南](../docs/SHANNON_INTEGRATION.md)

**示例**：
```typescript
// ❌ 禁止 Mock：E2E 测试必须使用完整真实环境
test('完整电商购物流程 - E2E 测试', async ({ page }) => {
  const baseUrl = 'http://localhost:3000'
  const apiUrl = 'http://localhost:8000'

  // 步骤 1: 用户登录
  await page.goto(`${baseUrl}/login`)
  await page.fill('[name="email"]', 'buyer@example.com')
  await page.fill('[name="password"]', 'Buyer123!')
  await page.click('button[type="submit"]')
  await expect(page).toHaveURL(`${baseUrl}/dashboard`)

  // 验证数据库：用户已登录
  const user = await db.users.findOne({ email: 'buyer@example.com' })
  expect(user.isOnline).toBe(true)

  // 步骤 2: 浏览商品
  await page.goto(`${baseUrl}/products`)
  await page.click('[data-product-id="prod-001"]')
  await expect(page.locator('.product-name')).toHaveText('测试商品 A')

  // 步骤 3: 添加到购物车
  await page.click('button:has-text("加入购物车")')
  await expect(page.locator('.cart-count')).toHaveText('1')

  // 验证数据库：购物车已更新
  const cart = await db.carts.findOne({ userId: user.id })
  expect(cart.items).toHaveLength(1)
  expect(cart.items[0].productId).toBe('prod-001')

  // 步骤 4: 进入购物车
  await page.click('.cart-icon')
  await expect(page).toHaveURL(`${baseUrl}/cart`)
  await expect(page.locator('.cart-item')).toHaveCount(1)

  // 步骤 5: 结算
  await page.click('button:has-text("去结算")')
  await expect(page).toHaveURL(`${baseUrl}/checkout`)

  // 填写收货地址
  await page.fill('[name="address"]', '测试地址 123 号')
  await page.fill('[name="phone"]', '13800138000')

  // 步骤 6: 选择支付方式
  await page.click('[data-payment="alipay"]')

  // 步骤 7: 提交订单
  await page.click('button:has-text("提交订单")')

  // 等待订单创建
  await page.waitForURL(`${baseUrl}/order/success`)

  // 验证数据库：订单已创建
  const order = await db.orders.findOne({ userId: user.id })
  expect(order).toBeDefined()
  expect(order.status).toBe('pending_payment')
  expect(order.items).toHaveLength(1)
  expect(order.totalAmount).toBe(99.99)
  expect(order.shippingAddress).toBe('测试地址 123 号')

  // 验证数据库：购物车已清空
  const cartAfter = await db.carts.findOne({ userId: user.id })
  expect(cartAfter.items).toHaveLength(0)

  // 验证数据库：库存已扣减
  const product = await db.products.findOne({ id: 'prod-001' })
  expect(product.stock).toBe(99) // 假设初始库存 100

  // 步骤 8: 模拟支付回调（真实环境）
  const paymentResponse = await fetch(`${apiUrl}/api/payment/callback`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      orderId: order.id,
      status: 'success',
      transactionId: 'real-tx-' + Date.now()
    })
  })
  expect(paymentResponse.ok).toBe(true)

  // 验证数据库：订单状态已更新
  const orderAfterPayment = await db.orders.findOne({ id: order.id })
  expect(orderAfterPayment.status).toBe('paid')
  expect(orderAfterPayment.paidAt).toBeDefined()

  // 步骤 9: 查看订单详情
  await page.goto(`${baseUrl}/orders/${order.id}`)
  await expect(page.locator('.order-status')).toHaveText('已支付')
  await expect(page.locator('.order-amount')).toHaveText('¥99.99')

  // 最终验证：完整流程无误
  console.log('✅ E2E 测试通过：完整购物流程正常')
})

// 测试异常流程
test('库存不足流程 - E2E 测试', async ({ page }) => {
  // 1. 设置库存为 0
  await db.products.updateOne(
    { id: 'prod-002' },
    { $set: { stock: 0 } }
  )

  // 2. 尝试购买
  await page.goto('http://localhost:3000/products/prod-002')
  await page.click('button:has-text("加入购物车")')

  // 3. 验证错误提示
  await expect(page.locator('.error-message')).toHaveText('商品库存不足')

  // 4. 验证购物车未更新
  const user = await db.users.findOne({ email: 'buyer@example.com' })
  const cart = await db.carts.findOne({ userId: user.id })
  expect(cart.items.find(item => item.productId === 'prod-002')).toBeUndefined()
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
    // 默认使用无头模式（自动 E2E 测试）
    headless: true,
  },
  webServer: {
    command: 'npm run dev',
    port: 3000,
    reuseExistingServer: true,
  },
  // 自定义模式：人类介入测试时使用有头模式
  projects: [
    {
      name: 'automated',  // 自动 E2E 测试（无头模式）
      use: {
        headless: true,
      },
    },
    {
      name: 'human-in-the-loop',  // 人类介入测试（有头模式）
      use: {
        headless: false,
      },
    },
  ],
})
```

### 运行测试

```bash
# 运行所有 E2E 测试（默认无头模式）
npx playwright test

# 运行特定测试（无头模式）
npx playwright test login.spec.ts

# 人类介入测试模式（有头模式）
npx playwright test --project=human-in-the-loop

# UI 模式（有头）
npx playwright test --ui

# 调试模式（有头）
npx playwright test --debug
```

### 行为准则测试环节配置

在行为准则测试环节中，自动 E2E 测试阶段**必须使用无头模式**：

```bash
# ✅ 正确：自动 E2E 测试（无头模式）
npx playwright test --project=automated

# ✅ 正确：使用默认配置（无头模式）
npx playwright test

# ❌ 错误：自动测试不应该使用有头模式
# npx playwright test --project=human-in-the-loop  # 仅在人类介入时使用
```

**脚本配置示例**：

```json
// package.json
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:headed": "playwright test --project=human-in-the-loop",
    "test:e2e:ui": "playwright test --ui",
    "test:e2e:debug": "playwright test --debug"
  }
}
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

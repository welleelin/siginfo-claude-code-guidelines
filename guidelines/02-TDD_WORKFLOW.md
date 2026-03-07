# TDD 开发流程

> 版本：1.0.0
> 最后更新：2026-03-07

---

## 📋 概述

测试驱动开发（TDD）是一种软件开发方法，要求在编写功能代码之前先编写测试代码。

---

## 🎯 TDD 核心原则

1. **先写测试** - 在实现功能前先写测试
2. **小步迭代** - 每次只实现一个小功能
3. **快速反馈** - 频繁运行测试获得反馈
4. **重构优化** - 在测试保护下安全重构

---

## 🔄 TDD 三步循环

```
┌─────────────────────────────────────────────────────────────┐
│                    TDD 三步循环                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐          │
│  │   RED    │─────▶│  GREEN   │─────▶│ REFACTOR │          │
│  │ 写失败测试│      │ 实现功能  │      │ 重构优化  │          │
│  └──────────┘      └──────────┘      └──────────┘          │
│       │                                     │               │
│       │                                     │               │
│       └─────────────────────────────────────┘               │
│                    循环迭代                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔴 Step 1: RED（写失败测试）

### 目标
编写一个失败的测试，明确要实现的功能

### 步骤

1. **分析需求**
   - 理解要实现的功能
   - 确定输入和输出
   - 识别边界条件

2. **编写测试用例**
   ```typescript
   // 示例：用户登录功能测试
   describe('用户登录', () => {
     it('应该成功登录有效用户', async () => {
       const result = await login('user@example.com', 'password123')
       expect(result.success).toBe(true)
       expect(result.token).toBeDefined()
     })

     it('应该拒绝无效密码', async () => {
       const result = await login('user@example.com', 'wrongpassword')
       expect(result.success).toBe(false)
       expect(result.error).toBe('密码错误')
     })
   })
   ```

3. **运行测试**
   ```bash
   npm test
   ```

4. **确认测试失败**
   - 测试应该失败（红色）
   - 失败原因：功能尚未实现

### 为什么测试必须先失败？

- ✅ 确保测试真的在测试功能
- ✅ 避免测试永远通过（假阳性）
- ✅ 验证测试逻辑正确

---

## 🟢 Step 2: GREEN（实现功能）

### 目标
编写最小代码让测试通过

### 步骤

1. **实现最小功能**
   ```typescript
   // 示例：实现登录功能
   async function login(email: string, password: string) {
     // 最小实现：只让测试通过
     const user = await findUserByEmail(email)
     if (!user) {
       return { success: false, error: '用户不存在' }
     }

     const isValid = await verifyPassword(password, user.passwordHash)
     if (!isValid) {
       return { success: false, error: '密码错误' }
     }

     const token = generateToken(user.id)
     return { success: true, token }
   }
   ```

2. **运行测试**
   ```bash
   npm test
   ```

3. **确认测试通过**
   - 测试应该通过（绿色）
   - 所有断言都满足

### 为什么只写最小代码？

- ✅ 避免过度设计
- ✅ 快速验证方向正确
- ✅ 减少不必要的复杂度

---

## 🔵 Step 3: REFACTOR（重构优化）

### 目标
在测试保护下优化代码

### 步骤

1. **识别重构机会**
   - 重复代码
   - 复杂逻辑
   - 不清晰的命名
   - 性能问题

2. **执行重构**
   ```typescript
   // 重构前
   async function login(email: string, password: string) {
     const user = await findUserByEmail(email)
     if (!user) {
       return { success: false, error: '用户不存在' }
     }
     const isValid = await verifyPassword(password, user.passwordHash)
     if (!isValid) {
       return { success: false, error: '密码错误' }
     }
     const token = generateToken(user.id)
     return { success: true, token }
   }

   // 重构后：提取验证逻辑
   async function login(email: string, password: string) {
     const user = await authenticateUser(email, password)
     if (!user) {
       return { success: false, error: '认证失败' }
     }

     const token = generateToken(user.id)
     return { success: true, token }
   }

   async function authenticateUser(email: string, password: string) {
     const user = await findUserByEmail(email)
     if (!user) return null

     const isValid = await verifyPassword(password, user.passwordHash)
     return isValid ? user : null
   }
   ```

3. **运行测试**
   ```bash
   npm test
   ```

4. **确认测试仍然通过**
   - 重构不应该破坏功能
   - 所有测试仍然通过

### 常见重构模式

| 模式 | 说明 | 示例 |
|------|------|------|
| 提取函数 | 将复杂逻辑提取为独立函数 | `authenticateUser()` |
| 提取变量 | 将复杂表达式提取为变量 | `const isAuthenticated = ...` |
| 重命名 | 改进命名清晰度 | `user` → `authenticatedUser` |
| 消除重复 | 合并重复代码 | 提取公共逻辑 |

---

## 📊 测试覆盖率要求

### 最低覆盖率：80%

**覆盖类型**：
- 语句覆盖率（Statement Coverage）≥ 80%
- 分支覆盖率（Branch Coverage）≥ 80%
- 函数覆盖率（Function Coverage）≥ 80%
- 行覆盖率（Line Coverage）≥ 80%

### 检查覆盖率

```bash
# 运行测试并生成覆盖率报告
npm test -- --coverage

# 查看覆盖率报告
open coverage/index.html
```

### 覆盖率报告示例

```
File                | % Stmts | % Branch | % Funcs | % Lines |
--------------------|---------|----------|---------|---------|
auth/login.ts       |   95.00 |    90.00 |  100.00 |   95.00 |
auth/register.ts    |   85.00 |    80.00 |   90.00 |   85.00 |
auth/verify.ts      |   90.00 |    85.00 |  100.00 |   90.00 |
--------------------|---------|----------|---------|---------|
All files           |   90.00 |    85.00 |   96.67 |   90.00 |
```

---

## 🧪 测试类型

### 1. 单元测试（Unit Tests）

**目标**：测试单个函数或类

**示例**：
```typescript
describe('generateToken', () => {
  it('应该生成有效的 JWT token', () => {
    const token = generateToken('user-123')
    expect(token).toBeDefined()
    expect(token.split('.')).toHaveLength(3)
  })

  it('应该包含用户 ID', () => {
    const token = generateToken('user-123')
    const payload = decodeToken(token)
    expect(payload.userId).toBe('user-123')
  })
})
```

### 2. 集成测试（Integration Tests）

**目标**：测试多个模块的集成

**示例**：
```typescript
describe('用户认证流程', () => {
  it('应该完成完整的注册登录流程', async () => {
    // 注册
    const registerResult = await register({
      email: 'test@example.com',
      password: 'password123'
    })
    expect(registerResult.success).toBe(true)

    // 登录
    const loginResult = await login('test@example.com', 'password123')
    expect(loginResult.success).toBe(true)
    expect(loginResult.token).toBeDefined()
  })
})
```

### 3. E2E 测试（End-to-End Tests）

**目标**：测试完整用户流程

**示例**：
```typescript
test('用户登录流程', async ({ page }) => {
  // 访问登录页
  await page.goto('/login')

  // 填写表单
  await page.fill('[name="email"]', 'user@example.com')
  await page.fill('[name="password"]', 'password123')

  // 点击登录
  await page.click('button[type="submit"]')

  // 验证跳转到首页
  await expect(page).toHaveURL('/dashboard')
})
```

---

## 🎯 TDD 最佳实践

### 1. 测试应该独立

```typescript
// ❌ 错误：测试之间有依赖
let user: User

test('创建用户', () => {
  user = createUser('test@example.com')
  expect(user).toBeDefined()
})

test('更新用户', () => {
  updateUser(user.id, { name: 'New Name' })  // 依赖上一个测试
  expect(user.name).toBe('New Name')
})

// ✅ 正确：每个测试独立
test('创建用户', () => {
  const user = createUser('test@example.com')
  expect(user).toBeDefined()
})

test('更新用户', () => {
  const user = createUser('test@example.com')  // 独立创建
  updateUser(user.id, { name: 'New Name' })
  expect(user.name).toBe('New Name')
})
```

### 2. 测试应该快速

```typescript
// ❌ 错误：测试太慢
test('发送邮件', async () => {
  await sendEmail('test@example.com', 'Hello')  // 真实发送邮件
  // 等待邮件到达...
})

// ✅ 正确：使用 Mock
test('发送邮件', async () => {
  const mockSendEmail = jest.fn()
  await sendEmail('test@example.com', 'Hello')
  expect(mockSendEmail).toHaveBeenCalled()
})
```

### 3. 测试应该清晰

```typescript
// ❌ 错误：测试不清晰
test('test1', () => {
  const r = f('a', 'b')
  expect(r).toBe(true)
})

// ✅ 正确：测试清晰
test('应该验证有效的邮箱地址', () => {
  const isValid = validateEmail('user@example.com')
  expect(isValid).toBe(true)
})
```

### 8. 确定性测试原则

**目标**：确保测试结果可重复

**原则**：
- 隔离时间依赖（使用 `jest.useFakeTimers()`）
- 隔离随机性（使用固定种子）
- Mock 外部依赖（使用 MSW/nock）
- 确定性排序（显式排序规则）

**示例**：

```typescript
// ❌ 错误：依赖真实时间
test('创建用户', () => {
  const user = createUser('Alice')
  expect(user.createdAt).toBe(Date.now()) // 测试会失败
})

// ✅ 正确：Mock 时间
test('创建用户', () => {
  jest.useFakeTimers()
  jest.setSystemTime(new Date('2024-03-07T00:00:00Z'))

  const user = createUser('Alice')
  expect(user.createdAt).toBe(1709769600000) // 测试通过

  jest.useRealTimers()
})

// ❌ 错误：依赖随机性
test('生成 ID', () => {
  const id = generateId()
  expect(id).toBe('abc123') // 测试会失败
})

// ✅ 正确：使用固定种子
import seedrandom from 'seedrandom'

test('生成 ID', () => {
  const rng = seedrandom('fixed-seed')
  const id = generateId(rng)
  expect(id).toBe('abc123') // 测试通过
})

// ❌ 错误：依赖真实 API
test('获取用户', async () => {
  const user = await fetchUser('123')
  expect(user.name).toBe('Alice') // 测试可能失败
})

// ✅ 正确：使用 MSW Mock
import { rest } from 'msw'
import { setupServer } from 'msw/node'

const server = setupServer(
  rest.get('/api/users/:id', (req, res, ctx) => {
    return res(ctx.json({ id: '123', name: 'Alice' }))
  })
)

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())

test('获取用户', async () => {
  const user = await fetchUser('123')
  expect(user.name).toBe('Alice') // 测试通过
})
```

**验证方法**：

```bash
# 运行 3 次测试，验证结果一致
npm test -- --testNamePattern="用户登录" --runInBand
npm test -- --testNamePattern="用户登录" --runInBand
npm test -- --testNamePattern="用户登录" --runInBand

# 使用确定性验证脚本
./scripts/verify-determinism.sh "用户登录" 3
```

**相关文档**：[确定性开发规范](14-DETERMINISTIC_DEVELOPMENT.md)

---

## 🔧 TDD 工具

### Jest（JavaScript/TypeScript）

```bash
# 安装
npm install --save-dev jest @types/jest

# 配置
# jest.config.js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  coverageThreshold: {
    global: {
      statements: 80,
      branches: 80,
      functions: 80,
      lines: 80
    }
  }
}

# 运行
npm test
npm test -- --coverage
npm test -- --watch
```

### Playwright（E2E 测试）

```bash
# 安装
npm install --save-dev @playwright/test

# 配置
# playwright.config.ts
import { defineConfig } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  use: {
    baseURL: 'http://localhost:3000',
  },
})

# 运行
npx playwright test
npx playwright test --ui
```

---

## 📝 TDD 检查清单

### 开始前

- [ ] 理解需求
- [ ] 确定测试场景
- [ ] 准备测试环境

### RED 阶段

- [ ] 编写测试用例
- [ ] 运行测试
- [ ] 确认测试失败

### GREEN 阶段

- [ ] 实现最小功能
- [ ] 运行测试
- [ ] 确认测试通过

### REFACTOR 阶段

- [ ] 识别重构机会
- [ ] 执行重构
- [ ] 运行测试
- [ ] 确认测试仍然通过

### 完成后

- [ ] 检查覆盖率 ≥ 80%
- [ ] 代码审查
- [ ] 提交代码

---

## 🔗 相关文档

- [行动准则](01-ACTION_GUIDELINES.md)
- [E2E 测试流程](04-E2E_TESTING_FLOW.md)
- [质量门禁](05-QUALITY_GATE.md)

---

## 📝 更新日志

| 日期 | 版本 | 更新内容 | 更新人 |
|------|------|---------|--------|
| 2026-03-07 | 1.0.0 | 初始版本 | - |

---

> **TDD 核心理念**：
> 1. 先写测试 - 明确目标
> 2. 小步迭代 - 快速反馈
> 3. 重构优化 - 持续改进
> 4. 测试保护 - 安全重构

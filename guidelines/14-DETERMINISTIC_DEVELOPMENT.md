# 确定性开发规范

> **版本**：1.0.0
> **最后更新**：2026-03-07
> **基于**：软件工程最佳实践 + 长期记忆系统集成

---

## 📋 概述

本文档明确确定性开发的定义、验证机制和编码原则，确保开发结果可重复、可验证、可追溯。

### 核心价值

| 价值点 | 说明 |
|--------|------|
| 🎯 **可重复性** | 相同输入 → 相同输出 |
| ✅ **可验证性** | 结果可通过测试验证 |
| 📝 **可追溯性** | 决策和状态可追溯 |
| 🔧 **可调试性** | 问题可复现和定位 |
| 🛡️ **可恢复性** | Compact 后状态可恢复 |

---

## 🎯 确定性定义

### 什么是确定性结果？

**定义**：在相同的输入条件下，系统总是产生相同的输出结果。

```
确定性系统：
输入 A → 处理 → 输出 X
输入 A → 处理 → 输出 X（相同）
输入 A → 处理 → 输出 X（相同）

非确定性系统：
输入 A → 处理 → 输出 X
输入 A → 处理 → 输出 Y（不同）
输入 A → 处理 → 输出 Z（不同）
```

### 确定性 vs 非确定性对比

| 维度 | 确定性系统 | 非确定性系统 |
|------|-----------|-------------|
| **可重复性** | ✅ 100% 可重复 | ❌ 结果不一致 |
| **可验证性** | ✅ 测试结果稳定 | ❌ 测试结果不稳定 |
| **可追溯性** | ✅ 状态可追溯 | ❌ 状态难追溯 |
| **可调试性** | ✅ 问题可复现 | ❌ 问题难复现 |
| **可恢复性** | ✅ 状态可恢复 | ❌ 状态难恢复 |

### 为什么需要确定性？

1. **测试可靠性**：测试结果稳定，不会随机失败
2. **问题可复现**：生产问题可在开发环境复现
3. **结果可验证**：开发结果可通过测试验证
4. **状态可恢复**：Compact 后可恢复到正确状态
5. **决策可追溯**：关键决策可追溯到原因

---

## 🔍 不确定性来源识别

### 6 类不确定性来源

| 类型 | 常见表现 | 改造方案 |
|------|---------|---------|
| **时间依赖** | `Date.now()`, `new Date()` | `jest.useFakeTimers()` |
| **随机性** | `Math.random()`, `crypto.randomUUID()` | `seedrandom('fixed-seed')` |
| **网络请求** | `fetch()`, `axios.get()` | MSW Mock |
| **文件系统** | `fs.readdir()`, `glob()` | 显式排序 |
| **并发操作** | `Promise.all()`, `Promise.race()` | 确定性排序 |
| **环境变量** | `process.env.NODE_ENV` | 测试环境固定配置 |

### 详细改造方案

#### 1. 时间依赖

**问题代码**：
```typescript
// ❌ 非确定性：每次运行时间不同
function createUser(name: string) {
  return {
    id: generateId(),
    name,
    createdAt: Date.now() // 不确定性来源
  }
}

test('创建用户', () => {
  const user = createUser('Alice')
  expect(user.createdAt).toBe(1709798400000) // 测试会失败
})
```

**改造方案**：
```typescript
// ✅ 确定性：使用 Mock 时间
function createUser(name: string, now: () => number = Date.now) {
  return {
    id: generateId(),
    name,
    createdAt: now() // 依赖注入
  }
}

test('创建用户', () => {
  jest.useFakeTimers()
  jest.setSystemTime(new Date('2024-03-07T00:00:00Z'))

  const user = createUser('Alice')
  expect(user.createdAt).toBe(1709769600000) // 测试通过

  jest.useRealTimers()
})
```

#### 2. 随机性

**问题代码**：
```typescript
// ❌ 非确定性：每次生成不同 ID
function generateId() {
  return Math.random().toString(36).substring(2, 15)
}

test('生成 ID', () => {
  const id = generateId()
  expect(id).toBe('abc123') // 测试会失败
})
```

**改造方案**：
```typescript
// ✅ 确定性：使用固定种子
import seedrandom from 'seedrandom'

function generateId(rng: () => number = Math.random) {
  return rng().toString(36).substring(2, 15)
}

test('生成 ID', () => {
  const rng = seedrandom('fixed-seed')
  const id = generateId(rng)
  expect(id).toBe('abc123') // 测试通过
})
```

#### 3. 网络请求

**问题代码**：
```typescript
// ❌ 非确定性：依赖真实 API
async function fetchUser(id: string) {
  const response = await fetch(`/api/users/${id}`)
  return response.json()
}

test('获取用户', async () => {
  const user = await fetchUser('123')
  expect(user.name).toBe('Alice') // 测试可能失败（API 不可用）
})
```

**改造方案**：
```typescript
// ✅ 确定性：使用 MSW Mock
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

#### 4. 文件系统

**问题代码**：
```typescript
// ❌ 非确定性：文件顺序不确定
async function listFiles(dir: string) {
  return fs.readdir(dir)
}

test('列出文件', async () => {
  const files = await listFiles('./src')
  expect(files[0]).toBe('index.ts') // 测试可能失败（顺序不确定）
})
```

**改造方案**：
```typescript
// ✅ 确定性：显式排序
async function listFiles(dir: string) {
  const files = await fs.readdir(dir)
  return files.sort() // 确定性排序
}

test('列出文件', async () => {
  const files = await listFiles('./src')
  expect(files[0]).toBe('index.ts') // 测试通过
})
```

#### 5. 并发操作

**问题代码**：
```typescript
// ❌ 非确定性：Promise.all 顺序不确定
async function fetchUsers(ids: string[]) {
  const promises = ids.map(id => fetchUser(id))
  return Promise.all(promises) // 顺序不确定
}

test('批量获取用户', async () => {
  const users = await fetchUsers(['1', '2', '3'])
  expect(users[0].id).toBe('1') // 测试可能失败
})
```

**改造方案**：
```typescript
// ✅ 确定性：显式排序
async function fetchUsers(ids: string[]) {
  const promises = ids.map(id => fetchUser(id))
  const users = await Promise.all(promises)
  return users.sort((a, b) => a.id.localeCompare(b.id)) // 确定性排序
}

test('批量获取用户', async () => {
  const users = await fetchUsers(['3', '1', '2'])
  expect(users[0].id).toBe('1') // 测试通过
})
```

#### 6. 环境变量

**问题代码**：
```typescript
// ❌ 非确定性：依赖环境变量
function getApiUrl() {
  return process.env.API_URL || 'http://localhost:3000'
}

test('获取 API URL', () => {
  const url = getApiUrl()
  expect(url).toBe('http://localhost:3000') // 测试可能失败（环境变量不同）
})
```

**改造方案**：
```typescript
// ✅ 确定性：测试环境固定配置
function getApiUrl(env: Record<string, string> = process.env) {
  return env.API_URL || 'http://localhost:3000'
}

test('获取 API URL', () => {
  const url = getApiUrl({ API_URL: 'http://localhost:3000' })
  expect(url).toBe('http://localhost:3000') // 测试通过
})
```

---

## 📐 确定性编码原则

### 5 大原则

#### 1. 隔离外部依赖

**原则**：使用依赖注入，避免直接调用外部依赖

**示例**：
```typescript
// ❌ 错误：直接调用外部依赖
class UserService {
  async getUser(id: string) {
    return fetch(`/api/users/${id}`).then(r => r.json())
  }
}

// ✅ 正确：依赖注入
class UserService {
  constructor(private http: HttpClient) {}

  async getUser(id: string) {
    return this.http.get(`/api/users/${id}`)
  }
}

// 测试时注入 Mock
const mockHttp = { get: jest.fn() }
const service = new UserService(mockHttp)
```

#### 2. 使用固定种子

**原则**：随机数生成使用固定种子

**示例**：
```typescript
// ❌ 错误：使用 Math.random()
function shuffle<T>(array: T[]): T[] {
  return array.sort(() => Math.random() - 0.5)
}

// ✅ 正确：使用固定种子
import seedrandom from 'seedrandom'

function shuffle<T>(array: T[], seed: string = 'default'): T[] {
  const rng = seedrandom(seed)
  return array.sort(() => rng() - 0.5)
}

// 测试时使用固定种子
test('洗牌', () => {
  const result = shuffle([1, 2, 3], 'test-seed')
  expect(result).toEqual([2, 1, 3]) // 结果可重复
})
```

#### 3. Mock 时间

**原则**：使用 `jest.useFakeTimers()` Mock 时间

**示例**：
```typescript
// ❌ 错误：使用 Date.now()
function createTimestamp() {
  return Date.now()
}

// ✅ 正确：依赖注入 + Mock 时间
function createTimestamp(now: () => number = Date.now) {
  return now()
}

test('创建时间戳', () => {
  jest.useFakeTimers()
  jest.setSystemTime(new Date('2024-03-07T00:00:00Z'))

  const timestamp = createTimestamp()
  expect(timestamp).toBe(1709769600000)

  jest.useRealTimers()
})
```

#### 4. 确定性排序

**原则**：显式定义排序规则，避免依赖默认顺序

**示例**：
```typescript
// ❌ 错误：依赖默认顺序
async function getUsers() {
  return db.query('SELECT * FROM users')
}

// ✅ 正确：显式排序
async function getUsers() {
  return db.query('SELECT * FROM users ORDER BY id ASC')
}

// 多级排序
async function getUsers() {
  const users = await db.query('SELECT * FROM users')
  return users.sort((a, b) => {
    if (a.name !== b.name) return a.name.localeCompare(b.name)
    return a.id - b.id
  })
}
```

#### 5. 显式状态管理

**原则**：避免全局状态，使用显式状态管理

**示例**：
```typescript
// ❌ 错误：全局状态
let counter = 0

function increment() {
  counter++
  return counter
}

// ✅ 正确：显式状态
class Counter {
  private value = 0

  increment() {
    this.value++
    return this.value
  }

  reset() {
    this.value = 0
  }
}

test('计数器', () => {
  const counter = new Counter()
  expect(counter.increment()).toBe(1)
  expect(counter.increment()).toBe(2)
})
```

---

## ✅ 确定性验证清单

### 测试可重复性验证

**目标**：确保测试运行 3 次结果一致

**验证方法**：
```bash
# 运行 3 次测试
npm test -- --testNamePattern="用户登录" --runInBand
npm test -- --testNamePattern="用户登录" --runInBand
npm test -- --testNamePattern="用户登录" --runInBand

# 对比结果
diff test-result-1.log test-result-2.log
diff test-result-2.log test-result-3.log
```

**通过标准**：
- 3 次运行结果完全一致
- 测试通过率 100%
- 无随机失败

### 不确定性检测

**目标**：扫描代码中的不确定性来源

**检测脚本**：`scripts/verify-determinism.sh`

**检测内容**：
1. 时间依赖：`Date.now()`, `new Date()`
2. 随机性：`Math.random()`, `crypto.randomUUID()`
3. 网络请求：`fetch()`, `axios.get()`（未 Mock）
4. 文件系统：`fs.readdir()`（未排序）
5. 并发操作：`Promise.all()`（未排序）
6. 环境变量：`process.env`（未固定）

**输出示例**：
```
🔍 确定性验证报告

时间依赖：
  ⚠️  src/utils/time.ts:15 - Date.now()
  ✅  src/utils/time.ts:20 - jest.useFakeTimers()

随机性：
  ⚠️  src/utils/id.ts:10 - Math.random()
  ✅  src/utils/id.ts:15 - seedrandom('fixed-seed')

网络请求：
  ⚠️  src/api/user.ts:25 - fetch() (未 Mock)
  ✅  src/api/user.ts:30 - MSW Mock

统计：
  ✅ 已隔离：12 处
  ⚠️  未隔离：3 处
  隔离率：80%
```

### Mock 接口检测

**目标**：确保所有 Mock 接口都有标记

**检测脚本**：`scripts/scan-mock-interfaces.sh`

**标记格式**：
```typescript
// ⚠️ MOCK: 认证 API 未开发，预计 2026-03-10 替换
const mockAuthApi = rest.post('/api/auth/login', (req, res, ctx) => {
  return res(ctx.json({ token: 'mock-token' }))
})
```

**输出示例**：
```
📋 Mock 接口清单：

已标记：
  ✅ /api/auth/login - 认证 API 未开发
  ✅ /api/users/profile - 用户服务未部署

可能未标记：
  ❌ /api/orders/list - 未找到标记

统计：
  已标记：2 个
  可能未标记：1 个
  标记率：67%
```

---

## 🔄 与长期记忆系统集成

### Compact 前保存确定性约束

**触发条件**：上下文使用率达到 80%

**保存内容**：
```markdown
## 🧪 确定性约束 (持久化保存，compact 后必须保留)

### 不确定性来源记录
| 文件 | 行号 | 类型 | 状态 | 处理方式 |
|------|------|------|------|---------|
| src/utils/time.ts | 15 | 时间依赖 | ✅ 已隔离 | jest.useFakeTimers() |
| src/utils/id.ts | 10 | 随机性 | ✅ 已隔离 | seedrandom('fixed-seed') |
| src/api/user.ts | 25 | 网络请求 | ⚠️  未隔离 | 待添加 MSW Mock |

### Mock 接口清单
| 接口 | 标记状态 | 预计替换时间 | 关联任务 |
|------|---------|-------------|---------|
| /api/auth/login | ✅ 已标记 | 2026-03-10 | TASK-15 |
| /api/users/profile | ✅ 已标记 | 2026-03-12 | TASK-18 |

### 测试可重复性验证
| 测试套件 | 运行次数 | 结果一致性 | 最后验证时间 |
|---------|---------|-----------|-------------|
| 用户登录 | 3 | 100% | 2026-03-07 10:00 |
| 订单创建 | 3 | 100% | 2026-03-07 10:15 |
```

### Compact 后恢复验证

**触发条件**：Compact 完成后

**恢复脚本**：`scripts/post-compact-recovery.sh`

**验证步骤**：
1. 检查 MEMORY.md 存在
2. 验证确定性约束章节完整
3. 验证 Mock 接口清单
4. 验证测试可重复性记录
5. 运行确定性验证
6. 生成恢复报告

**输出示例**：
```
✅ Compact 后恢复验证报告

1. MEMORY.md 存在：✅
2. 确定性约束章节：✅
3. Mock 接口清单：✅ (2 个接口)
4. 测试可重复性记录：✅ (2 个测试套件)
5. 确定性验证：⚠️  (3 处未隔离)

建议：
- 隔离 src/api/user.ts:25 的网络请求
- 添加 MSW Mock
```

### 测试结果可追溯性

**目标**：保存测试证据，支持追溯

**保存内容**：
```markdown
## 🧪 测试结果记录 (仅记录真实 API 测试)

| 测试类型 | 开始时间 | 完成时间 | 通过率 | 是否使用 Mock |
|---------|---------|---------|-------|--------------|
| 前端 Mock | 10:00 | 10:15 | 100% | ✅ 是 (仅 UI 验证) |
| 后端 API | 10:20 | 10:35 | 100% | ❌ 否 |
| 联调测试 | 10:40 | 11:00 | 100% | ❌ 否 |

### 测试证据
- 前端 Mock 测试：screenshots/frontend-mock-20260307-1015.png
- 后端 API 测试：logs/backend-api-20260307-1035.log
- 联调测试：videos/integration-20260307-1100.mp4
```

---

## 🔧 自动化脚本

### 1. post-compact-recovery.sh

**功能**：Compact 后自动恢复验证

**使用方式**：
```bash
# 自动触发（Compact 后）
./scripts/post-compact-recovery.sh

# 手动触发
./scripts/post-compact-recovery.sh --manual
```

**验证步骤**：
1. 检查 MEMORY.md 存在
2. 验证确定性约束章节完整
3. 验证 Mock 接口清单
4. 验证测试可重复性记录
5. 运行确定性验证
6. 生成恢复报告

**输出**：`checkpoints/recovery-YYYYMMDD-HHMMSS.log`

### 2. scan-mock-interfaces.sh

**功能**：扫描 Mock 接口标记

**使用方式**：
```bash
# 扫描所有文件
./scripts/scan-mock-interfaces.sh

# 扫描指定目录
./scripts/scan-mock-interfaces.sh src/api
```

**检测内容**：
- 已标记的 Mock（`// ⚠️ MOCK:`）
- 可能未标记的 Mock（启发式检测）

**输出**：
```
📋 Mock 接口清单：
  ✅ /api/auth/login - 已标记
  ❌ /api/users/profile - 未标记
统计：已标记 X，可能未标记 Y
```

### 3. verify-determinism.sh

**功能**：验证确定性

**使用方式**：
```bash
# 快速检查（不运行测试）
./scripts/verify-determinism.sh --quick

# 完整验证（包含测试可重复性）
./scripts/verify-determinism.sh "用户登录" 3

# 扫描指定目录
./scripts/verify-determinism.sh --dir src/api
```

**检测内容**：
1. 时间依赖（`Date.now()`, `new Date()`）
2. 随机性（`Math.random()`, `crypto.randomUUID()`）
3. 测试可重复性（运行 N 次，验证结果一致）

**输出**：
```
🔍 确定性验证报告

时间依赖：
  ⚠️  src/utils/time.ts:15 - Date.now()
  ✅  src/utils/time.ts:20 - jest.useFakeTimers()

随机性：
  ⚠️  src/utils/id.ts:10 - Math.random()
  ✅  src/utils/id.ts:15 - seedrandom('fixed-seed')

测试可重复性：
  ✅ 用户登录 - 3 次运行结果一致
  ⚠️  订单创建 - 3 次运行结果不一致

统计：
  ✅ 已隔离：12 处
  ⚠️  未隔离：3 处
  隔离率：80%
```

---

## 📊 确定性指标

| 指标 | 目标值 | 测量方式 |
|------|--------|---------|
| 测试可重复性 | 100% | 连续 3 次运行结果一致 |
| Mock 接口标记率 | 100% | 所有 Mock 接口都有标记 |
| 不确定性隔离率 | 100% | 所有不确定性来源已隔离 |
| 测试通过率 | 95%+ | 自动化测试报告 |
| 问题可复现率 | 90%+ | 生产问题可在开发环境复现 |

---

## 🔗 相关文档

- [系统总则](00-SYSTEM_OVERVIEW.md) - 核心规范
- [TDD 工作流](02-TDD_WORKFLOW.md) - 测试驱动开发
- [质量门禁](05-QUALITY_GATE.md) - 质量检查清单
- [长期记忆管理](11-LONG_TERM_MEMORY.md) - 记忆系统集成
- [协作模式与效率提升](13-COLLABORATION_EFFICIENCY.md) - 效率优化

---

*版本：1.0.0*
*最后更新：2026-03-07*

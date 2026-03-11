# 行动准则

> 版本：1.0.0
> 最后更新：2026-03-07

---

## 📋 概述

本文档定义了使用 Claude Code 进行软件开发的完整行动准则，确保开发流程规范、高效、可追溯。

---

## 🎯 核心原则

1. **规划先行** - 编码前必须规划
2. **质量优先** - 代码质量过关才能测试
3. **测试驱动** - 先写测试，再写实现
4. **API 完整** - API 开发完整才能联调
5. **安全第一** - 安全检查通过才能发布
6. **文档同步** - 代码和文档同步更新
7. **可追溯性** - 所有决策和变更可追溯

---

## 🔄 完整开发流程

### 流程概览

```
Phase 1: 会话启动准备
    ↓
Phase 2: 任务规划
    ↓
Phase 3: 代码质量检查 ← 质量门禁（必须通过）
    ↓
Phase 4: TDD 开发（RED → GREEN → REFACTOR）
    ↓
Phase 5: API 完整性检查 ← 完整性门禁（必须通过）
    ↓
Phase 6: E2E 测试（前后端联调 + 端到端测试）
    ↓
Phase 7: 安全性检查 ← 安全门禁（必须通过）
    ↓
Phase 8: 质量门禁（最终验证）
    ↓
Git 提交 & 发布
```

### Phase 0: 变更影响分析（前置检查）

**目标**：在开始任何代码修改前，检查是否影响稳定模块

**执行时机**：接收到新需求后，开始任何代码修改前

**步骤**：

1. **读取稳定模块清单**
   ```bash
   cat MEMORY.md | grep -A 20 "🔒 稳定模块清单"
   ```

2. **分析需求涉及的文件**
   - 列出需要新增的文件
   - 列出需要修改的文件
   - 列出需要删除的文件

3. **检查是否与稳定模块重叠**
   ```bash
   ./scripts/check-stable-zones.sh
   ```

4. **判断影响级别**

   | 影响级别 | 定义 | 处理方式 |
   |---------|------|---------|
   | 🟢 无影响 | 不涉及稳定模块 | 直接执行 Phase 1 |
   | 🟡 间接影响 | 调用稳定模块的接口 | 验证接口兼容性后继续 |
   | 🟠 直接影响 | 需要修改稳定模块 | **必须用户确认** |
   | 🔴 破坏性影响 | 重构稳定模块 | **必须用户确认 + 详细方案** |

5. **生成影响报告**（如果涉及稳定模块）
   ```bash
   ./scripts/generate-impact-report.sh
   ```

6. **发送确认通知**（如果需要）
   ```javascript
   await sendNotification({
     level: 'P1',
     type: 'change_impact_confirmation',
     title: '稳定模块变更确认',
     content: '需求涉及修改已稳定的XXX系统',
     impactReport: '...',
     options: ['confirm', 'modify_approach', 'reject']
   })
   ```

7. **等待用户确认**（如果需要）
   - 确认：继续执行 Phase 1
   - 修改方案：重新设计实现方案
   - 拒绝：停止任务

**产出**：
- 变更影响报告（如果涉及稳定模块）
- 用户确认记录（如果需要确认）

**详细文档**：[代码稳定区域保护规范](15-STABLE_ZONE_PROTECTION.md)

---

### Phase 1: 会话启动准备

**目标**：确保环境和上下文准备就绪

**步骤**：

0. **检查插件和技能更新**（最高优先级）
   ```bash
   # 检查 bmad-method 插件更新
   /plugin update bmad-method

   # 检查其他已安装插件更新
   /plugin update everything-claude-code
   /plugin update workflow-studio

   # 检查 GitHub 学习到的技能更新
   /skill update

   # 或批量更新所有
   /plugin update --all
   /skill update --all
   ```

   **更新策略**：
   - ✅ 优先更新 bmad-method（核心需求分析工具）
   - ✅ 更新 everything-claude-code（命令库、技能库）
   - ✅ 更新 workflow-studio（流程图工具）
   - ✅ 更新所有 GitHub 学习到的技能
   - ⚠️ 更新后验证功能正常

   **验证更新**：
   ```bash
   # 验证插件版本
   /plugin list

   # 验证技能可用性
   /skill list
   ```

1. **检查插件环境**
   ```bash
   /plugin list
   ```

   必备插件：
   - bmad-method（需求分析）
   - everything-claude-code（命令库）
   - workflow-studio（流程图）
   - pencil（UI 设计）

2. **读取项目文档**（按顺序）
   - `CLAUDE.md` - 项目概述
   - `ACTION_GUIDELINES.md` - 行动准则
   - `MEMORY.md` - 项目当前状态
   - `PENDING_TESTS.md` - 待测试记录
   - `architecture.md` - 工程文档
   - `task.json` - 待执行任务列表

3. **环境检查**
   ```bash
   pwd                # 确认目录
   git status         # 检查更改
   git log -5         # 查看历史
   ```

**产出**：清晰的项目上下文，明确下一个任务

---

### Phase 2: 任务规划

**目标**：在写代码前，先想清楚要做什么

**规划轨道选择**（基于任务复杂度）：

| 轨道 | 适用场景 | 预计时间 | 使用工具 |
|------|---------|---------|---------|
| **Quick Flow** | 小任务、Bug 修复 | < 2 小时 | `/plan` + `/bmad-quick-spec` |
| **Standard** | 中型功能开发 | 2-8 小时 | `/plan` + BMAD Method 部分流程 |
| **Enterprise** | 大型系统、架构设计 | > 8 小时 | BMAD Method 完整流程 |

#### 轨道 1：Quick Flow（小任务）

**适用场景**：Bug 修复、小功能、简单重构

**步骤**：

1. **快速规划**
   ```bash
   /plan "任务描述"
   ```

2. **可选：生成快速规格**
   ```bash
   /bmad-quick-spec
   ```

3. **确认计划**
   - 同意：回复 "yes" 或 "proceed"
   - 修改：回复 "modify: [你的修改]"

**产出**：实施计划（可选流程图）

#### 轨道 2：Standard（中型任务）

**适用场景**：新功能开发、模块重构、API 设计

**步骤**：

1. **智能指导**（推荐）
   ```bash
   /bmad-help
   ```
   BMAD 会自动检测项目状态，推荐下一步操作

2. **需求分析**（可选）
   ```bash
   # 如果需要头脑风暴
   /bmad-brainstorming

   # 如果需要技术调研
   /bmad-technical-research "调研主题"
   ```

3. **创建 PRD**（推荐）
   ```bash
   /bmad-create-prd
   ```
   产出：`_bmad-output/planning-artifacts/PRD.md`

4. **架构设计**（推荐）
   ```bash
   /bmad-create-architecture
   ```
   产出：`_bmad-output/planning-artifacts/architecture.md`

5. **生成流程图**（使用 workflow-studio）
   ```markdown
   ```flow
   TD
   A[开始] --> B{判断条件}
   B -->|是| C[执行操作 1]
   B -->|否| D[执行操作 2]
   C --> E[结束]
   D --> E
   ```
   ```

6. **确认计划**
   - 同意：回复 "yes" 或 "proceed"
   - 修改：回复 "modify: [你的修改]"

**产出**：PRD + Architecture + 流程图

#### 轨道 3：Enterprise（大型任务）

**适用场景**：大型系统、完整产品、架构重构

**步骤**：

1. **智能指导**
   ```bash
   /bmad-help
   ```

2. **分析阶段**
   ```bash
   # 头脑风暴
   /bmad-brainstorming

   # 领域调研
   /bmad-domain-research "领域名称"

   # 市场调研
   /bmad-market-research "业务想法"

   # 技术调研
   /bmad-technical-research "技术主题"

   # 创建产品简介
   /bmad-create-product-brief
   ```

3. **规划阶段**
   ```bash
   # 创建 PRD
   /bmad-create-prd

   # UX 设计
   /bmad-create-ux-design
   ```

4. **方案设计阶段**
   ```bash
   # 架构设计
   /bmad-create-architecture

   # Epic 和 Story 分解
   /bmad-create-epics-and-stories

   # 实现就绪检查
   /bmad-check-implementation-readiness
   ```

5. **Sprint 规划**
   ```bash
   /bmad-sprint-planning
   ```

**产出**：完整的规划文档集
- Product Brief
- PRD
- UX Design
- Architecture
- Epics & Stories
- Sprint Plan

#### 通用规则

**需要流程图的场景**：
- ✅ 涉及多个步骤的任务
- ✅ 有分支判断的业务逻辑
- ✅ 需要多人协作的复杂任务
- ✅ 有时序关系的 API 调用
- ✅ 状态流转复杂的功能

**BMAD Method 产出位置**：
- 规划产物：`_bmad-output/planning-artifacts/`
- 实现产物：`_bmad-output/implementation-artifacts/`

**项目上下文**：
- 静态规则：`project-context.md`（技术栈、实现规则）
- 动态记忆：`MEMORY.md`（关键决策、经验教训）

---

### Phase 3: 代码质量检查

> **关键原则**：代码质量必须过关后，才能进入测试阶段。这是进入测试的质量门禁。

**目标**：确保代码质量和规范，为测试阶段打好基础

**步骤**：

```bash
/code-review
```

**检查项**：
- 代码质量（可读性、可维护性）
- 代码规范（命名、格式、注释）
- 性能问题（算法复杂度、资源使用）
- 最佳实践（设计模式、架构原则）
- 代码风格（统一风格、团队规范）

**问题等级**：
- 🔴 CRITICAL - 必须修复，阻止进入测试
- 🟠 HIGH - 强烈建议修复，阻止进入测试
- 🟡 MEDIUM - 建议修复
- 🟢 LOW - 可选修复

**质量门禁**：
- ✅ 无 CRITICAL 级别问题
- ✅ 无 HIGH 级别问题
- ✅ 代码规范检查通过
- ✅ 静态分析通过

**产出**：代码审查报告，修复建议

**⚠️ 重要**：只有通过代码质量检查后，才能进入 Phase 4（TDD 开发）。

---

### Phase 4: TDD 开发

**目标**：用测试驱动的方式高质量实现功能

**开发模式选择**：

| 模式 | 适用场景 | 使用工具 |
|------|---------|---------|
| **Quick Dev** | 小任务、快速迭代 | `/tdd` + `/bmad-quick-dev` |
| **Story Dev** | 中大型任务、Sprint 开发 | `/bmad-create-story` + `/bmad-dev-story` |

#### 模式 1：Quick Dev（快速开发）

**适用场景**：小任务、Bug 修复、简单功能

**步骤**：

##### Step 1: RED（写失败测试）

```bash
/tdd
```

1. 根据需求编写测试用例
2. 运行测试，确认失败（红色）
3. 记录测试文件位置

**为什么先写失败测试？**
- 确保你清楚需求是什么
- 避免过度开发
- 测试覆盖率自然达标

##### Step 2: GREEN（实现功能）

1. 编写最小代码让测试通过
2. 不要优化，先实现功能
3. 运行测试，看到绿色通过

**为什么只写最小代码？**
- 避免过度设计
- 快速验证方向正确
- 后续重构更有针对性

**可选：使用 BMAD Quick Dev**
```bash
/bmad-quick-dev "quick-spec-file.md"
```

##### Step 3: REFACTOR（重构优化）

1. 优化代码结构
2. 消除重复
3. 改进命名
4. 确保测试仍然通过

**为什么最后重构？**
- 功能正确后再优化
- 有测试保护，重构放心
- 避免过早优化

##### Step 4: VERIFY（验证闭环）

```bash
/verify
```

1. 运行全部相关测试
2. 生成测试报告
3. 分析失败原因
4. 修复或记录问题

**产出**：通过测试的功能代码，测试报告

#### 模式 2：Story Dev（Story 驱动开发）

**适用场景**：中大型任务、Sprint 开发、团队协作

**前提条件**：
- ✅ 已完成 Epic 和 Story 分解（`/bmad-create-epics-and-stories`）
- ✅ 已完成 Sprint 规划（`/bmad-sprint-planning`）

**步骤**：

##### Step 1: 创建 Story 文件

```bash
/bmad-create-story "story-identifier"
```

产出：`_bmad-output/implementation-artifacts/story-[id].md`

Story 文件包含：
- Story 描述和验收标准
- 技术实现方案
- 依赖关系
- 测试要求

##### Step 2: 实现 Story

```bash
/bmad-dev-story "story-file.md"
```

BMAD Developer Agent 会：
1. 读取 Story 文件上下文
2. 按照 TDD 流程实现（RED → GREEN → REFACTOR）
3. 确保测试覆盖率 ≥ 80%
4. 生成实现报告

##### Step 3: 代码审查

```bash
/bmad-code-review
```

BMAD Code Reviewer 会：
- 检查代码质量
- 验证是否符合 Story 要求
- 检查测试覆盖率
- 提供改进建议

##### Step 4: 更新 Sprint 状态

```bash
/bmad-sprint-status
```

查看：
- 已完成的 Story
- 进行中的 Story
- 待开发的 Story
- Sprint 风险

##### Step 5: Sprint 完成后回顾

```bash
/bmad-retrospective "epic-name"
```

总结：
- 成功经验
- 遇到的问题
- 改进建议
- 下一步计划

**产出**：
- Story 实现代码
- 测试代码
- 代码审查报告
- Sprint 状态报告
- 回顾总结

---

### Phase 5: API 完整性检查

> **关键原则**：在进行 API 测试之前，务必确保所有 API 都已开发完整。未完整的 API 必须先开发完成，再进行下一步测试。

**目标**：确保 API 开发完整，避免在不完整的 API 上进行测试

**检查步骤**：

#### Step 1: 列出所有需要的 API

根据需求文档或任务描述，列出所有需要的 API 端点：

```bash
# 示例：用户登录功能需要的 API
POST /api/auth/login          # 用户登录
POST /api/auth/logout         # 用户登出
GET  /api/auth/verify         # 验证 Token
GET  /api/user/profile        # 获取用户信息
```

#### Step 2: 检查 API 开发状态

对每个 API 进行状态检查：

```bash
# 方法 1: 检查 API 路由定义
grep -r "POST.*\/api\/auth\/login" src/routes/
grep -r "GET.*\/api\/user\/profile" src/routes/

# 方法 2: 检查 API 实现文件
ls -la src/api/auth.ts
ls -la src/controllers/user.ts

# 方法 3: 使用 API 文档工具
npm run api:docs  # 生成 API 文档
```

#### Step 3: 验证 API 完整性

使用检查清单验证每个 API：

```
API 完整性检查清单：

□ 1. 路由定义
   - 路由路径正确
   - HTTP 方法正确
   - 中间件配置完整

□ 2. 控制器实现
   - 请求参数验证
   - 业务逻辑实现
   - 响应格式正确
   - 错误处理完整

□ 3. 数据模型
   - 数据库表/集合存在
   - 字段定义完整
   - 索引配置正确

□ 4. 依赖服务
   - 外部 API 已配置
   - 第三方服务已接入
   - 环境变量已设置

□ 5. 基础测试
   - 单元测试已编写
   - 基本功能可运行
   - 无明显错误
```

#### Step 4: 标记未完成的 API

如果发现未完成的 API，必须明确标记：

```typescript
// ⚠️ API 未完成：用户登出功能尚未实现，预计 2026-03-15 完成
// TODO: 实现登出逻辑
//   1. 清除 Redis 中的 Session
//   2. 记录登出日志
//   3. 返回成功响应
export async function logout(req: Request, res: Response) {
  throw new Error('API 未实现')
}
```

#### Step 5: 决策流程

```
┌─────────────────────────────────────────────────────────────┐
│                    API 完整性检查决策流程                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  检查所有 API                                               │
│       │                                                     │
│       ▼                                                     │
│  所有 API 都已完整？                                         │
│       │                                                     │
│       ├─ 是 ──▶ 继续进行 API 测试（Phase 5）                │
│       │                                                     │
│       └─ 否 ──▶ 识别未完成的 API                            │
│                      │                                      │
│                      ▼                                      │
│                 评估影响范围                                 │
│                      │                                      │
│                      ├─ 核心 API 未完成                      │
│                      │   └─▶ 优先开发核心 API               │
│                      │        └─▶ 完成后重新检查             │
│                      │                                      │
│                      ├─ 非核心 API 未完成                    │
│                      │   └─▶ 标记为 Mock                    │
│                      │        └─▶ 继续测试，后续替换         │
│                      │                                      │
│                      └─ 外部依赖 API 未接入                  │
│                          └─▶ 使用沙箱环境                    │
│                               └─▶ 继续测试                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Step 6: API 完整性报告

生成 API 完整性报告：

```markdown
## API 完整性检查报告

**检查时间**：2026-03-07 10:00
**检查人员**：Claude Code
**任务 ID**：task-52

### 已完成的 API（4/5）

| API | 状态 | 完成度 | 备注 |
|-----|------|--------|------|
| POST /api/auth/login | ✅ 完成 | 100% | 已测试 |
| GET /api/auth/verify | ✅ 完成 | 100% | 已测试 |
| GET /api/user/profile | ✅ 完成 | 100% | 已测试 |
| PUT /api/user/profile | ✅ 完成 | 100% | 已测试 |

### 未完成的 API（1/5）

| API | 状态 | 完成度 | 预计完成时间 | 影响 |
|-----|------|--------|-------------|------|
| POST /api/auth/logout | ⚠️ 未完成 | 30% | 2026-03-15 | 非核心功能 |

### 决策

- ✅ 核心 API 已完成，可以进行联调测试
- ⚠️ 登出 API 未完成，暂时使用 Mock，标记为待替换
- 📋 后续任务：完成登出 API 并替换 Mock

### 下一步

继续进行 Phase 5: E2E 测试
```

#### 违规处理

如果在 API 未完成的情况下强行进行测试：

| 违规行为 | 后果 | 处理方式 |
|---------|------|---------|
| 核心 API 未完成就测试 | 测试结果不可信 | ❌ 阻止测试，要求先完成 API |
| 未标记 Mock API | 后续难以替换 | ⚠️ 警告并要求补充标记 |
| 跳过 API 完整性检查 | 质量无法保障 | ❌ 阻止进入下一阶段 |

**产出**：API 完整性报告，未完成 API 清单

---

### Phase 6: 真实业务全流程闭环测试 🔴 最高优先级

> **核心原则**：测试不只是验证 UI 元素存在，而是验证**真实业务流程、真实数据、完整闭环**。

**目标**：验证系统真正可用，人类可以直接使用

**详细文档**：[真实业务全流程闭环测试规范](12-REAL_BUSINESS_TESTING.md)

**REAL 测试原则**：
```
R - Real Data     真实数据（生产环境数据结构）
E - End-to-End    端到端（前后端完整联调）
A - Actual Flow   实际流程（真实业务场景）
L - Loop Closed   闭环验证（从起点到终点的完整链路）
```

**步骤**：

```bash
# 1. 准备真实测试数据
./scripts/prepare-test-data.sh

# 2. 运行真实业务测试
npx playwright test --project=real-business

# 3. 生成覆盖率报告
./scripts/generate-coverage-report.sh

# 4. 生成人类可用性评估报告
./scripts/generate-usability-report.sh
```

**浏览器模式配置**：

| 测试阶段 | 浏览器模式 | 配置 | 用途 |
|---------|----------|------|------|
| **自动 E2E 测试** | 无头模式（headless） | `headless: true` | 行为准则测试环节、CI/CD |
| **人类介入测试** | 有头模式（headed） | `headless: false` | 人类观看、Agentation 标注 |
| **Self-Driving 评审** | 有头模式（headed） | `headless: false` | AI 自主标注、人类观看 |

**核心原则**：
- ✅ **行为准则测试环节中，自动 E2E 测试阶段必须使用无头模式（headless）**
- ✅ 人类介入测试阶段使用有头模式（headed）
- ✅ 无头模式节省资源，适合自动化和 CI/CD

**测试层次**：

1. **前端 Mock 测试** ✅ 允许 Mock（仅验证 UI 交互）
   - 验证前端页面交互正确
   - 用 Mock 数据，不依赖后端
   - ⚠️ **仅用于 UI 验证，不能代替真实测试**

2. **后端 API 测试** ❌ 禁止 Mock
   - 验证后端 API 功能正确
   - 必须使用真实数据

3. **前后端联调测试** ❌ 禁止 Mock
   - 验证前后端集成正常
   - 必须使用真实 API

4. **真实业务全流程闭环测试** ❌ 禁止 Mock 🔴 核心
   - **真实数据**：从测试数据库获取真实用户、商品等
   - **真实业务流程**：完整业务场景（登录→购买→支付→验证）
   - **完整闭环验证**：前端 UI + 后端 API + 数据库状态
   - **功能覆盖率报告**：与需求文档对比，确保 100% 覆盖

5. **人类可用性评估** 🔴 最终验收
   - **功能完整性**：所有核心功能都能正常使用
   - **数据一致性**：前后端数据完全一致
   - **流程连贯性**：业务流程无断点
   - **用户体验**：界面友好、操作流畅
   - **综合评分 ≥ 85 分**才能通过验收

**测试报告要求**：

每次测试必须生成以下报告：

1. **功能覆盖率报告** (`REAL_TEST_COVERAGE_REPORT.md`)
   - 功能模块覆盖详情
   - 业务闭环验证
   - 数据一致性检查
   - 未覆盖功能清单

2. **人类可用性评估报告**
   - 功能验收状态
   - 数据验收状态
   - 流程验收状态
   - 综合评分

**产出**：
- E2E 测试报告
- 功能覆盖率报告
- 人类可用性评估报告
- 截图/视频证据

---

### Phase 7: 安全性检查

> **关键原则**：在 API 完整性检测和前后端联调测试完成后，必须进行全面的安全性检查，确保系统安全可靠。

**目标**：识别和修复安全漏洞，确保系统安全

**步骤**：

```bash
/security-review
```

**检查项**：

#### 1. 认证与授权
- ✅ 认证机制正确实现（JWT/Session/OAuth）
- ✅ Token 有效期和刷新机制
- ✅ 密码强度要求和加密存储
- ✅ 权限验证完整（RBAC/ABAC）
- ✅ 防止越权访问

#### 2. 输入验证
- ✅ 所有用户输入已验证
- ✅ SQL 注入防护（参数化查询）
- ✅ XSS 防护（输入过滤、输出转义）
- ✅ CSRF 防护（Token 验证）
- ✅ 文件上传安全（类型、大小、路径验证）

#### 3. 数据安全
- ✅ 敏感数据加密存储
- ✅ 传输层加密（HTTPS/TLS）
- ✅ 数据库连接加密
- ✅ 日志脱敏（不记录密码、Token）
- ✅ 备份数据加密

#### 4. API 安全
- ✅ API 认证和授权
- ✅ 速率限制（防止暴力破解）
- ✅ API 密钥管理
- ✅ CORS 配置正确
- ✅ 防止 API 滥用

#### 5. 依赖安全
- ✅ 第三方库无已知漏洞
- ✅ 依赖版本及时更新
- ✅ 供应链安全
- ✅ License 合规性

#### 6. 配置安全
- ✅ 生产环境配置正确
- ✅ 调试模式已关闭
- ✅ 错误信息不泄露敏感数据
- ✅ 默认密码已修改
- ✅ 不必要的服务已关闭

**安全扫描工具**：

```bash
# 依赖漏洞扫描
npm audit
# 或
yarn audit

# 代码安全扫描
npm run security-scan

# OWASP 依赖检查
dependency-check --project myapp --scan .
```

**问题等级**：
- 🔴 CRITICAL - 严重安全漏洞，必须立即修复
- 🟠 HIGH - 高危漏洞，强烈建议修复
- 🟡 MEDIUM - 中危漏洞，建议修复
- 🟢 LOW - 低危漏洞，可选修复

**安全门禁**：
- ✅ 无 CRITICAL 级别安全漏洞
- ✅ 无 HIGH 级别安全漏洞
- ✅ 所有敏感数据已加密
- ✅ 认证授权机制完整

**产出**：安全审查报告，漏洞修复建议

**⚠️ 重要**：只有通过安全性检查后，才能进入 Phase 8（质量门禁）。

---

### Phase 8: 质量门禁

**目标**：确保质量达标后再提交

**检查清单**：

```
□ 代码质量（Phase 3 已通过）
□ 构建成功（npm run build / mvn package）
□ 单元测试通过（覆盖率 ≥ 80%）
□ API 完整性检查通过（Phase 5）
□ 集成测试通过（所有相关测试用例）
□ E2E 测试通过（Phase 6）
□ 安全性检查通过（Phase 7，无 CRITICAL/HIGH 漏洞）
□ 失败修复（或记录原因）
□ 文档更新（MEMORY.md、task.json）
□ Git 提交（规范格式）
```

**Git 提交格式**：
```
feat: 实现用户登录功能 (任务 5)

- 创建登录页面 views/login/index.vue
- 实现认证 API api/auth.ts
- 添加 E2E 测试 e2e/05-login.spec.ts
- 测试覆盖：3 个新测试用例
- 需求关联：FR-001
```

**产出**：高质量的代码提交

---

## 🚨 关键约束

### Mock 模式使用规范

> **核心原则**：前端和后端可以独立使用 Mock 测试，但前后端联调和 E2E 测试必须使用真实数据，确保生产环境 95% 无 Bug。

#### 测试阶段与 Mock 使用规则

| 阶段 | 是否使用 Mock | 说明 | 质量目标 |
|------|-------------|------|---------|
| **前端开发阶段** | ✅ 允许 | 前端独立开发时，使用 Mock 数据验证 UI 交互 | UI 功能正常 |
| **前端单元测试** | ✅ 允许 | 验证前端组件逻辑，不依赖后端 | 组件覆盖率 ≥80% |
| **后端开发阶段** | ✅ 允许 | 后端独立开发时，使用 Mock 数据验证业务逻辑 | 业务逻辑正确 |
| **后端单元测试** | ✅ 允许 | 验证后端服务逻辑，Mock 外部依赖（数据库/第三方 API） | 服务覆盖率 ≥80% |
| **后端 API 测试** | ⚠️ 部分允许 | 可 Mock 外部依赖，但必须用真实数据库测试核心逻辑 | API 功能正确 |
| **前后端联调测试** | ❌ **严格禁止** | 必须连接真实后端，使用真实数据，按需求规定流程测试 | 集成无问题 |
| **E2E 端到端测试** | ❌ **严格禁止** | 完整流程必须使用真实 API 和数据，模拟真实用户操作 | 生产环境 95% 无 Bug |

#### Mock 使用的三个层次

```
┌─────────────────────────────────────────────────────────────┐
│                    Mock 使用层次                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Layer 1: 单元测试（✅ 允许 Mock）                           │
│  ├─ 前端组件测试 - Mock API 响应                            │
│  ├─ 后端服务测试 - Mock 数据库/外部 API                      │
│  └─ 目标：验证单个模块逻辑正确                               │
│                                                             │
│  Layer 2: 集成测试（⚠️ 部分 Mock）                          │
│  ├─ 后端 API 测试 - 真实数据库 + Mock 外部 API              │
│  ├─ 前端集成测试 - Mock 后端 API                            │
│  └─ 目标：验证模块间接口正确                                 │
│                                                             │
│  Layer 3: 联调 & E2E（❌ 禁止 Mock）                        │
│  ├─ 前后端联调 - 真实前端 + 真实后端 + 真实数据库            │
│  ├─ E2E 测试 - 完整真实环境 + 真实数据 + 真实流程            │
│  └─ 目标：确保生产环境 95% 无 Bug                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Mock 标记规范

所有 Mock 代码必须明确标记，便于后续替换：

```typescript
// ⚠️ MOCK: 用户服务 API 未开发，预计 2026-03-15 替换为真实 API
const mockUserApi = {
  getUser: (id: string) => ({
    id,
    name: 'Mock User',
    email: 'mock@example.com'
  })
}

// ⚠️ MOCK: 支付网关未接入，预计 2026-03-20 替换为真实支付
const mockPayment = {
  charge: (amount: number) => ({
    success: true,
    transactionId: 'mock-tx-' + Date.now()
  })
}
```

#### 联调测试强制要求

**前后端联调测试必须满足**：

1. **真实环境**：
   - ✅ 前端连接真实后端 API
   - ✅ 后端连接真实数据库
   - ✅ 使用真实数据（非 Mock 数据）
   - ✅ 按需求规定的完整流程测试

2. **测试覆盖**：
   - ✅ 正常流程（Happy Path）
   - ✅ 异常流程（Error Handling）
   - ✅ 边界条件（Boundary Cases）
   - ✅ 并发场景（Concurrency）

3. **数据验证**：
   - ✅ 数据库状态正确
   - ✅ API 响应正确
   - ✅ 前端显示正确
   - ✅ 业务逻辑正确

4. **质量目标**：
   - ✅ 联调测试通过率 100%
   - ✅ 无数据不一致问题
   - ✅ 无接口调用错误
   - ✅ 为生产环境 95% 无 Bug 提供保障

#### E2E 测试强制要求

**端到端测试必须满足**：

1. **完整流程**：
   - ✅ 从用户登录到业务完成的完整路径
   - ✅ 模拟真实用户操作（点击、输入、等待）
   - ✅ 验证每个步骤的正确性
   - ✅ 检查最终结果的准确性

2. **真实环境**：
   - ✅ 使用与生产环境相同的配置
   - ✅ 使用真实的 API 端点
   - ✅ 使用真实的数据库
   - ✅ 使用真实的第三方服务（或沙箱环境）

3. **测试场景**：
   - ✅ 核心业务流程（如下单、支付、发货）
   - ✅ 用户权限验证
   - ✅ 数据一致性验证
   - ✅ 性能和稳定性验证

4. **质量目标**：
   - ✅ E2E 测试通过率 100%
   - ✅ 关键路径无阻塞
   - ✅ 用户体验流畅
   - ✅ 生产环境 95% 无 Bug

#### 测试报告验证机制

生成测试报告前，必须执行验证：

```javascript
function validateTestReport(testResults) {
  const errors = []

  // 检查 1: 联调测试是否使用了 Mock
  if (testResults.integrationTest?.usedMock) {
    errors.push('❌ 前后端联调测试禁止使用 Mock 模式')
  }

  // 检查 2: E2E 测试是否使用了 Mock
  if (testResults.e2eTest?.usedMock) {
    errors.push('❌ E2E 测试禁止使用 Mock 模式')
  }

  // 检查 3: 是否所有 Mock 接口都有标记
  const unmarkedMocks = scanForUnmarkedMocks()
  if (unmarkedMocks.length > 0) {
    errors.push(`⚠️ 发现 ${unmarkedMocks.length} 个未标记的 Mock 接口`)
  }

  // 检查 4: 联调测试是否覆盖完整流程
  if (!testResults.integrationTest?.fullFlowCovered) {
    errors.push('⚠️ 联调测试未覆盖完整业务流程')
  }

  // 检查 5: E2E 测试是否使用真实数据
  if (!testResults.e2eTest?.usedRealData) {
    errors.push('❌ E2E 测试未使用真实数据')
  }

  return {
    valid: errors.length === 0,
    errors,
    qualityScore: calculateQualityScore(testResults)
  }
}

function calculateQualityScore(testResults) {
  // 质量评分：目标 95%
  const weights = {
    unitTest: 0.2,        // 单元测试 20%
    integrationTest: 0.3, // 集成测试 30%
    e2eTest: 0.5          // E2E 测试 50%
  }

  const score =
    testResults.unitTest.passRate * weights.unitTest +
    testResults.integrationTest.passRate * weights.integrationTest +
    testResults.e2eTest.passRate * weights.e2eTest

  return {
    score: Math.round(score * 100),
    target: 95,
    passed: score >= 0.95
  }
}
```

#### 违规处理

如果发现违反 Mock 使用规范：

1. **自动检测**：
   ```bash
   ./scripts/scan-mock-interfaces.sh
   ./scripts/verify-determinism.sh
   ```

2. **阻止提交**：
   - 联调测试使用 Mock → 阻止合并
   - E2E 测试使用 Mock → 阻止合并
   - Mock 接口未标记 → 警告并要求补充

3. **质量门禁**：
   - 质量评分 < 95% → 阻止发布
   - 联调测试未通过 → 阻止发布
   - E2E 测试未通过 → 阻止发布

### 端口冲突排查规范

> **执行任何测试前，必须先排查端口占用情况。**

**检查流程**：
```bash
# Step 1: 识别测试需要使用的端口
# 前端：3000, 5173, 8080
# 后端：8000, 8080, 3333
# 数据库：5432, 3306, 27017

# Step 2: 检查端口占用状态
lsof -i :<端口号>

# Step 3: 处理冲突
# - 端口空闲 → 直接使用
# - 被必要服务占用 → 复用现有服务
# - 被无关进程占用 → 更换测试端口
# - 被残留进程占用 → 清理后重启
```

**严禁行为**：
- ❌ 发现端口占用，直接 kill 占用进程
- ❌ 强制绑定端口，忽略冲突
- ❌ 不检查端口，直接启动测试

---

## 🧠 上下文管理

### 阈值管理

| 阈值 | 触发动作 | 通知级别 |
|------|---------|---------|
| 70% | 预警通知 | P2 |
| 80% | 自动保存到 Memory | P2 |
| 90% | 强制 compact | P1 |

### Compact 后恢复检查清单

每次 compact 完成后，必须执行：

```
□ 1. 读取 MEMORY.md 持久化区域
   - 确认测试状态
   - 确认 Mock 模式使用状态

□ 2. 验证约束条件
   - Mock 模式是否仅在允许阶段使用
   - 联调测试是否已切换到真实 API

□ 3. 检查测试报告
   - 确认报告未包含 Mock 测试（前端除外）
   - 确认所有 Mock 接口都有标记

□ 4. 继续任务前确认
   - 如有未完成的真实 API 测试，优先执行
   - 如有未标记的 Mock 接口，补充标记
```

---

## 🔔 人类介入点

### 需要人类确认的场景

| 场景 | 级别 | 响应时间 |
|------|------|---------|
| 规划完成待确认 | P2 | 2 小时 |
| 测试失败待决策 | P2 | 2 小时 |
| 遇到阻塞需介入 | P1 | 30 分钟 |
| 架构决策点 | P1 | 30 分钟 |
| 风险接受确认 | P1 | 30 分钟 |
| 任务完成通知 | P3 | 24 小时 |

### 必须人类执行的任务

| 任务类型 | 原因 |
|---------|------|
| 需求确认 | 需要业务理解 |
| 架构决策 | 需要战略思考 |
| 风险接受 | 需要责任承担 |
| 发布决策 | 需要业务判断 |
| 紧急处理 | 需要灵活应变 |
| 资源协调 | 需要跨团队沟通 |

---

## 📊 进度追踪

### 检查点管理

```bash
# 开始任务
/checkpoint start <task_id>

# 查看状态
/checkpoint status <task_id>

# 完成任务
/checkpoint complete <task_id>

# 列出所有检查点
/checkpoint list
```

### 状态保存

```bash
# 关键节点保存
/save-state "完成需求分析"
/save-state "上下文达到 80%"
/save-state "任务暂停"
```

### 状态恢复

```bash
# 恢复最新状态
/restore-state latest

# 恢复特定检查点
/restore-state <checkpoint_id>

# 列出可用检查点
/restore-state list
```

---

## 🎓 最佳实践

### 1. 任务开始前必须规划

```bash
# ❌ 错误：直接开始写代码
# 开始写代码...

# ✅ 正确：先规划再执行
/plan "实现用户登录功能"
# 等待确认后再开始
```

### 2. 严格执行 TDD 流程

```bash
# ❌ 错误：先写实现再补测试
# 写实现代码...
# 补测试...

# ✅ 正确：先写测试再实现
/tdd
# RED → GREEN → REFACTOR
```

### 3. 完成后必须验证

```bash
# ❌ 错误：写完就提交
git commit -m "完成功能"

# ✅ 正确：验证后再提交
/verify
# 通过后再提交
```

### 4. 关键节点保存状态

```bash
# ✅ 需求分析完成
/save-state "完成需求分析"

# ✅ 上下文达到 80%
/save-state "上下文达到 80%"

# ✅ 任务暂停
/save-state "任务暂停，明天继续"
```

---

## ❓ 常见问题

### Q1: 任务规划后可以直接开始吗？

**A**: 必须等待人类确认后才能开始

### Q2: 测试失败了怎么办？

**A**: 分析失败原因，修复后重新测试

### Q3: 可以跳过代码审查吗？

**A**: 不可以，代码审查是质量门禁的一部分

### Q4: Mock 测试可以代替真实测试吗？

**A**: 不可以，联调和 E2E 测试必须使用真实 API

### Q5: 上下文达到 90% 怎么办？

**A**: 自动触发 compact，保存状态后压缩

---

## 🔗 相关文档

- [TDD 开发流程](02-TDD_WORKFLOW.md)
- [多 Agent 协作](03-MULTI_AGENT.md)
- [E2E 测试流程](04-E2E_TESTING_FLOW.md)
- [质量门禁](05-QUALITY_GATE.md)
- [可追溯性规范](06-TRACEABILITY.md)
- [插件管理](07-PLUGIN_MANAGEMENT.md)

---

## 📝 更新日志

| 日期 | 版本 | 更新内容 | 更新人 |
|------|------|---------|--------|
| 2026-03-07 | 1.0.0 | 初始版本 | - |

---

> **核心理念**：
> 1. 规划先行 - 想清楚再动手
> 2. 测试驱动 - 先写测试再实现
> 3. 质量优先 - 通过门禁才提交
> 4. 文档同步 - 代码文档同步更新
> 5. 可追溯性 - 所有决策可追溯

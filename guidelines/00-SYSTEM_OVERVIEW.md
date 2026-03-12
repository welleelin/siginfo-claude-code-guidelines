# 系统总则

> 本文档定义了整个开发系统的核心原则、插件管理规范和自动化边界

---

## 🎯 核心理念

1. **TDD 优先** - 先写测试，再写实现
2. **文档驱动** - 以工程文档为基准进行开发
3. **多 Agent 协作** - 使用专家团队模式提高效率
4. **质量验证** - 完成后必须进行测试验证
5. **可追溯性** - 记录详细日志，支持断点续传
6. **自动化优先** - 能自动的不手动，不能自动的明确人类介入点
7. **上下文管理** - 实时监控上下文使用量，自动保存和压缩
8. **Mock 模式规范** - 前端开发可用 Mock，联调测试必须用真实 API
9. **端口排查** - 测试前先检查端口占用，避开已占用端口，严禁强占
10. **测试真实性** - 严禁"为了通过而测试"，截图必须审查，404/空白必须报 Bug
11. **AI 自主验证** - AI 必须自动验证预期效果，不能等用户发现问题 ⭐

---

## 🔌 必备插件管理

### 插件清单

| 插件名称 | 用途 | 安装方式 | GitHub |
|---------|------|---------|--------|
| **bmad-method** | 需求分析、架构设计、多 Agent 协作 | `/plugin install bmad-method` | [BMAD](https://github.com/bmad-method) |
| **everything-claude-code** | 命令库、技能库、Agent 库、规则 | 手动安装 | [everything-claude-code](https://github.com/anthropics/everything-claude-code) |
| **workflow-studio** | 流程图、时序图、可视化工作流 | `/plugin install workflow-studio` | [workflow-studio](https://github.com/workflow-studio) |
| **pencil** | UI 设计原型、线框图 | MCP 服务 | [OpenPencil](https://github.com/openpencil-ai) |
| **agentation** | UI 设计标注、AI 协作评审 | Skill + npm 安装 | [neondatabase/agentation](https://github.com/neondatabase/agentation) |
| **shannon** | AI 自主渗透测试、安全漏洞扫描 | Docker + CLI | [KeygraphHQ/shannon](https://github.com/KeygraphHQ/shannon) |

### 插件初始化检查

在每次新会话或新项目开始时，必须执行：

```bash
# Step 0: 检查并更新插件和技能（最高优先级）
# 更新 bmad-method 插件
/plugin update bmad-method

# 更新其他核心插件
/plugin update everything-claude-code
/plugin update workflow-studio

# 更新所有 GitHub 学习到的技能
/skill update --all

# 或批量更新所有插件
/plugin update --all

# Step 1: 检查已安装插件
/plugin list

# Step 2: 验证必备插件
必需插件：
- bmad-method (需求分析/多 Agent 协作)
- everything-claude-code (命令/技能/规则)
- workflow-studio (流程图/可视化)
- pencil (UI 原型设计 - MCP 服务)
- agentation (UI 设计标注 - 前端项目)
- shannon (安全渗透测试 - 发布前必备)

# Step 3: 缺失插件安装
如果缺失，立即执行：
/plugin install bmad-method
/plugin install everything-claude-code
/plugin install workflow-studio

# Pencil MCP 如未配置，需手动添加 MCP 配置

# Step 4: 验证更新成功
/plugin list  # 查看插件版本
/skill list   # 查看技能列表
```

**更新策略**：
- ✅ 每次会话启动时自动检查更新
- ✅ 优先更新 bmad-method（核心需求分析工具）
- ✅ 更新 everything-claude-code（命令库、技能库）
- ✅ 更新所有 GitHub 学习到的技能
- ⚠️ 更新后验证功能正常
- ⚠️ 如更新失败，使用现有版本继续

### 插件能力使用场景

| 阶段 | 使用插件 | 具体能力 |
|------|---------|---------|
| **需求分析** | bmad-method | `/bmad-help`, `/bmad-brainstorming`, `/bmad-bmm-research`, `/bmad-bmm-create-product-brief` |
| **架构设计** | bmad-method + pencil | `/bmad-bmm-create-prd`, `/bmad-bmm-create-architecture` + 绘制架构图 |
| **任务规划** | bmad-method + everything-claude-code | `/bmad-bmm-create-epics-and-stories`, `/plan` 命令 + workflow-studio 流程图 |
| **TDD 开发** | bmad-method + everything-claude-code | `/bmad-bmm-dev-story`, `/tdd` 命令 |
| **UI 设计** | bmad-method + pencil + agentation | `/bmad-bmm-create-ux-design`, 创建页面原型，Agentation 设计标注 |
| **流程设计** | workflow-studio | 创建业务流程图、时序图 |
| **代码审查** | bmad-method + everything-claude-code | `/bmad-bmm-code-review`, `/code-review` |
| **E2E 测试** | bmad-method + everything-claude-code | `/bmad-agent-bmm-qa`, `/e2e` 命令 |
| **安全渗透测试** | shannon | Shannon 自主漏洞扫描 + PoC 生成 |
| **人类介入测试** | agentation + agentation-self-driving | UI 问题标注，自主设计评审 |
| **构建修复** | everything-claude-code | `/build-fix` 命令 |
| **重构优化** | everything-claude-code | `/refactor-clean` 命令 |

**BMAD Method 核心命令**：
- `/bmad-help` - 智能指导，自动检测项目状态并推荐下一步
- `/bmad-bmm-quick-spec` + `/bmad-bmm-quick-dev` - 快速流程（小型任务）
- `/bmad-bmm-create-prd` → `/bmad-bmm-create-architecture` → `/bmad-bmm-create-epics-and-stories` - 完整规划流程（中大型项目）

详见：[BMAD Method 集成指南](../docs/BMAD_METHOD_INTEGRATION.md)

---

## 🤖 自动化与人类介入边界

### 完全自动执行（无需人类介入）

| 任务类型 | 自动化命令 | 说明 |
|---------|-----------|------|
| ✅ 插件更新 | `/plugin update --all`, `/skill update --all` | 检查并更新插件和技能 |
| ✅ 环境检查 | `/plugin list`, `git status` | 检查插件状态、代码状态 |
| ✅ 代码检查 | `npm run lint` | 静态代码分析 |
| ✅ 构建验证 | `npm run build` | 编译检查 |
| ✅ 单元测试 | `npm test` / `mvn test` | 自动化测试 |
| ✅ E2E 测试 | `npx playwright test` | 端到端测试 |
| ✅ 格式化 | `npm run format` | 代码格式化 |
| ✅ 依赖更新 | `npm update` | 依赖检查更新 |

### 需要人类确认（半自动）

| 任务类型 | 自动部分 | 人类确认点 |
|---------|---------|-----------|
| ⚠️ 任务规划 | 生成计划 + 流程图 | **确认计划可行性** |
| ⚠️ 代码审查 | 自动扫描问题 | **确认修复方案** |
| ⚠️ 依赖升级 | 检测新版本 | **确认升级风险** |
| ⚠️ 重构建议 | 识别重构点 | **确认重构范围** |
| ⚠️ 测试失败 | 生成失败报告 | **确认是否阻塞** |
| ⚠️ 合并请求 | 准备合并内容 | **确认合并时机** |

### 必须人类执行（不可自动）

| 任务类型 | 原因 | 人类职责 |
|---------|------|---------|
| 🔴 需求确认 | 需要业务理解 | 明确需求边界和优先级 |
| 🔴 架构决策 | 需要战略思考 | 技术选型和架构方向 |
| 🔴 风险接受 | 需要责任承担 | 接受已知风险 |
| 🔴 发布决策 | 需要业务判断 | 决定发布时机 |
| 🔴 紧急处理 | 需要灵活应变 | 突发问题处理 |
| 🔴 资源协调 | 需要跨团队沟通 | 协调外部依赖 |

---

## 📊 上下文管理与自动压缩

### Model 上下文配额

| Model | Context Limit | 预警线 (70%) | 压缩线 (80%) | 强制线 (90%) |
|-------|--------------|-------------|-------------|-------------|
| qwen3.5-plus | 91k tokens | 63.7k | 72.8k | 81.9k |
| claude-sonnet-4 | 200k tokens | 140k | 160k | 180k |
| claude-opus-4 | 200k tokens | 140k | 160k | 180k |
| gemini-2.5-pro | 128k tokens | 89.6k | 102.4k | 115.2k |

### 上下文监控机制

PM Agent 每 30 秒检测一次各窗口的上下文使用量：

```
┌─────────────────────────────────────────────────────────────────┐
│                    上下文监控流程                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  每 30 秒检测 ──▶ 计算使用率 ──▶ 判断阈值                        │
│                                     │                           │
│         ┌───────────────────────────┼───────────────────────┐   │
│         │                           │                       │   │
│         ▼                           ▼                       ▼   │
│    70% 预警                    80% 准备压缩            90% 强制压缩  │
│         │                           │                       │   │
│         ▼                           ▼                       ▼   │
│    发送 P2 通知               自动保存关键信息         自动执行 compact  │
│    提醒用户                   到 MEMORY.md            保存状态后压缩    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 自动保存机制

当上下文使用率达到 80% 时，自动触发 Memory 保存：

```javascript
// 自动保存的关键信息
const criticalInfo = {
  taskId: 'task-52',              // 当前任务 ID
  taskProgress: 'implementation',  // 任务阶段
  currentStep: '编写登录页面组件',  // 当前步骤
  variables: { ... },             // 关键变量
  decisions: [                    // 重要决策
    {
      timestamp: '2026-03-03T10:00:00Z',
      decision: '选择方案 A',
      reason: '性能更好'
    }
  ],
  testResults: { ... },           // 测试结果
  filesModified: [...]            // 修改的文件列表
}

// 保存到 MEMORY.md
await saveToMemory(criticalInfo)
```

### 防止 Compact 后遗忘关键上下文的机制

**问题**：多次 compact 后，Agent 可能遗忘之前的测试规范（如 Mock 模式使用规则），导致：
- 重复使用 Mock 模式进行测试
- 将 Mock 测试结果误报为正式测试结果

**解决方案**：在 `MEMORY.md` 中持久化保存关键约束和测试状态

#### 1. 测试状态持久化

```markdown
## 🧪 测试状态 (持久化保存，compact 后必须保留)

### Mock 模式使用状态
- [ ] 前端 Mock 测试 - 状态：____ (pending/running/completed/skipped)
- [ ] 后端 API 测试 - 状态：____ (必须使用真实 API)
- [ ] 前后端联调测试 - 状态：____ (必须使用真实 API)
- [ ] E2E 端到端测试 - 状态：____ (必须使用真实 API)

### 已识别的 Mock 接口
| 接口名称 | Mock 原因 | 预计替换时间 | 关联任务 |
|---------|----------|-------------|---------|
| /api/xxx | 接口未开发 | 2026-03-10 | TASK-15 |

### 测试结果记录 (仅记录真实 API 测试)
| 测试类型 | 开始时间 | 完成时间 | 通过率 | 是否使用 Mock |
|---------|---------|---------|-------|--------------|
| 前端 Mock | 10:00 | 10:15 | 100% | ✅ 是 (仅 UI 验证) |
| 后端 API | 10:20 | 10:35 | 100% | ❌ 否 |
| 联调测试 | 10:40 | 11:00 | 100% | ❌ 否 |
```

#### 2. Compact 前必须保存的约束

```javascript
// compact 前强制保存的约束信息
const constraints = {
  testingRules: {
    mockAllowed: ['前端开发阶段', '前端 Mock 测试'],
    mockForbidden: ['后端 API 测试', '前后端联调', 'E2E 测试'],
    mockMarkers: ['// ⚠️ MOCK:', '// TODO: Mock 替换']
  },
  portCheckRequired: true,  // 测试前必须检查端口
  dataValidation: {
    requireRealData: true,   // 必须使用真实数据
    mockDataNotAllowed: true // Mock 数据不允许用于正式测试
  }
}

// 保存到 MEMORY.md 的固定位置（不会被 compact 清除）
await saveToMemory({ constraints }, { persistent: true })
```

#### 3. 测试报告验证机制

生成测试报告前，必须执行验证：

```javascript
// 测试报告生成前的验证
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

  return {
    valid: errors.length === 0,
    errors
  }
}
```

#### 4. Compact 后恢复检查清单

每次 compact 完成后，Agent 必须执行：

```
□ 1. 读取 MEMORY.md 中的测试状态
   - 确认各阶段测试是否完成
   - 确认 Mock 模式使用状态

□ 2. 验证约束条件
   - Mock 模式是否仅在允许阶段使用
   - 联调测试是否已切换到真实 API

□ 3. 检查测试报告
   - 确认报告的测试结果未包含 Mock 测试（前端 Mock 测试除外）
   - 确认所有 Mock 接口都有标记

□ 4. 继续任务前确认
   - 如有未完成的真实 API 测试，优先执行
   - 如有未标记的 Mock 接口，补充标记
```

### 自动 Compact 流程

当上下文使用率达到 90% 时，自动触发 compact：

```flow
TD
A[检测到 90% 阈值] --> B[保存当前状态]
B --> C[生成状态快照]
C --> D[执行 compact 命令]
D --> E[等待 compact 完成]
E --> F[读取 MEMORY.md 恢复上下文]
F --> G[继续执行任务]
```

### Compact 命令行动准则

在行动准则中定义 compact 触发条件：

```markdown
## 自动 Compact 触发条件

以下情况自动执行 compact：

1. **上下文使用率 ≥ 90%** - 强制压缩
2. **上下文使用率 ≥ 80% 且用户确认** - 用户确认压缩
3. **任务阶段完成** - 主动压缩保存

Compact 前自动保存：
- 当前任务 ID 和进度
- 关键变量和决策
- 测试结果和修改文件

Compact 后自动恢复：
- 从 MEMORY.md 读取上下文
- 恢复任务执行状态
- 继续未完成的步骤
```

---

## 🔔 通知触发条件

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  待规划  │───▶│  规划中  │───▶│ 待人类确认│───▶│  开发中  │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
     │               │               │               │
     ▼               ▼               ▼               ▼
 自动检测      自动生成计划     发送通知       自动执行 TDD
 新任务        + 流程图        等待确认       + 测试
                                              │
     ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
     │  已完成  │◀───│ 验证通过 │◀───│  开发完成 │◀───│ 需要帮助 │
     └──────────┘    └──────────┘    └──────────┘    └──────────┘
          │               │               │               │
          │               │               │               ▼
          │               │               │         发送通知
          │               │               │         请求帮助
          │               │               ▼
          │               │          自动提交
          │               │          更新文档
          │               ▼
          │          自动运行
          │          验证测试
          ▼
     自动通知
     完成
```

---

## 🔔 通知触发条件

### 通知级别定义

| 级别 | 标识 | 响应时间 | 示例 |
|------|------|---------|------|
| **P0 - 紧急** | 🔴 | 立即 | 生产事故、数据丢失风险 |
| **P1 - 重要** | 🟠 | 30 分钟内 | 关键阻塞、决策点 |
| **P2 - 普通** | 🟡 | 2 小时内 | 确认请求、评审邀请 |
| **P3 - 提醒** | 🟢 | 24 小时内 | 进度通知、完成通知 |

### 通知触发矩阵

| 场景 | 级别 | 人类介入点 | 自动执行部分 |
|------|------|-----------|-------------|
| **规划完成待确认** | P2 | 确认计划 | 生成计划 + 流程图 |
| **测试失败待决策** | P2 | 决策是否继续 | 生成失败报告 |
| **遇到阻塞需介入** | P1 | 处理阻塞 | 发送通知 + 暂停任务 |
| **架构决策点** | P1 | 选择方案 | 提供选项分析 |
| **风险接受确认** | P1 | 确认接受 | 识别并记录风险 |
| **任务完成通知** | P3 | 知悉 | 自动提交 + 更新文档 |
| **定时巡检报告** | P3 | 知悉 | 生成报告 |
| **紧急错误** | P0 | 立即处理 | 发送多渠道通知 |

---

## 🔄 会话启动流程

### Step 0: 插件和技能更新检查（最高优先级）

```bash
# 0.1 更新核心插件
/plugin update bmad-method
/plugin update everything-claude-code
/plugin update workflow-studio

# 0.2 更新所有 GitHub 学习到的技能
/skill update --all

# 0.3 或批量更新所有插件
/plugin update --all

# 0.4 验证更新成功
/plugin list  # 查看插件版本
/skill list   # 查看技能列表
```

**更新原则**：
- ✅ 每次会话启动时自动检查更新
- ✅ 优先更新 bmad-method（核心需求分析工具）
- ✅ 更新 everything-claude-code（命令库、技能库）
- ✅ 更新所有 GitHub 学习到的技能
- ⚠️ 更新后验证功能正常
- ⚠️ 如更新失败，使用现有版本继续

# Step 1: 插件环境检查

```bash
# 1.1 检查已安装插件
/plugin list

# 1.2 验证必备插件
必需插件：
- bmad-method (需求分析/多 Agent 协作)
- everything-claude-code (命令/技能/规则)
- workflow-studio (流程图/可视化)
- pencil (UI 原型设计 - MCP 服务)
- agentation (UI 设计标注 - 前端项目必备)

# 1.3 检查必备技能
/skill list
# 确认以下技能存在：
# - agentation (安装工具栏)
# - agentation-self-driving (自主评审模式)

# 1.4 缺失插件安装
如果缺失，立即执行：
/plugin install <插件名>
/skill <技能名>

# 1.5 验证规则加载
ls ~/.claude/rules/  # 确认规则文件存在
```

### Step 2: 读取核心文档（必做，按顺序）

1. `CLAUDE.md` - 项目概述
2. `ACTION_GUIDELINES.md` - 行动准则
3. `MEMORY.md` - 项目快照、当前状态
4. `PENDING_TESTS.md` - 待测试记录
5. `architecture.md` - 工程文档
6. `task.json` - 待执行任务列表

### Step 3: 环境检查

```bash
pwd                    # 确认当前目录
git status --short     # 检查未提交更改
git log --oneline -5   # 查看最近提交
```

### Step 4: 确认下一个任务

从 `task.json` 中找到第一个 `passes: false` 的任务，告知用户即将执行。

---

## 📊 与 Claude Monitor UI 的集成

### 项目分工

| 功能 | 负责项目 | 说明 |
|------|---------|------|
| 行动准则定义 | siginfo-claude-code-guidelines | 定义流程、规范、模板 |
| 任务监督 | claude-monitor-ui | PM Agent 自动监督各窗口任务状态 |
| 通知发送 | claude-monitor-ui | 多渠道通知（飞书/钉钉/短信等） |
| 确认反馈 | claude-monitor-ui | 接收用户确认，生成确认凭证 |

### 对接 API 接口

行动准则执行过程中需要调用 Claude Monitor UI 的以下 API：

```javascript
// 1. 发送通知（需要人类确认时）
POST http://localhost:8083/api/notification/send
{
  "level": "P2",
  "type": "plan_confirm",
  "taskId": "task-52",
  "title": "任务规划待确认",
  "content": "规划已完成，请确认是否继续",
  "channels": ["feishu", "in-app"],
  "timeout": 7200000,
  "actions": ["confirm", "modify", "pause"]
}

// 2. 确认反馈（用户点击确认按钮后）
POST http://localhost:8083/api/notification/confirm
{
  "notifyId": "notify-xxx",
  "userId": "user-001",
  "action": "confirm",  // confirm/modify/pause/skip
  "taskId": "task-52",
  "timestamp": "2026-03-03T10:30:00Z"
}

// 3. 任务状态更新
POST http://localhost:8083/api/task/status
{
  "taskId": "task-52",
  "status": "waiting_human|in_progress|blocked|completed",
  "notifyLevel": "P2"
}

// 4. 获取任务列表（PM Agent 巡检用）
GET http://localhost:8083/api/tasks?status=pending

// 5. 获取窗口状态
GET http://localhost:8083/api/windows

// 6. 发送完成通知
POST http://localhost:8083/api/notification/send
{
  "level": "P3",
  "type": "task_completed",
  "taskId": "task-52",
  "title": "任务完成",
  "content": "任务已完成，测试通过率 100%",
  "channels": ["in-app"]
}
```

### 确认凭证机制

当用户通过任意渠道（飞书/钉钉/短信等）确认后，Claude Monitor UI 会：

1. 生成确认凭证（包含签名防伪造）
2. 标记通知为已确认
3. 停止二次通知
4. 触发后续流程（如继续任务执行）

行动准则项目无需处理确认逻辑，只需调用发送通知 API 即可。

---

## 🔌 端口冲突排查规范

### 核心原则

> **执行任何测试前，必须先排查端口占用情况。如果发现端口被占用，必须避开已占用的端口，严禁强制占用或终止正在使用的进程。**

### 端口排查流程

在启动测试前，自动执行以下检查：

```bash
# Step 1: 识别测试需要使用的端口
# 常见端口：
# - 前端开发服务器：3000, 5173, 8080
# - 后端 API 服务器：8000, 8080, 3333
# - 数据库：5432 (PostgreSQL), 3306 (MySQL), 27017 (MongoDB)
# - E2E 测试：49342 (Playwright), 9515 (ChromeDriver)

# Step 2: 检查端口占用状态
# macOS / Linux:
lsof -i :<端口号>
# 或
netstat -an | grep <端口号>

# Windows:
netstat -ano | findstr :<端口号>

# Step 3: 判断占用进程
- 如果是测试相关的必要服务 → 记录，尝试复用
- 如果是无关进程 → 更换测试端口，不终止该进程
- 如果是残留测试进程 → 清理后重启
```

### 端口冲突处理策略

| 场景 | 处理方式 | 示例命令 |
|------|---------|---------|
| **端口空闲** | 直接使用 | 启动服务 |
| **被必要服务占用** | 复用现有服务 | 不重启，直接使用 |
| **被无关进程占用** | 更换测试端口 | `PORT=3001 npm run dev` |
| **被残留测试进程占用** | 清理后重启 | `kill <PID>` 后重启 |

### 严禁行为

```
❌ 错误做法 1: 发现端口占用，直接 kill 占用进程
   → 风险：可能终止生产服务或其他重要进程

❌ 错误做法 2: 强制绑定端口，忽略冲突
   → 风险：测试启动失败或行为异常

❌ 错误做法 3: 不检查端口，直接启动测试
   → 风险：端口冲突导致测试失败，浪费时间排查

✅ 正确做法：先检查，再决定复用或更换端口
```

---

## 📚 文档索引

### 核心规范

| 文档 | 用途 |
|------|------|
| [ACTION_GUIDELINES.md](01-ACTION_GUIDELINES.md) | ⭐ 核心行动准则 |
| [TDD_WORKFLOW.md](02-TDD_WORKFLOW.md) | TDD 开发流程 |
| [MULTI_AGENT.md](03-MULTI_AGENT.md) | 多 Agent 协作 |
| [E2E_TESTING_FLOW.md](04-E2E_TESTING_FLOW.md) | E2E 测试验证流程 |
| [QUALITY_GATE.md](05-QUALITY_GATE.md) | 质量门禁 |
| [TRACEABILITY.md](06-TRACEABILITY.md) | 可追溯性规范 |
| [PLUGIN_MANAGEMENT.md](07-PLUGIN_MANAGEMENT.md) | 插件使用规范 |
| [TEST-INTEGRITY.md](15-TEST-INTEGRITY.md) | 测试真实性验证规范 |

### 企业级测试框架

| 文档 | 用途 |
|------|------|
| [TEST_SOLUTION.md](../TEST_SOLUTION.md) | Playwright 企业级测试解决方案总览 |
| [ENTERPRISE_TEST_FRAMEWORK.md](../ENTERPRISE_TEST_FRAMEWORK.md) | 企业级测试框架设计（15 层测试金字塔） |
| [e2e/README.md](../e2e/README.md) | 测试框架使用指南 |
| [COMPREHENSIVE_TESTING_WORKFLOW.md](17-COMPREHENSIVE_TESTING_WORKFLOW.md) | 综合测试工作流 |
| [REAL_BUSINESS_TESTING.md](18-REAL_BUSINESS_TESTING.md) | 真实业务测试规范 |

### 最佳实践

| 文档 | 用途 |
|------|------|
| [LONG_RUNNING_AGENTS.md](08-LONG_RUNNING_AGENTS.md) | 长期运行 Agent 最佳实践 |
| [ANTHROPIC_LONG_RUNNING_AGENTS.md](10-ANTHROPIC_LONG_RUNNING_AGENTS.md) | Anthropic 官方指南 |
| [LONG_TERM_MEMORY.md](11-LONG_TERM_MEMORY.md) | 长期记忆管理 |
| [AGENT_REACH_INTEGRATION.md](12-AGENT_REACH_INTEGRATION.md) | Agent-Reach 互联网能力集成 |
| [AUTOMATION_MODES.md](09-AUTOMATION_MODES.md) | 项目级自动化模式配置 |
| [DETERMINISTIC_DEVELOPMENT.md](14-DETERMINISTIC_DEVELOPMENT.md) | 确定性开发流程 |
| [COLLABORATION_EFFICIENCY.md](13-COLLABORATION_EFFICIENCY.md) | 协作效率优化 |
| [STABLE_ZONE_PROTECTION.md](15-STABLE_ZONE_PROTECTION.md) | 稳定区保护机制 |
| [DOCLING_INTEGRATION.md](16-DOCLING_INTEGRATION.md) | DocLing 文档处理集成 |

---

*版本：1.0.0*
*最后更新：2026-03-12*

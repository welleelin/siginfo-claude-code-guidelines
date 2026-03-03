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

---

## 🔌 必备插件管理

### 插件清单

| 插件名称 | 用途 | 安装方式 | 是否必备 |
|---------|------|---------|---------|
| **bmad-method** | 需求分析、架构设计、多 Agent 协作 | `/plugin install bmad-method` | ✅ 必备 |
| **everything-claude-code** | 命令库、技能库、Agent 库、规则 | 手动安装 | ✅ 必备 |
| **workflow-studio** | 流程图、时序图、可视化工作流 | `/plugin install workflow-studio` | ✅ 必备 |
| **pencil** | UI 设计原型、线框图 | MCP 服务 | ✅ 必备 |

### 插件初始化检查

在每次新会话或新项目开始时，必须执行：

```bash
# Step 1: 检查已安装插件
/plugin list

# Step 2: 验证必备插件
必需插件：
- bmad-method (需求分析/多 Agent 协作)
- everything-claude-code (命令/技能/规则)
- workflow-studio (流程图/可视化)
- pencil (UI 原型设计 - MCP 服务)

# Step 3: 缺失插件安装
如果缺失，立即执行：
/plugin install bmad-method
/plugin install everything-claude-code
/plugin install workflow-studio

# Pencil MCP 如未配置，需手动添加 MCP 配置
```

### 插件能力使用场景

| 阶段 | 使用插件 | 具体能力 |
|------|---------|---------|
| **需求分析** | bmad-method | `bmm-create-product-brief`, `bmm-market-research` |
| **架构设计** | bmad-method + workflow-studio | `bmm-create-architecture` + 绘制架构图 |
| **任务规划** | everything-claude-code | `/plan` 命令 + workflow-studio 流程图 |
| **TDD 开发** | everything-claude-code | `/tdd` 命令 |
| **UI 设计** | pencil | 创建页面原型 |
| **流程设计** | workflow-studio | 创建业务流程图、时序图 |
| **代码审查** | bmad-method + everything-claude-code | `bmm-code-review` + `/code-review` |
| **E2E 测试** | everything-claude-code | `/e2e` 命令 |
| **构建修复** | everything-claude-code | `/build-fix` 命令 |
| **重构优化** | everything-claude-code | `/refactor-clean` 命令 |

---

## 🤖 自动化与人类介入边界

### 完全自动执行（无需人类介入）

| 任务类型 | 自动化命令 | 说明 |
|---------|-----------|------|
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

## 📋 任务执行状态机

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

### Step 0: 插件环境检查（最高优先级）

```bash
# 0.1 检查插件列表
/plugin list

# 0.2 验证必备插件
必需插件：
- bmad-method (需求分析/多 Agent 协作)
- everything-claude-code (命令/技能/规则)
- workflow-studio (流程图/可视化)
- pencil (UI 原型设计 - MCP 服务)

# 0.3 缺失插件安装
如果缺失，立即执行：
/plugin install <插件名>

# 0.4 验证规则加载
ls ~/.claude/rules/  # 确认规则文件存在
```

### Step 1: 读取核心文档（必做，按顺序）

1. `CLAUDE.md` - 项目概述
2. `ACTION_GUIDELINES.md` - 行动准则
3. `MEMORY.md` - 项目快照、当前状态
4. `PENDING_TESTS.md` - 待测试记录
5. `architecture.md` - 工程文档
6. `task.json` - 待执行任务列表

### Step 2: 环境检查

```bash
pwd                    # 确认当前目录
git status --short     # 检查未提交更改
git log --oneline -5   # 查看最近提交
```

### Step 3: 确认下一个任务

从 `task.json` 中找到第一个 `passes: false` 的任务，告知用户即将执行。

---

## 📊 与 Claude Monitor UI 的集成

### 项目分工

| 功能 | 负责项目 | 说明 |
|------|---------|------|
| 行动准则定义 | sig-claude-code-guidelines | 定义流程、规范、模板 |
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

## 📚 文档索引

| 文档 | 用途 |
|------|------|
| [ACTION_GUIDELINES.md](01-ACTION_GUIDELINES.md) | ⭐ 核心行动准则 |
| [TDD_WORKFLOW.md](02-TDD_WORKFLOW.md) | TDD 开发流程 |
| [MULTI_AGENT.md](03-MULTI_AGENT.md) | 多 Agent 协作 |
| [E2E_TESTING_FLOW.md](04-E2E_TESTING_FLOW.md) | E2E 测试验证流程 |
| [QUALITY_GATE.md](05-QUALITY_GATE.md) | 质量门禁 |
| [TRACEABILITY.md](06-TRACEABILITY.md) | 可追溯性规范 |
| [PLUGIN_MANAGEMENT.md](07-PLUGIN_MANAGEMENT.md) | 插件使用规范 |

---

*版本：1.0.0*
*最后更新：2026-03-03*

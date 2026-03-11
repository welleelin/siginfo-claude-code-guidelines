# 长期记忆管理规范

> **版本**：1.1.0
> **最后更新**：2026-03-09
> **基于**：Anthropic 官方最佳实践 + OpenClaw Memory 架构 + Planning-with-Files 技能

---

## 📋 概述

### 为什么需要长期记忆？

AI Agent 在长周期任务中面临的核心挑战：

| 问题 | 表现 | 后果 |
|------|------|------|
| 上下文限制 | Token 耗尽后早期信息丢失 | 遗忘项目初期决策 |
| 会话断裂 | 每次新会话从零开始 | 重复解释相同信息 |
| 状态丢失 | Compact 后无持久化 | 需要重新建立上下文 |
| 决策遗忘 | 关键决策未记录 | 重复讨论相同问题 |

### 解决方案

**文件就是记忆** - 所有需要持久化的信息写入 Markdown 文件，模型只"记住"写在磁盘上的内容。

---

## 🏗️ 三层记忆架构

```
┌─────────────────────────────────────────────────────────────┐
│                    OpenClaw 三层记忆架构                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐  Hourly 层（短期记忆）                  │
│  │  会话级记忆     │  - 当前会话的技术决策                   │
│  │  (每小时同步)   │  - 实时问题解决过程                     │
│  │                 │  - 用户偏好的即时捕获                   │
│  └─────────────────┘  存储：memory/YYYY-MM-DD.md             │
│                                                             │
│  ┌─────────────────┐  Daily 层（中期记忆）                   │
│  │  每日归档       │  - 项目进展、已完成任务                 │
│  │  (23:00 同步)    │  - 重要决策记录                         │
│  │                 │  - 技术债务管理                         │
│  └─────────────────┘  存储：memory/YYYY-MM-DD.md + 标签索引   │
│                                                             │
│  ┌─────────────────┐  Weekly 层（长期记忆）                  │
│  │  周度总结       │  - 核心知识、最佳实践                   │
│  │  (周日 22:00)    │  - 模式识别与复用                       │
│  │                 │  - 技术架构决策                         │
│  └─────────────────┘  存储：MEMORY.md + 知识库               │
│                                                             │
│  ┌─────────────────┐  Context 层（工作记忆）                 │
│  │  当前会话       │  - 系统提示词注入                       │
│  │  (实时)         │  - 对话历史、工具调用                   │
│  │                 │  - 自动压缩管理                         │
│  └─────────────────┘  阈值：70% 预警/80% 保存/90% compact     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 各层详细说明

#### 1. Hourly 层（短期记忆）

**同步频率**：每小时一次

**存储内容**：
- 当前会话的技术决策
- 实时问题解决过程
- 用户偏好的即时捕获
- 临时笔记和待办

**文件格式**：`memory/YYYY-MM-DD.md`

**检索方式**：实时向量搜索 + 关键词匹配

**保留策略**：7 天后归档

#### 2. Daily 层（中期记忆）

**同步频率**：每日 23:00

**存储内容**：
- 项目进展和已完成任务
- 重要决策和原因
- 技术债务记录
- 知识沉淀

**文件格式**：按日期组织的 Markdown 文件

**检索方式**：时间线 + 标签双重索引

**保留策略**：永久保留，按项目周期归档

#### 3. Weekly 层（长期记忆）

**同步频率**：每周日 22:00

**存储内容**：
- 核心知识和最佳实践
- 模式识别与复用
- 技术架构决策 (ADR)
- 用户偏好和规范

**文件格式**：`MEMORY.md` + 结构化知识库

**检索方式**：语义搜索 + 关联分析

**保留策略**：永久保留，定期清理过时信息

---

## 📁 文件布局

```
project/
├── MEMORY.md                      # Weekly 层 - 长期记忆（仅主会话加载）
├── AGENTS.md                      # 行为规范（每次会话加载）
├── HEARTBEAT.md                   # 定期检查任务
├── .heartbeat-status.json         # 心跳状态记录
├── memory/
│   ├── 2026-03-04.md              # Daily 层 - 每日日志
│   ├── 2026-03-03.md
│   └── 2026-03-02.md
├── checkpoints/
│   ├── checkpoint-20260304-120000.json  # 状态检查点
│   └── checkpoint-20260304-180000.json
└── templates/
    ├── MEMORY.md.template
    ├── memory-template.md
    ├── AGENTS.md.template
    └── HEARTBEAT.md.template
```

### 文件说明

| 文件 | 用途 | 加载条件 | 大小限制 |
|------|------|---------|---------|
| MEMORY.md | 长期记忆 | 仅主会话 | 20KB |
| AGENTS.md | 行为规范 | 每次会话 | 10KB |
| HEARTBEAT.md | 检查任务 | 每次会话 | 5KB |
| memory/*.md | 每日日志 | 今天 + 昨天 | 每文件 10KB |
| checkpoints/*.json | 状态检查点 | 按需读取 | 每文件 5KB |
| task_plan.md | 任务路线图 | 使用 /plan 时 | 10KB |
| findings.md | 任务发现 | 使用 /plan 时 | 10KB |
| progress.md | 任务进度 | 使用 /plan 时 | 10KB |

---

## 🧩 Planning-with-Files 融合

> **版本**：v2.18.2 | **基准通过率**：96.7% | **支持平台**：16+ IDE

### 融合架构

```
┌─────────────────────────────────────────────────────────────────┐
│           长期记忆系统 + Planning-with-Files 融合架构            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              长期记忆层 (Weekly/Daily/Hourly)            │   │
│  │                                                         │   │
│  │  MEMORY.md ─── 项目级长期记忆                           │   │
│  │  memory/*.md ─── 每日日志                               │   │
│  │  HEARTBEAT.md ─── 定期任务                              │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                    │
│                            ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              任务规划层 (planning-with-files)            │   │
│  │                                                         │   │
│  │  task_plan.md ─── 任务路线图（5 阶段工作流）            │   │
│  │  findings.md ─── 知识库（2-Action 规则）                │   │
│  │  progress.md ─── 会话日志（5-Question Reboot Test）     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                    │
│                            ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              上下文层 (Context)                          │   │
│  │                                                         │   │
│  │  70% 预警 → 80% 自动保存 → 90% 强制 compact             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 职责分工

| 文件 | 职责 | 生命周期 | 更新频率 |
|------|------|---------|---------|
| **MEMORY.md** | 项目级长期记忆 | 永久 | Weekly |
| **memory/*.md** | 每日日志 | 7 天 | Hourly/Daily |
| **task_plan.md** | 单任务路线图 | 任务期间 | 每阶段 |
| **findings.md** | 单任务发现 | 任务期间 | 每 2 次搜索 |
| **progress.md** | 单任务进度 | 任务期间 | 每阶段完成 |

### 使用场景

| 场景 | 推荐文件 | 说明 |
|------|---------|------|
| 项目里程碑记录 | MEMORY.md | 跨任务的长期决策 |
| 技术选型决策 | MEMORY.md + findings.md | 长期 + 任务级 |
| 每日开发日志 | memory/*.md | 临时性工作记录 |
| 复杂任务规划 | task_plan.md | 5 阶段工作流 |
| 技术调研发现 | findings.md | 2-Action 规则 |
| 任务进度追踪 | progress.md | 5-Question Reboot Test |

### 快速启动

```bash
# 启动任务规划模式
/plan

# 查看规划状态
/plan:status

# 开始新规划
/plan:start
```

### 关键特性

1. **会话恢复** - `/clear` 后自动恢复之前会话
2. **2-Action 规则** - 每 2 次搜索/浏览后必须更新 findings.md
3. **5-Question Reboot Test** - 验证上下文完整性：
   - Where am I? → 当前阶段
   - Where am I going? → 剩余阶段
   - What's the goal? → 目标陈述
   - What have I learned? → findings.md
   - What have I done? → progress.md

---

## 🔄 同步机制

### Hourly 同步

**触发条件**：每小时整点

**执行脚本**：`./scripts/sync-hourly.sh`

**操作步骤**：
1. 检查当前会话状态
2. 记录技术决策和待办
3. 更新 memory/YYYY-MM-DD.md
4. 更新 .heartbeat-status.json

### Daily 归档

**触发条件**：每日 23:00

**执行脚本**：`./scripts/archive-daily.sh`

**操作步骤**：
1. 读取当日 memory 文件
2. 提取重要决策和教训
3. 更新 MEMORY.md 相关章节
4. 生成日报摘要
5. 准备明日待办

### Weekly 总结

**触发条件**：每周日 22:00

**执行脚本**：`./scripts/summarize-weekly.sh`

**操作步骤**：
1. 读取过去 7 天的 memory 文件
2. 提取关键决策和模式
3. 更新 MEMORY.md
4. 清理过时信息
5. 生成周报

---

## 🧠 Context 管理

### 阈值管理

| 阈值 | 触发动作 | 通知级别 |
|------|---------|---------|
| 70% | 预警通知 | P2 |
| 80% | 自动保存到 Memory | P2 |
| 90% | 强制 compact | P1 |

### 自动保存内容

当上下文达到 80% 时，自动保存以下信息：

```javascript
const criticalInfo = {
  taskId: 'task-52',
  taskProgress: 'implementation',
  currentStep: '编写登录页面组件',
  keyDecisions: [...],
  testResults: {...},
  filesModified: [...]
}
```

### Memory Flush

**触发条件**：上下文接近压缩阈值

**操作流程**：
1. 提醒将重要信息写入 memory 文件
2. 等待 Agent 完成写入
3. 执行 compact
4. 验证 compact 成功

**配置示例**：
```json
{
  "compaction": {
    "memoryFlush": {
      "enabled": true,
      "softThresholdTokens": 4000
    }
  }
}
```

---

## 🔍 检索优化

### 混合检索配置

```json
{
  "hybrid": {
    "vectorWeight": 0.7,    // 语义相似度
    "textWeight": 0.3,      // 关键词匹配
    "candidateMultiplier": 4
  },
  "temporalDecay": {
    "enabled": true,
    "halfLifeDays": 30      // 30 天后分数减半
  },
  "mmr": {
    "enabled": true,
    "lambda": 0.7           // 去重参数
  }
}
```

### 检索策略

| 查询类型 | 推荐策略 | 示例 |
|---------|---------|------|
| 精确查询 | 关键词匹配 | commit hash、API 名称 |
| 语义搜索 | 向量检索 | "上周的部署问题" |
| 历史回溯 | 时间范围 | "2026-02 的配置决策" |
| 多维分析 | 标签组合 | "tag:deployment + tag:error" |

### 时间衰减算法

```
decayedScore = score * e^(-λ * ageInDays)

其中：λ = ln(2) / halfLifeDays
```

**效果示例**（halfLifeDays=36）：
| 时间 | 剩余分数 |
|------|---------|
| 今天 | 100% |
| 7 天前 | 84% |
| 36 天前 | 50% |
| 90 天前 | 12.5% |
| 180 天前 | 1.6% |

---

## 🛡️ 安全与隐私

### MEMORY.md 加载规则

| 会话类型 | 是否加载 MEMORY.md | 说明 |
|---------|------------------|------|
| 主会话 (1 对 1) | ✅ 加载 | 私密环境，可访问长期记忆 |
| 群组对话 | ❌ 不加载 | 公共场合，避免泄露隐私 |

### 敏感信息处理

**禁止写入记忆文件**：
- API Key、密码、Token
- 服务器 IP 地址（使用占位符）
- 个人联系方式（Telegram ID 等）
- 数据库连接字符串

**正确做法**：
```markdown
# ❌ 错误
API_KEY: sk-1234567890abcdef

# ✅ 正确
API_KEY: 存在于环境变量 BLOG_API_KEY
```

### Git 备份配置

```gitignore
# .gitignore 推荐配置
.DS_Store
.key
.pem
.secrets/
~/.openclaw/credentials/
*.local
```

---

## 📊 工作流状态管理

### 状态定义

```typescript
interface WorkflowState {
  id: string;
  type: "deploy" | "content-creation" | "monitoring";
  status: "pending" | "running" | "waiting" | "completed" | "failed";
  currentStep: number;
  totalSteps: number;
  context: Record<string, any>;
  createdAt: Date;
  updatedAt: Date;
}
```

### 状态流转

```
pending → running → waiting → completed
              ↓
           failed → (retry) → running
```

### 人工介入点配置

```json
{
  "humanIntervention": {
    "deploy": "final-confirm",
    "config-change": "show-diff",
    "delete": "step-by-step",
    "publish": "pre-review"
  }
}
```

---

## 🐛 错误处理

### 错误分级

| 级别 | 类型 | 处理策略 | 通知级别 |
|------|------|---------|---------|
| L1 | 网络超时、临时失败 | 自动重试（指数退避） | 无 |
| L2 | API 不可用、资源缺失 | 备选方案 + P1 通知 | 飞书 |
| L3 | 权限错误、数据损坏 | 立即停止 + P0 通知 | 电话 |

### 重试策略

```bash
# 指数退避配置
初始延迟：1 秒
最大延迟：60 秒
最大重试：3 次
延迟公式：delay = min(initial * 2^attempt, max)
```

### 错误日志格式

```json
{
  "errorId": "error-task-52-20260304-104500",
  "taskId": "task-52",
  "timestamp": "2026-03-04T10:45:00+08:00",
  "step": "实现功能",
  "error": {
    "type": "L2",
    "code": "API_UNAVAILABLE",
    "message": "认证 API 无法访问"
  },
  "actions": [
    {"action": "retry", "attempt": 1, "result": "failed"},
    {"action": "try_alternative", "result": "failed"},
    {"action": "notify_human", "level": "P1"}
  ],
  "resolution": {
    "status": "pending_human_intervention"
  }
}
```

---

## ✅ 最佳实践

### 记忆内容组织

**推荐分类**：
- 技术决策：架构选择、技术选型
- 问题解决：错误排查、方案设计
- 用户偏好：沟通风格、工作习惯
- 项目进展：里程碑、风险评估

### 搜索策略优化

| 目标 | 推荐查询 | 说明 |
|------|---------|------|
| 具体技术问题 | 精确关键词 | "Dev.to API 发布错误" |
| 概念性探索 | 语义搜索 | "如何解决部署问题" |
| 历史回溯 | 时间范围 | "2026-02 的配置决策" |
| 多维分析 | 标签组合 | "tag:deployment + tag:success" |

### 数据维护规范

- **定期清理**：删除过时信息（Weekly 总结时）
- **版本管理**：Git 备份关键历史
- **权限控制**：敏感信息分离存储
- **备份策略**：多重数据保护

---

## 📈 性能指标

| 指标 | 目标值 | 测量方式 |
|------|--------|---------|
| 查询响应时间 | <100ms | memory_search 耗时 |
| 同步开销 | <5% 系统资源 | CPU/内存监控 |
| 语义匹配准确率 | 85-95% | 相关性问题抽样 |
| 上下文召回率 | 90%+ | 检索覆盖率 |
| 可用性 | 99.9% | 运行时间统计 |
| 数据完整性 | 100% | 校验和检查 |

---

## 🔧 实施检查清单

### 个人开发者

- [ ] 从小开始：先实现 Hourly 层
- [ ] 保持简洁：避免过度复杂化
- [ ] 定期回顾：每周检查记忆质量
- [ ] 持续优化：根据使用习惯调整结构

### 团队项目

- [ ] 统一标准：制定记忆规范
- [ ] 权限管理：区分个人和团队记忆
- [ ] 知识共享：建立团队记忆库
- [ ] 质量监控：定期评估记忆价值

---

## 📚 相关文档

- [系统总则](./00-SYSTEM_OVERVIEW.md) - 上下文管理
- [长期运行 Agent 最佳实践](./08-LONG_RUNNING_AGENTS.md)
- [Anthropic 官方指南](./10-ANTHROPIC_LONG_RUNNING_AGENTS.md)
- [自动化模式配置](./09-AUTOMATION_MODES.md)

---

## 📝 更新日志

| 版本 | 日期 | 更新内容 | 作者 |
|------|------|---------|------|
| 1.0.0 | 2026-03-04 | 初始版本，整合 Anthropic + OpenClaw 最佳实践 | - |

---

> **核心原则**：
> 1. 写下来！不要指望"心智笔记"，文件是唯一的真相
> 2. 分层管理：MEMORY.md（长期）+ memory/日志（短期）+ AGENTS.md（规则）
> 3. 定期回顾：通过 heartbeat 或手动，从 daily log 提炼到 MEMORY.md
> 4. 隐私第一：敏感数据分离，MEMORY.md 只在主会话加载

# 四项目集成分析 - BMAD Method + everything-claude-code + oh-my-claudecode + sig-claude-code-guidelines

> **版本**：1.0.0
> **分析日期**：2026-03-08
> **分析者**：Claude (Opus 4.6)

---

## 📋 概述

本文档分析四个 Claude Code 生态项目的集成方案，旨在建立从需求到交付的完整 AI 辅助开发流程。

### 四个项目简介

| 项目 | Stars | 定位 | 核心能力 |
|------|-------|------|---------|
| **BMAD Method** | 39.5K⭐ | AI 驱动的敏捷开发框架 | 需求分析、架构设计、Story 驱动开发 |
| **everything-claude-code** | 65K⭐ | Agent harness 性能优化系统 | 50+ 技能库、33 命令、16 Agent |
| **oh-my-claudecode** | 8.7K⭐ | 多 Agent 编排引擎 | Team 编排、智能模型路由、成本优化 |
| **sig-claude-code-guidelines** | - | 开发规范与流程 | TDD 工作流、长期记忆、质量门禁 |

---

## 🎯 项目详细分析

### 1. BMAD Method

**GitHub**: https://github.com/bmad-code-org/BMAD-METHOD
**版本**: v6.0.1
**社区**: Discord 活跃

#### 核心能力

**9 个专业化 Agent**：
- Analyst (Mary) - 需求分析
- PM (John) - 产品管理
- Architect (Winston) - 架构设计
- Scrum Master (Bob) - Sprint 管理
- Developer (Amelia) - 开发实现
- QA (Quinn) - 质量保证
- UX Designer (Olivia) - 用户体验
- Tech Writer (Paige) - 技术文档
- Quick Flow Solo Dev - 快速开发

**34+ 工作流**：

```
Phase 1: Analysis（分析）
├─ bmad-brainstorming - 头脑风暴
├─ bmad-domain-research - 领域调研
├─ bmad-market-research - 市场调研
└─ bmad-create-product-brief - 产品简介

Phase 2: Planning（规划）
├─ bmad-create-prd - 创建 PRD
└─ bmad-create-ux-design - UX 设计

Phase 3: Solutioning（方案设计）
├─ bmad-create-architecture - 架构设计
├─ bmad-create-epics-and-stories - Epic/Story 分解
└─ bmad-check-implementation-readiness - 实现就绪检查

Phase 4: Implementation（实现）
├─ bmad-sprint-planning - Sprint 规划
├─ bmad-create-story - 创建 Story
├─ bmad-dev-story - 实现 Story
├─ bmad-code-review - 代码审查
├─ bmad-correct-course - 纠正路线
└─ bmad-retrospective - 回顾总结
```

**3 种规划轨道**：
- **Quick Flow**：小任务（<2h），快速规划和实现
- **BMad Method**：中型项目（2-8h），完整规划流程
- **Enterprise**：大型系统（>8h），深度规划和架构设计

**文档产出**：
- PRD.md - 产品需求文档
- architecture.md - 架构设计文档
- epic-*.md - Epic 文档
- story-*.md - Story 文档
- project-context.md - 项目上下文

**智能指导**：
- `/bmad-help` - 自动检测项目状态，推荐下一步

---

### 2. everything-claude-code

**GitHub**: https://github.com/affaan-m/everything-claude-code
**版本**: v1.8.0
**来源**: Anthropic Hackathon Winner

#### 核心能力

**16 个专业 Agent**：
- planner, architect, tdd-guide, code-reviewer
- security-reviewer, build-error-resolver, e2e-runner
- refactor-cleaner, doc-updater, go-reviewer
- python-reviewer, database-reviewer 等

**50+ 技能库**：
- 编程语言：golang, cpp, python, django, springboot, swift
- 前后端：frontend-patterns, backend-patterns, api-design
- 测试：tdd-workflow, e2e-testing, eval-harness
- DevOps：deployment-patterns, docker-patterns, database-migrations
- AI 内容：continuous-learning-v2, article-writing, market-research

**33 个命令**：
- build-fix, code-review, e2e, eval, learn
- harness-audit, loop-start, model-route 等

**生态工具**：
- **Skill Creator** - 从代码库生成技能
- **AgentShield** - 安全审计器
- **Plankton** - 代码质量强制执行
- **Continuous Learning v2** - 基于 instinct 的持续学习

**跨平台支持**：
- Claude Code, Codex, OpenCode, Cursor, Cowork

---

### 3. oh-my-claudecode

**GitHub**: https://github.com/Yeachan-Heo/oh-my-claudecode
**版本**: v4.4.0+

#### 核心能力

**32 个分层 Agent**：
- 按模型能力分层（Haiku/Sonnet/Opus）
- 自动选择最合适的模型

**编排模式**：
- **Team 模式**（推荐）：`team-plan → team-prd → team-exec → team-verify → team-fix`
- **Autopilot**：自主执行
- **Ultrawork**：最大并行度
- **Ralph**：持久模式
- **Pipeline**：顺序执行

**CLI Workers**（v4.4.0+）：
- tmux 中运行 Codex/Gemini/Claude CLI 工作进程
- 按需启动，任务完成后自动退出

**智能模型路由**：
- Haiku：轻量任务，成本低
- Sonnet：标准任务，平衡性能和成本
- Opus：复杂任务，最强推理能力
- **成本降低 30-50%**

**魔法关键词**：
- team, autopilot, ralph, ulw, ralplan
- deep-interview, deepsearch, ultrathink
- cancelomc, stopomc

**零配置体验**：
- 开箱即用，自然语言交互

---

### 4. sig-claude-code-guidelines

**本项目**

#### 核心能力

**14 个核心规范文档**：
- 系统总则、行动准则、TDD 工作流
- 多 Agent 协作、E2E 测试、质量门禁
- 可追溯性、插件管理、长期记忆管理
- 协作效率、确定性开发 等

**三层长期记忆系统**：
- **Hourly 层**：实时记录（每小时同步）
- **Daily 层**：每日归档（23:00 归档）
- **Weekly 层**：周度总结（周日总结）

**TDD 工作流**：
- RED（写失败测试）→ GREEN（实现功能）→ REFACTOR（重构优化）
- 测试覆盖率 ≥ 80%

**质量门禁**：
- 代码质量检查（Phase 3）
- API 完整性检查（Phase 5）
- 安全性检查（Phase 7）
- 确定性验证（Phase 8）

**确定性开发**：
- 6 类不确定性来源识别
- 5 大确定性编码原则
- 3 个自动化验证脚本

**互联网访问**：
- Agent-Reach 集成
- GitHub CLI、yt-dlp、RSS 等

---

## 📊 四项目对比分析

### 对比矩阵

| 维度 | BMAD Method | everything-cc | oh-my-cc | sig-guidelines |
|------|-------------|--------------|----------|---------------|
| **定位** | AI 驱动敏捷开发框架 | 技能和命令库 | Agent 编排平台 | 开发规范和流程 |
| **Agent 数量** | 9 个专业化 | 16 个 | 32 个 | 10+ 个 |
| **核心能力** | Story 驱动开发 | 50+ 技能 | Team 编排 | TDD + 记忆系统 |
| **工作流** | 34+ 结构化工作流 | 命令式技能 | 自定义工作流 | 8 阶段开发流程 |
| **规划能力** | ⭐⭐⭐⭐⭐ 强 | ⭐⭐ 弱 | ⭐⭐⭐ 中 | ⭐⭐⭐⭐ 强 |
| **文档产出** | PRD/Architecture/Story | 无 | 自定义 | MEMORY.md/task.json |
| **记忆系统** | project-context.md | 无 | 无 | ⭐⭐⭐⭐⭐ 三层架构 |
| **质量门禁** | Implementation Readiness | 无 | 无 | ⭐⭐⭐⭐⭐ 三道门禁 |
| **模型路由** | 无 | 无 | ⭐⭐⭐⭐⭐ 智能路由 | 无 |
| **成本优化** | 无 | 无 | ⭐⭐⭐⭐⭐ 30-50% | 无 |
| **Hook 系统** | 无 | ✅ 基础 | ⭐⭐⭐⭐⭐ 31 个 | 无 |
| **互联网访问** | 无 | 无 | 无 | ⭐⭐⭐⭐⭐ Agent-Reach |
| **安装方式** | npx bmad-method install | 插件 | 插件 | Git submodule |
| **社区活跃度** | ⭐⭐⭐⭐⭐ 39K stars | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ 新项目 |

### 能力互补分析

| 项目 | 擅长领域 | 不足之处 |
|------|---------|---------|
| **BMAD Method** | 需求分析、架构设计、Story 分解 | 缺少记忆系统、质量门禁较弱 |
| **everything-cc** | 丰富的技能库、快速命令 | 缺少结构化规划、无记忆系统 |
| **oh-my-cc** | Agent 编排、Team 协作、成本优化 | 文档较少、学习曲线陡 |
| **sig-guidelines** | TDD 流程、长期记忆、质量门禁 | 需求分析能力弱、Agent 较少 |

### 功能重叠与互补

**重叠功能**（需要协调）：
- Agent 定义：code-reviewer, planner, architect, developer
- 代码审查：四个项目都有
- TDD 指导：BMAD Method + sig-guidelines 都有
- 构建修复：everything-cc 和 oh-my-cc 都有

**互补功能**（可直接集成）：
- **需求分析**：BMAD Method → 全部（最强）
- **长期记忆**：sig-guidelines → 全部（唯一）
- **模型路由**：oh-my-cc → 全部（唯一）
- **技能库**：everything-cc → 全部（最丰富）
- **编排模式**：oh-my-cc → 全部（最强）
- **质量门禁**：sig-guidelines → 全部（最完整）
- **Hook 系统**：oh-my-cc → 全部（最完整）
- **互联网访问**：sig-guidelines → 全部（唯一）

---

## 🏗️ 集成架构设计

### 五层架构模型

```
L0: 规划层 (Planning) - BMAD Method 主导
├─ 需求分析：bmad-brainstorming, bmad-domain-research
├─ 产品规划：bmad-create-prd
├─ 架构设计：bmad-create-architecture
└─ Story 分解：bmad-create-epics-and-stories

L1: 基础设施层 (Infrastructure)
├─ sig-guidelines: 规则、规范、模板
├─ everything-cc: 规则库、配置
└─ oh-my-cc: 状态管理、Hook 系统

L2: 能力层 (Capabilities)
├─ everything-cc: 50+ 技能、33 命令
├─ sig-guidelines: 脚本工具、记忆系统
└─ oh-my-cc: 技能组合系统

L3: Agent 层 (Agents)
├─ BMAD Method: 9 个专业化 Agent
├─ everything-cc: 16 专业 Agent
├─ oh-my-cc: 32 分层 Agent (Haiku/Sonnet/Opus)
└─ sig-guidelines: 记忆管理 Agent

L4: 编排层 (Orchestration)
├─ oh-my-cc: Team/Autopilot/Ultrawork 模式
├─ sig-guidelines: TDD 工作流、质量门禁
├─ BMAD Method: Sprint 管理、Story 驱动
└─ everything-cc: 并行 Agent 执行
```

### 集成架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                    四项目集成架构 v1.0                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Phase 1: 需求分析与规划（BMAD Method 主导）                     │
│  ├─ bmad-help（智能指导）                                        │
│  ├─ bmad-create-prd（PRD 创建）                                 │
│  ├─ bmad-create-architecture（架构设计）                        │
│  ├─ bmad-create-epics-and-stories（Story 分解）                 │
│  └─ 产出：PRD.md, architecture.md, epic-*.md                   │
│                          ↓                                      │
│  Phase 2: 开发执行（sig-guidelines 主导）                        │
│  ├─ TDD 开发流程（测试先行）                                     │
│  ├─ 代码质量检查（质量门禁）                                     │
│  ├─ API 完整性检查                                              │
│  ├─ E2E 测试                                                    │
│  ├─ 安全性检查                                                  │
│  └─ 产出：高质量代码 + 测试覆盖                                  │
│                          ↓                                      │
│  Phase 3: 技能增强（everything-cc 辅助）                        │
│  ├─ 50+ 快速技能命令                                            │
│  ├─ 代码生成、重构、优化                                        │
│  ├─ 文档生成                                                    │
│  └─ 产出：效率提升工具集                                        │
│                          ↓                                      │
│  Phase 4: 团队协作（oh-my-cc 辅助）                             │
│  ├─ 32 个 Agent 编排                                            │
│  ├─ Team 协作模式                                               │
│  ├─ 多 Agent 并行执行                                           │
│  └─ 产出：团队协作能力                                          │
│                                                                 │
│  贯穿全流程：长期记忆系统（sig-guidelines）                      │
│  ├─ Hourly 层：实时记录（每小时同步）                           │
│  ├─ Daily 层：每日归档（23:00 归档）                            │
│  ├─ Weekly 层：周度总结（周日总结）                             │
│  └─ 产出：MEMORY.md + memory/*.md                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔧 集成策略

### 核心原则

1. **以 BMAD Method 为规划层** - 提供需求分析、架构设计、Story 分解
2. **以 sig-guidelines 为执行层** - 提供 TDD 流程、质量门禁、记忆系统
3. **以 everything-cc 为能力层** - 提供命令、技能、Agent
4. **以 oh-my-cc 为编排引擎** - 提供高效的多 Agent 协作和成本优化

### Agent 协作矩阵

| 阶段 | BMAD Method | sig-guidelines | everything-cc | oh-my-cc |
|------|-------------|---------------|--------------|----------|
| **需求分析** | Analyst (Mary) | - | - | - |
| **产品规划** | PM (John) | Planner | - | - |
| **架构设计** | Architect (Winston) | Architect | - | Team Review |
| **Story 分解** | Scrum Master (Bob) | - | - | - |
| **TDD 开发** | Developer (Amelia) | TDD-Guide | Code Generator | Parallel Dev |
| **代码审查** | Developer (Amelia) | Code-Reviewer | - | Team Review |
| **测试** | QA (Quinn) | E2E-Runner | Test Generator | - |
| **文档** | Tech Writer (Paige) | Doc-Updater | Doc Generator | - |
| **记忆管理** | - | Memory-Keeper | - | - |

### 工作流集成

#### 小型任务（Quick Flow）

```bash
# 1. 快速规划（BMAD Method）
/bmad-quick-spec

# 2. TDD 开发（sig-guidelines）
/tdd

# 3. 质量检查（sig-guidelines）
/code-review
/security-review

# 4. 记忆归档（sig-guidelines）
./scripts/sync-hourly.sh
```

#### 中型项目（BMad Method）

```bash
# Phase 1: 规划（BMAD Method）
/bmad-help
/bmad-create-prd
/bmad-create-architecture
/bmad-create-epics-and-stories

# Phase 2: 开发（sig-guidelines）
/tdd  # 每个 Story
./scripts/check-api-completeness.sh
/e2e
/security-review

# Phase 3: 记忆（sig-guidelines）
./scripts/archive-daily.sh
```

#### 大型项目（Enterprise）

```bash
# Phase 1: 规划（BMAD Method + oh-my-cc）
/bmad-create-prd
/bmad-create-architecture
/team-review  # oh-my-cc 多 Agent 评审

# Phase 2: 开发（sig-guidelines + everything-cc）
/tdd
/skill-generate-tests  # everything-cc
/code-review

# Phase 3: 协作（oh-my-cc）
/team-parallel-dev  # 多 Agent 并行开发

# Phase 4: 记忆（sig-guidelines）
./scripts/summarize-weekly.sh
```

---

## ⚠️ 潜在冲突与解决方案

### 1. 命令命名冲突

**冲突**：
- `/plan` - sig-guidelines 和 everything-cc 都有
- `/tdd` - sig-guidelines 和 everything-cc 都有
- `/code-review` - 四个项目都有
- `bmad-dev` vs `/tdd` vs `/skill-dev` - 开发命令重叠

**解决方案**：分层命名 + 功能合并

```bash
# 规划层（BMAD Method）
/bmad-help          # 智能指导
/bmad-create-prd    # 创建 PRD
/bmad-create-architecture  # 架构设计
/bmad-dev-story     # 实现 Story

# 执行层（sig-guidelines）
/plan               # 任务规划（sig-guidelines 流程）
/tdd                # TDD 开发（sig-guidelines 流程）
/code-review        # 代码审查（sig-guidelines 质量门禁）

# 技能层（everything-cc）
/skill-dev-*        # 开发技能
/skill-test-*       # 测试技能
/skill-doc-*        # 文档技能

# 编排层（oh-my-cc）
/team-dev           # 团队开发
/autopilot          # 自动驾驶模式
```

### 2. Agent 职责重叠

**解决方案**：统一 code-reviewer

```
统一 code-reviewer:
├─ 基础定义：everything-cc 的 code-reviewer.md
├─ 增强功能：oh-my-cc 的分层审查（Haiku/Sonnet/Opus）
├─ 记忆能力：sig-guidelines 的历史审查记录
├─ 质量标准：sig-guidelines 的质量门禁
└─ Story 审查：BMAD Method 的 Story 级别审查
```

### 3. 配置文件冲突

**解决方案**：统一配置结构

```
project/
├── CLAUDE.md                    # 项目配置（合并四个项目）
├── AGENTS.md                    # Agent 行为规范（合并）
├── MEMORY.md                    # 长期记忆（sig-guidelines）
├── project-context.md           # 项目上下文（BMAD Method）
├── _bmad-output/                # BMAD Method 产出
│   ├── PRD.md
│   ├── architecture.md
│   └── epic-*.md
├── .unified/                    # 统一配置目录
│   ├── state/                   # 状态文件（oh-my-cc 格式）
│   ├── checkpoints/             # 检查点（sig-guidelines）
│   ├── memory/                  # 记忆文件（sig-guidelines）
│   └── config/                  # 配置文件
└── ~/.claude/                   # 全局配置
    ├── rules/                   # 规则（合并）
    ├── agents/                  # Agent 定义（合并）
    ├── commands/                # 命令（合并）
    └── skills/                  # 技能（everything-cc）
```

### 4. 文档产出冲突

**解决方案**：明确文档分工

| 文档类型 | 负责项目 | 用途 | 示例 |
|---------|---------|------|------|
| **规划文档** | BMAD Method | 需求、架构、Story | PRD.md, architecture.md, epic-*.md |
| **记忆文档** | sig-guidelines | 决策、教训、状态 | MEMORY.md, memory/*.md |
| **任务文档** | sig-guidelines | 任务列表、进度 | task.json |
| **上下文文档** | BMAD Method | 技术栈、规则 | project-context.md |

### 5. 记忆系统冲突

**解决方案**：明确分工

- **project-context.md** (BMAD Method)：
  - 存储技术栈、实现规则（静态）
  - 项目初始化时创建，很少修改
  - 示例：使用 React + TypeScript，遵循 Airbnb 规范

- **MEMORY.md** (sig-guidelines)：
  - 存储关键决策、经验教训（动态）
  - 持续更新，记录项目演进
  - 示例：为什么选择 Zustand 而不是 Redux

---

## 📊 集成效果预期

| 指标 | 集成前 | 集成后 | 提升 |
|------|--------|--------|------|
| **需求分析时间** | 2 小时 | 30 分钟 | 75% ↓ |
| **架构设计质量** | 70% | 90% | 20% ↑ |
| **开发效率** | 基准 | 2x | 100% ↑ |
| **代码质量** | 80% | 95% | 15% ↑ |
| **测试覆盖率** | 60% | 85% | 25% ↑ |
| **Bug 率** | 基准 | 0.3x | 70% ↓ |
| **成本** | 基准 | 0.5-0.7x | 30-50% ↓ |
| **团队协作效率** | 基准 | 2x | 100% ↑ |

---

## 🎯 实施建议

### 阶段 1：基础集成（1-2 周）

**目标**：让 BMAD Method 和 sig-guidelines 协同工作

**步骤**：
1. 安装 BMAD Method：`npx bmad-method install`
2. 配置 sig-guidelines 规则
3. 测试基本工作流：`/bmad-create-prd` → `/tdd` → `/code-review`
4. 验证文档产出和记忆系统

**验收标准**：
- ✅ BMAD Method 能生成 PRD 和 Architecture
- ✅ sig-guidelines 能执行 TDD 流程
- ✅ 记忆系统能正常记录

### 阶段 2：技能增强（2-3 周）

**目标**：集成 everything-cc 和 oh-my-cc

**步骤**：
1. 安装 everything-cc 插件
2. 安装 oh-my-cc 插件
3. 测试技能命令和 Agent 编排
4. 建立 Agent 协作矩阵

**验收标准**：
- ✅ 50+ 技能命令可用
- ✅ 32 个 Agent 可编排
- ✅ 多 Agent 并行执行正常

### 阶段 3：流程优化（3-4 周）

**目标**：优化集成工作流，提升效率

**步骤**：
1. 根据实际使用调整工作流
2. 解决冲突和重叠问题
3. 建立最佳实践文档
4. 培训团队成员

**验收标准**：
- ✅ 工作流顺畅无阻塞
- ✅ 团队成员熟练使用
- ✅ 效率提升 50%+

---

## 🔗 相关资源

- **BMAD Method 官方文档**: https://docs.bmad-method.org/
- **BMAD Method GitHub**: https://github.com/bmad-code-org/BMAD-METHOD
- **everything-claude-code GitHub**: https://github.com/affaan-m/everything-claude-code
- **oh-my-claudecode GitHub**: https://github.com/Yeachan-Heo/oh-my-claudecode
- **sig-claude-code-guidelines**: 本项目
- **Discord 社区**: https://discord.gg/gk8jAdXWmj

---

*文档版本：1.0.0*
*最后更新：2026-03-08*
*分析者：Claude (Opus 4.6)*

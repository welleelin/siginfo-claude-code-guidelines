# 四项目集成规则配置

> **版本**：1.0.0
> **创建日期**：2026-03-08
> **最后更新**：2026-03-08

---

## 📋 概述

本文档定义四个项目的规则整合方案，确保规则系统无冲突、高效协作。

---

## 🏗️ 规则层次结构

```
L0: 核心规则层（sig-guidelines）
├─ 00-SYSTEM_OVERVIEW.md - 系统总则
├─ 01-ACTION_GUIDELINES.md - 行动准则
├─ 02-TDD_WORKFLOW.md - TDD 工作流
├─ 05-QUALITY_GATE.md - 质量门禁
└─ 14-DETERMINISTIC_DEVELOPMENT.md - 确定性开发

L1: 规划层规则（BMAD Method）
├─ BMAD Method 工作流（25 个）
├─ BMAD Method Agent（10 个）
└─ project-context.md - 项目上下文

L2: 能力层规则（everything-cc）
├─ 技能库规则（50+ 技能）
├─ 命令规则（33 个命令）
└─ Agent 规则（16 个 Agent）

L3: 编排层规则（oh-my-cc）
├─ Team 编排规则
├─ 模型路由规则
└─ Hook 系统规则
```

---

## 🎯 规则优先级

### 优先级定义

| 优先级 | 层级 | 项目 | 说明 |
|--------|------|------|------|
| **P0 - 最高** | 核心规则 | sig-guidelines | 系统总则、质量门禁、确定性开发 |
| **P1 - 高** | 规划规则 | BMAD Method | 需求分析、架构设计、Story 驱动 |
| **P2 - 中** | 能力规则 | everything-cc | 技能库、命令、快速开发 |
| **P3 - 低** | 编排规则 | oh-my-cc | Team 编排、模型路由 |

### 冲突解决原则

当规则冲突时，按优先级执行：
1. **P0 规则优先**：质量门禁、TDD 工作流、确定性开发不可妥协
2. **P1 规则补充**：BMAD Method 的规划流程补充 sig-guidelines
3. **P2 规则增强**：everything-cc 的技能库增强开发效率
4. **P3 规则优化**：oh-my-cc 的编排优化成本和性能

---

## 📐 规则整合方案

### 1. 核心规则层（sig-guidelines）

**保留规则**：
- ✅ 00-SYSTEM_OVERVIEW.md - 系统总则
- ✅ 01-ACTION_GUIDELINES.md - 行动准则
- ✅ 02-TDD_WORKFLOW.md - TDD 工作流
- ✅ 03-MULTI_AGENT.md - 多 Agent 协作
- ✅ 04-E2E_TESTING_FLOW.md - E2E 测试流程
- ✅ 05-QUALITY_GATE.md - 质量门禁
- ✅ 06-TRACEABILITY.md - 可追溯性
- ✅ 07-PLUGIN_MANAGEMENT.md - 插件管理
- ✅ 08-LONG_RUNNING_AGENTS.md - 长期运行 Agent
- ✅ 09-AUTOMATION_MODES.md - 自动化模式
- ✅ 10-ANTHROPIC_LONG_RUNNING_AGENTS.md - Anthropic 官方指南
- ✅ 11-LONG_TERM_MEMORY.md - 长期记忆管理
- ✅ 12-AGENT_REACH_INTEGRATION.md - 互联网访问
- ✅ 13-COLLABORATION_EFFICIENCY.md - 协作效率
- ✅ 14-DETERMINISTIC_DEVELOPMENT.md - 确定性开发

**增强规则**：
- 在 01-ACTION_GUIDELINES.md 中添加 BMAD Method 工作流集成
- 在 03-MULTI_AGENT.md 中添加 BMAD Method Agent 协作矩阵
- 在 07-PLUGIN_MANAGEMENT.md 中添加 everything-cc 和 oh-my-cc 插件管理

### 2. 规划层规则（BMAD Method）

**集成方式**：作为 sig-guidelines 的补充

**工作流映射**：

| BMAD Method 工作流 | sig-guidelines 阶段 | 说明 |
|-------------------|-------------------|------|
| brainstorming | Phase 2 - 任务规划 | 头脑风暴 |
| create-product-brief | Phase 2 - 任务规划 | 产品简介 |
| domain-research | Phase 2 - 任务规划 | 领域调研 |
| market-research | Phase 2 - 任务规划 | 市场调研 |
| technical-research | Phase 2 - 任务规划 | 技术调研 |
| create-prd | Phase 2 - 任务规划 | 创建 PRD |
| create-ux-design | Phase 2 - 任务规划 | UX 设计 |
| create-architecture | Phase 2 - 任务规划 | 架构设计 |
| create-epics-and-stories | Phase 2 - 任务规划 | Epic/Story 分解 |
| check-implementation-readiness | Phase 3 - 代码质量检查 | 实现就绪检查 |
| sprint-planning | Phase 4 - TDD 开发 | Sprint 规划 |
| create-story | Phase 4 - TDD 开发 | 创建 Story |
| dev-story | Phase 4 - TDD 开发 | 实现 Story |
| code-review | Phase 3 - 代码质量检查 | 代码审查 |
| qa-generate-e2e-tests | Phase 6 - E2E 测试 | 生成 E2E 测试 |
| sprint-status | Phase 8 - 质量门禁 | Sprint 状态 |
| retrospective | Phase 8 - 质量门禁 | 回顾总结 |
| quick-spec | Phase 2 - 任务规划 | 快速规格 |
| quick-dev | Phase 4 - TDD 开发 | 快速开发 |

**Agent 映射**：

| BMAD Method Agent | sig-guidelines Agent | 职责 |
|------------------|---------------------|------|
| bmm-analyst | - | 需求分析（新增） |
| bmm-pm | Planner | 产品管理 |
| bmm-architect | Architect | 架构设计 |
| bmm-sm | - | Scrum Master（新增） |
| bmm-dev | TDD-Guide | 开发实现 |
| bmm-qa | E2E-Runner | 质量保证 |
| bmm-ux-designer | - | UX 设计（新增） |
| bmm-tech-writer | Doc-Updater | 技术文档 |
| bmm-quick-flow-solo-dev | - | 快速开发（新增） |
| core-bmad-master | - | BMAD 主控（新增） |

### 3. 能力层规则（everything-cc）

**集成方式**：作为快速命令和技能库

**命令映射**：

| everything-cc 命令 | sig-guidelines 命令 | 说明 |
|-------------------|-------------------|------|
| /plan | /plan | 功能合并 |
| /tdd | /tdd | 功能合并 |
| /code-review | /code-review | 功能合并 |
| /build-fix | - | 新增命令 |
| /refactor-clean | - | 新增命令 |
| /e2e | /e2e | 功能合并 |
| /skill-* | - | 新增技能命令 |

**技能库分类**：

| 分类 | 技能数量 | 用途 |
|------|---------|------|
| 编程语言 | 10+ | golang, cpp, python, django, springboot, swift |
| 前后端 | 5+ | frontend-patterns, backend-patterns, api-design |
| 测试 | 5+ | tdd-workflow, e2e-testing, eval-harness |
| DevOps | 5+ | deployment-patterns, docker-patterns, database-migrations |
| AI 内容 | 5+ | continuous-learning-v2, article-writing, market-research |

### 4. 编排层规则（oh-my-cc）

**集成方式**：作为多 Agent 编排引擎

**编排模式**：

| oh-my-cc 模式 | 使用场景 | 说明 |
|--------------|---------|------|
| Team 模式 | 大型项目 | team-plan → team-prd → team-exec → team-verify → team-fix |
| Autopilot 模式 | 自动化任务 | 自主执行 |
| Ultrawork 模式 | 并行开发 | 最大并行度 |
| Ralph 模式 | 长期任务 | 持久模式 |

**模型路由规则**：

| 任务复杂度 | 推荐模型 | 成本 | 说明 |
|-----------|---------|------|------|
| 轻量任务 | Haiku | 低 | 代码格式化、简单重构 |
| 标准任务 | Sonnet | 中 | TDD 开发、代码审查 |
| 复杂任务 | Opus | 高 | 架构设计、需求分析 |

---

## 🔧 配置文件整合

### 统一配置结构

```
project/
├── CLAUDE.md                    # 项目配置（合并四个项目）
├── AGENTS.md                    # Agent 行为规范（合并）
├── MEMORY.md                    # 长期记忆（sig-guidelines）
├── project-context.md           # 项目上下文（BMAD Method）
├── _bmad/                       # BMAD Method 核心
│   ├── _config/                 # BMAD 配置
│   │   ├── agents/              # Agent 定义
│   │   ├── workflow-manifest.csv # 工作流清单
│   │   └── ides/claude-code.yaml # IDE 配置
│   ├── bmm/                     # BMM 模块
│   └── core/                    # 核心模块
├── _bmad-output/                # BMAD Method 产出
│   ├── planning-artifacts/      # 规划产物
│   └── implementation-artifacts/ # 实现产物
├── .unified/                    # 统一配置目录
│   ├── config/                  # 配置文件
│   │   └── integration-rules.md # 本文件
│   ├── state/                   # 状态文件
│   ├── routing/                 # 模型路由配置
│   ├── hooks/                   # Hook 系统
│   └── memory/                  # 记忆文件
└── ~/.claude/                   # 全局配置
    ├── rules/                   # 规则（sig-guidelines）
    ├── agents/                  # Agent 定义（合并）
    ├── commands/                # 命令（合并）
    └── skills/                  # 技能（everything-cc）
```

### CLAUDE.md 整合

```markdown
# sig-claude-code-guidelines

## 核心规则（sig-guidelines）
- 系统总则：guidelines/00-SYSTEM_OVERVIEW.md
- 行动准则：guidelines/01-ACTION_GUIDELINES.md
- TDD 工作流：guidelines/02-TDD_WORKFLOW.md
- 质量门禁：guidelines/05-QUALITY_GATE.md

## 规划层（BMAD Method）
- BMAD 配置：_bmad/_config/
- 工作流：25 个（见 workflow-manifest.csv）
- Agent：10 个（见 agent-manifest.csv）
- 产出目录：_bmad-output/

## 能力层（everything-cc）
- 技能库：~/.claude/skills/
- 命令：~/.claude/commands/
- Agent：~/.claude/agents/

## 编排层（oh-my-cc）
- 模型路由：.unified/routing/
- Hook 系统：.unified/hooks/
- Team 编排：启用
```

---

## 📊 验证清单

### 规则整合验证

- [ ] sig-guidelines 的 14 个核心文档无冲突
- [ ] BMAD Method 的 25 个工作流正常工作
- [ ] BMAD Method 的 10 个 Agent 可调用
- [ ] everything-cc 的命令无命名冲突
- [ ] oh-my-cc 的编排模式可用

### 配置文件验证

- [ ] CLAUDE.md 合并完成
- [ ] AGENTS.md 合并完成
- [ ] project-context.md 创建完成
- [ ] .unified/ 目录结构正确

### 功能验证

- [ ] `/bmad-help` 命令可用
- [ ] `/bmad-create-prd` 工作流可用
- [ ] `/tdd` 命令可用（sig-guidelines）
- [ ] `/code-review` 命令可用（合并功能）

---

## 📝 更新日志

| 日期 | 版本 | 更新内容 | 更新人 |
|------|------|---------|--------|
| 2026-03-08 | 1.0.0 | 初始版本，定义四项目规则整合方案 | Claude |

---

> **注意**：
> - 规则冲突时，按优先级 P0 > P1 > P2 > P3 执行
> - 核心规则（sig-guidelines）不可妥协
> - 规划层规则（BMAD Method）补充核心规则
> - 能力层和编排层规则增强效率和性能

# 命令系统合并方案

> **版本**：1.0.0
> **创建日期**：2026-03-08
> **用途**：定义四项目命令系统的合并策略

---

## 📋 概述

本文档定义如何合并四个项目的命令系统，解决命名冲突，建立统一的命令体系。

---

## 🎯 命令来源

### sig-guidelines 命令（7 个）

| 命令 | 用途 | 实现方式 |
|------|------|---------|
| `/checkpoint` | 状态检查点管理 | scripts/checkpoint.sh |
| `/save-state` | 保存状态 | scripts/save-state.sh |
| `/restore-state` | 恢复状态 | scripts/restore-state.sh |
| `/sync-hourly` | Hourly 层同步 | scripts/sync-hourly.sh |
| `/archive-daily` | Daily 层归档 | scripts/archive-daily.sh |
| `/summarize-weekly` | Weekly 层总结 | scripts/summarize-weekly.sh |
| `/memory-search` | 记忆搜索 | 待实现 |

### BMAD Method 命令（25+ 个）

**智能指导**：
- `/bmad-help` - 智能指导

**快速流程**：
- `/bmad-bmm-quick-spec` - 生成快速规格
- `/bmad-bmm-quick-dev` - 快速开发

**Analysis 阶段**：
- `/bmad-bmm-brainstorming` - 头脑风暴
- `/bmad-bmm-domain-research` - 领域调研
- `/bmad-bmm-market-research` - 市场调研
- `/bmad-bmm-technical-research` - 技术调研
- `/bmad-bmm-create-product-brief` - 创建产品简介

**Planning 阶段**：
- `/bmad-bmm-create-prd` - 创建 PRD
- `/bmad-bmm-create-ux-design` - UX 设计

**Solutioning 阶段**：
- `/bmad-bmm-create-architecture` - 架构设计
- `/bmad-bmm-create-epics-and-stories` - Epic/Story 分解
- `/bmad-bmm-check-implementation-readiness` - 实现就绪检查

**Implementation 阶段**：
- `/bmad-bmm-sprint-planning` - Sprint 规划
- `/bmad-bmm-create-story` - 创建 Story
- `/bmad-bmm-dev-story` - 实现 Story
- `/bmad-bmm-code-review` - 代码审查
- `/bmad-bmm-correct-course` - 纠正路线
- `/bmad-bmm-sprint-status` - Sprint 状态
- `/bmad-bmm-retrospective` - 回顾总结

**Agent 调用**：
- `/bmad-agent-bmm-analyst` - 调用 Analyst Agent
- `/bmad-agent-bmm-pm` - 调用 PM Agent
- `/bmad-agent-bmm-architect` - 调用 Architect Agent
- `/bmad-agent-bmm-sm` - 调用 Scrum Master Agent
- `/bmad-agent-bmm-dev` - 调用 Developer Agent
- `/bmad-agent-bmm-qa` - 调用 QA Agent

### everything-claude-code 命令（33 个）

**规划与开发**：
- `/plan` - 任务规划
- `/tdd` - TDD 开发
- `/code-review` - 代码审查
- `/build-fix` - 构建修复
- `/refactor-clean` - 重构清理
- `/verify` - 验证
- `/e2e` - E2E 测试

**技能管理**：
- `/skill-create` - 创建技能
- `/skill-list` - 列出技能
- `/skill-search` - 搜索技能
- `/skill-update` - 更新技能

**Agent 管理**：
- `/agent-list` - 列出 Agent
- `/agent-run` - 运行 Agent
- `/agent-status` - Agent 状态

**其他命令**：
- `/learn` - 学习模式
- `/eval` - 评估
- `/harness-audit` - Harness 审计
- `/loop-start` - 循环开始
- `/model-route` - 模型路由

### oh-my-claudecode 魔法关键词（10+ 个）

| 关键词 | 映射命令 | 说明 |
|--------|---------|------|
| `team` | `/team-mode` | Team 协作模式 |
| `autopilot` | `/autopilot-mode` | 自动驾驶模式 |
| `ralph` | `/ralph-mode` | 持久模式 |
| `ulw` | `/ultrawork-mode` | 最大并行模式 |
| `ralplan` | `/ralplan-mode` | Ralph + Plan 模式 |
| `deep-interview` | `/deep-interview` | 深度访谈 |
| `deepsearch` | `/deepsearch` | 深度搜索 |
| `ultrathink` | `/ultrathink` | 深度思考 |

---

## 🔀 命令冲突解决

### 冲突 1: `/plan` 命令

**冲突来源**：
- sig-guidelines: 无 `/plan` 命令
- BMAD Method: 无 `/plan` 命令
- everything-cc: `/plan` - 任务规划
- oh-my-cc: 无 `/plan` 命令

**解决方案**：保留 everything-cc 的 `/plan` 命令

**功能增强**：
```bash
/plan "任务描述"
# 自动检测任务复杂度
# - 小任务（< 2h）：Quick Flow
# - 中型任务（2-8h）：Standard + 可选 BMAD Method
# - 大型任务（> 8h）：推荐 BMAD Method 完整流程
```

### 冲突 2: `/tdd` 命令

**冲突来源**：
- sig-guidelines: 无 `/tdd` 命令
- BMAD Method: `/bmad-bmm-dev-story` - Story 驱动开发
- everything-cc: `/tdd` - TDD 开发
- oh-my-cc: 无 `/tdd` 命令

**解决方案**：保留 everything-cc 的 `/tdd` 命令，增强功能

**功能增强**：
```bash
/tdd
# 自动检测开发模式
# - 有 Story 文件：使用 /bmad-bmm-dev-story
# - 无 Story 文件：使用标准 TDD 流程（RED → GREEN → REFACTOR）
```

### 冲突 3: `/code-review` 命令

**冲突来源**：
- sig-guidelines: 无 `/code-review` 命令
- BMAD Method: `/bmad-bmm-code-review` - BMAD 代码审查
- everything-cc: `/code-review` - 代码审查
- oh-my-cc: 无 `/code-review` 命令

**解决方案**：功能合并

**合并后功能**：
```bash
/code-review
# 执行顺序：
# 1. everything-cc 的基础代码审查
# 2. BMAD Method 的 Story 级别审查（如有 Story）
# 3. sig-guidelines 的质量门禁检查
```

---

## 📐 统一命令体系

### 命令分类

#### 1. 规划类命令

| 命令 | 来源 | 用途 |
|------|------|------|
| `/plan` | everything-cc | 任务规划（增强版） |
| `/bmad-help` | BMAD Method | 智能指导 |
| `/bmad-bmm-quick-spec` | BMAD Method | 快速规格 |
| `/bmad-bmm-create-prd` | BMAD Method | 创建 PRD |
| `/bmad-bmm-create-architecture` | BMAD Method | 架构设计 |
| `/bmad-bmm-create-epics-and-stories` | BMAD Method | Epic/Story 分解 |

#### 2. 开发类命令

| 命令 | 来源 | 用途 |
|------|------|------|
| `/tdd` | everything-cc | TDD 开发（增强版） |
| `/bmad-bmm-quick-dev` | BMAD Method | 快速开发 |
| `/bmad-bmm-dev-story` | BMAD Method | Story 实现 |
| `/build-fix` | everything-cc | 构建修复 |
| `/refactor-clean` | everything-cc | 重构清理 |

#### 3. 测试类命令

| 命令 | 来源 | 用途 |
|------|------|------|
| `/verify` | everything-cc | 验证 |
| `/e2e` | everything-cc | E2E 测试 |
| `/bmad-agent-bmm-qa` | BMAD Method | QA Agent |

#### 4. 审查类命令

| 命令 | 来源 | 用途 |
|------|------|------|
| `/code-review` | everything-cc | 代码审查（合并版） |
| `/bmad-bmm-code-review` | BMAD Method | BMAD 代码审查 |
| `/security-review` | sig-guidelines | 安全审查 |

#### 5. 记忆类命令

| 命令 | 来源 | 用途 |
|------|------|------|
| `/checkpoint` | sig-guidelines | 检查点管理 |
| `/save-state` | sig-guidelines | 保存状态 |
| `/restore-state` | sig-guidelines | 恢复状态 |
| `/sync-hourly` | sig-guidelines | Hourly 同步 |
| `/archive-daily` | sig-guidelines | Daily 归档 |
| `/summarize-weekly` | sig-guidelines | Weekly 总结 |
| `/memory-search` | sig-guidelines | 记忆搜索 |

#### 6. 编排类命令

| 命令 | 来源 | 用途 |
|------|------|------|
| `/team-mode` | oh-my-cc | Team 协作 |
| `/autopilot-mode` | oh-my-cc | 自动驾驶 |
| `/ralph-mode` | oh-my-cc | 持久模式 |
| `/ultrawork-mode` | oh-my-cc | 最大并行 |

#### 7. 技能类命令

| 命令 | 来源 | 用途 |
|------|------|------|
| `/skill-create` | everything-cc | 创建技能 |
| `/skill-list` | everything-cc | 列出技能 |
| `/skill-search` | everything-cc | 搜索技能 |
| `/skill-update` | everything-cc | 更新技能 |

---

## 🔧 命令实现方式

### 方式 1: 命令别名

```bash
# 在 ~/.claude/commands/ 中创建别名
# 例如：team-mode.md
alias: team
description: Team 协作模式
implementation: oh-my-claudecode team
```

### 方式 2: 命令包装器

```bash
# 在 ~/.claude/commands/ 中创建包装器
# 例如：code-review.md
description: 代码审查（合并版）
implementation: |
  1. 执行 everything-cc 的基础代码审查
  2. 如有 Story 文件，执行 BMAD Method 的 Story 审查
  3. 执行 sig-guidelines 的质量门禁检查
```

### 方式 3: 命令路由

```bash
# 在 ~/.claude/commands/ 中创建路由
# 例如：plan.md
description: 任务规划（智能路由）
implementation: |
  检测任务复杂度：
  - 小任务（< 2h）：Quick Flow
  - 中型任务（2-8h）：Standard
  - 大型任务（> 8h）：BMAD Method
```

---

## 📝 命令注册表

创建统一的命令注册表：`.unified/config/command-registry.md`

**格式**：
```markdown
| 命令 | 来源 | 类型 | 优先级 | 冲突解决 |
|------|------|------|--------|---------|
| /plan | everything-cc | 规划 | P2 | 增强版 |
| /tdd | everything-cc | 开发 | P2 | 增强版 |
| /code-review | everything-cc | 审查 | P2 | 合并版 |
| /bmad-help | BMAD Method | 规划 | P1 | 无冲突 |
| /checkpoint | sig-guidelines | 记忆 | P0 | 无冲突 |
| /team-mode | oh-my-cc | 编排 | P3 | 无冲突 |
```

---

## 🔗 相关文档

- [集成规则](./integration-rules.md) - 规则优先级
- [技能库整合方案](./skill-integration.md) - 技能库整合
- [Hook 系统扩展方案](./hook-extension.md) - Hook 系统

---

*版本：1.0.0 | 创建日期：2026-03-08*

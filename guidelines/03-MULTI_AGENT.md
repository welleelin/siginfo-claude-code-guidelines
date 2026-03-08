# 多 Agent 协作

> 版本：1.0.0
> 最后更新：2026-03-07

---

## 📋 概述

多 Agent 协作模式通过专业分工提高开发效率和代码质量。

---

## 🤖 可用 Agent

### sig-guidelines 核心 Agent

| Agent | 职责 | 使用场景 |
|-------|------|---------|
| **planner** | 任务规划 | 复杂功能、重构 |
| **architect** | 系统设计 | 架构决策 |
| **tdd-guide** | 测试驱动开发 | 新功能、Bug 修复 |
| **code-reviewer** | 代码审查 | 完成代码后 |
| **security-reviewer** | 安全审查 | 提交前 |
| **build-error-resolver** | 构建修复 | 构建失败时 |
| **e2e-runner** | E2E 测试 | 关键流程 |
| **refactor-cleaner** | 代码清理 | 代码维护 |
| **doc-updater** | 文档更新 | 文档维护 |

### BMAD Method 专业化 Agent

| Agent | 职责 | 使用场景 | 调用方式 |
|-------|------|---------|---------|
| **bmm-analyst** (Mary) | 需求分析 | 头脑风暴、领域调研、市场调研 | `/bmad-agent-bmm-analyst` |
| **bmm-pm** (John) | 产品管理 | 创建 PRD、产品简介 | `/bmad-agent-bmm-pm` |
| **bmm-architect** (Winston) | 架构设计 | 技术架构、系统设计 | `/bmad-agent-bmm-architect` |
| **bmm-sm** (Bob) | Scrum Master | Epic/Story 分解、Sprint 规划 | `/bmad-agent-bmm-sm` |
| **bmm-dev** (Amelia) | 开发实现 | Story 实现、代码编写 | `/bmad-agent-bmm-dev` |
| **bmm-qa** (Quinn) | 质量保证 | E2E 测试生成、测试执行 | `/bmad-agent-bmm-qa` |
| **bmm-ux-designer** (Olivia) | UX 设计 | 用户体验设计、原型设计 | `/bmad-agent-bmm-ux-designer` |
| **bmm-tech-writer** (Paige) | 技术文档 | 文档编写、API 文档 | `/bmad-agent-bmm-tech-writer` |
| **bmm-quick-flow-solo-dev** | 快速开发 | 小任务快速实现 | `/bmad-agent-bmm-quick-flow-solo-dev` |
| **core-bmad-master** | BMAD 主控 | 智能指导、流程协调 | `/bmad-help` |

---

## 🔄 协作模式

### 模式 1: 串行协作

```
planner → tdd-guide → code-reviewer → e2e-runner
```

**适用场景**：单一功能开发

### 模式 2: 并行协作

```
Agent 1: 后端 API
Agent 2: 前端页面
Agent 3: 数据库设计
```

**适用场景**：独立模块开发

### 模式 3: 团队模式

```
architect → planner → [tdd-guide, code-reviewer] → e2e-runner
```

**适用场景**：复杂功能从 0 到 1

### 模式 4: BMAD Method 完整流程

```
Phase 1: Analysis（分析）
bmm-analyst → bmm-pm (产品简介)

Phase 2: Planning（规划）
bmm-pm (PRD) → bmm-ux-designer (UX 设计)

Phase 3: Solutioning（方案设计）
bmm-architect (架构) → bmm-sm (Epic/Story 分解)

Phase 4: Implementation（实现）
bmm-sm (Sprint 规划) → bmm-dev (Story 实现) → bmm-qa (测试) → bmm-tech-writer (文档)
```

**适用场景**：大型项目、完整产品开发

---

## 🔀 Agent 协作矩阵

### 按开发阶段的 Agent 映射

| 阶段 | BMAD Method Agent | sig-guidelines Agent | 职责 |
|------|------------------|---------------------|------|
| **需求分析** | bmm-analyst (Mary) | - | 头脑风暴、领域调研、市场调研 |
| **产品规划** | bmm-pm (John) | planner | 创建 PRD、产品简介 |
| **架构设计** | bmm-architect (Winston) | architect | 技术架构、系统设计 |
| **Story 分解** | bmm-sm (Bob) | - | Epic/Story 分解、Sprint 规划 |
| **TDD 开发** | bmm-dev (Amelia) | tdd-guide | Story 实现、测试驱动开发 |
| **代码审查** | bmm-dev (Amelia) | code-reviewer | 代码质量检查、最佳实践 |
| **测试** | bmm-qa (Quinn) | e2e-runner | E2E 测试生成和执行 |
| **文档** | bmm-tech-writer (Paige) | doc-updater | 技术文档、API 文档 |
| **快速开发** | bmm-quick-flow-solo-dev | tdd-guide | 小任务快速实现 |

### Agent 选择决策树

```
任务类型？
├─ 小任务（< 2 小时）
│  └─ Quick Flow: /bmad-bmm-quick-spec + /bmad-bmm-quick-dev
│
├─ 中型任务（2-8 小时）
│  ├─ 需求不明确？
│  │  └─ bmm-analyst → bmm-pm → bmm-architect
│  └─ 需求明确？
│     └─ planner → tdd-guide → code-reviewer
│
└─ 大型任务（> 8 小时）
   └─ BMAD Method 完整流程
      └─ Analysis → Planning → Solutioning → Implementation
```

---

## 📝 使用示例

### 示例 1: 新功能开发

```bash
# 1. 规划
/plan "实现用户登录功能"

# 2. TDD 开发
/tdd

# 3. 代码审查
/code-review

# 4. E2E 测试
/e2e
```

### 示例 2: 并行开发

```bash
# 同时启动多个 Agent
Agent 1: 开发后端 API
Agent 2: 开发前端页面
Agent 3: 编写测试用例
```

### 示例 3: BMAD Method 完整流程

```bash
# Phase 1: 分析阶段
/bmad-help                              # 智能指导
/bmad-bmm-brainstorming                 # 头脑风暴
/bmad-bmm-domain-research "领域名称"     # 领域调研
/bmad-bmm-create-product-brief          # 创建产品简介

# Phase 2: 规划阶段
/bmad-bmm-create-prd                    # 创建 PRD
/bmad-bmm-create-ux-design              # UX 设计

# Phase 3: 方案设计阶段
/bmad-bmm-create-architecture           # 架构设计
/bmad-bmm-create-epics-and-stories      # Epic/Story 分解
/bmad-bmm-check-implementation-readiness # 实现就绪检查

# Phase 4: 实现阶段
/bmad-bmm-sprint-planning               # Sprint 规划
/bmad-bmm-create-story "story-id"       # 创建 Story
/bmad-bmm-dev-story "story-file.md"     # 实现 Story
/bmad-bmm-code-review                   # 代码审查
/bmad-bmm-sprint-status                 # Sprint 状态
/bmad-bmm-retrospective "epic-name"     # 回顾总结
```

### 示例 4: Quick Flow 快速开发

```bash
# 适用于小任务（< 2 小时）
/bmad-bmm-quick-spec                    # 生成快速规格
/bmad-bmm-quick-dev "quick-spec.md"     # 快速实现
```

---

## 🔗 相关文档

- [行动准则](01-ACTION_GUIDELINES.md)
- [TDD 开发流程](02-TDD_WORKFLOW.md)

---

*版本：1.0.0 | 最后更新：2026-03-07*

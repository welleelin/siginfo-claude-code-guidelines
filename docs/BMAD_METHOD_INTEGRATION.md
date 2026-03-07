# BMAD Method 集成指南

> 版本：1.0.0
> 最后更新：2026-03-07
> 基于：BMAD Method v6

---

## 📋 概述

BMAD Method (**B**uild **M**ore **A**rchitect **D**reams) 是一个 AI 驱动的开发框架，通过专业化 Agent、引导式工作流和智能规划，帮助从构思到实现的完整软件开发过程。

本文档说明如何将 BMAD Method 集成到 sig-claude-code-guidelines 项目中。

---

## 🎯 核心概念

### BMAD Method 四阶段流程

| 阶段 | 名称 | 内容 | 对应我们的流程 |
|------|------|------|---------------|
| Phase 1 | Analysis（分析） | 头脑风暴、调研、产品简介 | Phase 2: 任务规划 |
| Phase 2 | Planning（规划） | 创建需求文档（PRD/Tech-spec） | Phase 2: 任务规划 |
| Phase 3 | Solutioning（方案设计） | 设计架构 | Phase 2: 任务规划 + Phase 3: 代码质量检查 |
| Phase 4 | Implementation（实现） | 按 Epic 和 Story 构建 | Phase 4-8: TDD → 质量门禁 |

### 三种规划轨道

| 轨道 | 适用场景 | 创建文档 | 对应我们的场景 |
|------|---------|---------|---------------|
| **Quick Flow** | Bug 修复、简单功能（1-15 stories） | Tech-spec | 小型任务 |
| **BMad Method** | 产品、平台、复杂功能（10-50+ stories） | PRD + Architecture + UX | 中型项目 |
| **Enterprise** | 合规、多租户系统（30+ stories） | PRD + Architecture + Security + DevOps | 大型项目 |

---

## 🔧 安装与配置

### 安装 BMAD Method

```bash
# 在项目目录中安装
npx bmad-method install

# 选择模块：BMad Method
```

安装后会创建：
- `_bmad/` - agents、workflows、tasks 和配置
- `_bmad-output/` - 输出产物（PRD、架构文档等）

### 验证安装

```bash
# 在 Claude Code 中运行
/bmad-help

# 查看可用命令
ls .claude/commands/ | grep bmad
```

---

## 🤖 核心 Agent 列表

### BMM (Agile Suite) Agents

| Agent | 角色 | 主要工作流 | 命令 |
|-------|------|-----------|------|
| **Analyst (Mary)** | 分析师 | 头脑风暴、调研、创建简介 | `/bmad-agent-bmm-analyst` |
| **Product Manager (John)** | 产品经理 | 创建/验证 PRD、创建 Epics 和 Stories | `/bmad-agent-bmm-pm` |
| **Architect (Winston)** | 架构师 | 创建架构、实现就绪检查 | `/bmad-agent-bmm-architect` |
| **Scrum Master (Bob)** | Scrum Master | Sprint 规划、创建 Story | `/bmad-agent-bmm-sm` |
| **Developer (Amelia)** | 开发者 | 实现 Story、代码审查 | `/bmad-agent-bmm-dev` |
| **QA Engineer (Quinn)** | QA 工程师 | 自动化测试生成 | `/bmad-agent-bmm-qa` |
| **Quick Flow Solo Dev (Barry)** | 快速开发 | 快速规范、快速开发 | `/bmad-agent-bmm-quick` |
| **UX Designer (Sally)** | UX 设计师 | 创建 UX 设计 | `/bmad-agent-bmm-ux-designer` |
| **Technical Writer (Paige)** | 技术文档 | 文档项目、编写文档 | `/bmad-agent-bmm-tech-writer` |

---

## 📊 与现有流程的集成

### 集成映射

| 我们的 Phase | BMAD Method 阶段 | 使用的 Agent | 工作流 |
|-------------|-----------------|-------------|--------|
| **Phase 1: 会话启动** | - | - | 插件更新、环境检查 |
| **Phase 2: 任务规划** | Analysis + Planning + Solutioning | Analyst, PM, Architect | `/bmad-help` → `/bmad-bmm-create-prd` → `/bmad-bmm-create-architecture` |
| **Phase 3: 代码质量检查** | - | - | `/code-review` |
| **Phase 4: TDD 开发** | Implementation | Developer | `/bmad-bmm-dev-story` |
| **Phase 5: API 完整性检查** | - | - | `./scripts/check-api-completeness.sh` |
| **Phase 6: E2E 测试** | - | QA | `/bmad-agent-bmm-qa` |
| **Phase 7: 安全性检查** | - | - | `/security-review` |
| **Phase 8: 质量门禁** | - | Developer | `/bmad-bmm-code-review` |

### 推荐工作流

#### 小型任务（Quick Flow）

```bash
# 1. 快速规范
/bmad-bmm-quick-spec

# 2. 代码质量检查
/code-review

# 3. 快速开发
/bmad-bmm-quick-dev

# 4. API 完整性检查
./scripts/check-api-completeness.sh

# 5. E2E 测试
/e2e

# 6. 安全检查
/security-review

# 7. 代码审查
/bmad-bmm-code-review
```

#### 中型项目（BMad Method）

```bash
# Phase 2: 任务规划
/bmad-help  # 获取指导
/bmad-bmm-create-prd  # 创建 PRD
/bmad-bmm-create-architecture  # 创建架构
/bmad-bmm-create-epics-and-stories  # 创建 Epics 和 Stories
/bmad-bmm-check-implementation-readiness  # 实现就绪检查

# Phase 3: 代码质量检查
/code-review

# Phase 4: TDD 开发（每个 Story）
/bmad-bmm-sprint-planning  # 初始化 Sprint
/bmad-bmm-create-story  # 创建 Story 文件
/tdd  # TDD 开发
/bmad-bmm-dev-story  # 实现 Story

# Phase 5-8: 质量保障
./scripts/check-api-completeness.sh
/e2e
/security-review
/bmad-bmm-code-review
```

---

## 🎓 最佳实践

### 1. 使用 BMad-Help 作为起点

```bash
# 每次会话开始时
/bmad-help

# 询问具体问题
/bmad-help 我有一个 SaaS 想法，所有功能都清楚了，从哪里开始？
/bmad-help 我卡在 PRD 工作流上了
/bmad-help 显示已完成的工作
```

### 2. 每个工作流使用新对话

- ✅ 每个工作流开始新对话
- ✅ 避免上下文限制问题
- ✅ 保持 Agent 专注

### 3. 使用 Project Context

创建 `_bmad-output/project-context.md` 记录：
- 技术偏好
- 实现规则
- 团队约定
- 代码风格

```bash
# 在架构完成后生成
/bmad-bmm-generate-project-context
```

### 4. 工作流顺序

**必须遵循的顺序**：
1. PRD → Architecture → Epics & Stories
2. Sprint Planning → Create Story → Dev Story
3. 每个 Epic 完成后运行 Retrospective

**可选的顺序**：
- Brainstorming 和 Research 可以在 PRD 之前
- UX Design 可以在 PRD 之后、Architecture 之前
- Code Review 可以在 Dev Story 之后

---

## 🔗 关键命令速查

### 规划阶段

| 命令 | 用途 | Agent |
|------|------|-------|
| `/bmad-help` | 智能指导 | Any |
| `/bmad-brainstorming` | 头脑风暴 | Analyst |
| `/bmad-bmm-research` | 市场和技术调研 | Analyst |
| `/bmad-bmm-create-product-brief` | 创建产品简介 | Analyst |
| `/bmad-bmm-create-prd` | 创建 PRD | PM |
| `/bmad-bmm-create-ux-design` | 创建 UX 设计 | UX Designer |
| `/bmad-bmm-create-architecture` | 创建架构 | Architect |
| `/bmad-bmm-create-epics-and-stories` | 创建 Epics 和 Stories | PM |
| `/bmad-bmm-check-implementation-readiness` | 实现就绪检查 | Architect |

### 实现阶段

| 命令 | 用途 | Agent |
|------|------|-------|
| `/bmad-bmm-sprint-planning` | 初始化 Sprint | SM |
| `/bmad-bmm-create-story` | 创建 Story 文件 | SM |
| `/bmad-bmm-dev-story` | 实现 Story | Developer |
| `/bmad-bmm-code-review` | 代码审查 | Developer |
| `/bmad-bmm-retrospective` | Epic 回顾 | SM |
| `/bmad-bmm-correct-course` | 修正方向 | SM |

### 快速流程

| 命令 | 用途 | Agent |
|------|------|-------|
| `/bmad-bmm-quick-spec` | 快速规范 | Quick Flow Solo Dev |
| `/bmad-bmm-quick-dev` | 快速开发 | Quick Flow Solo Dev |

---

## 📁 输出文件结构

```
your-project/
├── _bmad/                                   # BMAD 配置
│   ├── _config/
│   │   ├── agents/                          # Agent 配置
│   │   └── workflows/                       # 工作流配置
│   └── ...
├── _bmad-output/
│   ├── planning-artifacts/
│   │   ├── PRD.md                           # 需求文档
│   │   ├── architecture.md                  # 架构文档
│   │   ├── ux-design.md                     # UX 设计（可选）
│   │   └── epics/                           # Epic 和 Story 文件
│   │       ├── epic-001-user-auth.md
│   │       └── stories/
│   │           ├── story-001-login.md
│   │           └── story-002-register.md
│   ├── implementation-artifacts/
│   │   └── sprint-status.yaml               # Sprint 跟踪
│   └── project-context.md                   # 实现规则（可选）
└── .claude/commands/                        # Claude Code 命令
    ├── bmad-agent-bmm-dev.md
    ├── bmad-bmm-create-prd.md
    └── ...
```

---

## 🔄 更新 BMAD Method

### 检查更新

```bash
# 在 Phase 1: 会话启动准备中自动执行
/plugin update bmad-method
```

### 重新安装

```bash
# 如果需要添加/删除模块
npx bmad-method install

# 选择新的模块配置
```

---

## 🆚 BMAD Method vs 现有流程

### 互补关系

| 方面 | BMAD Method | 现有流程 | 集成方式 |
|------|------------|---------|---------|
| **规划** | 结构化 PRD/Architecture | 任务规划 | BMAD 增强规划深度 |
| **开发** | Story-driven | TDD-driven | 结合使用 |
| **质量** | Code Review Agent | 质量门禁 | BMAD 补充代码审查 |
| **测试** | QA Agent | E2E 测试流程 | BMAD 生成测试 |
| **文档** | Technical Writer Agent | 文档同步 | BMAD 自动化文档 |

### 增强点

1. **规划阶段**：BMAD 提供结构化的 PRD 和架构设计
2. **Story 管理**：BMAD 提供 Epic/Story 分解和跟踪
3. **Agent 专业化**：每个角色有专门的 Agent
4. **智能指导**：BMad-Help 提供上下文感知的指导
5. **文档自动化**：Technical Writer Agent 自动生成文档

---

## 📚 学习资源

- **官方文档**：https://docs.bmad-method.org/
- **GitHub**：https://github.com/bmad-code-org/BMAD-METHOD
- **Discord**：https://discord.gg/gk8jAdXWmj
- **YouTube**：https://www.youtube.com/@BMadCode

---

## 🔗 相关文档

- [行动准则](../guidelines/01-ACTION_GUIDELINES.md)
- [系统总则](../guidelines/00-SYSTEM_OVERVIEW.md)
- [TDD 开发流程](../guidelines/02-TDD_WORKFLOW.md)
- [多 Agent 协作](../guidelines/03-MULTI_AGENT.md)

---

*版本：1.0.0 | 最后更新：2026-03-07*

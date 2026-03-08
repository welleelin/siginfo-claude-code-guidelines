# 插件管理

> 版本：1.1.0
> 最后更新：2026-03-08

---

## 📋 概述

插件管理规范定义了必备插件、安装方法、更新策略和使用场景。

---

## 🔌 必备插件

| 插件名称 | 用途 | 安装方式 | 是否必备 |
|---------|------|---------|---------|
| **bmad-method** | 需求分析、架构设计、多 Agent 协作 | `/plugin install bmad-method` | ✅ 必备 |
| **everything-claude-code** | 命令库、技能库、Agent 库、规则 | 手动安装 | ✅ 必备 |
| **workflow-studio** | 流程图、时序图、可视化工作流 | `/plugin install workflow-studio` | ✅ 必备 |
| **pencil** | UI 设计原型、线框图 | MCP 服务 | ✅ 必备 |

---

## 🚀 插件初始化

### Step 0: 检查并更新插件（最高优先级）

在每次新会话或新项目开始时，必须先执行更新：

```bash
# 更新 bmad-method 插件
/plugin update bmad-method

# 更新其他核心插件
/plugin update everything-claude-code
/plugin update workflow-studio

# 更新所有 GitHub 学习到的技能
/skill update --all

# 或批量更新所有插件
/plugin update --all
```

**更新策略**：
- ✅ 每次会话启动时自动检查更新
- ✅ 优先更新 bmad-method（核心需求分析工具）
- ✅ 更新 everything-claude-code（命令库、技能库）
- ✅ 更新所有 GitHub 学习到的技能
- ⚠️ 更新后验证功能正常
- ⚠️ 如更新失败，使用现有版本继续

### Step 1: 检查已安装插件

```bash
/plugin list
```

### Step 2: 验证必备插件

必需插件：
- bmad-method (需求分析/多 Agent 协作)
- everything-claude-code (命令/技能/规则)
- workflow-studio (流程图/可视化)
- pencil (UI 原型设计 - MCP 服务)

### Step 3: 安装缺失插件

```bash
# 安装 bmad-method
/plugin install bmad-method

# 安装 workflow-studio
/plugin install workflow-studio

# 安装 everything-claude-code
# 需要手动安装

# Pencil MCP 如未配置，需手动添加 MCP 配置
```

### Step 4: 验证更新成功

```bash
/plugin list  # 查看插件版本
/skill list   # 查看技能列表
```

---

## 📊 插件使用场景

| 阶段 | 使用插件 | 具体能力 |
|------|---------|---------|
| **需求分析** | bmad-method | `/bmad-help`, `/bmad-bmm-brainstorming`, `/bmad-bmm-research`, `/bmad-bmm-create-product-brief` |
| **架构设计** | bmad-method + pencil | `/bmad-bmm-create-prd`, `/bmad-bmm-create-architecture` + 绘制架构图 |
| **任务规划** | bmad-method + everything-claude-code | `/bmad-bmm-create-epics-and-stories`, `/plan` 命令 + workflow-studio 流程图 |
| **TDD 开发** | bmad-method + everything-claude-code | `/bmad-bmm-dev-story`, `/tdd` 命令 |
| **UI 设计** | bmad-method + pencil | `/bmad-bmm-create-ux-design`, 创建页面原型 |
| **流程设计** | workflow-studio | 创建业务流程图、时序图 |
| **代码审查** | bmad-method + everything-claude-code | `/bmad-bmm-code-review`, `/code-review` |
| **E2E 测试** | bmad-method + everything-claude-code | `/bmad-agent-bmm-qa`, `/e2e` 命令 |
| **构建修复** | everything-claude-code | `/build-fix` 命令 |
| **重构优化** | everything-claude-code | `/refactor-clean` 命令 |

---

## 🎯 BMAD Method 核心命令

### 智能指导

```bash
/bmad-help  # 自动检测项目状态并推荐下一步
```

### 快速流程（小型任务）

```bash
/bmad-bmm-quick-spec      # 生成快速规格
/bmad-bmm-quick-dev       # 快速开发实现
```

### 完整规划流程（中大型项目）

```bash
# Phase 1: Analysis（分析）
/bmad-bmm-brainstorming                 # 头脑风暴
/bmad-bmm-domain-research "领域名称"     # 领域调研
/bmad-bmm-market-research "业务想法"     # 市场调研
/bmad-bmm-technical-research "技术主题"  # 技术调研
/bmad-bmm-create-product-brief          # 创建产品简介

# Phase 2: Planning（规划）
/bmad-bmm-create-prd                    # 创建 PRD
/bmad-bmm-create-ux-design              # UX 设计

# Phase 3: Solutioning（方案设计）
/bmad-bmm-create-architecture           # 架构设计
/bmad-bmm-create-epics-and-stories      # Epic/Story 分解
/bmad-bmm-check-implementation-readiness # 实现就绪检查

# Phase 4: Implementation（实现）
/bmad-bmm-sprint-planning               # Sprint 规划
/bmad-bmm-create-story "story-id"       # 创建 Story
/bmad-bmm-dev-story "story-file.md"     # 实现 Story
/bmad-bmm-code-review                   # 代码审查
/bmad-bmm-correct-course                # 纠正路线
/bmad-bmm-sprint-status                 # Sprint 状态
/bmad-bmm-retrospective "epic-name"     # 回顾总结
```

---

## 🔧 BMAD Method 配置

### 安装位置

- **核心目录**: `_bmad/`
- **配置目录**: `_bmad/_config/`
- **产出目录**: `_bmad-output/`

### 配置文件

- `_bmad/_config/manifest.yaml` - 安装清单
- `_bmad/_config/workflow-manifest.csv` - 工作流清单（25 个）
- `_bmad/_config/agent-manifest.csv` - Agent 清单（10 个）
- `_bmad/_config/ides/claude-code.yaml` - Claude Code 配置

### 产出文件

- `_bmad-output/planning-artifacts/PRD.md` - 产品需求文档
- `_bmad-output/planning-artifacts/architecture.md` - 架构设计文档
- `_bmad-output/planning-artifacts/epic-*.md` - Epic 文档
- `_bmad-output/implementation-artifacts/story-*.md` - Story 文档

---

## 🔗 相关文档

- [行动准则](01-ACTION_GUIDELINES.md) - BMAD Method 工作流集成
- [多 Agent 协作](03-MULTI_AGENT.md) - BMAD Method Agent 协作矩阵
- [系统总则](00-SYSTEM_OVERVIEW.md) - 插件能力使用场景

---

*版本：1.1.0 | 最后更新：2026-03-08*

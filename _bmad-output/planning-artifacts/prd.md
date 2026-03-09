---
stepsCompleted:
  - step-01-init
  - step-02-discovery
  - step-02b-vision
  - step-02c-executive-summary
  - step-03-success
  - step-04-journeys
inputDocuments:
  - _bmad-output/planning-artifacts/project-context.md
  - _bmad-output/planning-artifacts/ux-design-specification.md
  - _bmad-output/planning-artifacts/wireframes-summary.md
  - docs/INTEGRATION_HANDBOOK.md
  - docs/QUICK_START_GUIDE.md
workflowType: 'prd'
documentCounts:
  briefs: 0
  research: 0
  brainstorming: 0
  projectDocs: 5
classification:
  projectType: developer_tool
  domain: general
  complexity: medium
  projectContext: brownfield
---

# 产品需求文档 - sig-claude-code-guidelines

**作者:** Cloud
**日期:** 2026-03-09

## 执行摘要

sig-claude-code-guidelines 是一套面向企业级 AI 辅助软件开发的确定性工程规范体系。它解决的核心问题是：当 AI Agent 深度参与软件开发全流程时，如何保证生成内容的质量可控、过程可追溯、责任可归属。

本项目的目标用户是采用 AI 辅助开发的技术团队（中高级工程师、技术负责人、架构师），为他们提供从需求获取 → UI 设计 → 前后端开发 → 测试验证 → 安全审查的全链路工程化规范。以 CLI（Claude Code）为主入口、IDE 为辅入口，通过 14 个核心规范文件、47 个 Agent 编排、4 道质量门禁和 3 种工作流模式，将 AI 辅助开发从"随意生成"提升为"工程化交付"。

### 是什么让它与众不同

**确定性优先（Determinism-First）**——这是本项目的核心设计哲学。当前主流 AI 编码工具追求生成速度，sig-guidelines 追求的是工程确定性：没有验证不推进，没有测试不交付，没有审查不合并。这不是对 AI 能力的限制，而是让 AI 在企业级约束下发挥最大价值。

**全链路可追溯**——每一个 AI 生成的决策、代码、设计都有明确的来源记录和质量验证。通过 TDD 优先、阶段性质量关卡、人类确认点机制，确保 AI 参与的每个环节都有人可担责、有据可查。

**CLI-First 架构**——以命令行为主入口意味着整个开发流程可被完全脚本化、自动化、可编排，天然适配 CI/CD 管线和团队级协作场景，区别于依赖 IDE 插件的方案。

**四项目深度整合**——将 sig-guidelines、oh-my-cc、everything-cc、BMAD Method 四个开源项目整合为五层架构体系（L0 规划 → L1 开发 → L2 编排 → L3 并行 → L4 验证），提供从单人快速开发到企业级多 Agent 协作的完整解决方案。

## 项目分类

| 维度 | 分类 | 说明 |
|------|------|------|
| **项目类型** | 开发者工具（Developer Tool） | CLI 脚本、规范文件、模板体系、Agent 编排系统 |
| **领域** | 通用软件工程（General） | 不限行业，适用于任何采用 AI 辅助开发的团队 |
| **复杂度** | 中等（Medium） | 四项目集成 + 多层架构，但无行业监管要求 |
| **项目上下文** | 棕地项目（Brownfield） | 已有 14 个核心规范、完整 UX 设计、自动化脚本体系 |

## 成功标准

### 用户成功

- **一人顶一个团队**：个人开发者借助 sig-guidelines + Claude Code，能独立完成从需求分析到上线交付的全流程，交付质量达到企业级团队标准
- **30 秒定位规范**：开发者在 30 秒内找到所需的具体规范文件，首次使用无需培训
- **零返工交付**：遵循规范产出的代码，在代码审查中不出现架构级返工，bug 率低于传统团队模式
- **全流程确定性**：每一步都有验证机制——需求确认后才设计，测试通过后才推进，审查通过后才合并

### 业务成功

| 时间节点 | 目标 | 衡量标准 |
|---------|------|---------|
| 3 个月 | 社区验证 | GitHub Stars ≥ 1,000，≥ 50 个 Fork |
| 6 个月 | 规模采纳 | GitHub Stars ≥ 5,000，≥ 3 个团队在生产环境使用 |
| 12 个月 | 行业标杆 | GitHub Stars ≥ 10,000，成为 AI 辅助开发领域的事实标准参考 |

### 技术成功

- **规范覆盖率 100%**：软件工程全链路（需求→设计→开发→测试→安全→部署）均有对应规范
- **自动化率 ≥ 80%**：完全自动执行的环节占整体流程 80% 以上
- **规范淘汰机制健全**：每个规范文件有版本号、最后验证日期、废弃标记，过时规范能被自动识别并提醒清理
- **向后兼容**：新增规范不破坏已稳定的工作流

### 可衡量结果

| 指标 | 基线（无规范） | 目标（使用规范） | 提升倍数 |
|------|--------------|----------------|---------|
| 单人日交付功能数 | 0.5 个 | 3-5 个 | 6-10x |
| 代码审查通过率 | 60% | 95%+ | 1.6x |
| 规范查找时间 | 10 分钟 | 30 秒 | 20x |
| Bug 逃逸率 | 15% | < 3% | 5x |
| 上下文利用效率 | 30% | 70%+ | 2.3x |

## 产品范围

### MVP — 最小可用产品

> 一个人用 Claude Code + sig-guidelines 能独立完成企业级项目的全流程交付

- **14 个核心规范文件**——覆盖全链路工程化流程
- **CLI-First 交互**——以 Claude Code 为主入口的完整开发体验
- **TDD 工作流**——先测试后实现的强制验证机制
- **4 道质量门禁**——代码质量 → API 完整性 → 安全 → 最终质量
- **稳定区域保护**——防止已验证代码被无意修改
- **快速开始指南**——5 分钟上手，无需培训

### 增长功能（Post-MVP）

- **规范生命周期管理**——自动检测过时规范、废弃提醒、版本迁移指引（解决"旧技能忘记淘汰"问题）
- **多项目集成**——oh-my-cc + everything-cc + BMAD 深度整合
- **团队协作模式**——多人/多 Agent 并行开发的编排支持
- **设计到代码全链路**——Pencil 设计 → 代码生成 → 视觉回归测试
- **社区贡献体系**——规范模板市场、最佳实践共享

### 愿景（Future）

- **行业规范模板库**——医疗、金融、政务等垂直行业的合规规范模板
- **AI Agent 认证体系**——对 Agent 产出进行企业级审计和认证
- **跨 AI 平台适配**——支持 Claude Code 以外的 AI 编码工具（Cursor、Windsurf 等）
- **私有化部署**——企业内网环境的完整部署方案

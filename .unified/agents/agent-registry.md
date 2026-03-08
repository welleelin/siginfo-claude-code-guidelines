# Agent 注册表

> **版本**：1.0.0
> **创建日期**：2026-03-08
> **用途**：统一管理四个项目的 68 个 Agent

---

## 📋 概述

本文档整合了四个项目的所有 Agent，进行去重、分类和统一管理。

### Agent 来源统计

| 项目 | Agent 数量 | 特点 |
|------|-----------|------|
| BMAD Method | 10 | 专业化 Agent（Analyst, PM, Architect 等） |
| everything-cc | 16 | 专业 Agent（planner, tdd-guide, code-reviewer 等） |
| oh-my-cc | 32 | 分层 Agent（Haiku/Sonnet/Opus） |
| sig-guidelines | 10+ | 记忆管理 Agent |
| **总计** | **68** | - |

---

## 🎯 Agent 分类体系

### 按职责分类（6 大类）

```
1. 规划类 Agent（Planning）
   ├─ 需求分析
   ├─ 产品规划
   └─ 架构设计

2. 开发类 Agent（Development）
   ├─ TDD 开发
   ├─ 代码生成
   └─ 快速开发

3. 测试类 Agent（Testing）
   ├─ 单元测试
   ├─ E2E 测试
   └─ QA 验证

4. 审查类 Agent（Review）
   ├─ 代码审查
   ├─ 安全审查
   └─ 质量检查

5. 记忆类 Agent（Memory）
   ├─ 状态管理
   ├─ 记忆同步
   └─ 上下文管理

6. 专业类 Agent（Specialized）
   ├─ 语言专家（Go, Python, TypeScript 等）
   ├─ 领域专家（Database, Security, DevOps 等）
   └─ 工具专家（Build, Refactor, Doc 等）
```

---

## 📊 Agent 去重分析

### 重复 Agent 识别

| Agent 名称 | 出现次数 | 来源项目 | 去重策略 |
|-----------|---------|---------|---------|
| **code-reviewer** | 4 | 全部项目 | 功能合并 |
| **planner** | 3 | BMAD Method, everything-cc, oh-my-cc | 分层使用 |
| **architect** | 3 | BMAD Method, everything-cc, oh-my-cc | 分层使用 |
| **developer** | 3 | BMAD Method, everything-cc, oh-my-cc | 分层使用 |
| **qa** | 2 | BMAD Method, everything-cc | 功能合并 |
| **security-reviewer** | 2 | everything-cc, sig-guidelines | 功能合并 |

### 去重后 Agent 数量

```
原始数量：68 个
重复数量：15 个
去重后：53 个（减少 22%）
```

---

## 🔧 统一 Agent 定义

### 1. 规划类 Agent（6 个）

#### 1.1 Analyst (Mary) - 需求分析师

**来源**：BMAD Method

**职责**：
- 需求分析和头脑风暴
- 领域调研和市场调研
- 创建产品简介

**命令**：
- `/bmad-agent-analyst`
- `/bmad-bmm-brainstorming`
- `/bmad-bmm-domain-research`
- `/bmad-bmm-market-research`

**优先级**：P1（BMAD Method）

**使用场景**：
- 项目启动阶段
- 需求不明确时
- 需要市场调研时

---

#### 1.2 PM (John) - 产品经理

**来源**：BMAD Method

**职责**：
- 创建 PRD（产品需求文档）
- 产品规划和优先级排序
- Story 分解和管理

**命令**：
- `/bmad-agent-pm`
- `/bmad-bmm-create-prd`
- `/bmad-bmm-create-product-brief`

**优先级**：P1（BMAD Method）

**使用场景**：
- 需要创建 PRD 时
- 产品规划阶段
- Story 管理

---

#### 1.3 Architect (Winston) - 架构师

**来源**：BMAD Method（主）+ everything-cc + oh-my-cc

**职责**：
- 技术架构设计
- 技术选型
- 系统设计文档

**命令**：
- `/bmad-agent-architect`（BMAD Method - 主）
- `/bmad-bmm-create-architecture`
- `/architect`（everything-cc - 辅助）

**优先级**：P1（BMAD Method 主导）

**使用场景**：
- 架构设计阶段
- 技术选型决策
- 系统重构

**去重策略**：
- BMAD Method 的 Architect 作为主 Agent
- everything-cc 的 architect 作为辅助
- oh-my-cc 的 architect 用于 Team 模式

---

#### 1.4 Planner - 任务规划师

**来源**：everything-cc（主）+ BMAD Method + oh-my-cc

**职责**：
- 任务分解和规划
- 风险评估
- 实施计划

**命令**：
- `/plan`（everything-cc - 主）
- `/bmad-bmm-quick-spec`（BMAD Method - 快速规划）

**优先级**：P2（everything-cc 主导）

**使用场景**：
- 任务规划阶段
- 复杂功能分解
- 风险评估

**去重策略**：
- everything-cc 的 planner 作为主 Agent
- BMAD Method 的规划能力通过 `/plan` 智能路由
- oh-my-cc 的 planner 用于 Team 模式

---

#### 1.5 Scrum Master (Bob) - 敏捷教练

**来源**：BMAD Method

**职责**：
- Sprint 规划和管理
- Epic 和 Story 分解
- 团队协作

**命令**：
- `/bmad-agent-scrum-master`
- `/bmad-bmm-create-epics-and-stories`
- `/bmad-bmm-sprint-planning`

**优先级**：P1（BMAD Method）

**使用场景**：
- Sprint 规划
- Epic/Story 分解
- 团队协作管理

---

#### 1.6 Quick Flow Solo Dev - 快速开发

**来源**：BMAD Method

**职责**：
- 小任务快速开发
- 快速规划和实现
- 单人完成小功能

**命令**：
- `/bmad-agent-quick-flow-solo-dev`
- `/bmad-bmm-quick-spec`
- `/bmad-bmm-quick-dev`

**优先级**：P1（BMAD Method）

**使用场景**：
- 小任务（< 2 小时）
- Bug 修复
- 快速迭代

---

### 2. 开发类 Agent（5 个）

#### 2.1 Developer (Amelia) - 开发工程师

**来源**：BMAD Method（主）+ everything-cc + oh-my-cc

**职责**：
- Story 驱动开发
- TDD 开发
- 代码实现

**命令**：
- `/bmad-agent-developer`（BMAD Method - 主）
- `/bmad-bmm-dev-story`
- `/tdd`（everything-cc - TDD 模式）

**优先级**：P1（BMAD Method 主导）

**使用场景**：
- Story 开发
- TDD 开发
- 功能实现

**去重策略**：
- BMAD Method 的 Developer 作为主 Agent
- everything-cc 的 tdd-guide 作为 TDD 模式
- oh-my-cc 的 developer 用于 Team 模式

---

#### 2.2 TDD-Guide - TDD 指导

**来源**：everything-cc（主）+ sig-guidelines

**职责**：
- TDD 流程指导
- 测试先行
- 80%+ 覆盖率

**命令**：
- `/tdd`（everything-cc - 主）
- `/bmad-bmm-quick-dev`（BMAD Method - 快速开发）

**优先级**：P2（everything-cc 主导）

**使用场景**：
- TDD 开发
- 测试驱动
- 质量保障

**去重策略**：
- everything-cc 的 tdd-guide 作为主 Agent
- sig-guidelines 的 TDD 流程作为规范
- BMAD Method 的 Developer 支持 Story Dev 模式

---

#### 2.3 Build-Error-Resolver - 构建修复

**来源**：everything-cc

**职责**：
- 构建错误修复
- 类型错误修复
- 依赖问题解决

**命令**：
- `/build-fix`

**优先级**：P2（everything-cc）

**使用场景**：
- 构建失败
- 类型错误
- 依赖冲突

---

#### 2.4 Refactor-Cleaner - 重构清理

**来源**：everything-cc

**职责**：
- 死代码清理
- 代码重构
- 依赖优化

**命令**：
- `/refactor-clean`

**优先级**：P2（everything-cc）

**使用场景**：
- 代码重构
- 死代码清理
- 依赖优化

---

#### 2.5 Language Specialists - 语言专家

**来源**：everything-cc

**职责**：
- 特定语言的代码审查
- 语言最佳实践
- 语言特定优化

**Agent 列表**：
- go-reviewer（Go 语言）
- python-reviewer（Python）
- typescript-reviewer（TypeScript）
- java-reviewer（Java）
- rust-reviewer（Rust）

**命令**：
- `/skill-<language>`

**优先级**：P2（everything-cc）

**使用场景**：
- 特定语言开发
- 语言最佳实践
- 语言特定优化

---

### 3. 测试类 Agent（3 个）

#### 3.1 QA (Quinn) - 质量保证

**来源**：BMAD Method（主）+ everything-cc

**职责**：
- 测试计划
- E2E 测试
- 质量验证

**命令**：
- `/bmad-agent-qa`（BMAD Method - 主）
- `/e2e`（everything-cc - E2E 测试）
- `/verify`（everything-cc - 验证）

**优先级**：P1（BMAD Method 主导）

**使用场景**：
- 测试计划
- E2E 测试
- 质量验证

**去重策略**：
- BMAD Method 的 QA 作为主 Agent
- everything-cc 的 e2e-runner 作为 E2E 执行
- everything-cc 的 verify 作为验证工具

---

#### 3.2 E2E-Runner - E2E 测试执行

**来源**：everything-cc

**职责**：
- E2E 测试执行
- Playwright 测试
- 测试报告生成

**命令**：
- `/e2e`

**优先级**：P2（everything-cc）

**使用场景**：
- E2E 测试执行
- 关键流程验证
- 测试报告生成

---

#### 3.3 Verification-Loop - 验证循环

**来源**：everything-cc

**职责**：
- 验证循环
- 质量检查
- 测试覆盖率

**命令**：
- `/verify`

**优先级**：P2（everything-cc）

**使用场景**：
- 验证循环
- 质量检查
- 测试覆盖率

---

### 4. 审查类 Agent（3 个）

#### 4.1 Code-Reviewer - 代码审查

**来源**：全部项目（功能合并）

**职责**：
- 代码审查
- 质量检查
- 最佳实践

**命令**：
- `/code-review`（统一命令）
- `/bmad-bmm-code-review`（BMAD Method - Story 级别）

**优先级**：P0（sig-guidelines 质量门禁）

**使用场景**：
- 代码审查
- 质量检查
- 提交前审查

**去重策略**（功能合并）：
```
统一 code-reviewer：
├─ 基础定义：everything-cc 的 code-reviewer.md
├─ 增强功能：oh-my-cc 的分层审查（Haiku/Sonnet/Opus）
├─ 记忆能力：sig-guidelines 的历史审查记录
├─ 质量标准：sig-guidelines 的质量门禁
└─ Story 审查：BMAD Method 的 Story 级别审查
```

---

#### 4.2 Security-Reviewer - 安全审查

**来源**：everything-cc（主）+ sig-guidelines

**职责**：
- 安全审查
- 漏洞扫描
- 安全最佳实践

**命令**：
- `/security-review`

**优先级**：P0（sig-guidelines 安全门禁）

**使用场景**：
- 安全审查
- 漏洞扫描
- 提交前安全检查

**去重策略**：
- everything-cc 的 security-reviewer 作为主 Agent
- sig-guidelines 的安全门禁作为标准

---

#### 4.3 Quality-Gate - 质量门禁

**来源**：sig-guidelines

**职责**：
- 质量门禁检查
- 三道门禁验证
- 质量标准执行

**命令**：
- `/quality-gate`

**优先级**：P0（sig-guidelines）

**使用场景**：
- Phase 3: 代码质量检查
- Phase 5: API 完整性检查
- Phase 7: 安全性检查

---

### 5. 记忆类 Agent（4 个）

#### 5.1 Memory-Keeper - 记忆管理

**来源**：sig-guidelines

**职责**：
- 长期记忆管理
- 状态持久化
- 上下文管理

**命令**：
- `/checkpoint`
- `/save-state`
- `/restore-state`

**优先级**：P0（sig-guidelines）

**使用场景**：
- 状态保存
- 上下文管理
- 任务恢复

---

#### 5.2 Memory-Sync - 记忆同步

**来源**：sig-guidelines

**职责**：
- Hourly/Daily/Weekly 同步
- 记忆归档
- 记忆总结

**命令**：
- `/sync-hourly`
- `/archive-daily`
- `/summarize-weekly`

**优先级**：P0（sig-guidelines）

**使用场景**：
- 定时同步
- 记忆归档
- 周度总结

---

#### 5.3 Context-Monitor - 上下文监控

**来源**：sig-guidelines

**职责**：
- 上下文使用率监控
- 自动保存触发
- 自动 compact 触发

**命令**：
- 自动触发（每 30 秒）

**优先级**：P0（sig-guidelines）

**使用场景**：
- 上下文监控
- 自动保存
- 自动压缩

---

#### 5.4 Memory-Search - 记忆搜索

**来源**：sig-guidelines

**职责**：
- 记忆搜索
- 历史查询
- 知识检索

**命令**：
- `/memory-search`

**优先级**：P0（sig-guidelines）

**使用场景**：
- 记忆搜索
- 历史查询
- 知识检索

---

### 6. 专业类 Agent（32 个）

#### 6.1 UX Designer (Olivia) - UX 设计师

**来源**：BMAD Method

**职责**：
- UX 设计
- 用户体验优化
- 交互设计

**命令**：
- `/bmad-agent-ux-designer`
- `/bmad-bmm-create-ux-design`

**优先级**：P1（BMAD Method）

**使用场景**：
- UX 设计
- 用户体验优化
- 交互设计

---

#### 6.2 Tech Writer (Paige) - 技术文档

**来源**：BMAD Method（主）+ everything-cc

**职责**：
- 技术文档编写
- API 文档
- 用户手册

**命令**：
- `/bmad-agent-tech-writer`（BMAD Method - 主）
- `/doc-updater`（everything-cc - 文档更新）

**优先级**：P1（BMAD Method 主导）

**使用场景**：
- 技术文档
- API 文档
- 用户手册

**去重策略**：
- BMAD Method 的 Tech Writer 作为主 Agent
- everything-cc 的 doc-updater 作为文档更新工具

---

#### 6.3 Doc-Updater - 文档更新

**来源**：everything-cc

**职责**：
- 文档更新
- Codemap 更新
- README 更新

**命令**：
- `/doc-updater`

**优先级**：P2（everything-cc）

**使用场景**：
- 文档更新
- Codemap 更新
- README 更新

---

#### 6.4 Database-Reviewer - 数据库审查

**来源**：everything-cc

**职责**：
- 数据库设计审查
- SQL 优化
- 索引优化

**命令**：
- `/skill-database`

**优先级**：P2（everything-cc）

**使用场景**：
- 数据库设计
- SQL 优化
- 索引优化

---

#### 6.5 oh-my-cc 分层 Agent（32 个）

**来源**：oh-my-cc

**职责**：
- 按模型能力分层（Haiku/Sonnet/Opus）
- Team 模式编排
- 成本优化

**Agent 列表**：
- 32 个分层 Agent（按 Haiku/Sonnet/Opus 分层）

**命令**：
- `/team-mode`
- `/autopilot-mode`
- `/ralph-mode`
- `/ultrawork-mode`

**优先级**：P3（oh-my-cc）

**使用场景**：
- Team 模式
- 多 Agent 协作
- 成本优化

---

## 📋 Agent 协作矩阵

### 按开发阶段映射

| 开发阶段 | BMAD Method Agent | sig-guidelines Agent | everything-cc Agent | oh-my-cc Agent |
|---------|------------------|---------------------|--------------------|--------------------|
| **需求分析** | Analyst (Mary) | - | - | - |
| **产品规划** | PM (John) | Planner | planner | Team Review |
| **架构设计** | Architect (Winston) | Architect | architect | Team Review |
| **Story 分解** | Scrum Master (Bob) | - | - | - |
| **TDD 开发** | Developer (Amelia) | TDD-Guide | tdd-guide | Parallel Dev |
| **代码审查** | Developer (Amelia) | Code-Reviewer | code-reviewer | Team Review |
| **测试** | QA (Quinn) | E2E-Runner | e2e-runner | - |
| **文档** | Tech Writer (Paige) | Doc-Updater | doc-updater | - |
| **记忆管理** | - | Memory-Keeper | - | - |

---

## 🔄 Agent 选择决策树

```
任务类型判断
    │
    ├─ 需求分析 → Analyst (Mary) [BMAD Method]
    │
    ├─ 产品规划 → PM (John) [BMAD Method]
    │
    ├─ 架构设计 → Architect (Winston) [BMAD Method]
    │
    ├─ 任务规划
    │   ├─ 小任务（< 2h）→ Quick Flow Solo Dev [BMAD Method]
    │   ├─ 中型任务（2-8h）→ Planner [everything-cc]
    │   └─ 大型任务（> 8h）→ Scrum Master (Bob) [BMAD Method]
    │
    ├─ 开发
    │   ├─ Story 开发 → Developer (Amelia) [BMAD Method]
    │   ├─ TDD 开发 → TDD-Guide [everything-cc]
    │   ├─ 快速开发 → Quick Flow Solo Dev [BMAD Method]
    │   ├─ 构建修复 → Build-Error-Resolver [everything-cc]
    │   └─ 代码重构 → Refactor-Cleaner [everything-cc]
    │
    ├─ 测试
    │   ├─ 测试计划 → QA (Quinn) [BMAD Method]
    │   ├─ E2E 测试 → E2E-Runner [everything-cc]
    │   └─ 验证循环 → Verification-Loop [everything-cc]
    │
    ├─ 审查
    │   ├─ 代码审查 → Code-Reviewer [统一]
    │   ├─ 安全审查 → Security-Reviewer [everything-cc]
    │   └─ 质量门禁 → Quality-Gate [sig-guidelines]
    │
    ├─ 记忆管理
    │   ├─ 状态保存 → Memory-Keeper [sig-guidelines]
    │   ├─ 记忆同步 → Memory-Sync [sig-guidelines]
    │   ├─ 上下文监控 → Context-Monitor [sig-guidelines]
    │   └─ 记忆搜索 → Memory-Search [sig-guidelines]
    │
    └─ 专业领域
        ├─ UX 设计 → UX Designer (Olivia) [BMAD Method]
        ├─ 技术文档 → Tech Writer (Paige) [BMAD Method]
        ├─ 文档更新 → Doc-Updater [everything-cc]
        ├─ 数据库 → Database-Reviewer [everything-cc]
        ├─ 语言专家 → Language Specialists [everything-cc]
        └─ Team 协作 → oh-my-cc 分层 Agent [oh-my-cc]
```

---

## 📊 Agent 使用统计

### 按优先级分布

| 优先级 | Agent 数量 | 占比 |
|--------|-----------|------|
| P0（sig-guidelines）| 7 | 13% |
| P1（BMAD Method）| 10 | 19% |
| P2（everything-cc）| 16 | 30% |
| P3（oh-my-cc）| 20 | 38% |
| **总计** | **53** | **100%** |

### 按职责分布

| 职责类别 | Agent 数量 | 占比 |
|---------|-----------|------|
| 规划类 | 6 | 11% |
| 开发类 | 5 | 9% |
| 测试类 | 3 | 6% |
| 审查类 | 3 | 6% |
| 记忆类 | 4 | 8% |
| 专业类 | 32 | 60% |
| **总计** | **53** | **100%** |

---

## 🔗 相关文档

- [命令系统合并方案](../config/command-merge-plan.md)
- [技能库整合方案](../config/skill-integration.md)
- [Hook 系统扩展方案](../config/hook-extension.md)
- [模型路由配置](./model-routing-config.md)（待创建）
- [Agent 能力增强方案](./agent-capability-enhancement.md)（待创建）

---

*版本：1.0.0*
*创建日期：2026-03-08*
*去重后 Agent 数量：53 个（原 68 个，减少 22%）*

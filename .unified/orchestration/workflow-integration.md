# 工作流整合方案

> **版本**：1.0.0
> **创建日期**：2026-03-08
> **用途**：整合四个项目的工作流，建立统一的开发编排体系

---

## 📋 概述

本文档定义了四项目集成后的统一工作流体系，整合：
- **sig-guidelines** 的 TDD 工作流作为标准流程
- **oh-my-cc** 的 Team/Autopilot 作为编排引擎
- **everything-cc** 的并行执行作为优化策略
- **BMAD Method** 的 Story 驱动作为规划框架

---

## 🎯 工作流架构

### 五层工作流模型

```
┌─────────────────────────────────────────────────────────────────┐
│                    统一工作流架构                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  L0: 规划工作流（BMAD Method 主导）                              │
│  ├─ Quick Flow（< 2h）：/bmad-bmm-quick-spec + quick-dev        │
│  ├─ Standard Flow（2-8h）：/plan + /tdd                         │
│  └─ Enterprise Flow（> 8h）：完整 BMAD Method 流程              │
│                                                                 │
│  L1: 开发工作流（sig-guidelines 主导）                           │
│  ├─ Phase 1: 会话启动准备                                       │
│  ├─ Phase 2: 任务规划（集成 BMAD Method）                       │
│  ├─ Phase 3: 代码质量检查（质量门禁）                           │
│  ├─ Phase 4: TDD 开发（测试先行）                               │
│  ├─ Phase 5: API 完整性检查（完整性门禁）                       │
│  ├─ Phase 6: E2E 测试                                           │
│  ├─ Phase 7: 安全性检查（安全门禁）                             │
│  └─ Phase 8: 质量门禁                                           │
│                                                                 │
│  L2: 编排工作流（oh-my-cc 主导）                                │
│  ├─ Team 模式：team-plan → team-prd → team-exec → team-verify  │
│  ├─ Autopilot 模式：自动驾驶，最小人类介入                      │
│  ├─ Ralph 模式：深度规划 + 自动执行                             │
│  └─ Ultrawork 模式：超高效并行执行                              │
│                                                                 │
│  L3: 并行工作流（everything-cc 优化）                           │
│  ├─ 并行 Agent 执行（独立任务同时执行）                         │
│  ├─ 并行测试执行（单元/集成/E2E 同时运行）                      │
│  └─ 并行构建验证（多环境同时构建）                              │
│                                                                 │
│  L4: 验证工作流（sig-guidelines 质量保障）                      │
│  ├─ 质量门禁（Phase 3）：代码规范、性能、最佳实践              │
│  ├─ 完整性门禁（Phase 5）：API 完整性、Mock 检查               │
│  ├─ 安全门禁（Phase 7）：安全漏洞、权限检查                    │
│  └─ 最终门禁（Phase 8）：综合质量评估                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔀 工作流整合策略

### 策略 1：按任务复杂度路由

| 任务复杂度 | 推荐工作流 | 说明 |
|-----------|-----------|------|
| **简单（< 2h）** | Quick Flow | BMAD Method Quick Flow Solo Dev |
| **中等（2-8h）** | Standard Flow | sig-guidelines TDD 工作流 |
| **复杂（> 8h）** | Enterprise Flow | 完整 BMAD Method + sig-guidelines |

### 策略 2：按团队规模路由

| 团队规模 | 推荐编排模式 | 说明 |
|---------|-------------|------|
| **单人** | Autopilot 模式 | 自动驾驶，最小介入 |
| **2-3 人** | Team 模式 | 分阶段协作 |
| **4+ 人** | Ultrawork 模式 | 超高效并行 |

### 策略 3：按项目阶段路由

| 项目阶段 | 推荐工作流 | 说明 |
|---------|-----------|------|
| **需求分析** | BMAD Method Analysis | Analyst + PM Agent |
| **架构设计** | BMAD Method Solutioning | Architect Agent |
| **功能开发** | sig-guidelines TDD | TDD-Guide + Developer |
| **测试验证** | everything-cc E2E | E2E-Runner + QA |
| **代码审查** | sig-guidelines Review | Code-Reviewer + Security-Reviewer |

---

## 📊 统一工作流定义

### 工作流 1：Quick Flow（快速开发）

**适用场景**：小任务（< 2 小时）、Bug 修复、简单功能

**流程图**：
```
开始
  │
  ▼
/bmad-bmm-quick-spec（快速规划）
  │
  ▼
/bmad-bmm-quick-dev（快速开发）
  │
  ├─ 编写测试
  ├─ 实现功能
  ├─ 运行测试
  └─ 代码审查
  │
  ▼
/verify（验证）
  │
  ▼
完成
```

**命令序列**：
```bash
# 1. 快速规划
/bmad-bmm-quick-spec

# 2. 快速开发（自动包含 TDD）
/bmad-bmm-quick-dev

# 3. 验证
/verify
```

**预计时间**：30 分钟 - 2 小时

---

### 工作流 2：Standard Flow（标准开发）

**适用场景**：中型任务（2-8 小时）、新功能开发

**流程图**：
```
开始
  │
  ▼
Phase 1: 会话启动准备
  ├─ 检查插件
  ├─ 读取核心文档
  └─ 环境检查
  │
  ▼
Phase 2: 任务规划
  ├─ /plan（sig-guidelines）
  ├─ 或 /bmad-bmm-create-prd（BMAD Method）
  └─ 人类确认
  │
  ▼
Phase 3: 代码质量检查（质量门禁）
  ├─ 代码规范检查
  ├─ 性能检查
  └─ 最佳实践检查
  │
  ▼
Phase 4: TDD 开发
  ├─ /tdd（sig-guidelines）
  ├─ 编写测试（RED）
  ├─ 实现功能（GREEN）
  └─ 重构优化（REFACTOR）
  │
  ▼
Phase 5: API 完整性检查（完整性门禁）
  ├─ Mock 接口检查
  ├─ API 覆盖率检查
  └─ 数据验证
  │
  ▼
Phase 6: E2E 测试
  ├─ /e2e（everything-cc）
  ├─ 关键流程测试
  └─ 测试报告生成
  │
  ▼
Phase 7: 安全性检查（安全门禁）
  ├─ 安全漏洞扫描
  ├─ 权限检查
  └─ 依赖安全检查
  │
  ▼
Phase 8: 质量门禁
  ├─ 综合质量评估
  ├─ 测试覆盖率检查
  └─ 文档完整性检查
  │
  ▼
完成
```

**命令序列**：
```bash
# Phase 1: 会话启动（自动）
# - 检查插件
# - 读取 MEMORY.md, CLAUDE.md, task.json

# Phase 2: 任务规划
/plan
# 或
/bmad-bmm-create-prd

# Phase 3: 代码质量检查
/code-review --pre-dev

# Phase 4: TDD 开发
/tdd

# Phase 5: API 完整性检查
/verify --api-completeness

# Phase 6: E2E 测试
/e2e

# Phase 7: 安全性检查
/security-review

# Phase 8: 质量门禁
/quality-gate
```

**预计时间**：2-8 小时

---

### 工作流 3：Enterprise Flow（企业级开发）

**适用场景**：大型任务（> 8 小时）、复杂系统、多人协作

**流程图**：
```
开始
  │
  ▼
Phase 1: Analysis（分析）
  ├─ /bmad-bmm-brainstorming
  ├─ /bmad-bmm-domain-research
  ├─ /bmad-bmm-market-research
  └─ /bmad-bmm-create-product-brief
  │
  ▼
Phase 2: Planning（规划）
  ├─ /bmad-bmm-create-prd
  ├─ /bmad-bmm-create-ux-design
  └─ 人类确认
  │
  ▼
Phase 3: Solutioning（方案设计）
  ├─ /bmad-bmm-create-architecture
  ├─ /bmad-bmm-create-epics-and-stories
  └─ /bmad-bmm-check-implementation-readiness
  │
  ▼
Phase 4: Implementation（实现）
  ├─ /bmad-bmm-sprint-planning
  ├─ 循环：
  │   ├─ /bmad-bmm-create-story
  │   ├─ /bmad-bmm-dev-story（包含 TDD）
  │   ├─ /bmad-bmm-code-review
  │   └─ /verify
  └─ /bmad-bmm-retrospective
  │
  ▼
Phase 5: Quality Assurance（质量保障）
  ├─ API 完整性检查
  ├─ E2E 测试
  ├─ 安全性检查
  └─ 质量门禁
  │
  ▼
完成
```

**命令序列**：
```bash
# Phase 1: Analysis
/bmad-bmm-brainstorming
/bmad-bmm-domain-research
/bmad-bmm-create-product-brief

# Phase 2: Planning
/bmad-bmm-create-prd
/bmad-bmm-create-ux-design

# Phase 3: Solutioning
/bmad-bmm-create-architecture
/bmad-bmm-create-epics-and-stories
/bmad-bmm-check-implementation-readiness

# Phase 4: Implementation (循环)
/bmad-bmm-sprint-planning
for each story:
  /bmad-bmm-create-story
  /bmad-bmm-dev-story
  /bmad-bmm-code-review
  /verify

# Phase 5: Quality Assurance
/verify --api-completeness
/e2e
/security-review
/quality-gate
```

**预计时间**：1-4 周

---

## 🚀 编排模式整合

### 模式 1：Team 模式（oh-my-cc）

**适用场景**：2-3 人团队协作

**流程**：
```
team-plan（规划）
  │
  ▼
team-prd（PRD 创建）
  │
  ▼
team-exec（并行执行）
  ├─ Agent 1: 后端 API
  ├─ Agent 2: 前端页面
  └─ Agent 3: 数据库
  │
  ▼
team-verify（验证）
  │
  ▼
team-fix（修复问题）
```

**集成方式**：
- team-plan 调用 sig-guidelines 的 /plan
- team-exec 使用 sig-guidelines 的 TDD 工作流
- team-verify 使用 sig-guidelines 的质量门禁

---

### 模式 2：Autopilot 模式（oh-my-cc）

**适用场景**：单人开发，最小人类介入

**流程**：
```
自动检测任务
  │
  ▼
自动选择工作流
  ├─ 简单 → Quick Flow
  ├─ 中等 → Standard Flow
  └─ 复杂 → Enterprise Flow
  │
  ▼
自动执行
  ├─ 自动规划
  ├─ 自动开发
  ├─ 自动测试
  └─ 自动审查
  │
  ▼
仅在关键点人类确认
  ├─ 规划完成
  ├─ 架构决策
  └─ 发布决策
```

**集成方式**：
- 使用 sig-guidelines 的 8 阶段流程
- 自动触发 BMAD Method 的 Agent
- 自动执行 everything-cc 的命令

---

### 模式 3：并行执行优化（everything-cc）

**适用场景**：独立任务并行执行

**并行策略**：

| 并行类型 | 说明 | 示例 |
|---------|------|------|
| **Agent 并行** | 多个 Agent 同时执行独立任务 | 后端 API + 前端页面 + 数据库 |
| **测试并行** | 单元/集成/E2E 测试同时运行 | `npm test & npm run test:e2e` |
| **构建并行** | 多环境同时构建 | dev + staging + prod |

**实现方式**：
```bash
# 并行 Agent 执行
/agent developer --task "后端 API" &
/agent developer --task "前端页面" &
/agent database-reviewer --task "数据库优化" &
wait

# 并行测试执行
npm test &
npm run test:integration &
npm run test:e2e &
wait

# 并行构建验证
npm run build:dev &
npm run build:staging &
npm run build:prod &
wait
```

---

## 📋 工作流配置

### 配置文件格式

```yaml
# .unified/orchestration/workflow-config.yaml

workflows:
  # Quick Flow 配置
  quick-flow:
    enabled: true
    maxDuration: 7200  # 2 小时
    phases:
      - name: "快速规划"
        command: "/bmad-bmm-quick-spec"
        timeout: 300
      - name: "快速开发"
        command: "/bmad-bmm-quick-dev"
        timeout: 3600
      - name: "验证"
        command: "/verify"
        timeout: 600

  # Standard Flow 配置
  standard-flow:
    enabled: true
    maxDuration: 28800  # 8 小时
    phases:
      - name: "会话启动"
        auto: true
      - name: "任务规划"
        command: "/plan"
        humanConfirm: true
      - name: "代码质量检查"
        command: "/code-review --pre-dev"
      - name: "TDD 开发"
        command: "/tdd"
      - name: "API 完整性检查"
        command: "/verify --api-completeness"
      - name: "E2E 测试"
        command: "/e2e"
      - name: "安全性检查"
        command: "/security-review"
      - name: "质量门禁"
        command: "/quality-gate"

  # Enterprise Flow 配置
  enterprise-flow:
    enabled: true
    maxDuration: 604800  # 1 周
    phases:
      - name: "Analysis"
        commands:
          - "/bmad-bmm-brainstorming"
          - "/bmad-bmm-domain-research"
          - "/bmad-bmm-create-product-brief"
      - name: "Planning"
        commands:
          - "/bmad-bmm-create-prd"
          - "/bmad-bmm-create-ux-design"
        humanConfirm: true
      - name: "Solutioning"
        commands:
          - "/bmad-bmm-create-architecture"
          - "/bmad-bmm-create-epics-and-stories"
          - "/bmad-bmm-check-implementation-readiness"
      - name: "Implementation"
        loop: true
        commands:
          - "/bmad-bmm-sprint-planning"
          - "/bmad-bmm-create-story"
          - "/bmad-bmm-dev-story"
          - "/bmad-bmm-code-review"
          - "/verify"
      - name: "Quality Assurance"
        commands:
          - "/verify --api-completeness"
          - "/e2e"
          - "/security-review"
          - "/quality-gate"

orchestration:
  # Team 模式配置
  team-mode:
    enabled: true
    maxAgents: 3
    phases:
      - "team-plan"
      - "team-prd"
      - "team-exec"
      - "team-verify"
      - "team-fix"

  # Autopilot 模式配置
  autopilot-mode:
    enabled: true
    autoSelect: true
    humanConfirmPoints:
      - "规划完成"
      - "架构决策"
      - "发布决策"

  # 并行执行配置
  parallel-execution:
    enabled: true
    maxParallel: 3
    types:
      - "agent"
      - "test"
      - "build"
```

---

## 🔧 工作流引擎

### 引擎架构

```
┌─────────────────────────────────────────────────────────────────┐
│                    工作流引擎架构                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. 任务接收                                                    │
│         │                                                       │
│         ▼                                                       │
│  2. 工作流选择                                                  │
│     ├─ 按复杂度路由                                            │
│     ├─ 按团队规模路由                                          │
│     └─ 按项目阶段路由                                          │
│         │                                                       │
│         ▼                                                       │
│  3. 编排模式选择                                                │
│     ├─ Team 模式                                               │
│     ├─ Autopilot 模式                                          │
│     └─ 并行执行模式                                            │
│         │                                                       │
│         ▼                                                       │
│  4. 阶段执行                                                    │
│     ├─ 顺序执行                                                │
│     ├─ 并行执行                                                │
│     └─ 循环执行                                                │
│         │                                                       │
│         ▼                                                       │
│  5. 质量门禁                                                    │
│     ├─ 质量门禁（Phase 3）                                     │
│     ├─ 完整性门禁（Phase 5）                                   │
│     ├─ 安全门禁（Phase 7）                                     │
│     └─ 最终门禁（Phase 8）                                     │
│         │                                                       │
│         ▼                                                       │
│  6. 完成报告                                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 引擎实现

```javascript
// .unified/orchestration/workflow-engine.js

class WorkflowEngine {
  constructor(config) {
    this.config = config;
    this.currentWorkflow = null;
    this.currentPhase = null;
  }

  // 选择工作流
  async selectWorkflow(task) {
    const complexity = this.assessComplexity(task);
    const teamSize = this.getTeamSize();
    const projectPhase = this.getProjectPhase();

    // 按复杂度路由
    if (complexity < 2) {
      return this.config.workflows['quick-flow'];
    } else if (complexity < 8) {
      return this.config.workflows['standard-flow'];
    } else {
      return this.config.workflows['enterprise-flow'];
    }
  }

  // 执行工作流
  async executeWorkflow(workflow, task) {
    this.currentWorkflow = workflow;

    for (const phase of workflow.phases) {
      this.currentPhase = phase;

      // 人类确认点
      if (phase.humanConfirm) {
        await this.waitForHumanConfirm(phase);
      }

      // 执行阶段
      if (phase.loop) {
        await this.executeLoopPhase(phase, task);
      } else if (phase.commands && phase.commands.length > 1) {
        await this.executeParallelPhase(phase);
      } else {
        await this.executeSequentialPhase(phase);
      }

      // 质量门禁检查
      if (this.isQualityGate(phase)) {
        const passed = await this.checkQualityGate(phase);
        if (!passed) {
          throw new Error(`质量门禁未通过：${phase.name}`);
        }
      }
    }

    return {
      success: true,
      workflow: workflow.name,
      duration: this.calculateDuration()
    };
  }

  // 执行顺序阶段
  async executeSequentialPhase(phase) {
    const command = phase.command || phase.commands[0];
    return await this.executeCommand(command);
  }

  // 执行并行阶段
  async executeParallelPhase(phase) {
    const promises = phase.commands.map(cmd => this.executeCommand(cmd));
    return await Promise.all(promises);
  }

  // 执行循环阶段
  async executeLoopPhase(phase, task) {
    const stories = task.stories || [];
    for (const story of stories) {
      for (const command of phase.commands) {
        await this.executeCommand(command, { story });
      }
    }
  }

  // 执行命令
  async executeCommand(command, context = {}) {
    console.log(`执行命令：${command}`);
    // 实际执行逻辑
    return { success: true, command, context };
  }

  // 等待人类确认
  async waitForHumanConfirm(phase) {
    console.log(`等待人类确认：${phase.name}`);
    // 发送通知，等待确认
    return true;
  }

  // 检查质量门禁
  async checkQualityGate(phase) {
    console.log(`检查质量门禁：${phase.name}`);
    // 执行质量检查
    return true;
  }

  // 评估复杂度
  assessComplexity(task) {
    let score = 0;
    if (task.estimatedHours > 8) score += 10;
    else if (task.estimatedHours > 2) score += 5;
    else score += 1;
    return score;
  }

  // 获取团队规模
  getTeamSize() {
    return 1; // 默认单人
  }

  // 获取项目阶段
  getProjectPhase() {
    return 'development'; // 默认开发阶段
  }

  // 判断是否为质量门禁
  isQualityGate(phase) {
    const qualityGatePhases = [
      '代码质量检查',
      'API 完整性检查',
      '安全性检查',
      '质量门禁'
    ];
    return qualityGatePhases.includes(phase.name);
  }

  // 计算执行时长
  calculateDuration() {
    // 计算逻辑
    return 3600; // 示例：1 小时
  }
}

module.exports = WorkflowEngine;
```

---

## 📊 工作流监控

### 监控指标

| 指标 | 说明 | 目标值 |
|------|------|--------|
| **工作流完成率** | 成功完成的工作流比例 | 95%+ |
| **平均执行时间** | 工作流平均执行时长 | 按预期 ±20% |
| **质量门禁通过率** | 首次通过质量门禁的比例 | 90%+ |
| **人类介入次数** | 需要人类确认的次数 | 最小化 |
| **并行执行效率** | 并行执行节省的时间 | 30%+ |

### 监控 API

```bash
# 查看工作流状态
GET /api/workflow/status?taskId=task-52

# 响应
{
  "success": true,
  "taskId": "task-52",
  "workflow": "standard-flow",
  "currentPhase": "TDD 开发",
  "progress": 50,
  "phases": [
    { "name": "会话启动", "status": "completed" },
    { "name": "任务规划", "status": "completed" },
    { "name": "代码质量检查", "status": "completed" },
    { "name": "TDD 开发", "status": "in_progress" },
    { "name": "API 完整性检查", "status": "pending" },
    { "name": "E2E 测试", "status": "pending" },
    { "name": "安全性检查", "status": "pending" },
    { "name": "质量门禁", "status": "pending" }
  ]
}
```

---

## 🎓 最佳实践

### 1. 工作流选择

| 场景 | 推荐工作流 | 原因 |
|------|-----------|------|
| Bug 修复 | Quick Flow | 快速定位和修复 |
| 新功能开发 | Standard Flow | 完整的 TDD 流程 |
| 大型重构 | Enterprise Flow | 需要完整规划 |
| 紧急修复 | Quick Flow | 最小化时间 |

### 2. 编排模式选择

| 场景 | 推荐模式 | 原因 |
|------|---------|------|
| 单人开发 | Autopilot | 自动化程度高 |
| 小团队 | Team 模式 | 协作效率高 |
| 大团队 | Ultrawork | 并行执行快 |

### 3. 质量门禁配置

- 代码质量检查（Phase 3）：必须通过
- API 完整性检查（Phase 5）：必须通过
- 安全性检查（Phase 7）：必须通过
- 最终质量门禁（Phase 8）：必须通过

---

## 🔗 相关文档

- [Agent 注册表](../agents/agent-registry.md)
- [模型路由配置](../agents/model-routing-config.md)
- [质量门禁集成](./quality-gate-integration.md)（待创建）
- [端到端测试方案](./e2e-testing-plan.md)（待创建）

---

*版本：1.0.0*
*创建日期：2026-03-08*
*预计实施时间：2 周*

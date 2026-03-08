# 四项目集成完整手册

> **版本**：1.0.0
> **发布日期**：2026-03-08
> **适用对象**：开发团队、架构师、项目经理

---

## 📋 目录

- [1. 项目概述](#1-项目概述)
- [2. 五层架构模型](#2-五层架构模型)
- [3. 三种工作流](#3-三种工作流)
- [4. 四道质量门禁](#4-四道质量门禁)
- [5. 三种编排模式](#5-三种编排模式)
- [6. Agent 体系](#6-agent-体系)
- [7. 实施指南](#7-实施指南)
- [8. 最佳实践](#8-最佳实践)
- [9. 常见问题](#9-常见问题)

---

## 1. 项目概述

### 1.1 集成目标

整合四个 Claude Code 生态项目，建立统一的 AI 辅助开发体系：

| 项目 | 定位 | 核心能力 |
|------|------|---------|
| **BMAD Method** | 规划层 | 需求分析、架构设计、Story 驱动 |
| **sig-guidelines** | 执行层 | TDD 流程、质量门禁、记忆系统 |
| **everything-cc** | 能力层 | 50+ 技能、33 命令、16 Agent |
| **oh-my-cc** | 编排层 | Team 协作、模型路由、成本优化 |

### 1.2 核心价值

```
开发效率提升：
├─ 小任务：3x 速度提升
├─ 中型任务：2x 速度提升
└─ 大型任务：1.5x 速度提升

质量保障提升：
├─ 测试覆盖率：≥ 80%
├─ 质量门禁通过率：90%+
└─ 生产环境无 Bug 率：95%+

成本优化效果：
├─ 模型使用成本：节省 30-50%
├─ 开发时间成本：节省 30%+
└─ 返工成本：节省 70%+
```

### 1.3 集成架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                    四项目集成架构 v1.0                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  L0: 规划层 (Planning) - BMAD Method 主导                        │
│  ├─ 需求分析、产品规划、架构设计、Story 分解                      │
│                                                                 │
│  L1: 开发层 (Development) - sig-guidelines 主导                  │
│  ├─ TDD 工作流、质量门禁、API 完整性检查                          │
│                                                                 │
│  L2: 编排层 (Orchestration) - oh-my-cc 主导                     │
│  ├─ Team/Autopilot/Ultrawork 模式                               │
│                                                                 │
│  L3: 并行层 (Parallel) - everything-cc 优化                     │
│  ├─ Agent 并行、测试并行、构建并行                               │
│                                                                 │
│  L4: 验证层 (Verification) - sig-guidelines 质量保障             │
│  ├─ 四道质量门禁（代码质量、API 完整性、安全性、最终质量）         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. 五层架构模型

### 2.1 L0: 规划层（BMAD Method）

**职责**：需求分析、产品规划、架构设计

**核心命令**：
```bash
/bmad-bmm-brainstorming          # 头脑风暴
/bmad-bmm-domain-research        # 领域调研
/bmad-bmm-create-prd             # 创建 PRD
/bmad-bmm-create-architecture    # 架构设计
/bmad-bmm-create-epics-and-stories  # Story 分解
```

**产出文档**：
- PRD.md - 产品需求文档
- architecture.md - 架构设计文档
- epic-*.md - Epic 文档
- story-*.md - Story 文档

### 2.2 L1: 开发层（sig-guidelines）

**职责**：TDD 开发、质量检查、API 完整性验证

**8 阶段流程**：
```
Phase 1: 会话启动准备（自动）
Phase 2: 任务规划（/plan）
Phase 3: 代码质量检查（质量门禁）
Phase 4: TDD 开发（/tdd）
Phase 5: API 完整性检查（完整性门禁）
Phase 6: E2E 测试（/e2e）
Phase 7: 安全性检查（安全门禁）
Phase 8: 质量门禁（/quality-gate）
```

**核心特性**：
- 测试先行（RED → GREEN → REFACTOR）
- 测试覆盖率 ≥ 80%
- 三层记忆系统（Hourly/Daily/Weekly）

### 2.3 L2: 编排层（oh-my-cc）

**职责**：多 Agent 协作、模型路由、成本优化

**三种编排模式**：

| 模式 | 适用场景 | 特点 |
|------|---------|------|
| **Team 模式** | 2-3 人团队 | 分阶段协作 |
| **Autopilot 模式** | 单人开发 | 自动驾驶 |
| **Ultrawork 模式** | 4+ 人团队 | 超高效并行 |

**模型路由策略**：
- Haiku 4.5：轻量任务（$1）
- Sonnet 4.6：主要开发（$3）
- Opus 4.5：架构决策（$15）

### 2.4 L3: 并行层（everything-cc）

**职责**：并行执行优化

**三种并行类型**：

| 类型 | 说明 | 预期提升 |
|------|------|---------|
| **Agent 并行** | 多个 Agent 同时执行独立任务 | 3x 速度 |
| **测试并行** | 单元/集成/E2E 测试同时运行 | 2x 速度 |
| **构建并行** | dev/staging/prod 同时构建 | 3x 速度 |

### 2.5 L4: 验证层（sig-guidelines）

**职责**：质量保障、安全检查

**四道质量门禁**：

```
门禁 1: 代码质量门禁（Phase 3）
├─ 代码规范（ESLint/Prettier）
├─ 代码复杂度（< 10）
├─ 代码重复率（< 5%）
└─ 通过标准：无 CRITICAL/HIGH 问题

门禁 2: API 完整性门禁（Phase 5）
├─ Mock 接口检查（无 Mock）
├─ API 覆盖率（100%）
├─ 数据验证检查
└─ 通过标准：无 Mock，100% 覆盖

门禁 3: 安全性门禁（Phase 7）
├─ 认证与授权
├─ 输入验证（SQL 注入/XSS）
├─ 数据安全（加密/脱敏）
└─ 通过标准：无 CRITICAL/HIGH 漏洞

门禁 4: 最终质量门禁（Phase 8）
├─ 测试覆盖率（≥ 80%）
├─ 测试通过率（100%）
├─ 构建成功率（100%）
└─ 通过标准：所有指标达标
```

---

## 3. 三种工作流

### 3.1 Quick Flow（快速开发）

**适用场景**：小任务（< 2 小时）、Bug 修复、简单功能

**流程图**：
```
开始 → 快速规划 → 快速开发 → 验证 → 完成
       (5 分钟)   (40 分钟)  (10 分钟)
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

### 3.2 Standard Flow（标准开发）

**适用场景**：中型任务（2-8 小时）、新功能开发

**8 阶段流程**：

```
Phase 1: 会话启动准备
├─ 检查插件（bmad-method, everything-cc, workflow-studio）
├─ 读取核心文档（MEMORY.md, CLAUDE.md, task.json）
└─ 环境检查（git status, 端口检查）

Phase 2: 任务规划
├─ /plan（sig-guidelines）
├─ 或 /bmad-bmm-create-prd（BMAD Method）
└─ 人类确认

Phase 3: 代码质量检查（质量门禁）
├─ 代码规范检查
├─ 性能检查
└─ 最佳实践检查

Phase 4: TDD 开发
├─ /tdd（sig-guidelines）
├─ 编写测试（RED）
├─ 实现功能（GREEN）
└─ 重构优化（REFACTOR）

Phase 5: API 完整性检查（完整性门禁）
├─ Mock 接口检查
├─ API 覆盖率检查
└─ 数据验证

Phase 6: E2E 测试
├─ /e2e（everything-cc）
├─ 关键流程测试
└─ 测试报告生成

Phase 7: 安全性检查（安全门禁）
├─ 安全漏洞扫描
├─ 权限检查
└─ 依赖安全检查

Phase 8: 质量门禁
├─ 综合质量评估
├─ 测试覆盖率检查
└─ 文档完整性检查
```

**预计时间**：2-8 小时

### 3.3 Enterprise Flow（企业级开发）

**适用场景**：大型任务（> 8 小时）、复杂系统、多人协作

**5 阶段流程**：

```
Phase 1: Analysis（分析）
├─ /bmad-bmm-brainstorming
├─ /bmad-bmm-domain-research
├─ /bmad-bmm-market-research
└─ /bmad-bmm-create-product-brief

Phase 2: Planning（规划）
├─ /bmad-bmm-create-prd
├─ /bmad-bmm-create-ux-design
└─ 人类确认

Phase 3: Solutioning（方案设计）
├─ /bmad-bmm-create-architecture
├─ /bmad-bmm-create-epics-and-stories
└─ /bmad-bmm-check-implementation-readiness

Phase 4: Implementation（实现）
├─ /bmad-bmm-sprint-planning
├─ 循环执行每个 Story：
│   ├─ /bmad-bmm-create-story
│   ├─ /bmad-bmm-dev-story（包含 TDD）
│   ├─ /bmad-bmm-code-review
│   └─ /verify
└─ /bmad-bmm-retrospective

Phase 5: Quality Assurance（质量保障）
├─ /verify --api-completeness
├─ /e2e
├─ /security-review
└─ /quality-gate
```

**预计时间**：1-4 周

### 3.4 工作流选择决策树

```
任务复杂度评估
    │
    ├─ < 2 小时 ────────▶ Quick Flow
    │                    ├─ 快速规划
    │                    ├─ 快速开发
    │                    └─ 验证
    │
    ├─ 2-8 小时 ────────▶ Standard Flow
    │                    └─ 8 阶段完整流程
    │
    └─ > 8 小时 ────────▶ Enterprise Flow
                         └─ 5 阶段 BMAD Method
```

---

## 4. 四道质量门禁

### 4.1 门禁 1：代码质量门禁（Phase 3）

**触发时机**：开发前

**检查清单**：

```yaml
code-quality-gate:
  checks:
    - name: "代码规范检查"
      tool: "eslint"
      severity: "CRITICAL"

    - name: "代码格式检查"
      tool: "prettier"
      severity: "HIGH"

    - name: "圈复杂度检查"
      threshold: 10
      severity: "HIGH"

    - name: "代码重复率检查"
      threshold: 5
      severity: "MEDIUM"

    - name: "函数长度检查"
      threshold: 50
      severity: "MEDIUM"

    - name: "文件大小检查"
      threshold: 800
      severity: "MEDIUM"

  passCriteria:
    - "无 CRITICAL 问题"
    - "无 HIGH 问题"
    - "MEDIUM 问题 < 5 个"
```

**实现示例**：

```javascript
class CodeQualityGate {
  async execute() {
    console.log('🔍 执行代码质量门禁检查...\n');

    for (const check of this.config.checks) {
      const result = await this.runCheck(check);
      this.results.push(result);

      if (!result.passed && check.severity === 'CRITICAL') {
        return this.fail();
      }
    }

    return this.evaluate();
  }
}
```

### 4.2 门禁 2：API 完整性门禁（Phase 5）

**触发时机**：开发完成后

**检查清单**：

```yaml
api-completeness-gate:
  checks:
    - name: "Mock 接口标记检查"
      command: "grep -r '// ⚠️ MOCK:' src/"
      severity: "CRITICAL"
      failOn: ["found"]

    - name: "API 覆盖率检查"
      threshold: 100
      severity: "CRITICAL"

    - name: "数据验证检查"
      severity: "HIGH"

    - name: "错误处理检查"
      severity: "HIGH"

    - name: "端口冲突检查"
      ports: [3000, 8000, 5173]
      severity: "HIGH"

  passCriteria:
    - "无 Mock 接口"
    - "API 覆盖率 100%"
    - "所有 API 有数据验证"
    - "所有 API 有错误处理"
    - "无端口冲突"
```

### 4.3 门禁 3：安全性门禁（Phase 7）

**触发时机**：测试完成后

**检查清单**：

```yaml
security-gate:
  checks:
    - name: "认证与授权检查"
      areas:
        - "JWT Token 验证"
        - "OAuth 流程"
        - "权限控制"
      severity: "CRITICAL"

    - name: "输入验证检查"
      areas:
        - "SQL 注入防护"
        - "XSS 防护"
        - "CSRF 防护"
      severity: "CRITICAL"

    - name: "数据安全检查"
      areas:
        - "敏感数据加密"
        - "密码哈希"
        - "数据脱敏"
      severity: "CRITICAL"

    - name: "依赖安全检查"
      tool: "npm audit"
      command: "npm audit --audit-level=high"
      severity: "HIGH"

  passCriteria:
    - "无 CRITICAL 漏洞"
    - "无 HIGH 漏洞"
```

### 4.4 门禁 4：最终质量门禁

**触发时机**：提交前

**检查清单**：

```yaml
# .unified/quality-gates/final-quality-gate.yaml

final-quality-gate:
  name: "最终质量门禁"
  phase: 8
  trigger: "pre-commit"

  checks:
    # 1. 测试覆盖率
    - name: "测试覆盖率检查"
      tool: "jest"
      command: "npm run test:coverage"
      threshold: 80
      severity: "CRITICAL"
      failOn: ["coverage < 80%"]

    # 2. 测试通过率
    - name: "测试通过率检查"
      tool: "jest"
      command: "npm test"
      threshold: 100
      severity: "CRITICAL"
      failOn: ["failed tests"]

    # 3. 构建成功
    - name: "构建成功检查"
      tool: "npm"
      command: "npm run build"
      severity: "CRITICAL"
      failOn: ["build failed"]

    # 4. 文档完整性
    - name: "文档完整性检查"
      files:
        - "README.md"
        - "API.md"
        - "CHANGELOG.md"
      severity: "HIGH"
      failOn: ["missing file"]

    # 5. 代码审查
    - name: "代码审查通过检查"
      tool: "custom"
      severity: "HIGH"
      failOn: ["review not approved"]

    # 6. 所有门禁通过
    - name: "前置门禁检查"
      gates:
        - "code-quality-gate"
        - "api-completeness-gate"
        - "security-gate"
      severity: "CRITICAL"
      failOn: ["gate failed"]

  passCriteria:
    - "测试覆盖率 ≥ 80%"
    - "测试通过率 100%"
    - "构建成功"
    - "文档完整"
    - "代码审查通过"
    - "所有前置门禁通过"

  onFailure:
    action: "block"
    notification:
      level: "P1"
      message: "最终质量门禁未通过，请修复问题"
```

**实现示例**：

```javascript
// .unified/quality-gates/final-quality-gate.js

const { execSync } = require('child_process');

class FinalQualityGate {
  constructor(config) {
    this.config = config;
    this.results = [];
  }

  async execute() {
    console.log('🔍 执行最终质量门禁检查...\n');

    // 1. 测试覆盖率检查
    const coverageCheck = await this.checkTestCoverage();
    this.results.push(coverageCheck);

    // 2. 测试通过率检查
    const testPassCheck = await this.checkTestPass();
    this.results.push(testPassCheck);

    // 3. 构建成功检查
    const buildCheck = await this.checkBuild();
    this.results.push(buildCheck);

    // 4. 文档完整性检查
    const docsCheck = await this.checkDocumentation();
    this.results.push(docsCheck);

    // 5. 前置门禁检查
    const gatesCheck = await this.checkPreviousGates();
    this.results.push(gatesCheck);

    return this.evaluate();
  }

  async checkTestCoverage() {
    console.log('  检查：测试覆盖率...');

    try {
      const output = execSync('npm run test:coverage', { encoding: 'utf-8' });
      const coverage = this.extractCoverage(output);
      const passed = coverage >= 80;

      console.log(`  测试覆盖率：${coverage}%`);
      console.log(passed ? '  ✅ 通过' : '  ❌ 失败');

      return {
        name: '测试覆盖率检查',
        passed,
        severity: 'CRITICAL',
        coverage
      };
    } catch (error) {
      console.log('  ❌ 失败');
      return {
        name: '测试覆盖率检查',
        passed: false,
        severity: 'CRITICAL',
        error: error.message
      };
    }
  }

  async checkTestPass() {
    console.log('  检查：测试通过率...');

    try {
      execSync('npm test', { encoding: 'utf-8' });
      console.log('  ✅ 所有测试通过');

      return {
        name: '测试通过率检查',
        passed: true,
        severity: 'CRITICAL'
      };
    } catch (error) {
      console.log('  ❌ 测试失败');
      return {
        name: '测试通过率检查',
        passed: false,
        severity: 'CRITICAL',
        error: error.message
      };
    }
  }

  async checkBuild() {
    console.log('  检查：构建成功...');

    try {
      execSync('npm run build', { encoding: 'utf-8' });
      console.log('  ✅ 构建成功');

      return {
        name: '构建成功检查',
        passed: true,
        severity: 'CRITICAL'
      };
    } catch (error) {
      console.log('  ❌ 构建失败');
      return {
        name: '构建成功检查',
        passed: false,
        severity: 'CRITICAL',
        error: error.message
      };
    }
  }

  evaluate() {
    const critical = this.results.filter(r => !r.passed && r.severity === 'CRITICAL');
    const high = this.results.filter(r => !r.passed && r.severity === 'HIGH');

    console.log('\n📊 检查结果：');
    console.log(`  CRITICAL: ${critical.length}`);
    console.log(`  HIGH: ${high.length}`);

    if (critical.length > 0 || high.length > 0) {
      return this.fail();
    }

    return this.pass();
  }

  pass() {
    console.log('\n✅ 最终质量门禁通过\n');
    return { success: true, gate: 'final-quality', results: this.results };
  }

  fail() {
    console.log('\n❌ 最终质量门禁未通过\n');
    return { success: false, gate: 'final-quality', results: this.results };
  }
}

module.exports = FinalQualityGate;
```

---

## 5. 三种编排模式

### 5.1 Team 模式（oh-my-cc）

**适用场景**：2-3 人团队协作

**流程图**：

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

| 阶段 | oh-my-cc 命令 | 集成的 sig-guidelines 能力 |
|------|--------------|---------------------------|
| team-plan | 任务规划 | /plan 命令 |
| team-prd | PRD 创建 | 文档模板 |
| team-exec | 并行执行 | TDD 工作流 |
| team-verify | 验证 | 质量门禁 |
| team-fix | 修复 | 代码审查 |

**命令示例**：

```bash
# 1. 团队规划
/team-plan "实现用户管理系统"

# 2. 创建 PRD
/team-prd

# 3. 并行执行（3 个 Agent 同时工作）
/team-exec

# 4. 验证
/team-verify

# 5. 修复问题（如有）
/team-fix
```

**预期效果**：
- 开发效率提升 2x
- 3 个 Agent 并行执行
- 无冲突（共享记忆）
- 质量门禁通过

---

### 5.2 Autopilot 模式（oh-my-cc）

**适用场景**：单人开发，最小人类介入

**流程图**：

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

**命令示例**：

```bash
# 启动 Autopilot 模式
/autopilot "实现用户登录功能"

# 系统自动：
# 1. 检测任务复杂度 → 中等
# 2. 选择 Standard Flow
# 3. 执行 8 个 Phase
# 4. 仅在 2 个关键点确认
```

**预期效果**：
- 自动识别任务类型
- 自动选择合适工作流
- 最小化人类介入（仅 3 个确认点）
- 质量不降低

---

### 5.3 并行执行优化（everything-cc）

**适用场景**：独立任务并行执行

**并行策略**：

| 并行类型 | 说明 | 预期提升 |
|---------|------|---------|
| **Agent 并行** | 多个 Agent 同时执行独立任务 | 3x 速度 |
| **测试并行** | 单元/集成/E2E 测试同时运行 | 2x 速度 |
| **构建并行** | dev/staging/prod 同时构建 | 3x 速度 |

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

**预期效果**：
- Agent 并行：3x 速度提升
- 测试并行：2x 速度提升
- 构建并行：3x 速度提升
- 总体时间节省 30%+

---

## 6. Agent 体系

### 6.1 Agent 总览

**四项目 Agent 统计**：

| 项目 | Agent 数量 | 核心 Agent |
|------|-----------|-----------|
| BMAD Method | 9 个 | Analyst, PM, Architect, Developer, QA |
| sig-guidelines | 10+ 个 | TDD-Guide, Code-Reviewer, Memory-Keeper |
| everything-cc | 16 个 | Planner, Build-Error-Resolver, E2E-Runner |
| oh-my-cc | 32 个 | Team Agents, Model Router |
| **去重后总计** | **47 个** | 合并重复 Agent |

### 6.2 Agent 分类

**按职责分类**：

```
规划类 Agent (6 个)
├─ Analyst (Mary) - BMAD Method
├─ PM (John) - BMAD Method
├─ Planner - sig-guidelines
├─ Architect (Winston) - BMAD Method
├─ Scrum Master (Bob) - BMAD Method
└─ Quick Flow Solo Dev - BMAD Method

开发类 Agent (8 个)
├─ Developer (Amelia) - BMAD Method
├─ TDD-Guide - sig-guidelines
├─ Build-Error-Resolver - everything-cc
├─ Refactor-Cleaner - everything-cc
├─ Go-Reviewer - everything-cc
├─ Python-Reviewer - everything-cc
├─ Database-Reviewer - everything-cc
└─ Frontend Developer - oh-my-cc

测试类 Agent (5 个)
├─ QA (Quinn) - BMAD Method
├─ E2E-Runner - everything-cc
├─ Test Generator - everything-cc
├─ Security-Reviewer - everything-cc
└─ QA Agent - oh-my-cc

审查类 Agent (4 个)
├─ Code-Reviewer - sig-guidelines
├─ Security-Reviewer - sig-guidelines
├─ Tech Writer (Paige) - BMAD Method
└─ Doc-Updater - everything-cc

记忆类 Agent (2 个)
├─ Memory-Keeper - sig-guidelines
└─ Context Manager - sig-guidelines

专业类 Agent (22 个)
├─ UX Designer (Olivia) - BMAD Method
├─ Model Router - oh-my-cc
├─ Team Coordinator - oh-my-cc
└─ ... (19 个专业领域 Agent)
```

### 6.3 Agent 协作矩阵

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

---

## 7. 实施指南

### 7.1 实施路线图

**阶段 1：基础设施整合（第 1-2 周）**

**目标**：建立统一的规则和配置基础

**任务清单**：
- [ ] 安装 BMAD Method (`npx bmad-method install`)
- [ ] 规则系统整合
  - 保留 sig-guidelines 的 14 个核心文档作为主规则
  - 添加 everything-cc 的通用规则作为补充
  - 配置 oh-my-cc 的兼容性规则作为适配层
- [ ] 长期记忆系统部署
  - 在所有项目中启用 sig-guidelines 的三层记忆
  - 配置自动同步（Hourly/Daily/Weekly）
- [ ] 上下文管理配置
  - 启用自动压缩机制
  - 配置阈值（70%/80%/90%）

**关键文件**：
- `MEMORY.md` - 扩展为统一记忆系统
- `project-context.md` - BMAD Method 项目上下文
- `CLAUDE.md` - 合并四个项目的配置
- `.unified/config/` - 新建统一配置目录

---

**阶段 2：能力层整合（第 3-4 周）**

**目标**：统一命令、技能和工具

**任务清单**：
- [ ] 命令系统合并
  - 保留 everything-cc 的 33 个命令
  - 添加 sig-guidelines 的 7 个记忆命令
  - 映射 oh-my-cc 的魔法关键词到命令
- [ ] 技能库整合
  - 通过 git submodule 引入 everything-cc 的 skills/
  - 配置 oh-my-cc 的技能组合系统
- [ ] Hook 系统扩展
  - 保留 oh-my-cc 的 31 个 Hook
  - 添加记忆同步 Hook
  - 添加质量门禁 Hook

**关键文件**：
- `commands/` - 合并命令系统
- `skills/` - 引入 everything-cc 技能库
- `.unified/hooks/` - 扩展 Hook 系统

---

**阶段 3：Agent 层整合（第 5-6 周）**

**目标**：统一 Agent 定义和路由

**任务清单**：
- [ ] Agent 去重和分类
  - 合并重复 Agent（如 code-reviewer）
  - 按职责分类（规划/开发/测试/审查/记忆/专业）
  - 创建统一 Agent 注册表
- [ ] 模型路由集成
  - 使用 oh-my-cc 的智能路由
  - 配置成本优化策略
- [ ] Agent 能力增强
  - 为所有 Agent 添加记忆访问能力
  - 为所有 Agent 添加上下文感知能力

**关键文件**：
- `agents/` - 统一 Agent 注册表
- `.unified/routing/` - 模型路由配置

---

**阶段 4：编排层整合（第 7-8 周）**

**目标**：统一工作流和编排模式

**任务清单**：
- [ ] 工作流整合
  - sig-guidelines 的 TDD 工作流作为标准流程
  - oh-my-cc 的 Team/Autopilot 作为编排引擎
  - everything-cc 的并行执行作为优化策略
- [ ] 质量门禁集成
  - sig-guidelines 的质量门禁作为标准
  - oh-my-cc 的验证协议作为补充
- [ ] 端到端测试
  - 完整功能开发流程测试
  - 多 Agent 协作场景测试

**关键文件**：
- `guidelines/01-ACTION_GUIDELINES.md` - 更新工作流
- `guidelines/05-QUALITY_GATE.md` - 增强质量门禁

---

### 7.2 验收标准

**阶段 1 验收**：
- [ ] BMAD Method 安装成功
- [ ] 长期记忆系统正常工作
- [ ] 上下文自动压缩正常触发
- [ ] 规则系统无冲突
- [ ] 配置文件结构统一

**阶段 2 验收**：
- [ ] 所有命令正常工作
- [ ] 技能库可正常访问
- [ ] Hook 系统正常触发
- [ ] 无命名冲突

**阶段 3 验收**：
- [ ] Agent 注册表完整
- [ ] 模型路由正常工作
- [ ] Agent 能力增强生效
- [ ] 成本降低 30%+

**阶段 4 验收**：
- [ ] BMAD Method Story 驱动开发正常
- [ ] sig-guidelines TDD 工作流正常
- [ ] oh-my-cc Team 编排正常
- [ ] 质量门禁通过
- [ ] 端到端测试通过

---

## 8. 最佳实践

### 8.1 工作流选择

| 场景 | 推荐工作流 | 原因 |
|------|-----------|------|
| Bug 修复 | Quick Flow | 快速定位和修复 |
| 新功能开发 | Standard Flow | 完整的 TDD 流程 |
| 大型重构 | Enterprise Flow | 需要完整规划 |
| 紧急修复 | Quick Flow | 最小化时间 |

### 8.2 编排模式选择

| 场景 | 推荐模式 | 原因 |
|------|---------|------|
| 单人开发 | Autopilot | 自动化程度高 |
| 小团队 | Team 模式 | 协作效率高 |
| 大团队 | Ultrawork | 并行执行快 |

### 8.3 质量门禁配置

**必须通过的门禁**：
- 代码质量检查（Phase 3）：无 CRITICAL/HIGH 问题
- API 完整性检查（Phase 5）：无 Mock，100% 覆盖
- 安全性检查（Phase 7）：无 CRITICAL/HIGH 漏洞
- 最终质量门禁（Phase 8）：所有指标达标

**推荐配置**：
```yaml
quality-gates:
  code-quality:
    enabled: true
    blocking: true
  api-completeness:
    enabled: true
    blocking: true
  security:
    enabled: true
    blocking: true
  final-quality:
    enabled: true
    blocking: true
```

---

## 9. 常见问题

### 9.1 安装与配置

**Q: 如何安装 BMAD Method？**

A: 执行以下命令：
```bash
npx bmad-method install
```

**Q: 如何检查插件状态？**

A: 执行以下命令：
```bash
/plugin list
```

**Q: 如何配置长期记忆系统？**

A: 参考 `guidelines/11-LONG_TERM_MEMORY.md`，执行：
```bash
./scripts/init-memory.sh
```

---

### 9.2 工作流使用

**Q: 如何选择合适的工作流？**

A: 根据任务复杂度：
- < 2 小时 → Quick Flow
- 2-8 小时 → Standard Flow
- > 8 小时 → Enterprise Flow

**Q: 如何启动 Autopilot 模式？**

A: 执行以下命令：
```bash
/autopilot "任务描述"
```

**Q: 如何并行执行多个 Agent？**

A: 使用 `&` 和 `wait`：
```bash
/agent developer --task "后端 API" &
/agent developer --task "前端页面" &
wait
```

---

### 9.3 质量门禁

**Q: 质量门禁失败怎么办？**

A: 按以下步骤处理：
1. 查看失败原因
2. 修复问题
3. 重新运行门禁
4. 确认通过

**Q: 如何跳过某个门禁？**

A: 不推荐跳过，但如果必须：
```yaml
quality-gates:
  <gate-name>:
    enabled: false
```

**Q: 如何查看门禁历史？**

A: 查看日志文件：
```bash
cat .unified/quality-gates/history.log
```

---

### 9.4 成本优化

**Q: 如何降低模型使用成本？**

A: 使用 oh-my-cc 的智能模型路由：
- 简单任务 → Haiku 4.5 ($1)
- 中等任务 → Sonnet 4.6 ($3)
- 复杂任务 → Opus 4.5 ($15)

**Q: 如何监控成本？**

A: 查看成本报告：
```bash
cat .unified/routing/cost-report.json
```

**Q: 预期成本节省多少？**

A: 30-50%，具体取决于任务分布。

---

### 9.5 故障排查

**Q: 上下文超限怎么办？**

A: 系统会自动处理：
- 70% → 预警通知
- 80% → 自动保存到 Memory
- 90% → 自动 compact

**Q: Agent 执行失败怎么办？**

A: 查看错误日志：
```bash
cat .unified/agents/error.log
```

**Q: 如何恢复中断的任务？**

A: 从检查点恢复：
```bash
./scripts/checkpoint.sh restore <task_id>
```

---

*版本：1.0.0*
*发布日期：2026-03-08*
*适用对象：开发团队、架构师、项目经理*

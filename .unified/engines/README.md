# 统一引擎 (Unified Engines)

> **版本**: 1.0.0
> **创建日期**: 2026-03-09
> **用途**: 四项目集成的工作流引擎和质量门禁引擎

---

## 📋 概述

本目录包含四项目集成后的核心引擎实现：

| 引擎 | 文件 | 用途 |
|------|------|------|
| **WorkflowEngine** | `workflow-engine.js` | 统一的工作流编排引擎 |
| **QualityGateEngine** | `quality-gate-engine.js` | 统一的质量门禁检查引擎 |
| **UnifiedEngine** | `index.js` | 统一入口，整合两个引擎 |

---

## 🚀 快速开始

### 安装依赖

```bash
# Node.js 项目
npm install

# 或直接使用（无外部依赖）
node index.js
```

### 基本使用

```javascript
const { UnifiedEngine } = require('./index');

// 创建引擎实例
const engine = new UnifiedEngine();

// 定义任务
const task = {
    title: '实现用户登录功能',
    description: '实现基本的用户登录功能',
    files: ['src/auth/login.ts', 'src/auth/login.test.ts'],
    linesOfCode: 150,
    dependencies: ['bcrypt', 'jsonwebtoken'],
    newTechStack: false,
    architecturalImpact: false
};

// 智能执行（自动选择工作流）
const result = await engine.smartExecute(task);

console.log(result);
```

---

## 📊 WorkflowEngine

### 功能

- ✅ 自动评估任务复杂度
- ✅ 自动选择合适的工作流（Quick/Standard/Enterprise）
- ✅ 执行工作流阶段
- ✅ 支持人类确认点
- ✅ 支持质量门禁集成

### 三种工作流

| 工作流 | 适用场景 | 预计时间 | 阶段数 |
|--------|---------|---------|--------|
| **Quick Flow** | 小任务（< 2h） | 30分钟-2小时 | 5 |
| **Standard Flow** | 中型任务（2-8h） | 2-8小时 | 8 |
| **Enterprise Flow** | 大型任务（> 8h） | 1-4周 | 5 |

### 使用示例

```javascript
const { WorkflowEngine } = require('./workflow-engine');

const engine = new WorkflowEngine();

// 1. 选择工作流
const workflow = engine.selectWorkflow(task);
console.log(`推荐工作流: ${workflow.name}`);

// 2. 执行工作流
const result = await engine.executeWorkflow(workflow, task);

// 3. 获取状态
const status = engine.getStatus();
console.log(`进度: ${status.progress}%`);
```

### 复杂度评估算法

```javascript
// 复杂度分数 = 基础分 + 文件数分 + 代码行数分 + 依赖关系分 + 新技术栈分 + 架构影响分

// 文件数量
// > 10 文件: +3 分
// > 5 文件: +2 分
// > 1 文件: +1 分

// 代码行数
// > 500 行: +3 分
// > 200 行: +2 分
// > 50 行: +1 分

// 依赖关系
// > 5 依赖: +2 分
// > 2 依赖: +1 分

// 新技术栈: +2 分
// 架构影响: +3 分

// 总分范围: 0-15
// < 2: Quick Flow
// < 8: Standard Flow
// >= 8: Enterprise Flow
```

---

## 🔍 QualityGateEngine

### 功能

- ✅ 四道质量门禁检查
- ✅ 多种检查工具支持
- ✅ 自动评估检查结果
- ✅ 详细的失败原因报告

### 四道质量门禁

| 门禁 | Phase | 触发时机 | 检查项数 |
|------|-------|---------|---------|
| **代码质量** | 3 | 开发前 | 6 |
| **API 完整性** | 5 | 开发后 | 5 |
| **安全性** | 7 | 测试后 | 6 |
| **最终质量** | 8 | 提交前 | 6 |

### 使用示例

```javascript
const { QualityGateEngine } = require('./quality-gate-engine');

const engine = new QualityGateEngine();

// 1. 执行单个门禁
const result = await engine.executeGate('code-quality');
console.log(`通过: ${result.success}`);

// 2. 执行所有门禁
const allResults = await engine.executeAll();

// 3. 获取状态
const status = engine.getOverallStatus();
console.log(`通过: ${status.passed}/${status.total}`);
```

### 检查项配置

```yaml
# 代码质量门禁示例
code-quality:
  checks:
    - name: 代码规范检查
      tool: eslint
      command: npm run lint
      severity: CRITICAL
      failOn: [error]

    - name: 代码复杂度检查
      tool: complexity
      command: npm run complexity
      severity: HIGH
      threshold: 10
      failOn: [exceed]
```

---

## 🔗 与 Claude Code 集成

### 方式 1: 作为 Skill 调用

```bash
# 在 Claude Code 中
/workflow-engine --task "实现用户登录功能"
/quality-gate --gate code-quality
```

### 方式 2: 作为 Agent 能力

```javascript
// Agent 配置
{
  "name": "workflow-agent",
  "capabilities": ["workflow-engine", "quality-gate"],
  "engine": "./unified/engines/index.js"
}
```

### 方式 3: 作为 Hook 触发

```yaml
# .claude/hooks.yaml
pre_tool_use:
  - trigger: "Write"
    action: "workflow-engine.check-code-quality"
```

---

## 📁 文件结构

```
.unified/engines/
├── index.js                  # 统一入口
├── workflow-engine.js        # 工作流引擎
├── quality-gate-engine.js    # 质量门禁引擎
└── README.md                 # 本文档
```

---

## 🧪 测试

```bash
# 运行引擎测试
cd scripts/e2e
./e2e-test.sh

# 或单独测试
node -e "
const { WorkflowEngine } = require('../../.unified/engines/workflow-engine');
const engine = new WorkflowEngine();
const task = { title: '测试', files: [], linesOfCode: 100 };
const result = engine.selectWorkflow(task);
console.log(result);
"
```

---

## 📈 性能指标

| 指标 | 目标值 | 说明 |
|------|--------|------|
| 工作流选择时间 | < 1s | 复杂度评估和路由 |
| 单门禁检查时间 | < 30s | 执行单个质量门禁 |
| 全部门禁检查时间 | < 2min | 执行四道质量门禁 |
| 内存占用 | < 50MB | 引擎运行时内存 |

---

## 🔧 配置

### 自定义工作流

```javascript
const { WorkflowEngine } = require('./workflow-engine');

const customConfig = {
    workflows: {
        'custom-flow': {
            name: 'Custom Flow',
            description: '自定义工作流',
            phases: [
                { name: 'planning', auto: true },
                { name: 'development', auto: true },
                { name: 'testing', auto: true }
            ]
        }
    }
};

const engine = new WorkflowEngine(customConfig);
```

### 自定义质量门禁

```javascript
const { QualityGateEngine } = require('./quality-gate-engine');

const customConfig = {
    'custom-gate': {
        name: 'Custom Gate',
        phase: 99,
        checks: [
            {
                name: 'Custom Check',
                command: 'npm run custom-check',
                severity: 'HIGH',
                failOn: ['failed']
            }
        ]
    }
};

const engine = new QualityGateEngine(customConfig);
```

---

*版本: 1.0.0*
*最后更新: 2026-03-09*

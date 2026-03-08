# 质量门禁集成方案

> **版本**：1.0.0
> **创建日期**：2026-03-08
> **用途**：整合四个项目的质量门禁体系，建立统一的质量保障机制

---

## 📋 概述

本文档定义了四项目集成后的统一质量门禁体系，整合：
- **sig-guidelines** 的三道质量门禁作为标准
- **oh-my-cc** 的验证协议作为补充
- **everything-cc** 的自动化检查工具
- **BMAD Method** 的 Implementation Readiness 检查

---

## 🎯 质量门禁架构

### 四道质量门禁

```
┌─────────────────────────────────────────────────────────────────┐
│                    统一质量门禁体系                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  门禁 1: 代码质量门禁（Phase 3）                                 │
│  ├─ 触发时机：开发前                                            │
│  ├─ 检查内容：                                                  │
│  │   ├─ 代码规范（ESLint/Prettier）                            │
│  │   ├─ 代码复杂度（圈复杂度 < 10）                            │
│  │   ├─ 代码重复率（< 5%）                                     │
│  │   ├─ 函数长度（< 50 行）                                    │
│  │   ├─ 文件大小（< 800 行）                                   │
│  │   └─ 最佳实践（immutability, error handling）              │
│  ├─ 通过标准：无 CRITICAL/HIGH 问题                            │
│  └─ 失败处理：修复后重新检查                                    │
│                                                                 │
│  门禁 2: API 完整性门禁（Phase 5）                              │
│  ├─ 触发时机：开发完成后                                        │
│  ├─ 检查内容：                                                  │
│  │   ├─ Mock 接口标记检查                                      │
│  │   ├─ API 覆盖率检查（100%）                                 │
│  │   ├─ 数据验证检查                                           │
│  │   ├─ 错误处理检查                                           │
│  │   └─ 端口冲突检查                                           │
│  ├─ 通过标准：无 Mock 接口，API 100% 覆盖                      │
│  └─ 失败处理：补充缺失 API，移除 Mock                          │
│                                                                 │
│  门禁 3: 安全性门禁（Phase 7）                                  │
│  ├─ 触发时机：测试完成后                                        │
│  ├─ 检查内容：                                                  │
│  │   ├─ 认证与授权（JWT/OAuth）                               │
│  │   ├─ 输入验证（SQL 注入/XSS）                              │
│  │   ├─ 数据安全（加密/脱敏）                                  │
│  │   ├─ API 安全（CORS/CSRF/Rate Limit）                      │
│  │   ├─ 依赖安全（npm audit）                                 │
│  │   └─ 配置安全（secrets 检查）                              │
│  ├─ 通过标准：无 CRITICAL/HIGH 漏洞                           │
│  └─ 失败处理：修复漏洞后重新检查                               │
│                                                                 │
│  门禁 4: 最终质量门禁（Phase 8）                                │
│  ├─ 触发时机：提交前                                           │
│  ├─ 检查内容：                                                  │
│  │   ├─ 测试覆盖率（≥ 80%）                                   │
│  │   ├─ 测试通过率（100%）                                     │
│  │   ├─ 构建成功率（100%）                                     │
│  │   ├─ 文档完整性（README/API 文档）                         │
│  │   ├─ 代码审查通过                                           │
│  │   └─ 所有门禁通过                                           │
│  ├─ 通过标准：所有指标达标                                     │
│  └─ 失败处理：修复问题后重新检查                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔍 门禁 1：代码质量门禁

### 检查清单

```yaml
# .unified/quality-gates/code-quality-gate.yaml

code-quality-gate:
  name: "代码质量门禁"
  phase: 3
  trigger: "pre-development"

  checks:
    # 1. 代码规范
    - name: "代码规范检查"
      tool: "eslint"
      command: "npm run lint"
      severity: "CRITICAL"
      failOn: ["error"]

    # 2. 代码格式
    - name: "代码格式检查"
      tool: "prettier"
      command: "npm run format:check"
      severity: "HIGH"
      failOn: ["formatting-error"]

    # 3. 代码复杂度
    - name: "圈复杂度检查"
      tool: "eslint-plugin-complexity"
      threshold: 10
      severity: "HIGH"
      failOn: ["complexity > 10"]

    # 4. 代码重复
    - name: "代码重复率检查"
      tool: "jscpd"
      threshold: 5
      severity: "MEDIUM"
      failOn: ["duplication > 5%"]

    # 5. 函数长度
    - name: "函数长度检查"
      tool: "eslint-plugin-max-lines"
      threshold: 50
      severity: "MEDIUM"
      failOn: ["function > 50 lines"]

    # 6. 文件大小
    - name: "文件大小检查"
      tool: "eslint-plugin-max-lines"
      threshold: 800
      severity: "MEDIUM"
      failOn: ["file > 800 lines"]

    # 7. 不可变性
    - name: "不可变性检查"
      tool: "eslint-plugin-immutable"
      severity: "HIGH"
      failOn: ["mutation detected"]

    # 8. 错误处理
    - name: "错误处理检查"
      tool: "eslint-plugin-promise"
      severity: "HIGH"
      failOn: ["unhandled promise rejection"]

  passCriteria:
    - "无 CRITICAL 问题"
    - "无 HIGH 问题"
    - "MEDIUM 问题 < 5 个"

  onFailure:
    action: "block"
    notification:
      level: "P1"
      message: "代码质量门禁未通过，请修复问题后重新检查"
```

### 实现脚本

```javascript
// .unified/quality-gates/code-quality-gate.js

const { execSync } = require('child_process');

class CodeQualityGate {
  constructor(config) {
    this.config = config;
    this.results = [];
  }

  async execute() {
    console.log('🔍 执行代码质量门禁检查...\n');

    for (const check of this.config.checks) {
      const result = await this.runCheck(check);
      this.results.push(result);

      if (!result.passed && check.severity === 'CRITICAL') {
        console.log(`❌ CRITICAL 问题：${check.name}`);
        return this.fail();
      }
    }

    return this.evaluate();
  }

  async runCheck(check) {
    console.log(`  检查：${check.name}...`);

    try {
      const output = execSync(check.command, { encoding: 'utf-8' });
      const passed = this.evaluateOutput(output, check);

      console.log(passed ? '  ✅ 通过' : '  ❌ 失败');

      return {
        name: check.name,
        passed,
        severity: check.severity,
        output
      };
    } catch (error) {
      console.log('  ❌ 失败');
      return {
        name: check.name,
        passed: false,
        severity: check.severity,
        error: error.message
      };
    }
  }

  evaluateOutput(output, check) {
    // 根据 failOn 条件评估输出
    for (const condition of check.failOn) {
      if (output.includes(condition)) {
        return false;
      }
    }
    return true;
  }

  evaluate() {
    const critical = this.results.filter(r => !r.passed && r.severity === 'CRITICAL');
    const high = this.results.filter(r => !r.passed && r.severity === 'HIGH');
    const medium = this.results.filter(r => !r.passed && r.severity === 'MEDIUM');

    console.log('\n📊 检查结果：');
    console.log(`  CRITICAL: ${critical.length}`);
    console.log(`  HIGH: ${high.length}`);
    console.log(`  MEDIUM: ${medium.length}`);

    if (critical.length > 0 || high.length > 0 || medium.length >= 5) {
      return this.fail();
    }

    return this.pass();
  }

  pass() {
    console.log('\n✅ 代码质量门禁通过\n');
    return { success: true, gate: 'code-quality', results: this.results };
  }

  fail() {
    console.log('\n❌ 代码质量门禁未通过\n');
    return { success: false, gate: 'code-quality', results: this.results };
  }
}

module.exports = CodeQualityGate;
```

---

## 🔍 门禁 2：API 完整性门禁

### 检查清单

```yaml
# .unified/quality-gates/api-completeness-gate.yaml

api-completeness-gate:
  name: "API 完整性门禁"
  phase: 5
  trigger: "post-development"

  checks:
    # 1. Mock 接口检查
    - name: "Mock 接口标记检查"
      tool: "grep"
      command: "grep -r '// ⚠️ MOCK:' src/"
      severity: "CRITICAL"
      failOn: ["found"]
      message: "发现未移除的 Mock 接口"

    # 2. API 覆盖率
    - name: "API 覆盖率检查"
      tool: "custom"
      threshold: 100
      severity: "CRITICAL"
      failOn: ["coverage < 100%"]

    # 3. 数据验证
    - name: "数据验证检查"
      tool: "eslint-plugin-validation"
      severity: "HIGH"
      failOn: ["missing validation"]

    # 4. 错误处理
    - name: "错误处理检查"
      tool: "eslint-plugin-error-handling"
      severity: "HIGH"
      failOn: ["missing error handler"]

    # 5. 端口冲突
    - name: "端口冲突检查"
      tool: "lsof"
      command: "lsof -i :3000 -i :8000"
      severity: "HIGH"
      failOn: ["port in use"]

  passCriteria:
    - "无 Mock 接口"
    - "API 覆盖率 100%"
    - "所有 API 有数据验证"
    - "所有 API 有错误处理"
    - "无端口冲突"

  onFailure:
    action: "block"
    notification:
      level: "P1"
      message: "API 完整性门禁未通过，请补充缺失 API"
```

### 实现脚本

```javascript
// .unified/quality-gates/api-completeness-gate.js

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

class ApiCompletenessGate {
  constructor(config) {
    this.config = config;
    this.results = [];
  }

  async execute() {
    console.log('🔍 执行 API 完整性门禁检查...\n');

    // 1. Mock 接口检查
    const mockCheck = await this.checkMockInterfaces();
    this.results.push(mockCheck);

    // 2. API 覆盖率检查
    const coverageCheck = await this.checkApiCoverage();
    this.results.push(coverageCheck);

    // 3. 数据验证检查
    const validationCheck = await this.checkDataValidation();
    this.results.push(validationCheck);

    // 4. 错误处理检查
    const errorHandlingCheck = await this.checkErrorHandling();
    this.results.push(errorHandlingCheck);

    // 5. 端口冲突检查
    const portCheck = await this.checkPortConflicts();
    this.results.push(portCheck);

    return this.evaluate();
  }

  async checkMockInterfaces() {
    console.log('  检查：Mock 接口标记...');

    try {
      const output = execSync('grep -r "// ⚠️ MOCK:" src/', { encoding: 'utf-8' });

      if (output.trim()) {
        console.log('  ❌ 发现 Mock 接口');
        console.log(output);
        return { name: 'Mock 接口检查', passed: false, severity: 'CRITICAL' };
      }

      console.log('  ✅ 无 Mock 接口');
      return { name: 'Mock 接口检查', passed: true, severity: 'CRITICAL' };
    } catch (error) {
      // grep 未找到匹配时会返回非零退出码
      console.log('  ✅ 无 Mock 接口');
      return { name: 'Mock 接口检查', passed: true, severity: 'CRITICAL' };
    }
  }

  async checkApiCoverage() {
    console.log('  检查：API 覆盖率...');

    // 读取 API 定义和实现
    const apiSpec = this.readApiSpec();
    const apiImpl = this.readApiImpl();

    const coverage = (apiImpl.length / apiSpec.length) * 100;
    const passed = coverage >= 100;

    console.log(`  API 覆盖率：${coverage.toFixed(2)}%`);
    console.log(passed ? '  ✅ 通过' : '  ❌ 失败');

    return {
      name: 'API 覆盖率检查',
      passed,
      severity: 'CRITICAL',
      coverage
    };
  }

  async checkDataValidation() {
    console.log('  检查：数据验证...');

    // 检查所有 API 是否有数据验证
    const apis = this.readApiImpl();
    const missingValidation = apis.filter(api => !this.hasValidation(api));

    const passed = missingValidation.length === 0;

    console.log(passed ? '  ✅ 通过' : `  ❌ 失败（${missingValidation.length} 个 API 缺少验证）`);

    return {
      name: '数据验证检查',
      passed,
      severity: 'HIGH',
      missingValidation
    };
  }

  async checkErrorHandling() {
    console.log('  检查：错误处理...');

    // 检查所有 API 是否有错误处理
    const apis = this.readApiImpl();
    const missingErrorHandling = apis.filter(api => !this.hasErrorHandling(api));

    const passed = missingErrorHandling.length === 0;

    console.log(passed ? '  ✅ 通过' : `  ❌ 失败（${missingErrorHandling.length} 个 API 缺少错误处理）`);

    return {
      name: '错误处理检查',
      passed,
      severity: 'HIGH',
      missingErrorHandling
    };
  }

  async checkPortConflicts() {
    console.log('  检查：端口冲突...');

    const ports = [3000, 8000, 5173]; // 常用端口
    const conflicts = [];

    for (const port of ports) {
      try {
        const output = execSync(`lsof -i :${port}`, { encoding: 'utf-8' });
        if (output.trim()) {
          conflicts.push({ port, process: output });
        }
      } catch (error) {
        // 端口未占用
      }
    }

    const passed = conflicts.length === 0;

    console.log(passed ? '  ✅ 无端口冲突' : `  ❌ 发现 ${conflicts.length} 个端口冲突`);

    return {
      name: '端口冲突检查',
      passed,
      severity: 'HIGH',
      conflicts
    };
  }

  readApiSpec() {
    // 读取 API 规范（如 OpenAPI/Swagger）
    return []; // 示例
  }

  readApiImpl() {
    // 读取 API 实现
    return []; // 示例
  }

  hasValidation(api) {
    // 检查 API 是否有数据验证
    return true; // 示例
  }

  hasErrorHandling(api) {
    // 检查 API 是否有错误处理
    return true; // 示例
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
    console.log('\n✅ API 完整性门禁通过\n');
    return { success: true, gate: 'api-completeness', results: this.results };
  }

  fail() {
    console.log('\n❌ API 完整性门禁未通过\n');
    return { success: false, gate: 'api-completeness', results: this.results };
  }
}

module.exports = ApiCompletenessGate;
```

---

## 🔍 门禁 3：安全性门禁

### 检查清单

```yaml
# .unified/quality-gates/security-gate.yaml

security-gate:
  name: "安全性门禁"
  phase: 7
  trigger: "post-testing"

  checks:
    # 1. 认证与授权
    - name: "认证与授权检查"
      areas:
        - "JWT Token 验证"
        - "OAuth 流程"
        - "权限控制"
        - "会话管理"
      severity: "CRITICAL"

    # 2. 输入验证
    - name: "输入验证检查"
      areas:
        - "SQL 注入防护"
        - "XSS 防护"
        - "CSRF 防护"
        - "参数验证"
      severity: "CRITICAL"

    # 3. 数据安全
    - name: "数据安全检查"
      areas:
        - "敏感数据加密"
        - "密码哈希"
        - "数据脱敏"
        - "传输加密（HTTPS）"
      severity: "CRITICAL"

    # 4. API 安全
    - name: "API 安全检查"
      areas:
        - "CORS 配置"
        - "Rate Limiting"
        - "API Key 管理"
        - "请求签名"
      severity: "HIGH"

    # 5. 依赖安全
    - name: "依赖安全检查"
      tool: "npm audit"
      command: "npm audit --audit-level=high"
      severity: "HIGH"
      failOn: ["high", "critical"]

    # 6. 配置安全
    - name: "配置安全检查"
      areas:
        - "Secrets 检查"
        - "环境变量"
        - ".env 文件"
        - "配置文件权限"
      severity: "CRITICAL"

  passCriteria:
    - "无 CRITICAL 漏洞"
    - "无 HIGH 漏洞"
    - "所有 API 有认证"
    - "所有输入有验证"
    - "敏感数据已加密"

  onFailure:
    action: "block"
    notification:
      level: "P0"
      message: "安全性门禁未通过，存在安全漏洞"
```

---

## 🔍 门禁 4：最终质量门禁

### 检查清单

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

---

## 🔧 质量门禁引擎

```javascript
// .unified/quality-gates/quality-gate-engine.js

const CodeQualityGate = require('./code-quality-gate');
const ApiCompletenessGate = require('./api-completeness-gate');
const SecurityGate = require('./security-gate');
const FinalQualityGate = require('./final-quality-gate');

class QualityGateEngine {
  constructor() {
    this.gates = {
      'code-quality': new CodeQualityGate(),
      'api-completeness': new ApiCompletenessGate(),
      'security': new SecurityGate(),
      'final-quality': new FinalQualityGate()
    };
    this.results = [];
  }

  async executeGate(gateName) {
    console.log(`\n${'='.repeat(60)}`);
    console.log(`  执行质量门禁：${gateName}`);
    console.log(`${'='.repeat(60)}\n`);

    const gate = this.gates[gateName];
    if (!gate) {
      throw new Error(`未知的质量门禁：${gateName}`);
    }

    const result = await gate.execute();
    this.results.push({ gate: gateName, ...result });

    return result;
  }

  async executeAll() {
    console.log('\n🚀 开始执行所有质量门禁...\n');

    for (const gateName of Object.keys(this.gates)) {
      const result = await this.executeGate(gateName);

      if (!result.success) {
        console.log(`\n❌ 质量门禁失败：${gateName}`);
        return this.fail(gateName);
      }
    }

    return this.pass();
  }

  pass() {
    console.log('\n' + '='.repeat(60));
    console.log('  ✅ 所有质量门禁通过');
    console.log('='.repeat(60) + '\n');

    return {
      success: true,
      results: this.results
    };
  }

  fail(failedGate) {
    console.log('\n' + '='.repeat(60));
    console.log(`  ❌ 质量门禁失败：${failedGate}`);
    console.log('='.repeat(60) + '\n');

    return {
      success: false,
      failedGate,
      results: this.results
    };
  }
}

module.exports = QualityGateEngine;
```

---

## 📊 质量门禁监控

### 监控指标

| 指标 | 说明 | 目标值 |
|------|------|--------|
| **门禁通过率** | 首次通过门禁的比例 | 90%+ |
| **平均修复时间** | 门禁失败到修复的平均时间 | < 30 分钟 |
| **重复失败率** | 同一问题重复失败的比例 | < 5% |
| **门禁执行时间** | 单个门禁平均执行时长 | < 5 分钟 |

---

## 🔗 相关文档

- [工作流整合方案](./workflow-integration.md)
- [端到端测试方案](./e2e-testing-plan.md)（待创建）
- [Agent 注册表](../agents/agent-registry.md)

---

*版本：1.0.0*
*创建日期：2026-03-08*
*预计实施时间：1 周*

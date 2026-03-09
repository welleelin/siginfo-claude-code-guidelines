/**
 * 质量门禁引擎 (QualityGateEngine)
 * =============================================================================
 * 版本: 1.0.0
 * 用途: 统一的质量门禁检查引擎，实现四道质量门禁
 * =============================================================================
 */

const { execSync } = require('child_process');

// =============================================================================
// 配置
// =============================================================================

const GATE_CONFIG = {
    'code-quality': {
        name: '代码质量门禁',
        phase: 3,
        trigger: 'pre-development',
        checks: [
            {
                name: '代码规范检查',
                tool: 'eslint',
                command: 'npm run lint',
                severity: 'CRITICAL',
                failOn: ['error']
            },
            {
                name: '代码格式检查',
                tool: 'prettier',
                command: 'npm run format:check',
                severity: 'HIGH',
                failOn: ['error']
            },
            {
                name: '代码复杂度检查',
                tool: 'complexity',
                command: 'npm run complexity',
                severity: 'HIGH',
                threshold: 10,
                failOn: ['exceed']
            },
            {
                name: '代码重复率检查',
                tool: 'duplication',
                command: 'npm run duplication',
                severity: 'MEDIUM',
                threshold: 5,
                failOn: ['exceed']
            },
            {
                name: '函数长度检查',
                tool: 'function-length',
                command: 'npm run function-length',
                severity: 'MEDIUM',
                threshold: 50,
                failOn: ['exceed']
            },
            {
                name: '文件大小检查',
                tool: 'file-size',
                command: 'npm run file-size',
                severity: 'MEDIUM',
                threshold: 800,
                failOn: ['exceed']
            }
        ],
        passCriteria: {
            noCritical: true,
            noHigh: true,
            maxMedium: 5
        }
    },
    'api-completeness': {
        name: 'API 完整性门禁',
        phase: 5,
        trigger: 'post-development',
        checks: [
            {
                name: 'Mock 接口检查',
                tool: 'grep',
                command: 'grep -r "// ⚠️ MOCK:" src/',
                severity: 'CRITICAL',
                expectedOutput: '',
                failOn: ['found']
            },
            {
                name: 'API 覆盖率检查',
                tool: 'api-coverage',
                command: 'npm run api-coverage',
                severity: 'CRITICAL',
                threshold: 100,
                failOn: ['below']
            },
            {
                name: '数据验证检查',
                tool: 'validation',
                command: 'npm run validation-check',
                severity: 'HIGH',
                failOn: ['missing']
            },
            {
                name: '错误处理检查',
                tool: 'error-handling',
                command: 'npm run error-handling-check',
                severity: 'HIGH',
                failOn: ['missing']
            },
            {
                name: '端口冲突检查',
                tool: 'port-check',
                command: 'npm run port-check',
                severity: 'MEDIUM',
                failOn: ['conflict']
            }
        ],
        passCriteria: {
            noCritical: true,
            noHigh: true,
            noMock: true
        }
    },
    'security': {
        name: '安全性门禁',
        phase: 7,
        trigger: 'post-testing',
        checks: [
            {
                name: '认证与授权检查',
                tool: 'auth-check',
                command: 'npm run auth-check',
                severity: 'CRITICAL',
                failOn: ['missing', 'weak']
            },
            {
                name: '输入验证检查',
                tool: 'input-validation',
                command: 'npm run input-validation-check',
                severity: 'CRITICAL',
                failOn: ['sql-injection', 'xss']
            },
            {
                name: '数据安全检查',
                tool: 'data-security',
                command: 'npm run data-security-check',
                severity: 'HIGH',
                failOn: ['unencrypted', 'leaked']
            },
            {
                name: 'API 安全检查',
                tool: 'api-security',
                command: 'npm run api-security-check',
                severity: 'HIGH',
                failOn: ['cors', 'csrf', 'rate-limit']
            },
            {
                name: '依赖安全检查',
                tool: 'npm-audit',
                command: 'npm audit',
                severity: 'HIGH',
                failOn: ['vulnerability']
            },
            {
                name: '配置安全检查',
                tool: 'config-security',
                command: 'npm run config-security-check',
                severity: 'CRITICAL',
                failOn: ['secrets-exposed']
            }
        ],
        passCriteria: {
            noCritical: true,
            noHigh: true
        }
    },
    'final-quality': {
        name: '最终质量门禁',
        phase: 8,
        trigger: 'pre-commit',
        checks: [
            {
                name: '测试覆盖率检查',
                tool: 'coverage',
                command: 'npm run test:coverage',
                severity: 'CRITICAL',
                threshold: 80,
                failOn: ['below']
            },
            {
                name: '测试通过率检查',
                tool: 'test-pass-rate',
                command: 'npm test',
                severity: 'CRITICAL',
                threshold: 100,
                failOn: ['failed']
            },
            {
                name: '构建检查',
                tool: 'build',
                command: 'npm run build',
                severity: 'CRITICAL',
                failOn: ['failed']
            },
            {
                name: '文档完整性检查',
                tool: 'doc-check',
                command: 'npm run doc-check',
                severity: 'MEDIUM',
                failOn: ['missing']
            },
            {
                name: '代码审查检查',
                tool: 'code-review',
                command: 'npm run code-review-check',
                severity: 'HIGH',
                failOn: ['pending', 'changes-requested']
            },
            {
                name: '所有门禁检查',
                tool: 'all-gates',
                command: 'npm run all-gates-check',
                severity: 'CRITICAL',
                failOn: ['failed']
            }
        ],
        passCriteria: {
            noCritical: true,
            noHigh: true,
            coverageMin: 80,
            testPassRate: 100,
            buildSuccess: true
        }
    }
};

// =============================================================================
// 检查执行器
// =============================================================================

class CheckExecutor {
    /**
     * 执行单个检查
     * @param {Object} check - 检查配置
     * @returns {Object} 检查结果
     */
    execute(check) {
        try {
            const output = execSync(check.command, {
                encoding: 'utf-8',
                cwd: process.cwd(),
                timeout: 60000 // 1 分钟超时
            });

            return this.evaluateOutput(output, check);
        } catch (error) {
            // 命令执行失败
            return {
                name: check.name,
                passed: false,
                severity: check.severity,
                error: error.message,
                output: error.stdout || error.stderr
            };
        }
    }

    /**
     * 评估输出
     * @param {string} output - 命令输出
     * @param {Object} check - 检查配置
     * @returns {Object} 评估结果
     */
    evaluateOutput(output, check) {
        const result = {
            name: check.name,
            severity: check.severity,
            output: output
        };

        // 检查失败条件
        if (check.failOn) {
            for (const condition of check.failOn) {
                if (this.checkCondition(output, condition, check)) {
                    result.passed = false;
                    result.reason = `失败条件满足: ${condition}`;
                    return result;
                }
            }
        }

        // 检查阈值
        if (check.threshold) {
            const value = this.extractValue(output, check.tool);
            if (value !== null) {
                if (check.failOn.includes('exceed') && value > check.threshold) {
                    result.passed = false;
                    result.reason = `阈值超限: ${value} > ${check.threshold}`;
                    result.value = value;
                    return result;
                }
                if (check.failOn.includes('below') && value < check.threshold) {
                    result.passed = false;
                    result.reason = `阈值不足: ${value} < ${check.threshold}`;
                    result.value = value;
                    return result;
                }
            }
        }

        result.passed = true;
        return result;
    }

    /**
     * 检查条件
     */
    checkCondition(output, condition, check) {
        switch (condition) {
            case 'error':
                return output.includes('error') || output.includes('Error');
            case 'found':
                return output.length > 0;
            case 'missing':
                return output.includes('missing') || output.includes('not found');
            case 'failed':
                return output.includes('failed') || output.includes('FAIL');
            case 'pending':
                return output.includes('pending');
            case 'changes-requested':
                return output.includes('changes requested');
            case 'vulnerability':
                return output.includes('vulnerability') || output.includes('vulnerable');
            case 'secrets-exposed':
                return output.includes('secret') || output.includes('api_key') || output.includes('password');
            case 'sql-injection':
                return output.includes('SQL injection') || output.includes('sql injection');
            case 'xss':
                return output.includes('XSS') || output.includes('Cross-Site Scripting');
            case 'cors':
                return output.includes('CORS') && !output.includes('CORS configured');
            case 'csrf':
                return output.includes('CSRF') && !output.includes('CSRF token');
            case 'rate-limit':
                return !output.includes('rate limit');
            case 'unencrypted':
                return output.includes('unencrypted') || !output.includes('encrypted');
            case 'leaked':
                return output.includes('leaked') || output.includes('exposed');
            case 'weak':
                return output.includes('weak') || output.includes('insecure');
            case 'conflict':
                return output.includes('conflict') || output.includes('in use');
            default:
                return false;
        }
    }

    /**
     * 从输出中提取值
     */
    extractValue(output, tool) {
        // 根据不同工具提取数值
        const patterns = {
            'coverage': /coverage[:\s]+(\d+(?:\.\d+)?)%?/i,
            'complexity': /complexity[:\s]+(\d+)/i,
            'duplication': /duplication[:\s]+(\d+(?:\.\d+)?)%?/i,
            'function-length': /max function length[:\s]+(\d+)/i,
            'file-size': /max file size[:\s]+(\d+)/i,
            'api-coverage': /api coverage[:\s]+(\d+(?:\.\d+)?)%?/i
        };

        const pattern = patterns[tool];
        if (pattern) {
            const match = output.match(pattern);
            if (match) {
                return parseFloat(match[1]);
            }
        }

        return null;
    }
}

// =============================================================================
// 质量门禁
// =============================================================================

class QualityGate {
    constructor(name, config) {
        this.name = name;
        this.config = config;
        this.executor = new CheckExecutor();
        this.results = [];
    }

    /**
     * 执行门禁检查
     * @returns {Object} 检查结果
     */
    async execute() {
        console.log(`\n🔍 执行 ${this.config.name}...`);
        console.log(`   Phase: ${this.config.phase}`);
        console.log(`   检查项: ${this.config.checks.length} 个`);
        console.log('');

        for (const check of this.config.checks) {
            console.log(`   ▶ ${check.name}...`);
            const result = this.executor.execute(check);
            this.results.push(result);

            if (result.passed) {
                console.log(`     ✅ 通过`);
            } else {
                console.log(`     ❌ 失败 (${result.severity})`);
                if (result.reason) {
                    console.log(`        原因: ${result.reason}`);
                }

                // CRITICAL 问题立即返回
                if (check.severity === 'CRITICAL') {
                    return this.fail();
                }
            }
        }

        return this.evaluate();
    }

    /**
     * 评估结果
     * @returns {Object} 评估结果
     */
    evaluate() {
        const critical = this.results.filter(r => !r.passed && r.severity === 'CRITICAL');
        const high = this.results.filter(r => !r.passed && r.severity === 'HIGH');
        const medium = this.results.filter(r => !r.passed && r.severity === 'MEDIUM');

        const criteria = this.config.passCriteria;

        // 检查通过标准
        if (criteria.noCritical && critical.length > 0) {
            return this.fail(`发现 ${critical.length} 个 CRITICAL 问题`);
        }
        if (criteria.noHigh && high.length > 0) {
            return this.fail(`发现 ${high.length} 个 HIGH 问题`);
        }
        if (criteria.maxMedium && medium.length >= criteria.maxMedium) {
            return this.fail(`发现 ${medium.length} 个 MEDIUM 问题（最大允许 ${criteria.maxMedium}）`);
        }

        return this.pass();
    }

    /**
     * 通过
     */
    pass() {
        console.log(`\n✅ ${this.config.name} 通过`);
        return {
            success: true,
            gate: this.name,
            results: this.results,
            summary: {
                total: this.results.length,
                passed: this.results.filter(r => r.passed).length,
                failed: this.results.filter(r => !r.passed).length
            }
        };
    }

    /**
     * 失败
     */
    fail(reason = '') {
        console.log(`\n❌ ${this.config.name} 未通过`);
        if (reason) {
            console.log(`   原因: ${reason}`);
        }
        return {
            success: false,
            gate: this.name,
            reason: reason,
            results: this.results,
            summary: {
                total: this.results.length,
                passed: this.results.filter(r => r.passed).length,
                failed: this.results.filter(r => !r.passed).length,
                critical: this.results.filter(r => !r.passed && r.severity === 'CRITICAL').length,
                high: this.results.filter(r => !r.passed && r.severity === 'HIGH').length,
                medium: this.results.filter(r => !r.passed && r.severity === 'MEDIUM').length
            }
        };
    }
}

// =============================================================================
// 质量门禁引擎
// =============================================================================

class QualityGateEngine {
    constructor(config = GATE_CONFIG) {
        this.config = config;
        this.gates = {};
        this.results = [];

        // 初始化所有门禁
        for (const [name, gateConfig] of Object.entries(config)) {
            this.gates[name] = new QualityGate(name, gateConfig);
        }
    }

    /**
     * 执行单个门禁
     * @param {string} gateName - 门禁名称
     * @returns {Object} 检查结果
     */
    async executeGate(gateName) {
        const gate = this.gates[gateName];
        if (!gate) {
            throw new Error(`未知的质量门禁: ${gateName}`);
        }

        const result = await gate.execute();
        this.results.push({ gate: gateName, ...result });
        return result;
    }

    /**
     * 执行所有门禁
     * @returns {Object} 总体结果
     */
    async executeAll() {
        console.log('\n═══════════════════════════════════════════════════════════════════');
        console.log('  执行所有质量门禁检查');
        console.log('═══════════════════════════════════════════════════════════════════');

        const gateOrder = ['code-quality', 'api-completeness', 'security', 'final-quality'];

        for (const gateName of gateOrder) {
            const result = await this.executeGate(gateName);
            if (!result.success) {
                return this.fail(gateName, result);
            }
        }

        return this.pass();
    }

    /**
     * 执行指定阶段的门禁
     * @param {number} phase - 阶段号
     * @returns {Object} 检查结果
     */
    async executePhase(phase) {
        const phaseGates = {
            3: 'code-quality',
            5: 'api-completeness',
            7: 'security',
            8: 'final-quality'
        };

        const gateName = phaseGates[phase];
        if (!gateName) {
            throw new Error(`Phase ${phase} 没有对应的质量门禁`);
        }

        return await this.executeGate(gateName);
    }

    /**
     * 获取门禁状态
     * @param {string} gateName - 门禁名称
     * @returns {Object} 门禁状态
     */
    getGateStatus(gateName) {
        const result = this.results.find(r => r.gate === gateName);
        if (!result) {
            return { status: 'not_executed' };
        }
        return {
            status: result.success ? 'passed' : 'failed',
            ...result
        };
    }

    /**
     * 获取总体状态
     * @returns {Object} 总体状态
     */
    getOverallStatus() {
        const executed = this.results.length;
        const passed = this.results.filter(r => r.success).length;
        const failed = this.results.filter(r => !r.success).length;

        return {
            total: Object.keys(this.gates).length,
            executed: executed,
            passed: passed,
            failed: failed,
            success: failed === 0 && executed === Object.keys(this.gates).length
        };
    }

    /**
     * 通过
     */
    pass() {
        console.log('\n═══════════════════════════════════════════════════════════════════');
        console.log('  ✅ 所有质量门禁通过');
        console.log('═══════════════════════════════════════════════════════════════════');

        return {
            success: true,
            gates: this.results,
            summary: this.getOverallStatus()
        };
    }

    /**
     * 失败
     */
    fail(gateName, result) {
        console.log('\n═══════════════════════════════════════════════════════════════════');
        console.log(`  ❌ 质量门禁未通过: ${gateName}`);
        console.log('═══════════════════════════════════════════════════════════════════');

        return {
            success: false,
            failedGate: gateName,
            reason: result.reason,
            gates: this.results,
            summary: this.getOverallStatus()
        };
    }
}

// =============================================================================
// 导出
// =============================================================================

module.exports = {
    QualityGateEngine,
    QualityGate,
    CheckExecutor,
    GATE_CONFIG
};

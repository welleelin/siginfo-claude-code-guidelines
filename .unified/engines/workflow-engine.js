/**
 * 工作流引擎 (WorkflowEngine)
 * =============================================================================
 * 版本: 1.0.0
 * 用途: 统一的工作流编排引擎，支持 Quick/Standard/Enterprise 三种工作流
 * =============================================================================
 */

const path = require('path');
const fs = require('fs');

// =============================================================================
// 配置
// =============================================================================

const CONFIG = {
    workflows: {
        'quick-flow': {
            name: 'Quick Flow',
            description: '快速开发流程（< 2小时）',
            maxDuration: 7200, // 2 小时（秒）
            phases: [
                { name: 'task_input', description: '任务输入', auto: true },
                { name: 'quick_planning', description: '快速规划', auto: true, maxTime: 300 },
                { name: 'quick_development', description: '快速开发', auto: true, maxTime: 2400 },
                { name: 'verification', description: '验证', auto: true, maxTime: 600 },
                { name: 'quality_check', description: '质量检查', auto: true, maxTime: 300 }
            ],
            humanConfirmPoints: []
        },
        'standard-flow': {
            name: 'Standard Flow',
            description: '标准开发流程（2-8小时）',
            minDuration: 7200,
            maxDuration: 28800, // 8 小时（秒）
            phases: [
                { name: 'session_startup', description: '会话启动准备', auto: true },
                { name: 'planning', description: '任务规划', auto: false, humanConfirm: true },
                { name: 'code_quality_gate', description: '代码质量检查', auto: true, qualityGate: true },
                { name: 'tdd_development', description: 'TDD 开发', auto: true },
                { name: 'api_completeness_gate', description: 'API 完整性检查', auto: true, qualityGate: true },
                { name: 'e2e_testing', description: 'E2E 测试', auto: true },
                { name: 'security_gate', description: '安全性检查', auto: true, qualityGate: true },
                { name: 'final_quality_gate', description: '最终质量门禁', auto: true, qualityGate: true }
            ],
            humanConfirmPoints: ['planning']
        },
        'enterprise-flow': {
            name: 'Enterprise Flow',
            description: '企业级开发流程（> 8小时）',
            minDuration: 28800,
            phases: [
                { name: 'analysis', description: '分析阶段', auto: true, commands: ['brainstorming', 'domain-research', 'market-research', 'product-brief'] },
                { name: 'planning', description: '规划阶段', auto: false, humanConfirm: true, commands: ['create-prd', 'create-ux-design'] },
                { name: 'solutioning', description: '方案设计阶段', auto: true, commands: ['create-architecture', 'create-epics-and-stories', 'check-implementation-readiness'] },
                { name: 'implementation', description: '实现阶段', auto: true, loop: true, commands: ['sprint-planning', 'create-story', 'dev-story', 'code-review', 'verify'] },
                { name: 'quality_assurance', description: '质量保障阶段', auto: true, commands: ['api-completeness', 'e2e', 'security-review', 'quality-gate'] }
            ],
            humanConfirmPoints: ['planning', 'solutioning']
        }
    },
    routing: {
        complexityThresholds: {
            quick: 2,    // < 2 使用 Quick Flow
            standard: 8   // < 8 使用 Standard Flow
        },
        teamSizeModes: {
            solo: 'autopilot',
            small: 'team',
            large: 'ultrawork'
        }
    }
};

// =============================================================================
// 复杂度评估器
// =============================================================================

class ComplexityAssessor {
    /**
     * 评估任务复杂度
     * @param {Object} task - 任务对象
     * @returns {number} 复杂度分数 (0-15)
     */
    assess(task) {
        let score = 0;

        // 1. 文件数量评估
        const fileCount = task.files?.length || 0;
        if (fileCount > 10) score += 3;
        else if (fileCount > 5) score += 2;
        else if (fileCount > 1) score += 1;

        // 2. 代码行数评估
        const linesOfCode = task.linesOfCode || 0;
        if (linesOfCode > 500) score += 3;
        else if (linesOfCode > 200) score += 2;
        else if (linesOfCode > 50) score += 1;

        // 3. 依赖关系评估
        const dependencies = task.dependencies?.length || 0;
        if (dependencies > 5) score += 2;
        else if (dependencies > 2) score += 1;

        // 4. 新技术栈
        if (task.newTechStack) score += 2;

        // 5. 架构影响
        if (task.architecturalImpact) score += 3;

        return Math.min(score, 15);
    }

    /**
     * 根据复杂度选择工作流
     * @param {number} complexity - 复杂度分数
     * @returns {string} 工作流名称
     */
    selectWorkflow(complexity) {
        const thresholds = CONFIG.routing.complexityThresholds;

        if (complexity < thresholds.quick) {
            return 'quick-flow';
        } else if (complexity < thresholds.standard) {
            return 'standard-flow';
        } else {
            return 'enterprise-flow';
        }
    }
}

// =============================================================================
// 工作流执行器
// =============================================================================

class WorkflowExecutor {
    constructor(workflow, task) {
        this.workflow = workflow;
        this.task = task;
        this.currentPhase = 0;
        this.startTime = null;
        this.results = [];
    }

    /**
     * 执行工作流
     */
    async execute() {
        this.startTime = Date.now();
        console.log(`\n🚀 开始执行工作流: ${this.workflow.name}`);
        console.log(`   任务: ${this.task.description || this.task.title}`);
        console.log(`   阶段数: ${this.workflow.phases.length}`);
        console.log('');

        try {
            for (let i = 0; i < this.workflow.phases.length; i++) {
                this.currentPhase = i;
                const phase = this.workflow.phases[i];

                // 检查人类确认点
                if (phase.humanConfirm) {
                    await this.waitForHumanConfirm(phase);
                }

                // 执行阶段
                const result = await this.executePhase(phase, i + 1);
                this.results.push(result);

                // 检查质量门禁
                if (phase.qualityGate) {
                    const passed = await this.checkQualityGate(phase);
                    if (!passed) {
                        throw new Error(`质量门禁未通过: ${phase.name}`);
                    }
                }
            }

            const duration = this.calculateDuration();
            console.log(`\n✅ 工作流完成: ${this.workflow.name}`);
            console.log(`   总耗时: ${this.formatDuration(duration)}`);

            return {
                success: true,
                workflow: this.workflow.name,
                duration: duration,
                results: this.results
            };
        } catch (error) {
            console.error(`\n❌ 工作流失败: ${error.message}`);
            return {
                success: false,
                error: error.message,
                phase: this.currentPhase,
                results: this.results
            };
        }
    }

    /**
     * 执行单个阶段
     */
    async executePhase(phase, phaseNumber) {
        console.log(`\n📋 Phase ${phaseNumber}/${this.workflow.phases.length}: ${phase.description}`);

        const phaseStart = Date.now();

        // 检查是否是循环阶段
        if (phase.loop) {
            return await this.executeLoopPhase(phase, phaseNumber);
        }

        // 检查是否有并行命令
        if (phase.commands && phase.commands.length > 1) {
            return await this.executeParallelPhase(phase, phaseNumber);
        }

        // 顺序执行
        const result = await this.executeCommand(phase);
        const duration = Date.now() - phaseStart;

        console.log(`   ✅ 完成 (${this.formatDuration(duration)})`);

        return {
            phase: phase.name,
            success: true,
            duration: duration,
            output: result
        };
    }

    /**
     * 执行循环阶段
     */
    async executeLoopPhase(phase, phaseNumber) {
        console.log(`   🔄 循环执行阶段...`);

        const stories = this.task.stories || [];
        const results = [];

        for (let i = 0; i < stories.length; i++) {
            console.log(`   📝 Story ${i + 1}/${stories.length}: ${stories[i].title}`);
            const result = await this.executeCommand(phase, stories[i]);
            results.push(result);
        }

        return {
            phase: phase.name,
            success: true,
            iterations: stories.length,
            results: results
        };
    }

    /**
     * 执行并行阶段
     */
    async executeParallelPhase(phase, phaseNumber) {
        console.log(`   ⚡ 并行执行 ${phase.commands.length} 个命令...`);

        const promises = phase.commands.map(cmd => this.executeSingleCommand(cmd));
        const results = await Promise.all(promises);

        return {
            phase: phase.name,
            success: true,
            parallel: true,
            results: results
        };
    }

    /**
     * 执行命令
     */
    async executeCommand(phase, context = null) {
        // 模拟命令执行
        // 实际实现会调用 Claude CLI 或 Agent
        return new Promise((resolve) => {
            setTimeout(() => {
                resolve({
                    command: phase.name,
                    success: true,
                    context: context
                });
            }, 100);
        });
    }

    /**
     * 执行单个命令
     */
    async executeSingleCommand(command) {
        return new Promise((resolve) => {
            setTimeout(() => {
                resolve({
                    command: command,
                    success: true
                });
            }, 100);
        });
    }

    /**
     * 等待人类确认
     */
    async waitForHumanConfirm(phase) {
        console.log(`\n⏳ 等待人类确认: ${phase.description}`);
        console.log(`   请确认是否继续...`);

        // 实际实现会发送通知并等待确认
        // 这里模拟确认
        return new Promise((resolve) => {
            setTimeout(() => {
                console.log(`   ✅ 已确认`);
                resolve(true);
            }, 100);
        });
    }

    /**
     * 检查质量门禁
     */
    async checkQualityGate(phase) {
        console.log(`\n🔍 检查质量门禁: ${phase.description}`);

        // 实际实现会调用 QualityGateEngine
        return new Promise((resolve) => {
            setTimeout(() => {
                console.log(`   ✅ 质量门禁通过`);
                resolve(true);
            }, 100);
        });
    }

    /**
     * 计算总耗时
     */
    calculateDuration() {
        return Date.now() - this.startTime;
    }

    /**
     * 格式化时间
     */
    formatDuration(ms) {
        const seconds = Math.floor(ms / 1000);
        const minutes = Math.floor(seconds / 60);
        const hours = Math.floor(minutes / 60);

        if (hours > 0) {
            return `${hours}小时${minutes % 60}分钟`;
        } else if (minutes > 0) {
            return `${minutes}分钟${seconds % 60}秒`;
        } else {
            return `${seconds}秒`;
        }
    }
}

// =============================================================================
// 工作流引擎
// =============================================================================

class WorkflowEngine {
    constructor(config = CONFIG) {
        this.config = config;
        this.assessor = new ComplexityAssessor();
        this.currentWorkflow = null;
        this.currentExecutor = null;
    }

    /**
     * 选择工作流
     * @param {Object} task - 任务对象
     * @returns {Object} 工作流配置
     */
    selectWorkflow(task) {
        const complexity = this.assessor.assess(task);
        const workflowName = this.assessor.selectWorkflow(complexity);
        const workflow = this.config.workflows[workflowName];

        console.log(`\n📊 任务分析:`);
        console.log(`   复杂度: ${complexity}/15`);
        console.log(`   推荐工作流: ${workflow.name}`);
        console.log(`   预计时间: ${workflow.maxDuration ? this.formatDuration(workflow.maxDuration * 1000) : '灵活'}`);

        return {
            name: workflowName,
            config: workflow,
            complexity: complexity
        };
    }

    /**
     * 执行工作流
     * @param {Object} workflow - 工作流对象
     * @param {Object} task - 任务对象
     */
    async executeWorkflow(workflow, task) {
        this.currentWorkflow = workflow;
        this.currentExecutor = new WorkflowExecutor(workflow.config, task);
        return await this.currentExecutor.execute();
    }

    /**
     * 智能执行（自动选择并执行工作流）
     * @param {Object} task - 任务对象
     */
    async smartExecute(task) {
        const workflow = this.selectWorkflow(task);
        return await this.executeWorkflow(workflow, task);
    }

    /**
     * 获取工作流状态
     */
    getStatus() {
        if (!this.currentExecutor) {
            return { status: 'idle' };
        }

        return {
            status: this.currentExecutor.currentPhase < this.currentWorkflow.config.phases.length ? 'running' : 'completed',
            workflow: this.currentWorkflow.name,
            currentPhase: this.currentExecutor.currentPhase,
            totalPhases: this.currentWorkflow.config.phases.length,
            progress: Math.round((this.currentExecutor.currentPhase / this.currentWorkflow.config.phases.length) * 100),
            results: this.currentExecutor.results
        };
    }

    /**
     * 格式化时间
     */
    formatDuration(ms) {
        const seconds = Math.floor(ms / 1000);
        const minutes = Math.floor(seconds / 60);
        const hours = Math.floor(minutes / 60);

        if (hours > 0) {
            return `${hours}小时`;
        } else if (minutes > 0) {
            return `${minutes}分钟`;
        } else {
            return `${seconds}秒`;
        }
    }
}

// =============================================================================
// 导出
// =============================================================================

module.exports = {
    WorkflowEngine,
    WorkflowExecutor,
    ComplexityAssessor,
    CONFIG
};

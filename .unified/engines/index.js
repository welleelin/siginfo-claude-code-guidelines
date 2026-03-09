/**
 * 统一引擎入口
 * =============================================================================
 * 版本: 1.0.0
 * 用途: 提供统一的工作流引擎和质量门禁引擎入口
 * =============================================================================
 */

const { WorkflowEngine, WorkflowExecutor, ComplexityAssessor, CONFIG: WORKFLOW_CONFIG } = require('./workflow-engine');
const { QualityGateEngine, QualityGate, CheckExecutor, GATE_CONFIG } = require('./quality-gate-engine');

// =============================================================================
// 统一引擎类
// =============================================================================

class UnifiedEngine {
    constructor() {
        this.workflowEngine = new WorkflowEngine(WORKFLOW_CONFIG);
        this.qualityGateEngine = new QualityGateEngine(GATE_CONFIG);
    }

    /**
     * 智能执行（自动选择工作流并执行）
     * @param {Object} task - 任务对象
     * @returns {Object} 执行结果
     */
    async smartExecute(task) {
        // 1. 选择工作流
        const workflow = this.workflowEngine.selectWorkflow(task);

        // 2. 执行工作流
        const workflowResult = await this.workflowEngine.executeWorkflow(workflow, task);

        // 3. 如果工作流成功，执行最终质量门禁
        if (workflowResult.success) {
            const gateResult = await this.qualityGateEngine.executeAll();
            return {
                ...workflowResult,
                qualityGate: gateResult
            };
        }

        return workflowResult;
    }

    /**
     * 执行指定工作流
     * @param {string} workflowName - 工作流名称
     * @param {Object} task - 任务对象
     */
    async executeWorkflow(workflowName, task) {
        const workflow = {
            name: workflowName,
            config: WORKFLOW_CONFIG.workflows[workflowName]
        };
        return await this.workflowEngine.executeWorkflow(workflow, task);
    }

    /**
     * 执行指定质量门禁
     * @param {string} gateName - 门禁名称
     */
    async executeQualityGate(gateName) {
        return await this.qualityGateEngine.executeGate(gateName);
    }

    /**
     * 执行所有质量门禁
     */
    async executeAllQualityGates() {
        return await this.qualityGateEngine.executeAll();
    }

    /**
     * 获取状态
     */
    getStatus() {
        return {
            workflow: this.workflowEngine.getStatus(),
            qualityGates: this.qualityGateEngine.getOverallStatus()
        };
    }
}

// =============================================================================
// 导出
// =============================================================================

module.exports = {
    // 统一引擎
    UnifiedEngine,

    // 工作流引擎
    WorkflowEngine,
    WorkflowExecutor,
    ComplexityAssessor,
    WORKFLOW_CONFIG,

    // 质量门禁引擎
    QualityGateEngine,
    QualityGate,
    CheckExecutor,
    GATE_CONFIG
};

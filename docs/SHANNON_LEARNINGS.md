# Shannon 源代码学习经验总结

> **版本**：1.0.0
> **最后更新**：2026-03-10
> **GitHub**: https://github.com/KeygraphHQ/shannon

---

## 📋 概述

本文档总结了对 Shannon AI 渗透测试工具的源代码学习成果，包括架构设计、核心代码解读、设计模式和集成经验。

### 仓库信息

| 项目 | 详情 |
|------|------|
| **GitHub** | https://github.com/KeygraphHQ/shannon |
| **Stars** | 33,004+ |
| **许可证** | AGPL-3.0 |
| **主要语言** | TypeScript |
| **代码量** | 约 15,000 行 |
| **团队** | Keygraph (Yusuf/Abu/Usama) |

### 核心能力

- **96.15% 成功率** - 在 XBOW benchmark 上 100/104 exploits
- **1 小时完成测试** - 完整 5 阶段流水线
- **成本约$50/次** - 使用 Claude Sonnet
- **自主断点续传** - 故障后从中断处恢复

---

## 🏗️ 架构设计分析

### 1. 五阶段流水线架构

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Pre-Recon  │───▶│    Recon    │───▶│    Vuln     │───▶│   Exploit   │───▶│   Report    │
│  (侦察前)    │    │  (侦察)     │    │  (分析)     │    │  (利用)     │    │  (报告)     │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
     │                    │                    │                    │                    │
     ▼                    ▼                    ▼                    ▼                    ▼
 外部扫描              端点发现            5 Agent 并行          5 Agent 并行        Markdown 报告
 源码分析              API 文档             漏洞确认              PoC 生成           高管摘要
```

**阶段详细说明**：

| 阶段 | 职责 | 输出文件 | 模型层级 |
|------|------|----------|---------|
| **Pre-Recon** | 外部扫描 + 源码分析 | `code_analysis_deliverable.md` | Large (Opus) |
| **Recon** | 攻击面测绘 | `recon_deliverable.md` | Large (Opus) |
| **Vuln Analysis** | 5 类漏洞并行分析 | 各类 `vulnerability_analysis.md` | Large (Opus) |
| **Exploitation** | 5 类漏洞并行利用 | 各类 `exploit.md` + PoC 脚本 | Large (Opus) |
| **Report** | 生成最终报告 | `comprehensive_security_assessment_report.md` | Small (Haiku) |

**设计洞察**：
- 阶段之间有明确的输入/输出边界
- 每个阶段独立提交 Git commit，支持断点续传
- 报告阶段使用小模型降低成本（此时不需要深度推理）

---

### 2. 多 Agent 设计

Shannon 定义了 **13 个专用 Agent**，每个 Agent 有明确的职责和提示模板：

```typescript
// src/session-manager.ts 核心代码
export const AGENTS: Readonly<Record<AgentName, AgentDefinition>> = Object.freeze({
  'pre-recon': {
    name: 'pre-recon',
    promptTemplate: 'pre-recon-code',
    deliverableFilename: 'code_analysis_deliverable.md',
    modelTier: 'large',
  },
  'recon': { /* ... */ },

  // 5 个漏洞分析 Agent
  'injection-vuln': { /* SQL/NoSQL/命令注入 */ },
  'xss-vuln': { /* XSS/客户端漏洞 */ },
  'auth-vuln': { /* 认证漏洞 */ },
  'ssrf-vuln': { /* SSRF */ },
  'authz-vuln': { /* 授权漏洞 */ },

  // 5 个漏洞利用 Agent
  'injection-exploit': { /* 利用注入漏洞 */ },
  'xss-exploit': { /* 利用 XSS */ },
  'auth-exploit': { /* 利用认证漏洞 */ },
  'ssrf-exploit': { /* 利用 SSRF */ },
  'authz-exploit': { /* 利用授权漏洞 */ },

  'report': {
    name: 'report',
    promptTemplate: 'report-executive',
    deliverableFilename: 'comprehensive_security_assessment_report.md',
    modelTier: 'small',
  },
});
```

**设计洞察**：
- 漏洞分析 + 利用分离：先确认漏洞存在，再生成 PoC
- 按 OWASP 类别分工：覆盖主流漏洞类型
- 每个 Agent 有专属提示模板（20-28KB），确保专业性

---

### 3. MCP Agent 映射（浏览器自动化）

```typescript
// src/session-manager.ts
export const MCP_AGENT_MAPPING: Record<string, PlaywrightAgent> = Object.freeze({
  'pre-recon-code': 'playwright-agent1',
  'recon': 'playwright-agent2',
  'vuln-injection': 'playwright-agent1',
  'vuln-xss': 'playwright-agent2',
  'vuln-auth': 'playwright-agent3',
  'vuln-ssrf': 'playwright-agent4',
  'vuln-authz': 'playwright-agent5',
  // 利用阶段同理映射
});
```

**架构优势**：
- **5 个独立 Playwright 实例** - 支持并行执行
- **避免资源竞争** - 每个 Agent 独立浏览器上下文
- **提高吞吐量** - 漏洞分析阶段 5 个 Agent 同时执行

---

## 📦 核心代码模块

### 1. Agent 执行服务（9 步生命周期）

**文件**：`src/services/agent-execution.ts`

```typescript
export class AgentExecutionService {
  async execute(
    agentName: AgentName,
    input: AgentExecutionInput,
    auditSession: AuditSession,
    logger: ActivityLogger
  ): Promise<Result<AgentEndResult, PentestError>> {

    // Step 1: 加载配置（可选）
    const configResult = await this.configLoader.loadOptional(configPath);

    // Step 2: 加载提示模板
    const promptTemplate = AGENTS[agentName].promptTemplate;
    const prompt = await loadPrompt(promptTemplate, { webUrl, repoPath }, ...);

    // Step 3: 【关键】创建 Git 检查点（断点续传核心）
    await createGitCheckpoint(repoPath, agentName, attemptNumber, logger);

    // Step 4: 启动审计日志
    await auditSession.startAgent(agentName, prompt, attemptNumber);

    // Step 5: 执行 Agent（Claude Agent SDK）
    const result: ClaudePromptResult = await runClaudePrompt(prompt, repoPath, ...);

    // Step 6: 支出保护检查
    if (isSpendingCapBehavior(...)) {
      // 检测到触发支出上限，自动回滚
      await this.handleSpendingCap(...);
    }

    // Step 7: 处理执行失败
    if (!result.success) {
      return err(new PentestError('Agent 执行失败'));
    }

    // Step 8: 验证输出
    const validationPassed = await validateAgentOutput(result, agentName, repoPath, logger);

    // Step 9: 【关键】成功提交
    await commitGitSuccess(repoPath, agentName, logger);
    const commitHash = await getGitCommitHash(repoPath);

    return ok({
      agentName,
      commitHash,
      deliverables: [...],
      auditLog: [...]
    });
  }
}
```

**关键设计**：

| 步骤 | 设计意图 | 可复用模式 |
|------|---------|-----------|
| Step 3 | 执行前创建检查点 | 任何长任务都应先保存状态 |
| Step 6 | 支出保护 | 使用 API 时的成本控制 |
| Step 8 | 输出验证 | AI 生成内容的质量门禁 |
| Step 9 | 成功提交 | 原子性操作，要么全成功要么回滚 |

---

### 2. Git 检查点机制（断点续传）

**文件**：`src/services/git-checkpoint.ts`

```typescript
export async function createGitCheckpoint(
  repoPath: string,
  agentName: AgentName,
  attemptNumber: number,
  logger: ActivityLogger
): Promise<void> {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const commitMessage = `checkpoint: ${agentName} (attempt ${attemptNumber + 1}) - ${timestamp}`;

  // 1. 暂存所有更改
  await execAsync('git add -A', { cwd: repoPath });

  // 2. 创建提交
  await execAsync(`git commit -m "${commitMessage}"`, { cwd: repoPath });

  // 3. 记录检查点
  const commitHash = await getGitCommitHash(repoPath);
  logger.info(`✅ Checkpoint created: ${commitHash}`);

  return { commitHash, timestamp };
}

export async function restoreFromCheckpoint(
  repoPath: string,
  targetCommit: string
): Promise<void> {
  // 1. 重置到目标提交
  await execAsync(`git reset --hard ${targetCommit}`, { cwd: repoPath });

  // 2. 清理工作目录
  await execAsync('git clean -fd', { cwd: repoPath });

  logger.info(`✅ Restored to checkpoint: ${targetCommit}`);
}
```

**恢复流程**：

```bash
# Shannon 启动时自动检测未完成的工作空间
./shannon workspaces

# 输出示例：
# workspace-123 (状态：暂停于 vuln-injection)
# 最后检查点：abc123

# 恢复命令
./shannon resume workspace-123

# 内部执行：
# 1. 找到最近的 successful checkpoint
# 2. git reset --hard <commit>
# 3. 从下一个阶段继续执行
```

**可复用模式**：
- 任何耗时操作都应在执行前创建检查点
- 检查点命名包含时间戳和上下文信息
- 恢复时清理工作目录，确保状态干净

---

### 3. 提示加载器（Prompt Engineering）

**文件**：`src/prompts/load-prompt.ts`

```typescript
export async function loadPrompt(
  templateName: string,
  variables: Record<string, string>,
  sharedFragments?: Record<string, string>
): Promise<string> {
  // 1. 读取模板文件 (20-28KB)
  const template = await fs.readFile(
    `prompts/${templateName}.txt`,
    'utf-8'
  );

  // 2. 加载共享片段
  const shared = await loadSharedFragments(sharedFragments);

  // 3. 变量替换
  let prompt = template;
  for (const [key, value] of Object.entries(variables)) {
    prompt = prompt.replace(new RegExp(`\\{\\{${key}\\}\\}`, 'g'), value);
  }

  // 4. 注入共享片段
  prompt = injectSharedFragments(prompt, shared);

  // 5. 验证完整性
  validatePrompt(prompt, templateName);

  return prompt;
}
```

**提示模板结构**（以 `vuln-injection.txt` 为例）：

```
# 角色定义
你是一位专注于 Injection 类漏洞（SQL/NoSQL/命令注入）的高级渗透测试专家。

# 任务目标
分析目标应用，识别所有潜在 Injection 漏洞，并生成可验证的 PoC。

# 输入信息
- 目标 URL: {{webUrl}}
- 源码路径：{{repoPath}}
- Recon 报告：{{reconReport}}
- Pre-Recon 报告：{{preReconReport}}

# 共享片段 - 约束条件
{{CONSTRAINTS}}

# 共享片段 - 输出格式
{{OUTPUT_FORMAT}}

# 共享片段 - 评估标准
{{EVALUATION_CRITERIA}}

# 开始分析
...
```

**设计洞察**：
- 大模板（20-28KB）提供充分的上下文和指导
- 共享片段减少重复，保持一致性
- 变量替换支持动态注入运行时信息

---

### 4. 支出保护机制

**文件**：`src/services/spending-protection.ts`

```typescript
export function isSpendingCapBehavior(
  result: ClaudePromptResult,
  agentName: AgentName
): boolean {
  // 检测 Claude 返回的停止原因
  return (
    result.stopReason === 'end_turn' &&
    result.usage.outputTokens >= MAX_OUTPUT_TOKENS[agentName]
  );
}

export async function handleSpendingCap(
  agentName: AgentName,
  attemptNumber: number,
  logger: ActivityLogger
): Promise<void> {
  if (attemptNumber >= MAX_RETRIES) {
    throw new PentestError(
      `Agent ${agentName} 已达到支出上限，重试 ${MAX_RETRIES} 次后仍失败`
    );
  }

  logger.warn(`⚠️ ${agentName} 触发支出上限，准备重试...`);

  // 1. 回滚到检查点
  await restoreFromCheckpoint();

  // 2. 降低模型层级（大→中→小）
  const nextTier = downgradeModelTier(agentName);

  // 3. 重新执行
  return executeAgent(agentName, { modelTier: nextTier });
}
```

**模型层级定义**：

```typescript
export const MODEL_TIERS = {
  'large': { model: 'claude-3-7-sonnet-20250219', maxTokens: 64000 },
  'medium': { model: 'claude-3-5-sonnet-20241022', maxTokens: 32000 },
  'small': { model: 'claude-3-haiku-20240307', maxTokens: 16000 },
};
```

**可复用模式**：
- API 调用必须有预算保护
- 检测到超支时自动降级策略
- 重试前必须先回滚状态

---

## 🎯 设计模式与最佳实践

### 1. Result 类型（函数式错误处理）

```typescript
// src/types/result.ts
export type Result<T, E> =
  | { success: true; value: T }
  | { success: false; error: E };

// 使用示例
export function ok<T>(value: T): Result<T, never> {
  return { success: true, value };
}

export function err<E>(error: E): Result<never, E> {
  return { success: false, error };
}

// 在业务逻辑中使用
const result = await agentExecutionService.execute(...);
if (!result.success) {
  return err(result.error);
}
// TypeScript 自动推断 result.value 可用
const deliverables = result.value.deliverables;
```

**优势**：
- 强制错误处理，无法忽略
- 类型安全的错误传播
- 清晰的 success/failure 分支

---

### 2. 服务层隔离

```
src/
├── services/           # 业务逻辑层（Temporal 无关）
│   ├── agent-execution.ts
│   ├── config-parser.ts
│   ├── git-checkpoint.ts
│   └── spending-protection.ts
├── temporal/           # 工作流编排层
│   ├── workflows.ts    # Temporal 工作流定义
│   └── activities.ts   # Temporal Activity（薄封装）
├── session-manager.ts  # Agent 定义注册表
└── prompts/            # 提示模板
```

**分层优势**：
- 服务层可独立测试，不依赖 Temporal
- 工作流层仅做编排，不含业务逻辑
- 易于替换工作流引擎（如改用 Inngest）

---

### 3. 审计日志模式

```typescript
// src/services/audit-session.ts
export class AuditSession {
  async startAgent(
    agentName: string,
    prompt: string,
    attemptNumber: number
  ): Promise<void> {
    await this.db.insert('agent_runs', {
      workspace_id: this.workspaceId,
      agent_name: agentName,
      prompt_hash: await hash(prompt),
      attempt_number: attemptNumber,
      started_at: new Date(),
      status: 'running'
    });
  }

  async endAgent(
    agentName: string,
    result: Result<AgentEndResult, PentestError>
  ): Promise<void> {
    await this.db.update('agent_runs', {
      status: result.success ? 'completed' : 'failed',
      ended_at: new Date(),
      output_tokens: result.success ? result.value.tokens : 0,
      commit_hash: result.success ? result.value.commitHash : null
    });
  }
}
```

**审计内容**：
- 每次 Agent 执行的输入/输出
- Prompt 哈希（用于去重和成本分析）
- Token 使用量统计
- Git commit hash（用于追溯）

---

## 🔧 集成经验

### 1. Docker 配置

**docker-compose.yml** 核心配置：

```yaml
version: '3.8'

services:
  temporal:
    image: temporalio/temporal:latest
    ports:
      - "7233:7233"
    environment:
      - DB=postgresql
      - DB_PORT=5432

  worker:
    build: .
    depends_on:
      - temporal
    environment:
      - TEMPORAL_ADDRESS=temporal:7233
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - CLAUDE_CODE_MAX_OUTPUT_TOKENS=64000
    volumes:
      - ./workspaces:/app/workspaces
      - ./repos:/app/repos
```

**关键配置点**：
- Temporal 和 Worker 必须在一个网络
- API Key 通过环境变量注入
- 工作空间和数据卷持久化

---

### 2. 环境变量管理

**.env.example**：

```bash
# Anthropic API
ANTHROPIC_API_KEY=sk-ant-xxxxx

# 可选：AWS Bedrock（如使用）
AWS_ACCESS_KEY_ID=xxx
AWS_SECRET_ACCESS_KEY=xxx

# 可选：支出保护
CLAUDE_CODE_MAX_OUTPUT_TOKENS=64000
SHANNON_MAX_SPENDING_USD=100
```

**安全实践**：
- `.env` 文件加入 `.gitignore`
- 使用 `.env.example` 作为模板
- 生产环境使用密钥管理服务

---

### 3. 工作空间恢复

**工作空间目录结构**：

```
workspaces/
└── pentest-20260310/
    ├── workspace.json          # 工作空间元数据
    ├── config.yaml             # 本次测试配置
    ├── reports/                # 最终报告
    ├── logs/                   # 审计日志
    ├── checkpoints/            # Git 检查点
    └── repos/                  # 目标源码（克隆）
```

**恢复命令**：

```bash
# 查看所有工作空间
./shannon workspaces

# 恢复特定工作空间
./shannon resume pentest-20260310

# 内部逻辑：
# 1. 读取 workspace.json 获取状态
# 2. 找到最近的 checkpoint
# 3. git reset --hard <commit>
# 4. 从下一个阶段继续
```

---

## 📊 性能与成本分析

### 基准测试结果

| 指标 | Shannon | 传统工具 | 提升 |
|------|---------|----------|------|
| **漏洞发现率** | 96.15% | 60-70% | +37% |
| **误报率** | 0% | 15-20% | -100% |
| **测试时间** | 1 小时 | 4-8 小时 | 4-8x |
| **成本** | $50/次 | $500+/人天 | 10x |

### 成本分解（单次测试）

| 阶段 | Token 用量 | 成本（USD） |
|------|-----------|-------------|
| Pre-Recon | 150K | $7.50 |
| Recon | 100K | $5.00 |
| Vuln Analysis (5 Agent) | 400K | $20.00 |
| Exploitation (5 Agent) | 300K | $15.00 |
| Report | 50K | $2.50 |
| **总计** | **1M** | **$50.00** |

**优化策略**：
- 报告阶段使用 Haiku（成本降低 80%）
- 并行执行减少等待时间
- 检查点机制避免重复执行

---

## ⚠️ 使用注意事项

### 网络要求

| 服务 | 必需 | 替代方案 |
|------|------|---------|
| Docker Hub | ✅ | 手动导入镜像 |
| Anthropic API | ✅ | AWS Bedrock |
| GitHub | ✅ | 本地源码 |
| 目标应用 | ✅ | 本地/测试环境 |

### 前置条件

- [ ] Docker 已安装并运行
- [ ] ANTHROPIC_API_KEY 已配置
- [ ] 目标应用源码已准备
- [ ] 目标应用可访问（测试环境）

### 推荐配置

```bash
# 推荐模型（最佳性价比）
export ANTHROPIC_API_KEY=sk-ant-xxx
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=64000

# 支出保护（可选）
export SHANNON_MAX_SPENDING_USD=100
```

---

## 🔄 与现有流程集成

### 集成点

```
┌─────────────────────────────────────────────────────────┐
│                  CI/CD Pipeline                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Code ──▶ Lint ──▶ Test ──▶ Build ──▶ E2E ──▶ Shannon  │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │ 测试金字塔                                         │ │
│  │                                                   │ │
│  │         /‾‾‾\  Shannon (安全测试)                 │ │
│  │       /‾‾‾‾‾‾‾\  E2E (端到端)                     │ │
│  │     /‾‾‾‾‾‾‾‾‾‾\  Integration (集成)              │ │
│  │   /‾‾‾‾‾‾‾‾‾‾‾‾‾\  Unit (单元)                    │ │
│  │  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾                                │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### GitHub Actions 集成

```yaml
# .github/workflows/security.yml
name: Security Test

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  shannon:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Shannon
        run: |
          git clone https://github.com/KeygraphHQ/shannon.git /opt/shannon
          cd /opt/shannon
          docker-compose up -d

      - name: Run Shannon
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          cd /opt/shannon
          ./shannon start URL=https://staging.example.com REPO=.

      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: shannon-report
          path: /opt/shannon/workspaces/*/reports/*.md
```

---

## 📚 学习资源

### 官方文档

- [Shannon GitHub](https://github.com/KeygraphHQ/shannon)
- [SHANNON-PRO.md](https://github.com/KeygraphHQ/shannon/blob/main/SHANNON-PRO.md) - 企业版功能
- [XBOW Benchmark](https://github.com/KeygraphHQ/xbow) - 测试基准

### 内部文档

- [SHANNON_INTEGRATION.md](SHANNON_INTEGRATION.md) - 集成指南
- [SHANNON_INSTALLATION.md](SHANNON_INSTALLATION.md) - 安装指南
- [SHANNON_TEST_REPORT.md](SHANNON_TEST_REPORT.md) - 测试报告

---

## ✅ 检查清单

### 学习成果

- [x] 理解 5 阶段流水线架构
- [x] 掌握 13 Agent 设计模式
- [x] 分析核心代码模块
- [x] 总结可复用设计模式
- [x] 记录集成经验

### 可复用模式

- [x] Result 类型（错误处理）
- [x] Git 检查点（断点续传）
- [x] 服务层隔离
- [x] 审计日志
- [x] 支出保护

### 集成准备

- [ ] Docker 镜像导入（网络问题解决后）
- [ ] 第一次渗透测试运行
- [ ] CI/CD 集成配置
- [ ] 团队培训

---

*版本：1.0.0*
*最后更新：2026-03-10*
*基于 Shannon v1.0.0 源代码分析*

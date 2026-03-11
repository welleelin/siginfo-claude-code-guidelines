# Shannon 集成指南

> **版本**：1.0.0
> **最后更新**：2026-03-10
> **用途**：为项目添加 AI 自主渗透测试能力

---

## 📋 概述

### 什么是 Shannon？

**Shannon** 是一个**自主 AI 渗透测试工具**，由 Keygraph 开发。它通过以下方式保护你的应用：

1. **代码感知动态测试** - 分析源代码识别攻击向量
2. **真实漏洞利用** - 执行实际攻击验证漏洞
3. **可复现 PoC** - 只报告可实际利用的漏洞，提供完整 Proof-of-Concept
4. **OWASP 覆盖** - 注入、XSS、SSRF、认证/授权漏洞

```
┌─────────────────────────────────────────────────────────────────┐
│                    Shannon 核心能力                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  🔍 白盒测试                                                    │
│  - 源代码分析识别攻击面                                         │
│  - 代码路径追踪漏洞点                                           │
│  - API 接口自动发现                                              │
│                                                                 │
│  🎯 自主攻击                                                    │
│  - 多 Agent 并行漏洞分析                                         │
│  - 真实浏览器执行攻击                                           │
│  - 自动化 PoC 生成                                                 │
│                                                                 │
│  📊 漏洞覆盖                                                    │
│  - SQL 注入、命令注入                                              │
│  - XSS（跨站脚本）                                                │
│  - SSRF（服务器端请求伪造）                                       │
│  - 认证绕过、权限提升                                             │
│                                                                 │
│  ✅ 验证报告                                                    │
│  - 只报告可实际利用的漏洞                                       │
│  - 每个漏洞都有完整 PoC                                         │
│  - 精确定位源代码位置                                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Shannon 产品版本

| 版本 | 许可证 | 用途 | 适合场景 |
|------|--------|------|---------|
| **Shannon Lite** | AGPL-3.0 | 本地测试 | 本项目集成（免费） |
| **Shannon Pro** | 商业许可 | 企业级 AppSec 平台 | 需要 SAST+SCA+ 渗透测试 |

---

## 🎯 使用场景

### 场景 1：发布前安全测试

在每次版本发布前，自动运行 Shannon 进行渗透测试：

```
开发完成 → E2E 测试通过 → Shannon 渗透测试 → 安全报告 → 发布
```

### 场景 2：CI/CD 安全门禁

在 CI/CD 流水线中集成 Shannon：

```yaml
# .github/workflows/security.yml
security-test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Run Shannon
      run: |
        git clone https://github.com/KeygraphHQ/shannon.git
        cd shannon
        ./shannon start URL=https://staging.example.com REPO=.
```

### 场景 3：人类介入安全评审

当 Shannon 发现漏洞时，触发人类安全专家评审：

```
Shannon 发现漏洞 → 生成报告 → 发送通知 → 安全专家确认 → 修复优先级
```

---

## 📦 安装与配置

### 方式 1：Docker 运行（推荐）

```bash
# 1. 克隆 Shannon 仓库
git clone https://github.com/KeygraphHQ/shannon.git
cd shannon

# 2. 配置 AI 凭证（选择一种）

# 方式 A: 导出环境变量
export ANTHROPIC_API_KEY="sk-ant-xxxxx"
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=64000

# 方式 B: 创建 .env 文件
cat > .env << 'EOF'
ANTHROPIC_API_KEY=sk-ant-xxxxx
CLAUDE_CODE_MAX_OUTPUT_TOKENS=64000
EOF

# 3. 运行渗透测试
./shannon start URL=https://your-app.com REPO=/path/to/your/repo
```

### 方式 2：npm 技能集成（本项目推荐）

创建 Skill 命令快速调用：

```bash
# 在 ~/.claude/skills/ 创建 shannon 技能目录
mkdir -p ~/.claude/skills/shannon
```

创建 `SKILL.md`：

```markdown
# Shannon Security Test

Run Shannon AI pentest against the target application.

## Usage

```bash
/shannon-start <URL> [REPO]
/shannon-logs [WORKFLOW_ID]
/shannon-query <WORKFLOW_ID>
/shannon-stop [CLEAN=true]
```

## Prerequisites

- Docker installed and running
- ANTHROPIC_API_KEY environment variable set
- Target application must be running

## Example

```bash
/shannon-start http://localhost:3000
/shannon-start https://staging.example.com REPO=.
```
```

### 方式 3：集成到测试脚本

在项目的测试脚本中添加 Shannon 阶段：

```bash
#!/bin/bash
# scripts/test-security.sh

set -e

echo "🔒 开始 Shannon 安全渗透测试..."

# 检查前置条件
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "❌ 错误：ANTHROPIC_API_KEY 未设置"
    exit 1
fi

# 启动 Shannon
cd /opt/shannon
./shannon start URL=$TARGET_URL REPO=$PROJECT_ROOT

# 等待测试完成
WORKFLOW_ID=$(./shannon query --latest --format id)
echo "📊 工作流 ID: $WORKFLOW_ID"

# 监控进度
./shannon logs $WORKFLOW_ID

# 生成报告
echo "📋 生成安全报告..."
./shannon report $WORKFLOW_ID

echo "✅ 安全测试完成"
```

---

## 🧪 在测试流程中的集成

### 完整测试流程

```
┌─────────────────────────────────────────────────────────────────┐
│                    完整测试验证流程                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Phase 1: 前端 Mock 测试                                         │
│  ├── 组件单元测试                                               │
│  ├── UI 快照测试                                                  │
│  └── 状态：✅ 使用 Mock 数据                                        │
│                                                                 │
│  Phase 2: 后端 API 测试                                          │
│  ├── API 端点测试                                                  │
│  ├── 数据库集成测试                                             │
│  └── 状态：✅ 使用真实 API                                         │
│                                                                 │
│  Phase 3: 前后端联调测试                                         │
│  ├── 完整用户流程测试                                           │
│  ├── 跨系统集成测试                                             │
│  └── 状态：✅ 使用真实 API                                         │
│                                                                 │
│  Phase 4: E2E 端到端测试                                         │
│  ├── Playwright 自动化测试                                        │
│  ├── 关键用户路径验证                                           │
│  └── 状态：✅ 使用真实 API                                         │
│                                                                 │
│  Phase 5: Shannon 安全渗透测试 ⭐ NEW                            │
│  ├── 源代码漏洞扫描                                             │
│  ├── 自主攻击验证                                               │
│  ├── PoC 生成                                                      │
│  └── 状态：✅ 白盒测试 + 真实攻击                                   │
│                                                                 │
│  Phase 6: 人类介入测试                                           │
│  ├── 用户体验评审                                               │
│  ├── 设计标注反馈（Agentation）                                  │
│  └── 状态：⚠️ 需要人类参与                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 测试阶段触发条件

| 阶段 | 触发条件 | Shannon 角色 |
|------|---------|-------------|
| Phase 1-4 | 开发完成 | 不运行 |
| Phase 5 | E2E 测试通过后 | **运行完整渗透测试** |
| Phase 6 | 安全测试通过 | 不运行（人类评审） |

### 与 Playwright E2E 的对比

| 维度 | Playwright E2E | Shannon |
|------|---------------|---------|
| **目的** | 功能正确性验证 | 安全漏洞发现 |
| **测试内容** | 用户流程、UI 交互 | 攻击向量、漏洞利用 |
| **数据** | 真实业务数据 | 攻击载荷（Payload） |
| **输出** | 测试通过/失败 | 漏洞报告 + PoC |
| **运行时机** | 每次提交 | 发布前/定期 |

---

## 📊 配置选项

### 环境变量

| 变量 | 必需 | 说明 |
|------|------|------|
| `ANTHROPIC_API_KEY` | ✅ | Anthropic API 密钥（或使用 `CLAUDE_CODE_OAUTH_TOKEN`） |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | ⚠️ | 推荐 64000，用于复杂分析 |
| `AWS_ACCESS_KEY_ID` | ❌ | 使用 AWS Bedrock 时需要 |
| `AWS_SECRET_ACCESS_KEY` | ❌ | 使用 AWS Bedrock 时需要 |

### Shannon 命令参数

```bash
# 基本用法
./shannon start URL=<目标 URL> REPO=<代码仓库路径>

# 可选参数
./shannon start \
    URL=https://your-app.com \
    REPO=/path/to/repo \
    WORKSPACE=my-pentest \      # 自定义工作区名称
    RESUME=true \               # 恢复之前的测试
    CLEAN=false                 # 停止时不清理数据
```

### 工作区管理

```bash
# 查看工作区
./shannon workspaces

# 恢复之前的测试
./shannon start WORKSPACE=my-pentest RESUME=true

# 停止测试（保留数据）
./shannon stop

# 完全清理
./shannon stop CLEAN=true
```

---

## 🔍 监控与日志

### 实时监控

```bash
# 查看实时日志
./shannon logs

# 查看特定工作流日志
./shannon logs ID=shannon-1234567890

# 查询进度
./shannon query ID=shannon-1234567890
```

### Temporal Web UI

Shannon 使用 Temporal 作为工作流引擎，提供 Web UI 监控：

```bash
# 打开 Web UI
open http://localhost:8233

# 查看:
# - 工作流状态
# - Worker 活动
# - 重试历史
# - 错误详情
```

### 进度阶段

Shannon 执行分为以下阶段：

```
1. 初始化 → 2. 侦察 → 3. 漏洞分析 → 4. 攻击利用 → 5. 报告生成
     │          │          │           │           │
     ▼          ▼          ▼           ▼           ▼
  容器启动   发现端点    并行分析    并行攻击    生成 PoC
```

---

## 📋 输出与报告

### 报告位置

```
shannon/
└── workspaces/
    └── <workspace-name>/
        ├── reports/
        │   └── shannon-report-<timestamp>.md    # 主报告
        ├── logs/
        │   ├── recon.log                        # 侦察日志
        │   ├── analysis.log                     # 分析日志
        │   └── exploitation.log                 # 攻击日志
        └── poc/
            ├── sqli-001.sh                      # SQL 注入 PoC
            ├── xss-001.html                     # XSS PoC
            └── auth-bypass-001.sh               # 认证绕过 PoC
```

### 报告结构示例

```markdown
# Shannon 渗透测试报告

**目标**: https://example.com
**时间**: 2026-03-10 10:00 - 11:30
**工作区**: pentest-20260310

## 执行摘要

发现 **5 个已验证漏洞**：
- 🔴 严重：2 个
- 🟠 高危：2 个
- 🟡 中等：1 个

## 漏洞详情

### [CRITICAL] SQL 注入导致认证绕过

**位置**: `POST /api/login`
**参数**: `username`
**PoC**:
```bash
curl -X POST https://example.com/api/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin\'--", "password": "anything"}'
# 响应：{"success": true, "token": "..."}
```

**源码位置**: `src/controllers/auth.ts:45`
**修复建议**: 使用参数化查询

### [HIGH] 反射型 XSS

**位置**: `GET /search`
**参数**: `q`
**PoC**:
```
https://example.com/search?q=<script>alert(document.cookie)</script>
```

**源码位置**: `src/views/search.vue:23`
**修复建议**: 输出编码 + CSP 头

...
```

---

## 🧪 在测试阶段的使用流程

### Phase 5: Shannon 安全测试执行流程

```bash
# Step 1: 确认 E2E 测试通过
npm run test:e2e
# ✅ 输出：All tests passed

# Step 2: 检查 Shannon 前置条件
./scripts/check-security-prereqs.sh
# ✅ Docker: Running
# ✅ ANTHROPIC_API_KEY: Set
# ✅ Target URL: Reachable

# Step 3: 启动 Shannon
cd /opt/shannon
./shannon start URL=http://localhost:3000 REPO=/path/to/project

# Step 4: 监控进度
./shannon logs
# [INFO]  Reconnaissance complete: 15 endpoints discovered
# [INFO]  Vulnerability analysis: 8 potential issues found
# [INFO]  Exploitation: 3 vulnerabilities confirmed with PoC

# Step 5: 等待完成
# 通常 30-90 分钟，取决于应用复杂度

# Step 6: 查看报告
cat workspaces/pentest-*/reports/*.md

# Step 7: 修复漏洞
# 根据报告中的 PoC 和源码位置进行修复

# Step 8: 回归测试
./shannon start URL=http://localhost:3000 RESUME=true
# 验证漏洞已修复
```

### 自动化脚本

创建 `scripts/run-shannon.sh`：

```bash
#!/bin/bash
set -e

TARGET_URL="${1:-http://localhost:3000}"
WORKSPACE="pentest-$(date +%Y%m%d)"

echo "═══════════════════════════════════════════════"
echo "   Shannon 安全渗透测试"
echo "═══════════════════════════════════════════════"
echo ""
echo "目标 URL: $TARGET_URL"
echo "工作区：$WORKSPACE"
echo ""

# 检查前置条件
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "❌ 错误：ANTHROPIC_API_KEY 未设置"
    exit 1
fi

if ! docker ps > /dev/null 2>&1; then
    echo "❌ 错误：Docker 未运行"
    exit 1
fi

# 检查目标是否可达
if ! curl -s --max-time 5 "$TARGET_URL" > /dev/null; then
    echo "❌ 错误：目标 URL 不可达 $TARGET_URL"
    exit 1
fi

echo "✅ 前置条件检查通过"
echo ""

# 启动 Shannon
echo "🚀 启动 Shannon..."
cd /opt/shannon
WORKFLOW_ID=$(./shannon start URL=$TARGET_URL WORKSPACE=$WORKSPACE | grep "Workflow ID" | cut -d: -f2 | tr -d ' ')

echo "📊 工作流 ID: $WORKFLOW_ID"
echo ""

# 监控进度
echo "📋 监控进度（按 Ctrl+C 查看报告）..."
./shannon logs ID=$WORKFLOW_ID

# 生成报告
echo ""
echo "📄 生成报告..."
REPORT_PATH=$(find workspaces/$WORKSPACE/reports -name "*.md" | head -1)
echo ""
echo "═══════════════════════════════════════════════"
echo "   报告位置：$REPORT_PATH"
echo "═══════════════════════════════════════════════"
cat $REPORT_PATH
```

---

## 🔧 故障排查

### 问题 1：无法启动容器

```bash
# 检查 Docker
docker ps

# 检查端口占用
lsof -i :8233  # Temporal UI
lsof -i :5432  # PostgreSQL

# 解决
docker stop shannon-redis shannon-temporal shannon-worker
./shannon start ...
```

### 问题 2：API 认证失败

```bash
# 检查环境变量
echo $ANTHROPIC_API_KEY

# 重新设置
export ANTHROPIC_API_KEY="sk-ant-xxxxx"

# 验证
curl -H "Authorization: Bearer $ANTHROPIC_API_KEY" https://api.anthropic.com/v1/messages \
  -d '{"model":"claude-sonnet-4-20250929","max_tokens":10}'
```

### 问题 3：目标不可达

```bash
# 检查目标服务
curl -I http://localhost:3000

# 如果是本地测试，确保服务在运行
npm run dev

# 检查防火墙
sudo ufw status
```

---

## ✅ 检查清单

### Shannon 安装检查

```
□ Shannon 仓库已克隆到 /opt/shannon
□ Docker 已安装并运行
□ ANTHROPIC_API_KEY 已设置
□ 目标 URL 可访问
```

### 测试流程集成检查

```
□ E2E 测试脚本已更新（包含 Shannon 阶段）
□ CI/CD 配置已添加安全测试
□ 报告输出位置已配置
□ 通知机制已设置（发现严重漏洞时）
```

### 修复验证检查

```
□ Shannon 发现的漏洞已全部修复
□ 回归测试通过
□ 安全报告已归档
□ 修复经验已记录到 MEMORY.md
```

---

## 📚 相关文档

- [E2E 测试流程](../guidelines/04-E2E_TESTING_FLOW.md) - 完整测试流程
- [Agentation 集成](./AGENTATION_INTEGRATION.md) - 人类介入测试
- [Shannon GitHub](https://github.com/KeygraphHQ/shannon) - 官方文档
- [Shannon Pro](./SHANNON_PRO.md) - 企业版功能

---

## 🔗 资源

| 资源 | 链接 |
|------|------|
| **GitHub** | https://github.com/KeygraphHQ/shannon |
| **官方文档** | https://keygraph.io/ |
| **Discord** | https://discord.gg/9ZqQPuhJB7 |
| **示例报告** | [sample-reports/shannon-report-juice-shop.md](https://github.com/KeygraphHQ/shannon/blob/main/sample-reports/shannon-report-juice-shop.md) |
| **Shannon Pro 详情** | [SHANNON-PRO.md](https://github.com/KeygraphHQ/shannon/blob/main/SHANNON-PRO.md) |

---

*版本：1.0.0*
*最后更新：2026-03-10*

# Shannon 安装指南

> **版本**：1.0.0
> **最后更新**：2026-03-10
> **状态**：✅ 安装完成

---

## 📋 安装摘要

Shannon 已成功安装在以下位置：

| 项目 | 位置 |
|------|------|
| **安装目录** | `/tmp/shannon-download` |
| **符号链接** | `~/shannon` → `/tmp/shannon-download` |
| **可执行文件** | `~/bin/shannon` → `/tmp/shannon-download/shannon` |
| **版本** | 1.0.0 |
| **仓库** | https://github.com/KeygraphHQ/shannon |

---

## 🔧 安装步骤

### 第一步：检查 Docker

```bash
# 检查 Docker 是否运行
docker ps

# 如果未运行，启动 Docker Desktop 或 OrbStack
open -a Docker
# 或
open orbstack://
```

### 第二步：克隆仓库

```bash
# 使用 gh CLI 克隆（推荐，速度更快）
cd /tmp
gh repo clone KeygraphHQ/shannon shannon-download

# 或使用 git 直接克隆
cd /tmp
git clone https://github.com/KeygraphHQ/shannon.git shannon-download
```

### 第三步：创建符号链接

```bash
# 创建可执行文件链接
mkdir -p ~/bin
ln -sf /tmp/shannon-download/shannon ~/bin/shannon

# 创建目录链接
ln -sf /tmp/shannon-download ~/shannon

# 添加到 PATH（如未添加）
export PATH=$HOME/bin:$PATH
```

### 第四步：验证安装

```bash
# 检查版本
shannon --version

# 或运行帮助
./shannon help
```

---

## 🔑 配置环境变量

### 设置 ANTHROPIC_API_KEY

```bash
# 临时设置（当前会话有效）
export ANTHROPIC_API_KEY="sk-ant-xxxxx"

# 永久设置（添加到 ~/.zshrc）
echo 'export ANTHROPIC_API_KEY="sk-ant-xxxxx"' >> ~/.zshrc
source ~/.zshrc
```

### 可选：配置其他环境变量

```bash
# 最大输出 Token（推荐）
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=64000

# 使用 AWS Bedrock（可选）
export AWS_ACCESS_KEY_ID="xxx"
export AWS_SECRET_ACCESS_KEY="xxx"
```

---

## 🚀 使用指南

### 启动渗透测试

```bash
# 基础用法
cd /tmp/shannon-download
./shannon start URL=http://localhost:3000 REPO=my-app

# 使用自定义工作空间
./shannon start URL=http://localhost:3000 REPO=my-app WORKSPACE=q1-audit

# 使用配置文件
./shannon start URL=http://localhost:3000 REPO=my-app CONFIG=./config.yaml

# 管道测试模式（快速）
./shannon start URL=http://localhost:3000 REPO=my-app PIPELINE_TESTING=true
```

### 查看进度

```bash
# 查看所有工作空间
./shannon workspaces

# 查看特定工作流日志
./shannon logs ID=example.com_shannon-1234567890

# 监控 UI
# 访问 http://localhost:8233
```

### 停止测试

```bash
# 停止所有容器
./shannon stop

# 停止并清理数据
./shannon stop CLEAN=true
```

---

## 📁 目录结构

```
/tmp/shannon-download/
├── shannon                  # 主执行脚本
├── docker-compose.yml       # Docker 配置
├── Dockerfile              # 容器镜像
├── src/                    # 源代码
├── configs/                # 配置文件
├── prompts/                # AI 提示模板
├── reports/                # 测试报告输出
├── workspaces/             # 工作空间数据
└── audit-logs/             # 审计日志
```

---

## 📊 输出文件

### 测试报告

```
/tmp/shannon-download/workspaces/<workspace-name>/
├── reports/
│   └── shannon-report-<timestamp>.md    # 主报告
├── logs/
│   ├── recon.log                        # 侦察日志
│   ├── analysis.log                     # 分析日志
│   └── exploitation.log                 # 利用日志
└── poc/
    ├── sqli-001.sh                      # SQL 注入 PoC
    ├── xss-001.html                     # XSS PoC
    └── auth-bypass-001.sh               # 认证绕过 PoC
```

---

## 🐛 故障排查

### Docker 无法连接

```bash
# 检查 Docker 是否运行
docker ps

# 重启 Docker
# macOS: 退出 Docker Desktop 后重新打开
# Linux: sudo systemctl restart docker
```

### API Key 错误

```bash
# 验证 API Key 是否设置
echo $ANTHROPIC_API_KEY

# 测试 API Key 是否有效
curl -H "Authorization: Bearer $ANTHROPIC_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"model":"claude-3-sonnet-20240229","max_tokens":10,"messages":[{"role":"user","content":"Hi"}]}' \
     https://api.anthropic.com/v1/messages
```

### 克隆速度慢

```bash
# 使用浅克隆
git clone --depth 1 https://github.com/KeygraphHQ/shannon.git

# 或使用 gh CLI（通常更快）
gh repo clone KeygraphHQ/shannon
```

---

## ✅ 检查清单

- [x] Docker 已安装并运行
- [x] Shannon 仓库已克隆
- [x] 符号链接已创建
- [x] 可执行文件可访问
- [ ] ANTHROPIC_API_KEY 已设置
- [ ] 第一次渗透测试已运行

---

## 🔗 相关文档

- [SHANNON_INTEGRATION.md](SHANNON_INTEGRATION.md) - Shannon 完整集成指南
- [SKILL.md](~/.claude/skills/shannon/SKILL.md) - Shannon Skill 命令
- [官方仓库](https://github.com/KeygraphHQ/shannon)

---

*版本：1.0.0*
*最后更新：2026-03-10*

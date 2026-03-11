# Shannon 安装和测试报告

> **版本**：1.0.0
> **最后更新**：2026-03-10
> **状态**：✅ 安装完成 | ⚠️ 测试受限

---

## 📋 安装摘要

### ✅ 完成的项目

| 项目 | 状态 | 详情 |
|------|------|------|
| **Docker 运行时** | ✅ 已安装并运行 | OrbStack Docker |
| **Shannon 仓库** | ✅ 已克隆 | `/tmp/shannon-download` (296MB) |
| **符号链接** | ✅ 已创建 | `~/bin/shannon`, `~/shannon` |
| **依赖仓库** | ✅ 已克隆 | OWASP Juice Shop 源码 |
| **API Key 配置** | ✅ 已设置 | ANTHROPIC_API_KEY |

### ⚠️ 受限项目

| 项目 | 状态 | 原因 |
|------|------|------|
| **Docker 镜像拉取** | ⚠️ 无法完成 | 网络限制无法访问 Docker Hub |
| **渗透测试运行** | ⚠️ 无法完成 | Docker 镜像无法下载 |

---

## 🔧 安装详情

### 1. Docker 环境

```bash
# Docker 版本
Docker version 28.5.2

# 运行时
OrbStack (macOS)
```

### 2. Shannon 安装位置

```
安装目录：/tmp/shannon-download
├── shannon              # 主执行脚本 (13.7KB)
├── docker-compose.yml   # Docker 配置
├── Dockerfile          # 容器镜像
├── src/                # 源代码 (12 个模块)
├── configs/            # 配置文件
├── prompts/            # AI 提示模板
├── repos/              # 目标源码仓库
│   └── juice-shop/     # OWASP Juice Shop (测试用)
└── audit-logs/         # 测试报告输出
```

### 3. 符号链接

```bash
~/bin/shannon -> /tmp/shannon-download/shannon
~/shannon -> /tmp/shannon-download
```

---

## 🚀 使用方法

### 启动渗透测试

```bash
# 设置环境变量
export ANTHROPIC_API_KEY="sk-ant-xxxxx"

# 进入目录
cd /tmp/shannon-download

# 启动测试
./shannon start URL=<目标 URL> REPO=<源码仓库名>

# 示例：测试 OWASP Juice Shop
./shannon start URL=https://juice-shop.herokuapp.com REPO=juice-shop

# 示例：测试本地应用
./shannon start URL=http://localhost:3000 REPO=my-app
```

### 监控进度

```bash
# 查看所有工作空间
./shannon workspaces

# 查看日志
./shannon logs ID=<workflow-id>

# Web UI 监控
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

## 📁 输出文件

测试完成后，报告将保存在：

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

## 🐛 当前限制

### 网络限制

由于网络环境限制，无法从 Docker Hub 拉取镜像：

```
Error: Get "https://registry-1.docker.io/v2/": context deadline exceeded
```

### 解决方案

**方案 1：手动导入镜像（推荐）**

```bash
# 1. 在有网络的机器上导出镜像
docker pull temporalio/temporal:latest
docker save temporalio/temporal:latest > temporal.tar

# 2. 复制到当前机器
scp temporal.tar user@host:/tmp/

# 3. 导入镜像
docker load < /tmp/temporal.tar
```

**方案 2：使用国内镜像源**

```bash
# 配置 Docker 使用国内镜像源
# 编辑 /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://registry.docker-cn.com"
  ]
}
```

---

## ✅ 检查清单

### 安装检查

- [x] Docker 已安装并运行
- [x] Shannon 仓库已克隆 (296MB)
- [x] 符号链接已创建
- [x] ANTHROPIC_API_KEY 已配置
- [x] 测试用源码已准备 (OWASP Juice Shop)
- [ ] Docker 镜像已导入 ⚠️
- [ ] 第一次渗透测试已运行 ⚠️

### 使用前检查

- [ ] Docker 镜像已导入（手动或通过网络）
- [ ] 目标应用 URL 已准备
- [ ] 目标应用源码已克隆到 `repos/` 目录

---

## 📊 架构说明

### Shannon 工作流程

```
┌─────────────────────────────────────────────────────────────────┐
│                    Shannon 架构                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────┐     ┌───────────────┐     ┌───────────────┐ │
│  │   Temporal    │◀───▶│    Worker     │◀───▶│    Agent      │ │
│  │  (工作流引擎)  │     │  (Node.js)    │     │  (AI Pentester)│ │
│  └───────────────┘     └───────────────┘     └───────────────┘ │
│         │                     │                       │         │
│         │                     │                       │         │
│         ▼                     ▼                       ▼         │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                    Source Code                               │ │
│  │                   (repos/ 目录)                              │ │
│  └─────────────────────────────────────────────────────────────┘ │
│         │                     │                       │         │
│         ▼                     ▼                       ▼         │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                   Target Application                         │ │
│  │                  (URL 指定的应用)                             │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 测试阶段

1. **侦察阶段** - 发现端点、API 文档、技术栈
2. **漏洞分析** - 并行分析各类攻击向量
3. **漏洞利用** - 生成真实 PoC
4. **报告生成** - 只报告可实际利用的漏洞

---

## 🔗 相关文档

- [SHANNON_INTEGRATION.md](SHANNON_INTEGRATION.md) - Shannon 完整集成指南
- [SHANNON_INSTALLATION.md](SHANNON_INSTALLATION.md) - Shannon 安装指南
- [SKILL.md](~/.claude/skills/shannon/SKILL.md) - Shannon Skill 命令
- [官方仓库](https://github.com/KeygraphHQ/shannon)

---

## 📝 下一步

### 立即可执行

1. **导入 Docker 镜像**
   ```bash
   # 从有网络的机器导入 temporalio/temporal:latest
   docker load < temporal.tar
   ```

2. **启动渗透测试**
   ```bash
   cd /tmp/shannon-download
   ./shannon start URL=http://localhost:3000 REPO=my-app
   ```

3. **查看测试报告**
   ```bash
   cat /tmp/shannon-download/workspaces/*/reports/*.md
   ```

### 长期规划

1. 建立定期安全测试流程（每次发布前）
2. 配置 CI/CD 集成
3. 建立漏洞修复追踪机制

---

*版本：1.0.0*
*最后更新：2026-03-10*

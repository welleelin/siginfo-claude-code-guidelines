# 大模型渠道配置与管理

> **版本**：2.0.0
> **创建日期**：2026-03-05
> **更新**：添加用量追踪与 Agent-Reach 集成

---

## 📋 概述

支持大模型渠道的快速切换、用量监控和场景化推荐。

---

## 🤖 支持的模型渠道

| 渠道 | 模型 ID | 级别 | 适用场景 | 成本 | 状态 |
|------|--------|------|---------|------|------|
| **Claude Opus** | claude-opus-4-20250514 | L1 | 架构设计、深度推理 | $$$$ | ✅ |
| **Claude Sonnet** | claude-sonnet-4-20250514 | L2 | 主力开发、平衡性能 | $$$ | ✅ |
| **Claude Haiku** | claude-3-5-haiku-20241022 | L3 | 快速任务、经济实惠 | $ | ✅ |
| **MiniMax** | minimax-text-01 | L3 | 中文内容生成 | $ | ⚠️ |
| **GLM** | glm-4-plus | L2 | 中文理解、代码生成 | $$ | ⚠️ |
| **Qwen** | qwen-max | L2 | 多语言支持 | $$ | ⚠️ |
| **DeepSeek** | deepseek-chat | L3 | 代码生成、数学推理 | $ | ⚠️ |

**级别说明**：
- **L1** - 最强能力，用于复杂架构设计和深度推理
- **L2** - 平衡能力，用于主力开发和一般任务
- **L3** - 经济实惠，用于快速任务和简单操作

---

## 📊 用量监控

### 用量获取方式

| 渠道 | 获取方式 | 说明 |
|------|---------|------|
| Claude | API + Agent-Reach | 优先 API，失败时用 Agent-Reach 获取控制台数据 |
| MiniMax | Agent-Reach | 需要 Cookie 登录控制台 |
| GLM | Agent-Reach | 需要 Cookie 登录控制台 |
| DeepSeek | API | 直接调用 API 查询 |
| Qwen | Agent-Reach | 需要 Cookie 登录阿里云控制台 |

### 用量配置文件

```yaml
# ~/.claude/model-usage.yaml
last_updated: 2026-03-05T10:00:00+08:00

channels:
  claude-opus:
    model_id: claude-opus-4-20250514
    level: L1
    usage:
      type: token
      used: 1250000
      limit: 5000000
      remaining: 3750000
      reset_date: 2026-04-01
      percentage: 25%
    source: api

  claude-sonnet:
    model_id: claude-sonnet-4-2025050514
    level: L2
    usage:
      type: token
      used: 2800000
      limit: 10000000
      remaining: 7200000
      reset_date: 2026-04-01
      percentage: 28%
    source: api

  claude-haiku:
    model_id: claude-3-5-haiku-20241022
    level: L3
    usage:
      type: token
      used: 450000
      limit: 20000000
      remaining: 19550000
      reset_date: 2026-04-01
      percentage: 2%
    source: api

  minimax:
    model_id: minimax-text-01
    level: L3
    usage:
      type: token
      used: 85000
      limit: 1000000
      remaining: 915000
      reset_date: 2026-03-31
      percentage: 8%
    source: agent-reach
    auth:
      type: cookie
      required: true

  glm:
    model_id: glm-4-plus
    level: L2
    usage:
      type: token
      used: 320000
      limit: 2000000
      remaining: 1680000
      reset_date: 2026-03-31
      percentage: 16%
    source: agent-reach
    auth:
      type: cookie
      required: true
```

---

## 🔧 Agent-Reach 集成

### 用量获取流程

当 API 无法获取用量信息时，自动使用 Agent-Reach 获取供应商控制台数据：

```
┌─────────────────┐
│ 1. 尝试 API 查询  │
└────────┬────────┘
         │
       失败
         │
         ▼
┌─────────────────┐
│ 2. 检查 Cookie   │ ← Agent-Reach 能力
└────────┬────────┘
         │
       未配置
         │
         ▼
┌─────────────────┐
│ 3. 引导用户配置  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 4. 访问控制台   │
│ - Anthropic     │
│ - MiniMax       │
│ - Zhipu (GLM)   │
│ - Aliyun (Qwen) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 5. 提取用量数据  │
└─────────────────┘
```

### 供应商控制台 URL

| 渠道 | 控制台 URL | 需要认证 |
|------|-----------|---------|
| Claude | https://console.anthropic.com/dashboard | Cookie |
| MiniMax | https://platform.minimaxi.com/ | Cookie |
| GLM | https://open.bigmodel.cn/ | Cookie |
| Qwen | https://dashscope.console.aliyun.com/ | Cookie |
| DeepSeek | https://platform.deepseek.com/ | Cookie |

---

## 🚀 快速切换

### 命令方式

```bash
# 切换到指定模型（自动检查用量）
/switch-model opus

# 查看用量状态
/switch-model --usage

# 查看推荐模型
/switch-model --recommend "任务描述"
```

### 快捷命令

```bash
/opus      /sonnet     /haiku
/minimax   /glm        /qwen       /deepseek
```

---

## 📊 用量告警

### 告警阈值

| 级别 | 用量百分比 | 动作 |
|------|-----------|------|
| 警告 | 70% | 通知用户 |
| 严重 | 85% | 建议切换模型 |
| 紧急 | 95% | 自动切换 L3 模型 |

### 告警输出

```bash
╔════════════════════════════════════════════════╗
║         ⚠️  模型用量告警                        ║
╠════════════════════════════════════════════════╣
║  模型：Claude Opus                              ║
║  已用：85% (4,250,000 / 5,000,000)             ║
║  剩余：750,000 tokens                          ║
║  重置：2026-04-01                              ║
╠════════════════════════════════════════════════╣
║  建议：                                        ║
║  1. 切换到 Claude Sonnet (当前 28%)            ║
║  2. 切换到 Claude Haiku (当前 2%)              ║
║  3. 联系管理员增加配额                         ║
╚════════════════════════════════════════════════╝
```

---

## 🔐 Cookie 配置

### 使用 Cookie-Editor 配置

```bash
# 1. 浏览器登录供应商控制台
# 2. 使用 Cookie-Editor 导出 Cookie
# 3. 配置到 Agent-Reach

/model-configure cookie claude "YOUR_COOKIE"
/model-configure cookie minimax "YOUR_COOKIE"
/model-configure cookie glm "YOUR_COOKIE"
```

### Cookie 安全

| 措施 | 说明 |
|------|------|
| 🔒 **本地存储** | Cookie 存在 `~/.claude/credentials/`，权限 600 |
| 🛡️ **专用小号** | 使用专用账号，避免主账号风险 |
| 🔄 **定期更换** | 建议每月更换一次 |
| 🚫 **不上传** | Cookie 不上传任何服务器 |

---

## 📝 使用场景

### 场景 1：用量不足自动切换

```bash
# 当前使用 Opus，用量 85%
# 切换时自动检查并提示

$ /switch-model opus

╔════════════════════════════════════════════════╗
║  ⚠️  用量告警                                   ║
║  Claude Opus 已用 85%，建议切换                ║
╠════════════════════════════════════════════════╣
║  推荐替代:                                     ║
║  1. Claude Sonnet (用量 28%，能力相近)         ║
║  2. Claude Haiku (用量 2%，经济实惠)           ║
╠════════════════════════════════════════════════╣
║  是否切换到 Claude Sonnet? (y/N)               ║
╚════════════════════════════════════════════════╝
```

### 场景 2：基于任务推荐模型

```bash
# 根据任务描述推荐模型
$ /switch-model --recommend "写一篇中文技术博客"

╔════════════════════════════════════════════════╗
║  📊 模型推荐                                    ║
╠════════════════════════════════════════════════╣
║  任务：写一篇中文技术博客                       ║
╠════════════════════════════════════════════════╣
║  推荐：MiniMax (中文内容生成优化)              ║
║  原因：                                        ║
║  - 中文生成能力强                              ║
║  - 当前用量 8%，充足                           ║
║  - 成本较低                                    ║
╠════════════════════════════════════════════════╣
║  备选：                                        ║
║  - GLM-4 (中文理解，用量 16%)                  ║
║  - Claude Sonnet (通用，用量 28%)              ║
╚════════════════════════════════════════════════╝
```

---

## 🔗 相关文档

- [switch-model 命令](../commands/switch-model.md)
- [Agent-Reach 集成](12-AGENT_REACH_INTEGRATION.md)
- [用量监控脚本](../scripts/model-usage-check.sh)

---

*版本：2.0.0*
*最后更新：2026-03-05*

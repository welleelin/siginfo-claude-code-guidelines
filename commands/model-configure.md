# /model-configure - 大模型配置命令

> **版本**：2.0.0
> **创建日期**：2026-03-05
> **更新**：添加 Cookie 配置支持

---

## 功能描述

配置大模型渠道的认证信息（API Key / Cookie），支持 Agent-Reach 获取用量。

---

## 用法

```bash
# 配置 API Key
/model-configure <模型> -key "YOUR_API_KEY"

# 配置 Cookie（用于 Agent-Reach 获取用量）
/model-configure <模型> -cookie "YOUR_COOKIE"

# 配置用量限额
/model-configure <模型> -limit <数量>

# 查看配置
/model-configure <模型> --show

# 清除配置
/model-configure <模型> --clear
```

---

## 参数

| 参数 | 说明 |
|------|------|
| `模型` | 模型简称 (opus/sonnet/haiku/minimax/glm/qwen/deepseek) |
| `-key` | 配置 API Key |
| `-cookie` | 配置 Cookie（用于控制台用量获取） |
| `-limit` | 配置用量限额 |
| `--show` | 查看当前配置 |
| `--clear` | 清除配置 |

---

## 配置 API Key

```bash
# 配置 MiniMax API Key
/model-configure minimax -key "YOUR_API_KEY"

# 配置 GLM API Key
/model-configure glm -key "YOUR_API_KEY"

# 配置 DeepSeek API Key
/model-configure deepseek -key "YOUR_API_KEY"

# 配置 Qwen API Key
/model-configure qwen -key "YOUR_API_KEY"
```

---

## 配置 Cookie（Agent-Reach 用量获取） ⭐ NEW

当 API 无法获取用量信息时，使用 Cookie 通过 Agent-Reach 访问供应商控制台：

### 步骤 1：浏览器登录

```bash
# 打开供应商控制台
Claude:   https://console.anthropic.com/dashboard
MiniMax:  https://platform.minimaxi.com/
GLM:      https://open.bigmodel.cn/
Qwen:     https://dashscope.console.aliyun.com/
DeepSeek: https://platform.deepseek.com/
```

### 步骤 2：导出 Cookie

使用 Chrome 插件 **Cookie-Editor**：
1. 点击 Cookie-Editor 图标
2. 点击 "Export" → "Copy to Clipboard"

### 步骤 3：配置 Cookie

```bash
# 配置 Claude Cookie
/model-configure claude -cookie "YOUR_COOKIE_STRING"

# 配置 MiniMax Cookie
/model-configure minimax -cookie "YOUR_COOKIE_STRING"

# 配置 GLM Cookie
/model-configure glm -cookie "YOUR_COOKIE_STRING"

# 配置 Qwen Cookie
/model-configure qwen -cookie "YOUR_COOKIE_STRING"
```

---

## 配置用量限额

```bash
# 配置 Claude Opus 用量限额（tokens）
/model-configure opus -limit 5000000

# 配置 Claude Sonnet 用量限额
/model-configure sonnet -limit 10000000

# 配置 MiniMax 用量限额
/model-configure minimax -limit 1000000
```

---

## 查看配置

```bash
# 查看单个模型配置
/model-configure opus --show

# 输出示例:
╔════════════════════════════════════════════════╗
║  📋 Claude Opus 配置                            ║
╠════════════════════════════════════════════════╣
║  模型 ID:   claude-opus-4-20250514             ║
║  级别：     L1                                 ║
║  API Key:   ✅ 已配置                          ║
║  Cookie:    ✅ 已配置 (Agent-Reach 用量获取)     ║
║  限额：     5,000,000 tokens                   ║
║  已用：     1,250,000 tokens (25%)             ║
║  剩余：     3,750,000 tokens                   ║
║  重置：     2026-04-01                         ║
╚════════════════════════════════════════════════╝
```

---

## 清除配置

```bash
# 清除 API Key
/model-configure minimax --clear

# 清除所有配置
/model-configure --clear-all
```

---

## 安全提示

| 措施 | 说明 |
|------|------|
| 🔒 **本地存储** | API Key/Cookie 存储在 `~/.claude/credentials/`，权限 600 |
| 🛡️ **专用账号** | 建议使用专用小号，避免主账号风险 |
| 🔄 **定期更换** | Cookie 建议每月更换一次 |
| 🚫 **不上传** | 凭据不上传任何服务器 |

---

## 故障排查

### Cookie 失效

```bash
# 1. 检查 Cookie 是否过期
/model-configure claude --show

# 2. 重新导出 Cookie
# 浏览器重新登录 → Cookie-Editor 导出 → 重新配置

# 3. 验证
/model-usage-check --summary
```

### 无法获取用量

```bash
# 1. 检查 Agent-Reach 是否安装
agent-reach doctor

# 2. 检查 Cookie 配置
/model-configure --show

# 3. 手动测试
curl -H "Cookie: YOUR_COOKIE" "https://r.jina.ai/https://console.anthropic.com/dashboard"
```

---

## 相关命令

- `/switch-model` - 切换模型（带用量检查）
- `/model-usage-check` - 检查用量
- `/agent-reach` - Agent-Reach 互联网访问

---

*版本：2.0.0*
*最后更新：2026-03-05*

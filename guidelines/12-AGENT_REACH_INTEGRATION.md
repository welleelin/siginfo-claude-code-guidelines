# cc-connect 集成指南

> **版本**：2.0.0
> **整合日期**：2026-03-10
> **来源**：https://github.com/chenhg5/cc-connect

---

## 📋 概述

cc-connect 是一个强大的桥接工具，让你通过聊天应用（飞书、钉钉、Telegram、Discord 等）远程控制本地运行的 AI Agent。

### 核心价值

| 特性 | 说明 |
|------|------|
| 🤖 **多 Agent 支持** | 支持 7 个 AI Agent（Claude Code、Codex、Cursor、Gemini、Qoder、OpenCode、iFlow） |
| 📱 **多平台支持** | 支持 9 个聊天平台，大部分无需公网 IP |
| 🔄 **实时同步** | 流式预览、实时消息更新 |
| 🎤 **语音支持** | STT 语音转文字、TTS 文字转语音 |
| ⏰ **定时任务** | 自然语言设置 cron 任务 |
| 🔗 **多机器人** | 群聊中多机器人互相通信 |

---

## 🏗️ 架构设计

```
        你（手机/平板/电脑）
               │
   ┌───────────┼───────────┐
   ▼           ▼           ▼
 飞书       Slack      Telegram  ...9 个平台
   │           │           │
   └───────────┼───────────┘
               ▼
         ┌────────────┐
         │ cc-connect │  ← 你的开发机器
         └────────────┘
         ┌─────┼─────┐
         ▼     ▼     ▼
    Claude  Gemini  Codex  ...7 个 Agent
     Code    CLI   OpenCode
```

---

## 📦 支持的 Agent

| Agent | 状态 | 说明 |
|-------|------|------|
| Claude Code | ✅ | Anthropic 官方 CLI |
| Codex (OpenAI) | ✅ | OpenAI 编码 Agent |
| Cursor Agent | ✅ | Cursor Agent CLI |
| Gemini CLI (Google) | ✅ | Google Gemini CLI |
| Qoder CLI | ✅ | Qoder 编码助手 |
| OpenCode (Crush) | ✅ | OpenCode Agent |
| iFlow CLI | ✅ | iFlow CLI |

---

## 📱 支持的平台

| 平台 | 连接方式 | 需要公网 IP | 说明 |
|------|---------|------------|------|
| 飞书 (Feishu/Lark) | WebSocket | ❌ 不需要 | 个人/企业均可 |
| 钉钉 (DingTalk) | Stream | ❌ 不需要 | 企业钉钉 |
| Telegram | Long Polling | ❌ 不需要 | 个人使用首选 |
| Slack | Socket Mode | ❌ 不需要 | 团队协作 |
| Discord | Gateway | ❌ 不需要 | 社区/团队 |
| QQ (NapCat) | WebSocket | ❌ 不需要 | 仅私聊 |
| QQ Bot (官方) | WebSocket | ❌ 不需要 | 官方机器人 |
| LINE | Webhook | ✅ 需要 | 需要 ngrok |
| 企业微信 (WeCom) | Webhook | ✅ 需要 | 需要 ngrok |

---

## 📦 安装

### npm 安装（推荐）

```bash
npm install -g cc-connect
```

### 二进制安装

```bash
# macOS/Linux
curl -L -o cc-connect https://github.com/chenhg5/cc-connect/releases/latest/download/cc-connect-$(uname -s)-$(uname -m)
chmod +x cc-connect
sudo mv cc-connect /usr/local/bin/
```

### 验证安装

```bash
cc-connect --version
```

---

## ⚙️ 配置

### 配置文件位置

```
~/.cc-connect/config.toml
```

### 最小配置示例

```toml
language = "zh"

[log]
level = "info"

[[projects]]
name = "default"

[projects.agent]
type = "claudecode"

[projects.agent.options]
work_dir = "/path/to/your/project"
mode = "default"

# 飞书配置
[[projects.platforms]]
type = "feishu"

[projects.platforms.options]
app_id = "cli_xxxxxx"
app_secret = "xxxxxx"
```

---

## 🚀 飞书配置指南

### 第一步：创建飞书应用

1. 访问 [飞书开放平台](https://open.feishu.cn/)
2. 点击「控制台」→「创建企业自建应用」
3. 填写应用名称（如 `cc-connect`）

### 第二步：获取凭证

在「凭据与基础信息」获取：
- **App ID**：`cli_xxxxxx`
- **App Secret**：`xxxxxx`

### 第三步：启用机器人

「应用能力」→「机器人」→「启用机器人」

### 第四步：配置权限

在「权限管理」中添加：

| 权限 | 标识 |
|------|------|
| 获取用户基本信息 | `contact:user.base:readonly` |
| 接收群聊消息 | `im:message.group:receive` |
| 接收单聊消息 | `im:message.p2p:receive` |
| 读取群消息 | `im:message.group_msg:readonly` |
| 读取单聊消息 | `im:message.p2p_msg:readonly` |
| 发送消息 | `im:message:send_as_bot` |

### 第五步：配置事件订阅

「事件订阅」→ 选择 **「使用长连接接收事件」** → 添加事件 `im.message.receive_v1`

### 第六步：发布应用

「版本管理与发布」→「创建版本」→「保存并发布」

---

## 🎮 使用

### 启动服务

```bash
cc-connect -config ~/.cc-connect/config.toml
```

### 后台运行

```bash
nohup cc-connect -config ~/.cc-connect/config.toml > ~/.cc-connect/cc-connect.log 2>&1 &
```

### 检查状态

```bash
pgrep -f cc-connect && echo "Running" || echo "Stopped"
```

### 查看日志

```bash
tail -50 ~/.cc-connect/cc-connect.log
```

---

## 💬 聊天命令

在聊天应用中可以使用以下命令：

| 命令 | 说明 |
|------|------|
| `/help` | 显示帮助 |
| `/model` | 切换模型 |
| `/mode` | 修改权限模式 |
| `/memory` | 读写 Agent 指令文件 |
| `/quiet` | 切换静默模式 |
| `/tts` | 切换语音回复 |
| `/status` | 显示会话状态 |
| `/clear` | 清除对话历史 |
| `/cron add` | 添加定时任务 |
| `/cron list` | 列出定时任务 |

---

## 🎤 语音配置

### STT（语音转文字）

```toml
[speech]
enabled = true
provider = "openai"  # 或 "groq"、"qwen"

[speech.openai]
api_key = "sk-xxx"
model = "whisper-1"
```

### TTS（文字转语音）

```toml
[tts]
enabled = true
provider = "qwen"  # 或 "openai"
voice = "Cherry"
tts_mode = "voice_only"

[tts.qwen]
api_key = "sk-xxx"
model = "qwen3-tts-flash"
```

---

## 🔗 相关链接

- **GitHub**: https://github.com/chenhg5/cc-connect
- **Discord**: https://discord.gg/kHpwgaM4kq
- **Telegram**: https://t.me/+odGNDhCjbjdmMmZl

---

## 📝 更新日志

| 版本 | 日期 | 更新内容 |
|------|------|---------|
| 2.0.0 | 2026-03-10 | 用 cc-connect 替换原有的 claude-to-im，支持 7 个 Agent 和 9 个平台 |
| 1.0.0 | 2026-03-05 | 初始版本，基于 Agent-Reach |

---

> **安全提醒**：
> - 提交到远程仓库时，务必删除配置文件中的 App ID 和 App Secret
> - 使用 `git update-index --assume-unchanged` 或 `.gitignore` 保护敏感配置
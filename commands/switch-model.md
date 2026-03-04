# /switch-model - 大模型渠道切换命令

> **版本**：1.0.0
> **创建日期**：2026-03-05

---

## 功能描述

快速切换不同的大模型渠道，根据任务需求选择最合适的模型。

---

## 用法

```bash
# 切换到指定模型
/switch-model <模型名称> [选项]

# 查看可用渠道
/switch-model --list

# 查看当前模型
/switch-model --current

# 查看使用统计
/switch-model --stats
```

---

## 参数

| 参数 | 说明 |
|------|------|
| `模型名称` | 模型简称或全名 |
| `--list` | 列出所有可用渠道 |
| `--current` | 显示当前激活的模型 |
| `--stats` | 显示使用统计 |
| `--configure` | 配置指定渠道的 API Key |

---

## 支持的模型

### Claude 系列

| 简称 | 全名 | 说明 |
|------|------|------|
| `opus` | claude-opus-4-20250514 | 最强推理、架构设计 |
| `sonnet` | claude-sonnet-4-20250514 | 主力开发、平衡性能 |
| `haiku` | claude-3-5-haiku-20241022 | 快速任务、经济实惠 |

### 国产模型

| 简称 | 全名 | 说明 |
|------|------|------|
| `minimax` | minimax-text-01 | 中文内容生成 |
| `glm` | glm-4-plus | 中文理解、代码生成 |
| `qwen` | qwen-max | 多语言支持、阿里达摩院 |
| `deepseek` | deepseek-chat | 代码生成、数学推理 |

---

## 示例

### 切换模型

```bash
# 切换到 Claude Opus（深度推理）
/switch-model opus

# 切换到 Claude Haiku（快速修改）
/switch-model haiku

# 切换到 MiniMax（中文写作）
/switch-model minimax

# 切换到 GLM（中文理解）
/switch-model glm

# 切换到 DeepSeek（数学推理）
/switch-model deepseek
```

### 查询操作

```bash
# 列出所有可用渠道
/switch-model --list

# 查看当前模型
/switch-model --current

# 查看今日使用统计
/switch-model --stats
```

### 配置操作

```bash
# 配置 MiniMax API Key
/switch-model --configure minimax

# 配置 GLM API Key
/switch-model --configure glm

# 配置 DeepSeek API Key
/switch-model --configure deepseek
```

---

## 快捷命令 ⭐ NEW

为了方便快速切换，定义以下别名：

```bash
# Claude 系列
/opus           # 切换到 Claude Opus
/sonnet         # 切换到 Claude Sonnet
/haiku          # 切换到 Claude Haiku

# 国产模型
/minimax        # 切换到 MiniMax
/glm            # 切换到 GLM
/qwen           # 切换到 Qwen
/deepseek       # 切换到 DeepSeek
```

---

## 执行流程

### 1. 切换模型

```
/switch-model <模型>
       │
       ▼
┌─────────────────┐
│ 1. 验证模型名称  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 2. 检查 API Key  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 3. 更新配置文件 │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 4. 确认切换成功 │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 5. 记录切换日志 │
└─────────────────┘
```

### 2. 输出示例

```bash
$ /switch-model opus

╔════════════════════════════════════════════════╗
║          🔄 切换大模型渠道                      ║
╠════════════════════════════════════════════════╣
║  当前模型：claude-sonnet-4-20250514            ║
║  目标模型：claude-opus-4-20250514              ║
╠════════════════════════════════════════════════╣
║  ✅ 验证通过                                    ║
║  ✅ API Key 已配置                              ║
║  ✅ 配置文件已更新                              ║
╠════════════════════════════════════════════════╣
║  🎉 已切换到 Claude Opus                        ║
║                                                ║
║  适用场景：                                    ║
║  - 复杂架构设计                                ║
║  - 深度推理问题                                ║
║  - 代码审查和安全分析                          ║
║  - 数学和科学问题                              ║
╠════════════════════════════════════════════════╣
║  💰 成本提示：Opus 比 Sonnet 贵约 3 倍           ║
║  💡 建议：复杂任务完成后切回 Sonnet             ║
╚════════════════════════════════════════════════╝
```

---

## 配置文件

### 当前模型配置

```yaml
# ~/.claude/active-model
claude-opus-4-20250514
```

### 渠道配置文件

```yaml
# ~/.claude/model-channels.yaml
channels:
  claude:
    opus:
      id: claude-opus-4-20250514
      name: Claude Opus 4
      provider: Anthropic
      cost: 4x
      status: active
      apiKey: ~/.claude/credentials/anthropic

    sonnet:
      id: claude-sonnet-4-20250514
      name: Claude Sonnet 4
      provider: Anthropic
      cost: 1x
      status: active
      apiKey: ~/.claude/credentials/anthropic

    haiku:
      id: claude-3-5-haiku-20241022
      name: Claude Haiku 3.5
      provider: Anthropic
      cost: 0.1x
      status: active
      apiKey: ~/.claude/credentials/anthropic

  minimax:
    text-01:
      id: minimax-text-01
      name: MiniMax Text 01
      provider: MiniMax
      cost: 0.5x
      status: pending
      apiKey: ~/.claude/credentials/minimax

  glm:
    glm-4-plus:
      id: glm-4-plus
      name: GLM-4 Plus
      provider: Zhipu AI
      cost: 0.8x
      status: active
      apiKey: ~/.claude/credentials/glm

  deepseek:
    chat:
      id: deepseek-chat
      name: DeepSeek Chat
      provider: DeepSeek
      cost: 0.3x
      status: active
      apiKey: ~/.claude/credentials/deepseek
```

---

## 自动切换规则

### 启用自动切换

```yaml
# ~/.claude/model-channels.yaml
autoSwitch:
  enabled: true

  # 基于任务类型
  rules:
    - pattern: ["架构设计", "系统规划", "技术方案"]
      model: opus
      reason: "复杂推理任务"

    - pattern: ["快速修复", "简单修改", "语法检查"]
      model: haiku
      reason: "快速经济任务"

    - pattern: ["中文写作", "翻译", "文案"]
      model: minimax
      reason: "中文优化模型"

    - pattern: ["代码审查", "安全分析", "漏洞"]
      model: sonnet
      reason: "代码审查任务"

    - pattern: ["数学", "计算", "算法"]
      model: deepseek
      reason: "数学推理优化"
```

---

## 错误处理

| 错误 | 原因 | 处理 |
|------|------|------|
| `模型不存在` | 输入的模型名称无效 | 使用 `--list` 查看可用模型 |
| `API Key 未配置` | 目标渠道未配置密钥 | 使用 `--configure` 配置 |
| `余额不足` | API 账户余额不足 | 充值或切换其他模型 |
| `切换失败` | 配置文件锁定 | 稍后重试 |

---

## 使用统计

```bash
# 查看统计
/switch-model --stats

# 输出示例:
╔════════════════════════════════════════════════╗
║       📊 大模型使用统计 (今日)                  ║
╠════════════════════════════════════════════════╣
║  Claude Sonnet:  45 次  ($2.50)  [54%]         ║
║  Claude Opus:    12 次  ($3.60)  [14%]         ║
║  Claude Haiku:   28 次  ($0.30)  [30%]         ║
║  MiniMax:         5 次  ($0.15)   [6%]         ║
║  GLM:             3 次  ($0.20)   [3%]         ║
╠════════════════════════════════════════════════╣
║  总计：93 次  ($6.75)                          ║
║  预算：$10.00                                  ║
║  剩余：$3.25                                   ║
╠════════════════════════════════════════════════╣
║  💡 建议：今日预算充足，可继续使用 Opus         ║
╚════════════════════════════════════════════════╝
```

---

## 相关命令

- `/model-doctor` - 检查所有渠道状态
- `/model-stats` - 查看使用统计
- `/model-configure` - 配置 API Key
- `/switch-model --list` - 列出所有渠道

---

## 注意事项

1. **上下文保留**：切换模型后，当前会话上下文保留
2. **成本监控**：Opus 成本较高，建议复杂任务完成后切回 Sonnet
3. **API Key 安全**：不提交到 git，使用环境变量存储
4. **切换频率**：避免过于频繁切换，保持任务连贯性

---

*版本：1.0.0*
*最后更新：2026-03-05*

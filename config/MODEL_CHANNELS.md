# 大模型渠道配置

> **版本**：1.0.0
> **创建日期**：2026-03-05

---

## 📋 概述

支持快速切换不同的大模型渠道，根据任务需求选择最合适的模型。

---

## 🤖 支持的大模型渠道

| 渠道 | 模型 | 适用场景 | 成本 |
|------|------|---------|------|
| **Claude** | claude-sonnet-4-20250514 | 主力开发、复杂任务 | $$$ |
| **Claude** | claude-opus-4-20250514 | 架构设计、深度推理 | $$$$ |
| **Claude** | claude-3-5-haiku-20241022 | 快速任务、简单修改 | $ |
| **MiniMax** | minimax-text-01 | 中文内容生成 | $ |
| **GLM** | glm-4-plus | 中文理解、代码生成 | $$ |
| **Qwen** | qwen-max | 多语言支持 | $$ |
| **DeepSeek** | deepseek-chat | 代码生成、数学推理 | $ |

---

## 🔧 渠道配置

### 当前激活渠道

```bash
# 查看当前渠道
cat ~/.claude/active-model

# 输出示例:
claude-sonnet-4-20250514
```

### 配置文件位置

| 文件 | 说明 |
|------|------|
| `~/.claude/active-model` | 当前激活的模型 |
| `~/.claude/model-channels.yaml` | 所有渠道配置 |
| `~/.claude/model-presets/` | 预设配置目录 |

---

## 🚀 快速切换

### 命令方式

```bash
# 切换到 Claude Opus (深度推理)
/switch-model claude-opus

# 切换到 Claude Haiku (快速任务)
/switch-model claude-haiku

# 切换到 MiniMax (中文生成)
/switch-model minimax

# 切换到 GLM (中文理解)
/switch-model glm

# 查看可用渠道
/switch-model --list
```

### 快捷命令

```bash
# 使用别名
/opus    # 切换到 Claude Opus
/sonnet  # 切换到 Claude Sonnet
/haiku   # 切换到 Claude Haiku
/minimax # 切换到 MiniMax
/glm     # 切换到 GLM
```

---

## 📊 渠道选择建议

### 按任务类型

| 任务类型 | 推荐模型 | 原因 |
|---------|---------|------|
| 复杂功能开发 | claude-sonnet / claude-opus | 代码能力强、推理深 |
| 架构设计 | claude-opus | 深度推理最佳 |
| 快速修改 | claude-haiku | 响应快、成本低 |
| 中文写作 | minimax / glm | 中文优化 |
| 代码审查 | claude-sonnet | 代码理解强 |
| 数学推理 | deepseek / claude-opus | 数学能力强 |
| 多语言翻译 | qwen / claude | 多语言支持好 |

### 按成本预算

| 预算 | 推荐模型 |
|------|---------|
| 无限 | claude-opus |
| 充足 | claude-sonnet |
| 经济 | claude-haiku / minimax / glm |
| 极限 | deepseek |

---

## 🔍 渠道状态诊断

```bash
# 检查所有渠道状态
/model-doctor

# 输出示例:
# ═══════════════════════════════════════
#         大模型渠道状态
# ═══════════════════════════════════════
#
# ✅ Claude Sonnet (当前)
# ✅ Claude Opus
# ✅ Claude Haiku
# ⚠️  MiniMax (需要配置 API Key)
# ✅ GLM
# ⚠️  Qwen (余额不足)
# ✅ DeepSeek
```

---

## 🔐 API Key 管理

### 配置 API Key

```bash
# 配置 MiniMax
/model-configure minimax-key "YOUR_API_KEY"

# 配置 GLM
/model-configure glm-key "YOUR_API_KEY"

# 配置 DeepSeek
/model-configure deepseek-key "YOUR_API_KEY"
```

### 安全存储

| 渠道 | 存储位置 | 说明 |
|------|---------|------|
| Claude | `~/.claude/credentials` | 自动配置 |
| MiniMax | `~/.claude/credentials/minimax` | 手动配置 |
| GLM | `~/.claude/credentials/glm` | 手动配置 |
| DeepSeek | `~/.claude/credentials/deepseek` | 手动配置 |

---

## 📝 使用场景

### 场景 1：复杂功能开发

```bash
# 1. 开始复杂任务
/switch-model claude-opus

# 2. 开始任务规划
/plan "实现分布式缓存系统"

# 3. 执行开发
# ... 开发完成

# 4. 切回主力模型
/switch-model claude-sonnet
```

### 场景 2：中文内容生成

```bash
# 1. 切换到 MiniMax
/switch-model minimax

# 2. 生成中文内容
# "写一篇关于 AI 的技术博客..."

# 3. 切回主力模型
/switch-model claude-sonnet
```

### 场景 3：快速迭代修改

```bash
# 1. 切换到 Haiku (快速、便宜)
/switch-model claude-haiku

# 2. 快速修改代码
# "把这个函数改成异步的..."
# "修复这个 bug..."

# 3. 需要深度思考时切回
/switch-model claude-sonnet
```

---

## 🔄 自动切换规则

### 基于任务类型自动切换

```yaml
# ~/.claude/model-channels.yaml
autoSwitch:
  enabled: true
  rules:
    - pattern: "架构设计 | 系统规划"
      model: claude-opus
    - pattern: "快速修复 | 简单修改"
      model: claude-haiku
    - pattern: "中文写作 | 翻译"
      model: minimax
    - pattern: "代码审查 | 安全分析"
      model: claude-sonnet
```

### 基于成本自动切换

```yaml
# 成本阈值
costThreshold:
  daily: 10  # 每日预算上限
  task: 2    # 单任务预算上限

# 超出后自动切换到经济模型
exceedAction:
  switch: claude-haiku
  notify: true
```

---

## 📊 使用统计

```bash
# 查看模型使用统计
/model-stats

# 输出示例:
# ═══════════════════════════════════════
#        大模型使用统计 (今日)
# ═══════════════════════════════════════
#
# Claude Sonnet: 45 次 ($2.50)
# Claude Opus:   12 次 ($3.60)
# Claude Haiku:  28 次 ($0.30)
# MiniMax:        5 次 ($0.15)
# GLM:            3 次 ($0.20)
#
# 总计：93 次 ($6.75)
# 预算剩余：$3.25
```

---

## 🚫 注意事项

| 注意 | 说明 |
|------|------|
| 🔒 **API Key 安全** | 不提交到 git，使用环境变量 |
| 💰 **成本监控** | 设置预算提醒，避免超支 |
| 🔄 **切换频率** | 避免频繁切换，保持上下文连贯 |
| 📝 **上下文保持** | 切换模型后上下文保留 |

---

## 🔗 相关文档

- [大模型渠道切换命令](../commands/switch-model.md)
- [Agent 行为规范](../templates/AGENTS.md.template)
- [成本优化指南](../guidelines/cost-optimization.md)

---

*版本：1.0.0*
*最后更新：2026-03-05*

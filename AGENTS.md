# Agent 行为规范

> 定义 Agent 的工作方式、行为边界和协作规则
> **版本**：3.0.0 (整合 Agent-Reach + 大模型渠道切换)

---

## 🤖 大模型渠道切换 ⭐ NEW

### 支持的模型渠道

| 渠道 | 模型 | 适用场景 | 成本 |
|------|------|---------|------|
| **Claude Opus** | claude-opus-4 | 架构设计、深度推理 | $$$$ |
| **Claude Sonnet** | claude-sonnet-4 | 主力开发、平衡性能 | $$$ |
| **Claude Haiku** | claude-3.5-haiku | 快速任务、经济实惠 | $ |
| **MiniMax** | minimax-text-01 | 中文内容生成 | $ |
| **GLM** | glm-4-plus | 中文理解、代码生成 | $$ |
| **DeepSeek** | deepseek-chat | 代码生成、数学推理 | $ |

### 快速切换命令

```bash
# 切换模型
/opus           # Claude Opus (深度推理)
/sonnet         # Claude Sonnet (主力开发)
/haiku          # Claude Haiku (快速修改)
/minimax        # MiniMax (中文写作)
/glm            # GLM-4 (中文理解)
/deepseek       # DeepSeek (数学推理)

# 查看状态
/switch-model --list     # 列出所有渠道
/switch-model --current  # 查看当前模型
/switch-model --stats    # 查看使用统计
```

### 渠道选择原则

| 任务类型 | 推荐模型 | 说明 |
|---------|---------|------|
| 复杂架构设计 | Claude Opus | 深度推理最佳 |
| 主力开发 | Claude Sonnet | 性能成本平衡 |
| 快速修改 | Claude Haiku | 响应快、成本低 |
| 中文内容 | MiniMax / GLM | 中文优化 |
| 数学推理 | DeepSeek / Opus | 数学能力强 |

---

## 🌐 Agent-Reach 互联网访问能力 ⭐ NEW

### 核心原则

Agent-Reach 为 AI Agent 提供互联网访问能力，支持 13+ 平台的无缝集成：

| 平台 | 用途 | 配置状态 |
|------|------|---------|
| 🌐 **网页** | 阅读任意网页 | ✅ 无需配置 |
| 📺 **YouTube** | 字幕提取 + 视频搜索 | ✅ 无需配置 |
| 📡 **RSS** | 阅读任意 RSS/Atom 源 | ✅ 无需配置 |
| 📦 **GitHub** | 读公开仓库 + 搜索 | ⚠️ 登录解锁完整功能 |
| 🐦 **Twitter/X** | 搜索推文、浏览时间线 | ⚠️ 需 Cookie |
| 📺 **B 站** | 字幕提取 + 视频搜索 | ⚠️ 服务器需代理 |
| 📖 **Reddit** | 搜索（Exa 免费） | ⚠️ 需代理 |
| 📕 **小红书** | 阅读、搜索、互动 | ⚠️ 需 Docker 服务 |
| 🎵 **抖音** | 视频解析、无水印下载 | ⚠️ 需 MCP 服务 |
| 🔍 **全网搜索** | AI 语义搜索 | ✅ 自动配置（MCP） |

### 使用原则

1. **先搜索再实现** - 避免重复造轮子
2. **多渠道验证** - GitHub + Twitter + YouTube 交叉验证
3. **及时记录** - 调研结果立即写入记忆
4. **凭据安全** - Cookie 使用专用小号，本地存储不上传

---

## 🔄 会话启动流程

每次会话启动时，Agent 必须按顺序执行以下步骤：

### 1. 读取核心文件
```bash
# 1. 读取用户信息
cat USER.md

# 2. 读取人格设定
cat SOUL.md

# 3. 读取今日和昨日日志（提供近期上下文）
cat memory/$(date +%Y-%m-%d).md
cat memory/$(date -d yesterday +%Y-%m-%d).md

# 4. 仅主会话：读取长期记忆
# （群组对话中不加载 MEMORY.md，避免隐私泄露）
if [ "$SESSION_TYPE" = "main" ]; then
  cat MEMORY.md
fi
```

### 2. 环境检查
```bash
# 确认工作目录
pwd

# 检查 Git 状态
git status

# 查看最近提交
git log --oneline -10

# 检查 Agent-Reach 状态 ⭐ NEW
agent-reach doctor
```

### 3. 状态恢复
- 检查是否有未完成的工作流
- 读取最近的检查点
- 确认可以继续执行的任务
- 检查 Agent-Reach 渠道状态 ⭐ NEW
```

---

## 📝 记忆写入规则

### 什么时候写什么？

#### 写入 MEMORY.md 的内容：
- ✅ 用户偏好（联系方式、工作时间、语言习惯）
- ✅ 策略性决策（"以后部署都要了确认"）
- ✅ 经验教训（"2026-02-13 配置错误导致服务中断"）
- ✅ 长期项目状态（"博客系列文章进度 3/16"）
- ✅ 互联网调研最佳实践（Agent-Reach 提炼） ⭐ NEW

#### 写入 memory/YYYY-MM-DD.md 的内容：
- ✅ 当日任务与进展
- ✅ 临时决策（"今天先通过测试，明天补"）
- ✅ 技术调研笔记（Agent-Reach 搜索结果） ⭐ NEW
- ✅ 待办事项
- ✅ 互联网调研中间结果 ⭐ NEW

#### 不要写入记忆文件的内容：
- ❌ 敏感凭据（API key、密码）→ 使用 `~/.openclaw/credentials/`
- ❌ Agent-Reach Cookie → 使用 `~/.agent-reach/config.yaml` ⭐ NEW
- ❌ 临时计算结果（"3 + 5 = 8"）→ 下次重新计算即可
- ❌ 工具返回的原始日志 → 太长，写总结即可

> **核心原则**：如果你希望 Agent 在下次会话中记住，就必须写文件。
> 所谓的"心智笔记"不存在，文件是唯一的真相。

---

## 🛡️ 安全规则

### 敏感操作确认

| 操作类型 | 确认级别 | 说明 |
|---------|---------|------|
| 代码校验 | 无需确认 | 完全自动执行 |
| 构建测试 | 无需确认 | 失败时通知 |
| 内容生成 | 审查确认 | 发布前审查 |
| 部署上线 | 最终确认 | 显示 diff 后确认 |
| 删除数据 | 每步确认 | 破坏性操作 |
| 配置变更 | 二次确认 | 显示 diff，二次确认 |

### 敏感信息保护

```bash
# 禁止记录的内容
- API Key、密码、Token
- 服务器 IP 地址（使用占位符）
- 个人 Telegram ID
- 数据库连接字符串
- Agent-Reach Cookie（存入 ~/.agent-reach/config.yaml） ⭐ NEW
```

### 日志脱敏

在记录日志或发送消息前必须脱敏：
- API Key → `<API_KEY_REDACTED>`
- 密码 → `<PASSWORD_REDACTED>`
- IP 地址 → `<IP_REDACTED>`
- Token → `<TOKEN_REDACTED>`

---

## 🤖 工作流管理

### 工作流状态

```typescript
interface WorkflowState {
  id: string;
  type: "deploy" | "content-creation" | "monitoring" | "research"; ⭐ NEW
  status: "pending" | "running" | "waiting" | "completed" | "failed";
  currentStep: number;
  totalSteps: number;
  context: Record<string, any>;
}
```

### 互联网调研工作流 ⭐ NEW

| 阶段 | 步骤 | Agent-Reach 命令 |
|------|------|-----------------|
| 准备 | 检查渠道状态 | `agent-reach doctor` |
| 执行 | GitHub 搜索 | `gh search repos "..."` |
| 执行 | Twitter 舆论 | `xreach search "..."` |
| 执行 | YouTube 教程 | `yt-dlp --dump-json "URL"` |
| 执行 | 全网搜索 | `exa search "..."` |
| 记录 | 写入 Hourly 层 | `echo "..." >> memory/今日.md` |
| 归档 | 提炼最佳实践 | 更新 MEMORY.md |

### 人工介入点

| 工作流类型 | 介入点 | 确认内容 |
|-----------|--------|---------|
| deploy | final-confirm | 部署前最终确认 |
| config-change | show-diff | 配置变更显示 diff |
| delete | step-by-step | 删除操作每步确认 |
| publish | pre-review | 发布前审查 |

### 执行原则

1. **提供选项**，而非做决定
   - ❌ 坏做法：Agent 自己决定重试
   - ✅ 好做法：分析问题，提供选项（重试/跳过/回滚）

2. **解释行为**，而非黑盒执行
   - 执行前说明计划和预计时间
   - 执行后报告结果和下一步

3. **持续学习**，而非固定规则
   - 从错误中学习并记录教训
   - 定期更新行为规范

---

## 📊 上下文管理

### 阈值管理

| 阈值 | 触发动作 | 通知级别 |
|------|---------|---------|
| 70% | 预警通知 | P2 |
| 80% | 自动保存到 Memory | P2 |
| 90% | 强制 compact | P1 |

### Memory Flush

当上下文接近压缩阈值时：
1. 提醒将重要信息写入 memory 文件
2. 然后再执行 compact
3. 确保关键决策不会因压缩而丢失

---

## 🔍 检索优化

### 搜索策略

| 查询类型 | 推荐策略 | 说明 |
|---------|---------|------|
| 精确查询 | 关键词匹配 | 具体技术问题、commit hash |
| 语义搜索 | 向量检索 | 概念性探索、相似问题 |
| 历史回溯 | 时间范围 | 指定日期范围 |
| 多维分析 | 标签组合 | 多条件过滤 |

### 混合检索配置

```json
{
  "vectorWeight": 0.7,
  "textWeight": 0.3,
  "recency": {
    "enabled": true,
    "halfLifeDays": 30
  },
  "mmr": {
    "enabled": true,
    "lambda": 0.7
  }
}
```

---

## 🔄 错误处理

### 错误分级

| 级别 | 类型 | 处理策略 |
|------|------|---------|
| L1 | 网络超时、临时失败 | 自动重试，最多 3 次 |
| L2 | API 不可用、资源缺失 | 尝试备选方案，通知人类 |
| L2.5 | Agent-Reach Cookie 过期 ⭐ NEW | 引导重新配置 Cookie |
| L3 | 权限错误、数据损坏 | 立即停止，通知人类 |

### 重试策略

```bash
# 指数退避
延迟时间 = 初始延迟 * (2 ^ 重试次数)
初始延迟：1 秒
最大延迟：60 秒
最大重试：3 次
```

---

## 📅 定期任务

### Heartbeat 检查

| 时间 | 任务 | 说明 |
|------|------|------|
| 每小时 | sync-hourly | 同步小时级记忆 |
| 每日 23:00 | archive-daily | 归档日志 |
| 每周日 22:00 | summarize-weekly | 周度总结 |
| 每日 9:00 | check-agent-reach ⭐ NEW | 检查 Agent-Reach 渠道状态 |

### 周度回顾

每周执行：
1. 读取过去 7 天的 memory/YYYY-MM-DD.md
2. 提取重要决策和教训
3. 更新 MEMORY.md 中的相关章节
4. 清理 MEMORY.md 中过时的信息

---

## 🚫 禁止行为

- ❌ 在群组对话中引用 MEMORY.md 内容
- ❌ 使用示例数据时不使用占位符
- ❌ 未经确认执行破坏性操作
- ❌ 记录敏感信息到日志
- ❌ 跳过测试直接部署
- ❌ 忘记写入记忆文件
- ❌ Agent-Reach Cookie 写入记忆文件（应存入 ~/.agent-reach/config.yaml） ⭐ NEW
- ❌ 互联网调研结果不记录来源 ⭐ NEW
- ❌ 使用过期 Cookie 或凭据 ⭐ NEW

---

> **Agent 行为准则**：
> 1. 始终先读取上下文再行动
> 2. 重要决策必须记录
> 3. 敏感操作必须确认
> 4. 错误必须学习和改进
> 5. 持续优化记忆管理
> 6. 先搜索互联网再实现（Agent-Reach） ⭐ NEW

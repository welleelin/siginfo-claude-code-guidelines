# sig-claude-code-guidelines - 项目概要

> **版本**: 2.0.0
> **最后更新**: 2026-03-05
> **状态**: 生产就绪

---

## 📌 一句话介绍

一套经过实战验证的 **AI 辅助软件开发规范**，让团队开发像流水线一样高效。

---

## 🎯 核心价值

### 解决的问题

| 痛点 | 后果 | 我们的方案 |
|------|------|-----------|
| 开发前没想清楚 | 写到一半推倒重来 | 任务规划 + 流程图可视化 |
| 测试后写 | 上线后 bug 频发 | TDD 测试驱动开发 |
| 代码提交混乱 | 出问题找不到原因 | 规范提交 + 质量门禁 |
| 新人上手慢 | 全靠口口相传 | 完整文档 + 行动准则 |
| AI 使用随意 | 效率低下 | 多 Agent 协作模式 |

### 带来的收益

```
✅ 开发效率提升 50%+  - 明确的流程，减少返工
✅ Bug 率降低 70%+    - 测试先行，质量前置
✅ 新人上手时间缩短   - 按文档操作，3 天上手
✅ 代码质量稳定       - 统一规范，自动审查
✅ AI 能力最大化      - 多 Agent 协作，效率翻倍
```

---

## 🚀 快速开始

### 5 分钟体验

```bash
# 1. 克隆项目
git clone https://github.com/your-org/sig-claude-code-guidelines.git
cd sig-claude-code-guidelines

# 2. 安装规则
./scripts/install.sh

# 3. 开始第一个任务
/plan "实现用户登录功能"
```

### 核心命令

| 命令 | 说明 | 频率 |
|------|------|------|
| `/plan "任务"` | 任务规划（含流程图） | 每个任务 |
| `/tdd` | 启动 TDD 开发流程 | 编码时 |
| `/code-review` | 代码审查 | 完成后 |
| `/switch-model` | 切换大模型渠道 | 按需 |
| `/memory-search` | 搜索项目记忆 | 按需 |

---

## 📋 核心流程

### 一个任务的完整生命周期

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  会话启动    │───▶│  任务规划    │───▶│  TDD 开发     │───▶│  验证提交    │
│  准备上下文  │    │  可视化计划  │    │  测试→实现   │    │  质量门禁    │
└──────────────┘    └──────────────┘    └──────────────┘    └──────────────┘
```

### 四阶段详解

| 阶段 | 目标 | 关键动作 | 产出物 |
|------|------|----------|--------|
| **1. 会话启动** | 环境准备 | 检查插件、读取文档 | 清晰上下文 |
| **2. 任务规划** | 想清楚再做 | 写计划、画流程图 | 实现计划 + 流程图 |
| **3. TDD 开发** | 高质量实现 | 写测试→实现→重构 | 通过测试的代码 |
| **4. 验证提交** | 质量达标 | 构建、测试、审查 | 规范提交 |

---

## 🏗️ 项目结构

```
sig-claude-code-guidelines/
│
├── README.md                 # 完整文档（36KB）
├── PROJECT_OVERVIEW.md       # 本文件 - 项目概要
├── CLAUDE.md                 # 项目使用说明
│
├── guidelines/               # 📋 核心准则（12 个文档）
│   ├── 00-SYSTEM_OVERVIEW.md    # 系统总则
│   ├── 01-ACTION_GUIDELINES.md  # 行动准则 ⭐
│   ├── 02-TDD_WORKFLOW.md       # TDD 开发流程
│   ├── 04-E2E_TESTING_FLOW.md   # E2E 测试流程
│   ├── 05-QUALITY_GATE.md       # 质量门禁
│   ├── 08-LONG_RUNNING_AGENTS.md # 长期运行 Agent
│   ├── 11-LONG_TERM_MEMORY.md    # 长期记忆 ⭐
│   └── 12-AGENT_REACH_INTEGRATION.md # 互联网访问 ⭐
│
├── scripts/                  # 🛠️ 工具脚本（13 个）
│   ├── init-plugins.sh       # 插件初始化
│   ├── init-memory.sh        # 记忆系统初始化
│   ├── checkpoint.sh         # 检查点管理
│   ├── switch-model.sh       # 大模型切换 ⭐
│   ├── init-model-channels.sh # 模型渠道初始化 ⭐
│   └── model-usage-check.sh  # 用量监控 ⭐
│
├── commands/                 # 通用命令（6 个）
│   ├── plan.md               # 任务规划
│   ├── tdd.md                # TDD 开发
│   ├── code-review.md        # 代码审查
│   └── switch-model.md       # 模型切换
│
├── agents/                   # Agent 定义（10+ 个）
│   ├── planner.md            # 规划专家
│   ├── architect.md          # 架构专家
│   ├── tdd-guide.md          # TDD 专家
│   └── memory-keeper.md      # 记忆管理 ⭐
│
├── templates/                # 项目模板（6 个）
│   ├── CLAUDE.md.template    # 项目配置
│   ├── MEMORY.md.template    # 长期记忆
│   └── task.json.template    # 任务列表
│
└── examples/                 # 示例项目
    └── requisition-system/   # 需求单系统（完整案例）
```

---

## ⭐ 核心特性

### 1. 测试驱动开发（TDD）

```
RED    → 写失败测试
GREEN  → 实现功能让测试通过
REFACTOR → 重构优化代码
VERIFY → 验证闭环
```

**收益**: 测试覆盖率自然达到 80%+，bug 率降低 70%

### 2. 多 Agent 协作

| Agent | 擅长 | 何时使用 |
|-------|------|---------|
| Planner | 任务规划 | 开始新任务 |
| Architect | 系统设计 | 架构决策 |
| TDD-Guide | 测试开发 | 写代码时 |
| Code-Reviewer | 代码审查 | 完成后 |
| E2E-Runner | E2E 测试 | 运行测试 |

**收益**: 专人专事，效率提升 50%+

### 3. 长期记忆系统（三层架构）

```
Hourly 层 → 短期记忆（每小时同步）
Daily 层  → 中期记忆（每日 23:00 归档）
Weekly 层 → 长期记忆（每周日总结）
```

**收益**: Compact 后不遗忘上下文，任务状态可恢复

### 4. 大模型渠道切换 ⭐ NEW

支持 7+ 个模型渠道，带用量监控和智能推荐：

| 类别 | 模型 | 成本 | 适用场景 |
|------|------|------|---------|
| 国际 | Claude Opus/Sonnet/Haiku | 4x/1x/0.1x | 全场景 |
| 国内 | Qwen/GLM/MiniMax/DeepSeek | 0.3x-0.8x | 中文/数学 |

**用量告警**: 70% 警告 → 85% 建议切换 → 95% 自动推荐

### 5. Agent-Reach 互联网访问 ⭐ NEW

一键解锁互联网能力：

- 🌐 阅读任意网页
- 📺 YouTube 字幕提取
- 🐦 Twitter/X 阅读
- 📦 GitHub 读写
- 🔍 全网搜索

**收益**: 实时获取最新信息，不再局限于训练数据

---

## 📊 质量门禁

任务完成前必须通过：

```
□ 构建成功 - npm run build 无错误
□ 测试通过 - 所有 E2E 测试 100% 通过
□ 失败修复 - 可修复的已修复，无法修复的已记录
□ 代码审查 - 无 CRITICAL/HIGH 级别问题
□ 文档更新 - MEMORY.md、task.json 已更新
□ Git 提交 - 所有更改已规范提交
```

**全部通过后方可进入下一任务**

---

## 🔌 必备插件

| 插件 | 用途 | 安装 |
|------|------|------|
| bmad-method | 需求分析 | `/plugin install bmad-method` |
| everything-claude-code | 命令库 | 预装 |
| workflow-studio | 流程图 | `/plugin install workflow-studio` |
| pencil | UI 设计 | `/plugin install pencil` |

---

## 🤖 与 Claude Monitor UI 集成

| 功能 | 负责项目 |
|------|---------|
| 行动准则定义 | sig-claude-code-guidelines |
| 任务监督 | claude-monitor-ui |
| 通知发送 | claude-monitor-ui (飞书/钉钉/短信) |
| 确认反馈 | claude-monitor-ui |

**API 端点**: `http://localhost:8083/api/`

---

## 📚 学习路径

### 第 1 周 - 新手入门
- [ ] 阅读 `PROJECT_OVERVIEW.md`（本文件）
- [ ] 阅读 `guidelines/01-ACTION_GUIDELINES.md`
- [ ] 完成第一个 TDD 任务

### 第 2-4 周 - 进阶提升
- [ ] 学习多 Agent 协作
- [ ] 掌握 E2E 测试流程
- [ ] 在实际项目中应用

### 1-3 个月 - 精通应用
- [ ] 根据团队调整规范
- [ ] 贡献最佳实践
- [ ] 帮助新人成长

---

## 🔗 相关资源

| 文档 | 说明 |
|------|------|
| [README.md](README.md) | 完整文档（36KB）|
| [docs/getting-started.md](docs/getting-started.md) | 详细安装指南 |
| [guidelines/01-ACTION_GUIDELINES.md](guidelines/01-ACTION_GUIDELINES.md) | 核心行动准则 |
| [config/MODEL_CHANNELS.md](config/MODEL_CHANNELS.md) | 大模型配置指南 |

---

## 🤝 贡献

欢迎贡献！你可以：

1. **提交 Issue** - 文档问题或改进建议
2. **提交 PR** - 修复 typo 或补充内容
3. **分享案例** - 应用成功经验

---

## 📄 许可证

MIT License

---

**版本**: 2.0.0
**最后更新**: 2026-03-05
**维护者**: 行动准则项目组

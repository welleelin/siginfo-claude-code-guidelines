# OMC Tumx 模式集成指南

> **版本**：1.0.0
> **最后更新**：2026-03-08
> **用途**：在 Pencil 设计工作流中使用 OMC Tumx 模式实现多模型协作

---

## 📋 概述

OMC (Open Model Context) 的 Tumx 模式允许多个 AI 模型同时协作完成设计任务，每个模型发挥其独特优势。

### 核心价值

| 特性 | 说明 |
|------|------|
| 🤝 **多模型协作** | Claude、GPT-4、Gemini 等模型同时工作 |
| 🎯 **专业分工** | 每个模型负责其擅长的领域 |
| 🔄 **实时同步** | 设计成果自动合并和同步 |
| 💰 **成本优化** | 根据任务复杂度选择合适的模型 |

---

## 🏗️ 架构设计

### Tumx + Pencil 集成架构

```
┌─────────────────────────────────────────────────────────────┐
│              OMC Tumx + Pencil 协作架构                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │  Claude Sonnet  │    │     GPT-4       │                │
│  │  UX 设计        │    │  视觉设计       │                │
│  │  交互逻辑       │    │  配色方案       │                │
│  └────────┬────────┘    └────────┬────────┘                │
│           │                      │                          │
│           └──────────┬───────────┘                          │
│                      │                                      │
│                      ▼                                      │
│           ┌─────────────────┐                               │
│           │   OMC Tumx      │                               │
│           │   协调器        │                               │
│           └────────┬────────┘                               │
│                    │                                        │
│                    ▼                                        │
│           ┌─────────────────┐                               │
│           │     Gemini      │                               │
│           │  设计验证       │                               │
│           │  可访问性检查   │                               │
│           └────────┬────────┘                               │
│                    │                                        │
│                    ▼                                        │
│           ┌─────────────────┐                               │
│           │  Pencil MCP     │                               │
│           │  设计画布       │                               │
│           └─────────────────┘                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 快速开始

### 1. 安装 OMC

```bash
# 安装 OMC CLI
npm install -g @omc/cli

# 验证安装
omc --version
```

### 2. 配置 Tumx 模式

```bash
# 初始化 Tumx 配置
omc tumx init

# 配置模型
omc tumx config add-model claude-sonnet-4 --role ux-designer
omc tumx config add-model gpt-4 --role visual-designer
omc tumx config add-model gemini --role validator
```

### 3. 启动 Tumx 会话

```bash
# 启动 Tumx 模式
omc tumx start

# 查看状态
omc tumx status
```

---

## 🎨 使用场景

### 场景 1：创建登录页面设计

```bash
# 1. 创建设计任务
omc tumx task create "设计用户登录页面"

# 2. 分配给不同模型
omc tumx assign claude-sonnet-4 "UX 设计和交互逻辑"
omc tumx assign gpt-4 "视觉设计和配色方案"
omc tumx assign gemini "设计验证和可访问性检查"

# 3. 查看协作进度
omc tumx status

# 4. 合并设计成果
omc tumx merge designs/login.pen

# 5. 提取设计 Token
./scripts/extract-design-tokens.sh login.pen
```

### 场景 2：设计系统创建

```bash
# 1. 创建设计系统任务
omc tumx task create "创建完整的设计系统"

# 2. 分工协作
omc tumx assign claude-sonnet-4 "定义组件规范和交互模式"
omc tumx assign gpt-4 "设计颜色系统和排版规范"
omc tumx assign gemini "验证设计一致性和可访问性"

# 3. 实时同步
omc tumx sync designs/design-system.pen

# 4. 生成设计 Token
./scripts/extract-design-tokens.sh design-system.pen
```

### 场景 3：设计审查和优化

```bash
# 1. 创建审查任务
omc tumx task create "审查现有设计并提出优化建议"

# 2. 多角度审查
omc tumx assign claude-sonnet-4 "用户体验审查"
omc tumx assign gpt-4 "视觉设计审查"
omc tumx assign gemini "技术可行性审查"

# 3. 收集反馈
omc tumx feedback collect

# 4. 应用优化
omc tumx apply-feedback designs/dashboard.pen
```

---

## 🔧 配置选项

### Tumx 配置文件

```json
{
  "tumx": {
    "models": [
      {
        "name": "claude-sonnet-4",
        "role": "ux-designer",
        "capabilities": ["interaction-design", "user-flow", "wireframing"],
        "priority": 1
      },
      {
        "name": "gpt-4",
        "role": "visual-designer",
        "capabilities": ["color-theory", "typography", "visual-hierarchy"],
        "priority": 2
      },
      {
        "name": "gemini",
        "role": "validator",
        "capabilities": ["accessibility", "consistency", "best-practices"],
        "priority": 3
      }
    ],
    "workflow": {
      "sequential": false,
      "parallel": true,
      "merge-strategy": "consensus"
    },
    "output": {
      "format": "pen",
      "auto-extract-tokens": true,
      "generate-report": true
    }
  }
}
```

### 模型角色定义

| 模型 | 角色 | 擅长领域 | 使用场景 |
|------|------|---------|---------|
| Claude Sonnet 4 | UX 设计师 | 交互设计、用户流程、信息架构 | 复杂交互、多步骤流程 |
| GPT-4 | 视觉设计师 | 配色方案、排版、视觉层次 | 品牌设计、视觉风格 |
| Gemini | 验证专家 | 可访问性、一致性、最佳实践 | 设计审查、质量保证 |

---

## 📊 工作流集成

### 与 sig-guidelines 集成

```bash
# Phase 2: 任务规划
/plan "实现用户注册功能"

# 启动 Tumx 设计协作
omc tumx start
omc tumx task create "设计用户注册页面"
omc tumx assign claude-sonnet-4 "UX 设计"
omc tumx assign gpt-4 "视觉设计"
omc tumx assign gemini "设计验证"

# 等待设计完成
omc tumx wait

# 合并设计成果
omc tumx merge designs/register.pen

# 提取设计 Token
./scripts/extract-design-tokens.sh register.pen

# Phase 4: TDD 开发
# 根据设计 Token 生成代码
# ...
```

### 自动化脚本集成

```bash
# 在 extract-design-tokens.sh 中添加 Tumx 支持
if command -v omc &> /dev/null; then
    log_info "检测到 OMC Tumx，启用多模型协作"
    omc tumx extract-tokens "$DESIGN_FILE" --output "$TOKEN_DIR"
else
    log_info "使用标准提取流程"
    # 标准提取逻辑
fi
```

---

## 🛠️ 最佳实践

### 1. 合理分工

```bash
# ✅ 好的分工
omc tumx assign claude-sonnet-4 "复杂交互逻辑设计"
omc tumx assign gpt-4 "品牌视觉风格设计"
omc tumx assign gemini "WCAG 2.1 可访问性验证"

# ❌ 不好的分工
omc tumx assign claude-sonnet-4 "所有设计工作"
# 没有发挥多模型协作的优势
```

### 2. 设置合理的优先级

```bash
# 按照设计流程设置优先级
# 1. UX 设计（定义交互）
# 2. 视觉设计（定义样式）
# 3. 设计验证（确保质量）
```

### 3. 定期同步和合并

```bash
# 每 30 分钟同步一次
omc tumx sync --interval 30m

# 关键节点手动合并
omc tumx merge designs/feature.pen
```

### 4. 记录设计决策

```bash
# 自动生成设计决策记录
omc tumx export-decisions > docs/design-decisions/feature.md
```

---

## 🔍 故障排查

### Q1: Tumx 启动失败

**解决方案**:

```bash
# 检查 OMC 版本
omc --version

# 重新初始化
omc tumx reset
omc tumx init

# 检查配置
omc tumx config validate
```

### Q2: 模型协作冲突

**解决方案**:

```bash
# 查看冲突
omc tumx conflicts list

# 手动解决冲突
omc tumx conflicts resolve --strategy manual

# 或使用自动解决
omc tumx conflicts resolve --strategy consensus
```

### Q3: 设计合并失败

**解决方案**:

```bash
# 检查设计文件
./scripts/validate-design-files.sh

# 分步合并
omc tumx merge --step-by-step designs/feature.pen

# 回滚到上一个版本
omc tumx rollback
```

---

## 📚 相关文档

- [OMC 官方文档](https://omc.dev/docs)
- [Tumx 模式指南](https://omc.dev/docs/tumx)
- [Pencil 集成文档](PENCIL_INTEGRATION.md)
- [Pencil 快速开始](PENCIL_QUICK_START.md)

---

## 🎯 下一步

1. ✅ 安装 OMC CLI
2. ✅ 配置 Tumx 模式
3. ✅ 尝试第一个协作设计任务
4. ✅ 集成到现有工作流

---

*最后更新：2026-03-08*

> **核心理念**：
> 1. 多模型协作 - 发挥各自优势
> 2. 专业分工 - 提高设计质量
> 3. 实时同步 - 保持一致性
> 4. 自动化集成 - 提升效率

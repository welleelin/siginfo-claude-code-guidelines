# Guidelines 目录索引

> **版本**：1.0.0
> **最后更新**：2026-03-08
> **用途**：帮助 Claude Code 快速定位和按需加载相关规范文档

---

## 📋 使用说明

### 如何使用本目录

1. **理解问题**：首先理解用户的需求或遇到的问题
2. **查找分类**：在下方目录中找到相关的问题分类
3. **按需加载**：只读取需要的文档，避免一次性加载所有内容
4. **组合使用**：复杂问题可能需要组合多个文档

### 目录结构

```
guidelines/
├── 00-SYSTEM_OVERVIEW.md          # 系统总则（必读）
├── 01-ACTION_GUIDELINES.md        # 行动准则（必读）
├── 02-TDD_WORKFLOW.md             # TDD 开发流程
├── 03-MULTI_AGENT.md              # 多 Agent 协作
├── 04-E2E_TESTING_FLOW.md         # E2E 测试流程
├── 05-QUALITY_GATE.md             # 质量门禁
├── 06-TRACEABILITY.md             # 可追溯性规范
├── 07-PLUGIN_MANAGEMENT.md        # 插件管理
├── 08-LONG_RUNNING_AGENTS.md      # 长期运行 Agent
├── 09-AUTOMATION_MODES.md         # 自动化模式配置
├── 10-ANTHROPIC_LONG_RUNNING_AGENTS.md  # Anthropic 官方指南
├── 11-LONG_TERM_MEMORY.md         # 长期记忆管理
├── 12-AGENT_REACH_INTEGRATION.md  # Agent-Reach 集成
├── 13-COLLABORATION_EFFICIENCY.md # 协作效率提升
├── 14-DETERMINISTIC_DEVELOPMENT.md # 确定性开发
└── 15-STABLE_ZONE_PROTECTION.md   # 稳定区域保护
```

---

## 🎯 按问题分类索引

### 1. 会话启动与初始化

**问题场景**：
- 新会话开始，不知道从哪里开始
- 需要检查项目状态
- 需要加载项目上下文

**相关文档**：
- 📖 [00-SYSTEM_OVERVIEW.md](00-SYSTEM_OVERVIEW.md) - 系统总则，会话启动流程
- 📖 [01-ACTION_GUIDELINES.md](01-ACTION_GUIDELINES.md) - Phase 1: 会话启动准备
- 📖 [07-PLUGIN_MANAGEMENT.md](07-PLUGIN_MANAGEMENT.md) - 插件检查和更新

**快速命令**：
```bash
# 读取系统总则
cat guidelines/00-SYSTEM_OVERVIEW.md

# 读取行动准则 Phase 1
cat guidelines/01-ACTION_GUIDELINES.md | grep -A 50 "Phase 1"
```

---

### 2. 任务规划与分解

**问题场景**：
- 接收到新需求，需要规划实施方案
- 需要分解大任务为小任务
- 需要选择合适的规划轨道（Quick/Standard/Enterprise）

**相关文档**：
- 📖 [01-ACTION_GUIDELINES.md](01-ACTION_GUIDELINES.md) - Phase 2: 任务规划
- 📖 [03-MULTI_AGENT.md](03-MULTI_AGENT.md) - BMAD Method Agent 使用
- 📖 [08-LONG_RUNNING_AGENTS.md](08-LONG_RUNNING_AGENTS.md) - 任务分解模式

**快速命令**：
```bash
# 读取任务规划章节
cat guidelines/01-ACTION_GUIDELINES.md | grep -A 200 "Phase 2"

# 读取 BMAD Method 使用指南
cat guidelines/03-MULTI_AGENT.md | grep -A 100 "BMAD Method"
```

---

### 3. 代码开发（TDD）

**问题场景**：
- 需要开发新功能
- 需要遵循 TDD 流程
- 需要确保测试覆盖率

**相关文档**：
- 📖 [01-ACTION_GUIDELINES.md](01-ACTION_GUIDELINES.md) - Phase 4: TDD 开发
- 📖 [02-TDD_WORKFLOW.md](02-TDD_WORKFLOW.md) - TDD 详细流程
- 📖 [14-DETERMINISTIC_DEVELOPMENT.md](14-DETERMINISTIC_DEVELOPMENT.md) - 确定性开发

**快速命令**：
```bash
# 读取 TDD 开发章节
cat guidelines/01-ACTION_GUIDELINES.md | grep -A 150 "Phase 4"

# 读取 TDD 详细流程
cat guidelines/02-TDD_WORKFLOW.md
```

---

### 4. 代码质量检查

**问题场景**：
- 代码写完了，需要检查质量
- 需要进行代码审查
- 需要确保代码规范

**相关文档**：
- 📖 [01-ACTION_GUIDELINES.md](01-ACTION_GUIDELINES.md) - Phase 3: 代码质量检查
- 📖 [05-QUALITY_GATE.md](05-QUALITY_GATE.md) - 质量门禁详细规则

**快速命令**：
```bash
# 读取代码质量检查章节
cat guidelines/01-ACTION_GUIDELINES.md | grep -A 50 "Phase 3"

# 读取质量门禁规则
cat guidelines/05-QUALITY_GATE.md
```

---

### 5. 测试与验证

**问题场景**：
- 需要进行 E2E 测试
- 需要进行前后端联调测试
- 需要验证 API 完整性

**相关文档**：
- 📖 [01-ACTION_GUIDELINES.md](01-ACTION_GUIDELINES.md) - Phase 5: API 完整性检查
- 📖 [01-ACTION_GUIDELINES.md](01-ACTION_GUIDELINES.md) - Phase 6: E2E 测试
- 📖 [04-E2E_TESTING_FLOW.md](04-E2E_TESTING_FLOW.md) - E2E 测试详细流程

**快速命令**：
```bash
# 读取 API 完整性检查章节
cat guidelines/01-ACTION_GUIDELINES.md | grep -A 100 "Phase 5"

# 读取 E2E 测试章节
cat guidelines/01-ACTION_GUIDELINES.md | grep -A 80 "Phase 6"

# 读取 E2E 测试详细流程
cat guidelines/04-E2E_TESTING_FLOW.md
```

---

### 6. 安全性检查

**问题场景**：
- 需要进行安全性检查
- 需要识别安全漏洞
- 需要确保系统安全

**相关文档**：
- 📖 [01-ACTION_GUIDELINES.md](01-ACTION_GUIDELINES.md) - Phase 7: 安全性检查
- 📖 [05-QUALITY_GATE.md](05-QUALITY_GATE.md) - 安全检查清单

**快速命令**：
```bash
# 读取安全性检查章节
cat guidelines/01-ACTION_GUIDELINES.md | grep -A 100 "Phase 7"
```

---

### 7. 稳定模块保护

**问题场景**：
- 需要修改已稳定的代码
- 担心破坏现有功能
- 需要进行变更影响分析

**相关文档**：
- 📖 [15-STABLE_ZONE_PROTECTION.md](15-STABLE_ZONE_PROTECTION.md) - 稳定区域保护规范
- 📖 [01-ACTION_GUIDELINES.md](01-ACTION_GUIDELINES.md) - Phase 0: 变更影响分析

**快速命令**：
```bash
# 读取稳定区域保护规范
cat guidelines/15-STABLE_ZONE_PROTECTION.md

# 检查稳定区域
./scripts/check-stable-zones.sh

# 生成影响报告
./scripts/generate-impact-report.sh
```

---

### 8. 上下文管理

**问题场景**：
- 上下文使用率过高
- 需要保存状态
- 需要执行 compact

**相关文档**：
- 📖 [00-SYSTEM_OVERVIEW.md](00-SYSTEM_OVERVIEW.md) - 上下文管理与自动压缩
- 📖 [11-LONG_TERM_MEMORY.md](11-LONG_TERM_MEMORY.md) - 长期记忆管理
- 📖 [08-LONG_RUNNING_AGENTS.md](08-LONG_RUNNING_AGENTS.md) - 状态持久化

**快速命令**：
```bash
# 读取上下文管理章节
cat guidelines/00-SYSTEM_OVERVIEW.md | grep -A 100 "上下文管理"

# 读取长期记忆管理
cat guidelines/11-LONG_TERM_MEMORY.md
```

---

### 9. 多 Agent 协作

**问题场景**：
- 需要使用多个 Agent 协作
- 需要选择合适的 Agent
- 需要并行执行任务

**相关文档**：
- 📖 [03-MULTI_AGENT.md](03-MULTI_AGENT.md) - 多 Agent 协作规范
- 📖 [08-LONG_RUNNING_AGENTS.md](08-LONG_RUNNING_AGENTS.md) - 长期运行 Agent 最佳实践
- 📖 [10-ANTHROPIC_LONG_RUNNING_AGENTS.md](10-ANTHROPIC_LONG_RUNNING_AGENTS.md) - Anthropic 官方指南

**快速命令**：
```bash
# 读取多 Agent 协作规范
cat guidelines/03-MULTI_AGENT.md

# 读取长期运行 Agent 最佳实践
cat guidelines/08-LONG_RUNNING_AGENTS.md
```

---

### 10. 插件与技能管理

**问题场景**：
- 需要安装或更新插件
- 需要使用特定技能
- 需要检查插件状态

**相关文档**：
- 📖 [07-PLUGIN_MANAGEMENT.md](07-PLUGIN_MANAGEMENT.md) - 插件管理规范
- 📖 [00-SYSTEM_OVERVIEW.md](00-SYSTEM_OVERVIEW.md) - 必备插件管理

**快速命令**：
```bash
# 读取插件管理规范
cat guidelines/07-PLUGIN_MANAGEMENT.md

# 检查插件状态
/plugin list

# 更新插件
/plugin update --all
```

---

### 11. 互联网访问与调研

**问题场景**：
- 需要进行技术调研
- 需要搜索 GitHub 项目
- 需要访问互联网资源

**相关文档**：
- 📖 [12-AGENT_REACH_INTEGRATION.md](12-AGENT_REACH_INTEGRATION.md) - Agent-Reach 集成指南
- 📖 [00-SYSTEM_OVERVIEW.md](00-SYSTEM_OVERVIEW.md) - 互联网访问最佳实践

**快速命令**：
```bash
# 读取 Agent-Reach 集成指南
cat guidelines/12-AGENT_REACH_INTEGRATION.md

# GitHub 搜索
gh search repos "关键词" --language=python --limit 10

# 代码搜索
gh search code "函数名" --language=python --limit 5
```

---

### 12. 自动化与效率提升

**问题场景**：
- 需要配置自动化模式
- 需要提升开发效率
- 需要减少重复工作

**相关文档**：
- 📖 [09-AUTOMATION_MODES.md](09-AUTOMATION_MODES.md) - 自动化模式配置
- 📖 [13-COLLABORATION_EFFICIENCY.md](13-COLLABORATION_EFFICIENCY.md) - 协作效率提升

**快速命令**：
```bash
# 读取自动化模式配置
cat guidelines/09-AUTOMATION_MODES.md

# 读取协作效率提升
cat guidelines/13-COLLABORATION_EFFICIENCY.md
```

---

### 13. 可追溯性与记录

**问题场景**：
- 需要记录关键决策
- 需要追溯历史变更
- 需要生成文档

**相关文档**：
- 📖 [06-TRACEABILITY.md](06-TRACEABILITY.md) - 可追溯性规范
- 📖 [11-LONG_TERM_MEMORY.md](11-LONG_TERM_MEMORY.md) - 长期记忆管理

**快速命令**：
```bash
# 读取可追溯性规范
cat guidelines/06-TRACEABILITY.md

# 查看 Git 历史
git log --oneline -10

# 查看文件变更历史
git log --follow -- <file_path>
```

---

## 🔄 常见工作流索引

### 工作流 1：新功能开发（完整流程）

```bash
# 1. 会话启动
cat guidelines/00-SYSTEM_OVERVIEW.md
cat guidelines/01-ACTION_GUIDELINES.md | grep -A 50 "Phase 1"

# 2. 变更影响分析
cat guidelines/15-STABLE_ZONE_PROTECTION.md
./scripts/check-stable-zones.sh

# 3. 任务规划
cat guidelines/01-ACTION_GUIDELINES.md | grep -A 200 "Phase 2"

# 4. TDD 开发
cat guidelines/02-TDD_WORKFLOW.md

# 5. 代码质量检查
cat guidelines/05-QUALITY_GATE.md

# 6. E2E 测试
cat guidelines/04-E2E_TESTING_FLOW.md

# 7. 安全性检查
cat guidelines/01-ACTION_GUIDELINES.md | grep -A 100 "Phase 7"
```

### 工作流 2：Bug 修复（快速流程）

```bash
# 1. 变更影响分析
./scripts/check-stable-zones.sh

# 2. 快速规划
cat guidelines/01-ACTION_GUIDELINES.md | grep -A 50 "Quick Flow"

# 3. TDD 修复
cat guidelines/02-TDD_WORKFLOW.md

# 4. 验证
cat guidelines/05-QUALITY_GATE.md
```

### 工作流 3：技术调研

```bash
# 1. 互联网访问工具
cat guidelines/12-AGENT_REACH_INTEGRATION.md

# 2. GitHub 搜索
gh search repos "关键词"

# 3. 记录调研结果
cat guidelines/11-LONG_TERM_MEMORY.md
```

---

## 📊 文档优先级

### 必读文档（每次会话）

1. **00-SYSTEM_OVERVIEW.md** - 系统总则
2. **01-ACTION_GUIDELINES.md** - 行动准则

### 按需阅读文档

根据具体问题，按需加载相关文档。

### 参考文档

- **08-LONG_RUNNING_AGENTS.md** - 长期运行 Agent 最佳实践
- **10-ANTHROPIC_LONG_RUNNING_AGENTS.md** - Anthropic 官方指南
- **11-LONG_TERM_MEMORY.md** - 长期记忆管理

---

## 🎯 使用示例

### 示例 1：用户说"帮我实现用户登录功能"

**思考过程**：
1. 这是一个新功能开发任务
2. 可能涉及稳定模块（如果已有登录系统）
3. 需要完整的开发流程

**按需加载**：
```bash
# Step 1: 检查稳定模块
cat guidelines/15-STABLE_ZONE_PROTECTION.md
./scripts/check-stable-zones.sh

# Step 2: 任务规划
cat guidelines/01-ACTION_GUIDELINES.md | grep -A 200 "Phase 2"

# Step 3: TDD 开发
cat guidelines/02-TDD_WORKFLOW.md

# Step 4: E2E 测试
cat guidelines/04-E2E_TESTING_FLOW.md
```

### 示例 2：用户说"上下文快满了"

**思考过程**：
1. 这是上下文管理问题
2. 需要保存状态或执行 compact

**按需加载**：
```bash
# 读取上下文管理章节
cat guidelines/00-SYSTEM_OVERVIEW.md | grep -A 100 "上下文管理"

# 读取长期记忆管理
cat guidelines/11-LONG_TERM_MEMORY.md
```

### 示例 3：用户说"帮我调研一下 React 状态管理方案"

**思考过程**：
1. 这是技术调研任务
2. 需要使用互联网访问工具

**按需加载**：
```bash
# 读取 Agent-Reach 集成指南
cat guidelines/12-AGENT_REACH_INTEGRATION.md

# 执行 GitHub 搜索
gh search repos "state management" --language=typescript --stars=">10000"
```

---

## 🔗 相关资源

- **MEMORY.md** - 项目记忆和稳定模块清单
- **project-context.md** - 项目上下文和技术栈
- **scripts/** - 自动化脚本
- **_bmad-output/** - BMAD Method 产出

---

## 📝 更新日志

| 日期 | 版本 | 更新内容 | 更新人 |
|------|------|---------|--------|
| 2026-03-08 | 1.0.0 | 初始版本 | Claude |

---

> **使用原则**：
> 1. 理解问题 - 先理解用户需求
> 2. 查找分类 - 在目录中找到相关分类
> 3. 按需加载 - 只读取需要的文档
> 4. 组合使用 - 复杂问题组合多个文档
> 5. 避免过载 - 不要一次性加载所有内容

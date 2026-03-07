# Commands 使用文档

> 版本：1.0.0
> 最后更新：2026-03-07

---

## 📋 概述

本文档说明所有可用命令的使用方法和最佳实践。

---

## 🎯 核心命令

### /plan - 任务规划

**用途**：在开始编码前，先规划任务实施方案

**使用场景**：
- 新功能开发
- 复杂重构
- 架构变更
- 多步骤任务

**命令格式**：
```bash
/plan "任务描述"
```

**示例**：
```bash
/plan "实现用户登录功能"
/plan "重构认证系统"
/plan "添加支付功能"
```

**执行流程**：
```
1. 分析任务需求
   ↓
2. 识别依赖和风险
   ↓
3. 生成实施计划
   ↓
4. 等待用户确认
   ↓
5. 开始执行
```

**输出内容**：
- 任务分解
- 实施步骤
- 风险评估
- 时间估算
- 依赖关系

---

### /tdd - 测试驱动开发

**用途**：强制执行 TDD 工作流，确保测试覆盖率

**使用场景**：
- 新功能开发
- Bug 修复
- 代码重构

**命令格式**：
```bash
/tdd
```

**执行流程**：
```
RED (写失败测试)
   ↓
GREEN (实现功能)
   ↓
REFACTOR (重构优化)
   ↓
VERIFY (验证闭环)
```

**要求**：
- 测试覆盖率 ≥ 80%
- 先写测试，再写实现
- 测试必须先失败，再通过

---

### /code-review - 代码审查

**用途**：自动审查代码质量和安全问题

**使用场景**：
- 完成代码后
- 提交前检查
- 定期审查

**命令格式**：
```bash
/code-review
```

**检查项**：
- 代码质量
- 安全漏洞
- 性能问题
- 最佳实践
- 代码风格

**问题等级**：
- 🔴 CRITICAL - 必须修复
- 🟠 HIGH - 强烈建议修复
- 🟡 MEDIUM - 建议修复
- 🟢 LOW - 可选修复

---

### /e2e - E2E 测试

**用途**：生成和运行端到端测试

**使用场景**：
- 关键用户流程
- 功能完成后
- 发布前验证

**命令格式**：
```bash
/e2e
```

**测试类型**：
- 用户注册登录
- 核心业务流程
- 支付流程
- 数据提交

**输出**：
- 测试用例
- 测试报告
- 截图/视频
- 失败日志

---

### /verify - 验证循环

**用途**：全面验证代码质量

**使用场景**：
- 任务完成后
- 提交前检查
- 发布前验证

**命令格式**：
```bash
/verify
/verify --determinism  # 确定性验证
```

**检查项**：
- ✅ 构建成功
- ✅ 测试通过
- ✅ 代码审查
- ✅ 文档更新
- ✅ Git 提交
- ✅ 确定性验证（使用 --determinism）

### 确定性验证

```bash
/verify --determinism
```

**验证内容**：
- 时间依赖检测（`Date.now()`, `new Date()`）
- 随机性检测（`Math.random()`, `crypto.randomUUID()`）
- 未 Mock 的 API 检测
- 测试可重复性验证（运行 3 次）

**输出示例**：
```
🔍 确定性验证报告

时间依赖：
  ⚠️  src/utils/time.ts:15 - Date.now()
  ✅  src/utils/time.ts:20 - jest.useFakeTimers()

随机性：
  ⚠️  src/utils/id.ts:10 - Math.random()
  ✅  src/utils/id.ts:15 - seedrandom('fixed-seed')

测试可重复性：
  ✅ 用户登录 - 3 次运行结果一致
  ⚠️  订单创建 - 3 次运行结果不一致

统计：
  ✅ 已隔离：12 处
  ⚠️  未隔离：3 处
  隔离率：80%
```

**相关文档**：[确定性开发规范](../guidelines/14-DETERMINISTIC_DEVELOPMENT.md)

---

## 🔧 辅助命令

### /checkpoint - 检查点管理

**用途**：管理任务检查点

**命令格式**：
```bash
/checkpoint start <task_id>    # 开始任务
/checkpoint status <task_id>   # 查看状态
/checkpoint complete <task_id> # 完成任务
/checkpoint list               # 列出所有检查点
```

**示例**：
```bash
/checkpoint start 52
/checkpoint status 52
/checkpoint complete 52
```

---

### /refactor-clean - 重构清理

**用途**：清理死代码和重复代码

**使用场景**：
- 代码重构
- 定期清理
- 性能优化

**命令格式**：
```bash
/refactor-clean
```

**清理内容**：
- 未使用的导入
- 死代码
- 重复代码
- 过时的注释

---

### /build-fix - 构建修复

**用途**：修复构建错误

**使用场景**：
- 构建失败
- 类型错误
- 依赖问题

**命令格式**：
```bash
/build-fix
```

**修复类型**：
- TypeScript 类型错误
- 依赖缺失
- 配置错误
- 语法错误

---

## 🧠 记忆系统命令

### /memory-search - 记忆搜索

**用途**：搜索历史记忆和决策

**命令格式**：
```bash
/memory-search "关键词"
```

**示例**：
```bash
/memory-search "部署问题"
/memory-search "认证方案"
/memory-search "性能优化"
```

**搜索范围**：
- MEMORY.md (长期记忆)
- memory/*.md (每日日志)
- checkpoints/*.json (检查点)

---

### /save-state - 保存状态

**用途**：保存当前任务状态

**命令格式**：
```bash
/save-state "原因说明"
```

**示例**：
```bash
/save-state "完成需求分析"
/save-state "上下文达到 80%"
/save-state "任务暂停"
```

**保存内容**：
- 当前任务 ID
- 任务进度
- 关键变量
- 技术决策
- 修改文件

---

### /restore-state - 恢复状态

**用途**：恢复之前的任务状态

**命令格式**：
```bash
/restore-state latest              # 恢复最新状态
/restore-state <checkpoint_id>     # 恢复特定检查点
/restore-state list                # 列出可用检查点
```

**示例**：
```bash
/restore-state latest
/restore-state checkpoint-task-52-20260307-150000
/restore-state list
```

---

## 🌐 互联网访问命令

### GitHub CLI 命令

**搜索仓库**：
```bash
gh search repos "关键词" --language=python --stars=">1000" --limit 10
```

**搜索代码**：
```bash
gh search code "函数名" --language=python --limit 5
```

**查看项目**：
```bash
gh repo view owner/repo
```

**详细用法**：参见 [GitHub CLI 使用手册](../docs/GITHUB_CLI_GUIDE.md)

---

## 🔄 工作流命令

### 完整开发流程

```bash
# 1. 规划任务
/plan "实现用户登录功能"

# 2. 开始任务
/checkpoint start 52

# 3. TDD 开发
/tdd

# 4. 代码审查
/code-review

# 5. E2E 测试
/e2e

# 6. 验证闭环
/verify

# 7. 保存状态
/save-state "任务完成"

# 8. 完成任务
/checkpoint complete 52
```

---

## 📊 命令使用统计

### 使用频率

| 命令 | 频率 | 说明 |
|------|------|------|
| /plan | 每个任务开始 | 必须 |
| /tdd | 每次开发 | 必须 |
| /code-review | 完成后 | 必须 |
| /e2e | 关键功能 | 推荐 |
| /verify | 提交前 | 必须 |
| /checkpoint | 任务节点 | 推荐 |
| /save-state | 关键节点 | 推荐 |

---

## ⚙️ 命令配置

### 自定义命令

在 `~/.claude/commands/` 目录下创建自定义命令：

```markdown
# my-command.md

## 命令名称
my-command

## 描述
自定义命令说明

## 使用方法
/my-command [参数]

## 示例
/my-command "示例参数"
```

### 命令别名

在 `~/.claude/settings.json` 中配置别名：

```json
{
  "commandAliases": {
    "p": "plan",
    "t": "tdd",
    "r": "code-review",
    "v": "verify"
  }
}
```

---

## 🎓 最佳实践

### 1. 任务开始前必须规划

```bash
# ❌ 错误：直接开始写代码
# 开始写代码...

# ✅ 正确：先规划再执行
/plan "实现用户登录功能"
# 等待确认后再开始
```

### 2. 严格执行 TDD 流程

```bash
# ❌ 错误：先写实现再补测试
# 写实现代码...
# 补测试...

# ✅ 正确：先写测试再实现
/tdd
# RED → GREEN → REFACTOR
```

### 3. 完成后必须验证

```bash
# ❌ 错误：写完就提交
git commit -m "完成功能"

# ✅ 正确：验证后再提交
/verify
# 通过后再提交
```

### 4. 关键节点保存状态

```bash
# ✅ 需求分析完成
/save-state "完成需求分析"

# ✅ 上下文达到 80%
/save-state "上下文达到 80%"

# ✅ 任务暂停
/save-state "任务暂停，明天继续"
```

---

## ❓ 常见问题

### Q1: 命令执行失败怎么办？

**A**: 检查命令格式和参数

```bash
# 查看命令帮助
/plan --help

# 查看所有可用命令
/help
```

### Q2: 如何查看命令历史？

**A**: 查看 memory 日志

```bash
# 查看今日命令历史
grep "^/" memory/$(date +%Y-%m-%d).md
```

### Q3: 命令可以组合使用吗？

**A**: 可以，按工作流顺序执行

```bash
/plan "任务" && /tdd && /code-review && /verify
```

---

## 🔗 相关文档

- [脚本使用说明](../scripts/README.md)
- [GitHub CLI 使用手册](../docs/GITHUB_CLI_GUIDE.md)
- [长期记忆管理规范](../guidelines/11-LONG_TERM_MEMORY.md)
- [自动化脚本示例](../docs/AUTOMATION_SCRIPTS.md)

---

## 📝 更新日志

| 日期 | 版本 | 更新内容 | 更新人 |
|------|------|---------|--------|
| 2026-03-07 | 1.0.0 | 初始版本，包含所有核心命令 | - |

---

> **使用提示**：
> 1. 熟悉核心命令的使用场景
> 2. 严格按照工作流执行命令
> 3. 关键节点及时保存状态
> 4. 定期搜索历史记忆
> 5. 善用命令别名提高效率

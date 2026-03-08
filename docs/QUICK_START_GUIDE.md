# 快速开始指南

> **版本**：1.0.0
> **最后更新**：2026-03-08
> **用途**：5 分钟快速上手代码稳定区域保护和目录索引系统

---

## 🎯 核心功能

### 1. 代码稳定区域保护

**解决的问题**：防止已稳定的代码被无意修改

**使用场景**：
- ✅ 登录功能已经稳定，不想被其他功能开发影响
- ✅ 支付系统已经测试通过，需要保护
- ✅ 核心业务逻辑已经上线，避免误改

### 2. Guidelines 目录索引

**解决的问题**：快速找到需要的规范文档

**使用场景**：
- ✅ 不知道读哪个文档
- ✅ 避免一次性加载所有文档
- ✅ 按需加载，节省上下文

---

## 🚀 5 分钟快速上手

### Step 1: 查看目录索引（30 秒）

```bash
cat guidelines/00-INDEX.md
```

**你会看到**：
- 13 个问题分类索引
- 3 个常见工作流索引
- 文档优先级说明

### Step 2: 标记稳定模块（2 分钟）

编辑 `MEMORY.md`，在 "🔒 稳定模块清单" 章节添加：

```markdown
### 用户登录系统 (AuthService)

**状态**: ✅ 已稳定
**最后验证**: 2026-03-08
**相关任务**: TASK-15
**测试覆盖率**: 95%

**相关文件**:
- `src/services/auth.service.ts`
- `src/controllers/auth.controller.ts`
- `src/middleware/auth.middleware.ts`

**禁止修改条件**:
- 非登录相关需求
- 未经用户确认的变更

**允许修改条件**:
- 登录功能增强（需确认）
- 安全漏洞修复（需确认）
```

### Step 3: 检查稳定区域（30 秒）

```bash
./scripts/check-stable-zones.sh
```

**如果没有变更**：
```
✅ 没有文件变更
```

**如果有变更但不涉及稳定模块**：
```
✅ 未影响稳定区域
```

**如果涉及稳定模块**：
```
⚠️  检测到稳定区域变更：
- src/services/auth.service.ts

❌ 需要用户确认才能继续
```

### Step 4: 生成影响报告（1 分钟）

如果涉及稳定模块，生成影响报告：

```bash
./scripts/generate-impact-report.sh
```

**输出**：
```
✅ 影响报告已生成：impact-report-20260308-153000.md

📋 下一步：
  1. 填写报告中的风险评估和建议方案
  2. 发送报告给用户确认
  3. 获得确认后继续开发
```

### Step 5: 按需加载文档（1 分钟）

根据问题查找相关文档：

```bash
# 例如：需要做技术调研
cat guidelines/00-INDEX.md | grep -A 15 "互联网访问"

# 输出会告诉你需要读哪些文档
# 然后按需加载
cat guidelines/12-AGENT_REACH_INTEGRATION.md
```

---

## 📚 常见场景速查

### 场景 1：开发新功能

```bash
# 1. 检查稳定区域
./scripts/check-stable-zones.sh

# 2. 查看任务规划文档
cat guidelines/00-INDEX.md | grep -A 15 "任务规划"

# 3. 按需加载
cat guidelines/01-ACTION_GUIDELINES.md | grep -A 200 "Phase 2"
```

### 场景 2：修复 Bug

```bash
# 1. 检查稳定区域
./scripts/check-stable-zones.sh

# 2. 查看 Bug 修复工作流
cat guidelines/00-INDEX.md | grep -A 20 "工作流 2"

# 3. 按照工作流执行
```

### 场景 3：技术调研

```bash
# 1. 查看目录索引
cat guidelines/00-INDEX.md | grep -A 15 "互联网访问"

# 2. 按需加载文档
cat guidelines/12-AGENT_REACH_INTEGRATION.md

# 3. 执行调研
gh search repos "关键词" --language=python --limit 10
```

### 场景 4：不知道做什么

```bash
# 查看完整目录索引
cat guidelines/00-INDEX.md

# 找到相关问题分类
# 按需加载文档
```

---

## 🎓 实战示例

### 示例 1：添加用户角色管理功能

```bash
# 1. 检查稳定区域
./scripts/check-stable-zones.sh
# 输出：⚠️ 检测到稳定区域变更：src/services/auth.service.ts

# 2. 生成影响报告
./scripts/generate-impact-report.sh
# 输出：✅ 影响报告已生成：impact-report-20260308-153000.md

# 3. 填写报告
# 编辑 impact-report-20260308-153000.md
# - 风险评估：🟡 中等风险
# - 建议方案：装饰器模式扩展

# 4. 发送报告给用户确认
# 用户回复：确认使用方案 1

# 5. 继续开发
# 按照方案 1 开发代码

# 6. 更新 MEMORY.md
# 记录变更决策
```

### 示例 2：调研 React 状态管理方案

```bash
# 1. 查看目录索引
cat guidelines/00-INDEX.md | grep -A 15 "互联网访问"

# 2. 按需加载文档
cat guidelines/12-AGENT_REACH_INTEGRATION.md

# 3. 执行 GitHub 搜索
gh search repos "state management" --language=typescript --stars=">10000" --limit 8

# 4. 记录调研结果到 MEMORY.md
# 在 "关键决策记录" 章节添加：
# | 2026-03-08 | 选择 Zustand | 轻量、简洁、社区活跃 | 前端架构 |
```

---

## 💡 最佳实践

### 1. 及时标记稳定模块

```bash
# 功能开发完成并测试通过后，立即标记
# 1. 在代码中添加 🔒 STABLE ZONE 注释
# 2. 在 MEMORY.md 中添加稳定模块记录
# 3. 提交代码
```

### 2. 开发前必检查

```bash
# 任何代码修改前，必须执行
./scripts/check-stable-zones.sh
```

### 3. 按需加载文档

```bash
# 不要一次性读取所有文档
# 先查看目录索引，找到相关分类
# 然后按需加载
cat guidelines/00-INDEX.md
```

### 4. 记录关键决策

```bash
# 在 MEMORY.md 中记录所有重要决策
# 特别是涉及稳定模块的变更
```

---

## 🔗 相关文档

- [Guidelines 目录索引](../guidelines/00-INDEX.md) - 完整的文档索引
- [代码稳定区域保护规范](../guidelines/15-STABLE_ZONE_PROTECTION.md) - 详细规范
- [行动准则](../guidelines/01-ACTION_GUIDELINES.md) - 开发流程
- [MEMORY.md](../MEMORY.md) - 项目记忆

---

## ❓ 常见问题

### Q1: 如何标记稳定模块？

**A**: 编辑 `MEMORY.md`，在 "🔒 稳定模块清单" 章节添加模块信息。

### Q2: 检查脚本报错怎么办？

**A**: 确保：
1. 在 Git 仓库中运行
2. MEMORY.md 中已定义稳定模块
3. 有文件变更（git diff 有输出）

### Q3: 如何跳过稳定区域检查？

**A**: 获得用户确认后，使用：
```bash
git commit --no-verify
```

### Q4: 目录索引太长，如何快速查找？

**A**: 使用 grep 过滤：
```bash
cat guidelines/00-INDEX.md | grep -A 15 "关键词"
```

### Q5: 如何知道读哪个文档？

**A**:
1. 先查看 `guidelines/00-INDEX.md`
2. 找到相关问题分类
3. 按需加载推荐的文档

---

## 📊 效果对比

| 场景 | 传统方式 | 使用新功能 | 提升 |
|------|---------|-----------|------|
| 技术调研 | 30 分钟 | 5 秒 | 360x |
| 找到相关文档 | 10 分钟 | 30 秒 | 20x |
| 防止误改稳定代码 | 事后修复 | 事前预防 | ∞ |
| 上下文使用 | 加载所有文档 | 按需加载 | 节省 70% |

---

## 🎯 下一步

1. ✅ 标记你的第一个稳定模块
2. ✅ 尝试检查稳定区域
3. ✅ 使用目录索引查找文档
4. ✅ 在实际项目中应用

---

*版本：1.0.0*
*最后更新：2026-03-08*

> **核心理念**：
> 1. 保护稳定代码 - 防止无意修改
> 2. 按需加载文档 - 节省上下文
> 3. 快速找到答案 - 提升效率

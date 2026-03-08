# 代码稳定区域保护规范

> **版本**：1.0.0
> **最后更新**：2026-03-08
> **目标**：防止已稳定的代码被无意修改，确保系统稳定性

---

## 📋 概述

### 核心问题

在开发过程中，经常出现以下问题：
- ✅ 登录功能已经稳定，测试通过
- ❌ 开发其他功能时，无意中修改了登录相关代码
- ❌ 登录功能再次出现问题，需要重新调试

### 解决方案

**代码稳定区域保护机制**：
1. **明确标记**：在代码和文档中标记已稳定的功能模块
2. **强制检查**：任务开始前强制执行变更影响分析
3. **用户确认**：涉及稳定模块必须用户确认
4. **自动化保护**：通过脚本和 Git hooks 自动检测

---

## 🎯 核心原则

1. **稳定优先** - 已稳定的代码不应被轻易修改
2. **明确标记** - 所有稳定模块必须明确标记
3. **影响分析** - 修改前必须分析影响范围
4. **用户确认** - 涉及稳定模块必须用户确认
5. **自动保护** - 通过工具自动检测和阻止

---

## 🔒 稳定区域定义

### 什么是稳定区域？

满足以下条件的代码模块：
- ✅ 功能已完整实现
- ✅ 测试已全部通过（单元测试 + 集成测试 + E2E 测试）
- ✅ 代码审查已通过
- ✅ 已在生产环境运行稳定（或准备发布）
- ✅ 无已知 Bug

### 稳定区域的生命周期

```
开发中 → 测试中 → 审查中 → 🔒 稳定 → 需要修改 → 解除稳定 → 开发中
```

---

## 📝 稳定区域标记

### 1. 在代码中标记

在稳定模块的文件头部添加标记：

```typescript
// ============================================
// 🔒 STABLE ZONE - 用户登录系统
// 最后验证：2026-03-08
// 相关任务：TASK-15
// 测试覆盖率：95%
// 禁止修改，除非：
//   1. 登录相关的直接需求
//   2. 经过用户明确确认
//   3. 安全漏洞修复（需确认）
// ============================================

export class AuthService {
  // ... 登录逻辑
}
```

### 2. 在 MEMORY.md 中记录

在 `MEMORY.md` 中添加 **稳定模块清单** 章节：

```markdown
## 🔒 稳定模块清单

### 用户登录系统 (AuthService)

**状态**: ✅ 已稳定
**最后验证**: 2026-03-08
**相关任务**: TASK-15
**测试覆盖率**: 95%

**相关文件**:
- `src/services/auth.service.ts`
- `src/controllers/auth.controller.ts`
- `src/middleware/auth.middleware.ts`
- `src/views/login/index.vue`

**禁止修改条件**:
- 非登录相关需求
- 未经用户确认的变更

**允许修改条件**:
- 登录功能增强（需确认）
- 安全漏洞修复（需确认）
- 依赖升级导致的必要调整（需确认）

**依赖关系**:
- 依赖：`UserService`, `TokenService`, `RedisService`
- 被依赖：`ProfileController`, `OrderController`
```

### 3. 在项目文档中记录

在 `project-context.md` 或 `architecture.md` 中记录：

```markdown
## 稳定模块

| 模块 | 状态 | 最后验证 | 负责人 |
|------|------|---------|--------|
| 用户登录系统 | 🔒 稳定 | 2026-03-08 | @developer |
| 支付系统 | 🔒 稳定 | 2026-03-05 | @developer |
| 订单系统 | 🚧 开发中 | - | @developer |
```

---

## 🔍 变更影响分析

### 执行时机

在开始任何代码修改前，必须执行变更影响分析。

### 分析步骤

#### Step 1: 识别变更范围

```bash
# 1. 读取 MEMORY.md 中的稳定模块清单
cat MEMORY.md | grep -A 20 "🔒 稳定模块清单"

# 2. 分析当前需求涉及的文件
# 例如：需求是"添加用户角色管理功能"
# 涉及文件：
# - src/services/role.service.ts (新增)
# - src/controllers/role.controller.ts (新增)
# - src/services/auth.service.ts (修改)
# - src/middleware/auth.middleware.ts (修改)

# 3. 检查是否与稳定模块重叠
# 发现：auth.service.ts 和 auth.middleware.ts 属于稳定的"用户登录系统"
```

#### Step 2: 评估影响级别

| 影响级别 | 定义 | 处理方式 |
|---------|------|---------|
| 🟢 无影响 | 不涉及稳定模块 | 直接执行 |
| 🟡 间接影响 | 调用稳定模块的接口 | 验证接口兼容性 |
| 🟠 直接影响 | 需要修改稳定模块 | **必须用户确认** |
| 🔴 破坏性影响 | 重构稳定模块 | **必须用户确认 + 详细方案** |

#### Step 3: 生成影响报告

```markdown
## 变更影响报告

**需求**: 添加用户角色管理功能

**涉及文件**:
- ✅ `src/services/role.service.ts` (新增)
- ✅ `src/controllers/role.controller.ts` (新增)
- ⚠️ `src/services/auth.service.ts` (修改)
- ⚠️ `src/middleware/auth.middleware.ts` (修改)

**稳定模块影响**:
- 🟠 **用户登录系统** - 需要修改 `auth.service.ts` 添加角色检查逻辑

**变更详情**:
```diff
// src/services/auth.service.ts
async validateToken(token: string) {
  const user = await this.verifyToken(token);
+ const roles = await this.roleService.getUserRoles(user.id);
+ user.roles = roles;
  return user;
}
```

**风险评估**:
- 🟡 中等风险：修改已稳定的登录验证逻辑
- 可能影响现有登录流程
- 需要重新测试登录功能

**建议方案**:

**方案 1（推荐）**：装饰器模式扩展
```typescript
// 保持原有 validateToken 不变
async validateToken(token: string) {
  return await this.verifyToken(token);
}

// 新增角色增强方法
async validateTokenWithRoles(token: string) {
  const user = await this.validateToken(token);
  user.roles = await this.roleService.getUserRoles(user.id);
  return user;
}
```

**方案 2**：直接修改（需重新测试）
```typescript
// 修改原有方法
async validateToken(token: string) {
  const user = await this.verifyToken(token);
  const roles = await this.roleService.getUserRoles(user.id);
  user.roles = roles;
  return user;
}
```

**需要用户确认**:
- [ ] 是否允许修改稳定的用户登录系统？
- [ ] 选择哪个实现方案？（推荐方案 1）
- [ ] 是否需要重新进行完整测试？
```

#### Step 4: 等待用户确认

```javascript
// 发送确认通知
await sendNotification({
  level: 'P1',
  type: 'change_impact_confirmation',
  title: '稳定模块变更确认',
  content: '需求涉及修改已稳定的用户登录系统',
  impactReport: '...',
  options: [
    { value: 'confirm_plan1', label: '确认（方案 1 - 装饰器模式）' },
    { value: 'confirm_plan2', label: '确认（方案 2 - 直接修改）' },
    { value: 'modify_approach', label: '修改实现方案' },
    { value: 'reject', label: '拒绝修改' }
  ]
})

// 阻塞等待确认
const result = await waitForConfirmation()

if (result.action === 'confirm_plan1') {
  // 使用方案 1 继续
} else if (result.action === 'confirm_plan2') {
  // 使用方案 2 继续
} else if (result.action === 'modify_approach') {
  // 重新设计方案
} else {
  // 停止任务
}
```

---

## 🚦 决策流程

```
接收新需求
    │
    ▼
┌─────────────────────┐
│ Step 0: 变更影响分析 │
└──────────┬──────────┘
           │
           ▼
    是否涉及稳定模块？
           │
    ┌──────┴──────┐
    │             │
   否            是
    │             │
    ▼             ▼
直接执行    生成影响报告
    │             │
    │             ▼
    │      评估影响级别
    │             │
    │      ┌──────┴──────┐
    │      │             │
    │   🟢 无影响      🟡 间接影响
    │      │             │
    │      ▼             ▼
    │   直接执行    验证接口兼容性
    │                    │
    │                    ▼
    │              兼容性 OK？
    │                    │
    │             ┌──────┴──────┐
    │             │             │
    │            是            否
    │             │             │
    │             ▼             ▼
    │        继续执行      发送 P2 通知
    │                      等待确认
    │
    │      ┌──────┴──────┐
    │      │             │
    │   🟠 直接影响    🔴 破坏性影响
    │      │             │
    │      ▼             ▼
    │   发送 P1 通知   发送 P0 通知
    │   等待确认       等待确认 + 详细方案
    │      │             │
    │      ▼             ▼
    │   用户确认？     用户确认？
    │      │             │
    │   ┌──┴──┐       ┌──┴──┐
    │   │     │       │     │
    │  确认  拒绝    确认  拒绝
    │   │     │       │     │
    │   ▼     ▼       ▼     ▼
    └──▶继续  停止    继续  停止
        │             │
        ▼             ▼
    执行任务      执行任务
        │             │
        ▼             ▼
   更新 MEMORY.md  更新 MEMORY.md
   标记新的稳定模块  标记新的稳定模块
```

---

## 🛠️ 自动化工具

### 1. 检查稳定区域脚本

创建 `scripts/check-stable-zones.sh`：

```bash
#!/bin/bash

# 检查变更是否影响稳定区域

set -e

CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null || echo "")
if [ -z "$CHANGED_FILES" ]; then
  CHANGED_FILES=$(git diff --name-only --cached 2>/dev/null || echo "")
fi

if [ -z "$CHANGED_FILES" ]; then
  echo "✅ 没有文件变更"
  exit 0
fi

STABLE_ZONES=$(grep -A 10 "🔒 稳定模块清单" MEMORY.md 2>/dev/null | grep "src/" | sed 's/.*`\(.*\)`.*/\1/' || echo "")

if [ -z "$STABLE_ZONES" ]; then
  echo "ℹ️  未定义稳定区域"
  exit 0
fi

echo "📋 变更文件："
echo "$CHANGED_FILES"
echo ""
echo "🔒 稳定区域："
echo "$STABLE_ZONES"
echo ""

CONFLICTS=""
for file in $CHANGED_FILES; do
  if echo "$STABLE_ZONES" | grep -q "$file"; then
    CONFLICTS="$CONFLICTS\n- $file"
  fi
done

if [ -n "$CONFLICTS" ]; then
  echo "⚠️  检测到稳定区域变更："
  echo -e "$CONFLICTS"
  echo ""
  echo "❌ 需要用户确认才能继续"
  echo ""
  echo "💡 提示："
  echo "  1. 生成影响报告：./scripts/generate-impact-report.sh"
  echo "  2. 获得用户确认后，更新 MEMORY.md"
  echo "  3. 使用 git commit --no-verify 跳过检查（仅在确认后）"
  exit 1
else
  echo "✅ 未影响稳定区域"
  exit 0
fi
```

### 2. 生成影响报告脚本

创建 `scripts/generate-impact-report.sh`：

```bash
#!/bin/bash

# 生成变更影响报告

set -e

REPORT_FILE="impact-report-$(date +%Y%m%d-%H%M%S).md"

cat > "$REPORT_FILE" <<EOF
# 变更影响报告

**生成时间**: $(date '+%Y-%m-%d %H:%M:%S')
**任务 ID**: ${TASK_ID:-未指定}

## 变更文件

EOF

git diff --name-status HEAD >> "$REPORT_FILE" 2>/dev/null || git diff --name-status --cached >> "$REPORT_FILE" 2>/dev/null || echo "无变更" >> "$REPORT_FILE"

cat >> "$REPORT_FILE" <<EOF

## 稳定模块影响

EOF

STABLE_ZONES=$(grep -A 10 "🔒 稳定模块清单" MEMORY.md 2>/dev/null | grep "src/" | sed 's/.*`\(.*\)`.*/\1/' || echo "")
CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null || git diff --name-only --cached 2>/dev/null || echo "")

CONFLICTS=""
for file in $CHANGED_FILES; do
  if echo "$STABLE_ZONES" | grep -q "$file"; then
    CONFLICTS="$CONFLICTS\n- 🟠 $file"
  fi
done

if [ -n "$CONFLICTS" ]; then
  echo -e "$CONFLICTS" >> "$REPORT_FILE"
else
  echo "✅ 无稳定模块影响" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" <<EOF

## 风险评估

- [ ] 影响级别：🟢 无影响 / 🟡 间接影响 / 🟠 直接影响 / 🔴 破坏性影响
- [ ] 需要重新测试：是 / 否
- [ ] 需要用户确认：是 / 否

## 建议方案

（请填写实现方案）

## 需要用户确认

- [ ] 是否允许修改稳定模块？
- [ ] 选择哪个实现方案？
- [ ] 是否需要重新进行完整测试？

EOF

echo "✅ 影响报告已生成：$REPORT_FILE"
echo ""
echo "📋 下一步："
echo "  1. 填写报告中的风险评估和建议方案"
echo "  2. 发送报告给用户确认"
echo "  3. 获得确认后继续开发"
```

### 3. Git Pre-commit Hook

创建 `.git/hooks/pre-commit`：

```bash
#!/bin/bash

# Git Pre-commit Hook - 检查稳定区域

echo "🔍 检查稳定区域..."

./scripts/check-stable-zones.sh

if [ $? -ne 0 ]; then
  echo ""
  echo "💡 如果已获得用户确认，使用以下命令跳过检查："
  echo "   git commit --no-verify"
  exit 1
fi

echo "✅ 稳定区域检查通过"
exit 0
```

---

## 📋 使用流程

### 场景 1：开发新功能（不涉及稳定模块）

```bash
# 1. 接收需求
需求：添加用户头像上传功能

# 2. 变更影响分析
./scripts/check-stable-zones.sh
# 输出：✅ 未影响稳定区域

# 3. 直接开发
# ... 开发代码 ...

# 4. 提交代码
git add .
git commit -m "feat: 添加用户头像上传功能"
# Pre-commit hook 自动检查，通过
```

### 场景 2：开发新功能（涉及稳定模块）

```bash
# 1. 接收需求
需求：添加用户角色管理功能

# 2. 变更影响分析
./scripts/check-stable-zones.sh
# 输出：⚠️ 检测到稳定区域变更：
#       - src/services/auth.service.ts

# 3. 生成影响报告
./scripts/generate-impact-report.sh
# 输出：✅ 影响报告已生成：impact-report-20260308-100000.md

# 4. 填写报告
# 编辑 impact-report-20260308-100000.md
# - 填写风险评估
# - 提供建议方案
# - 列出需要确认的问题

# 5. 发送报告给用户
# 通过飞书/钉钉/邮件发送报告

# 6. 等待用户确认
# 用户回复：确认使用方案 1（装饰器模式）

# 7. 继续开发
# ... 按照方案 1 开发代码 ...

# 8. 更新 MEMORY.md
# 记录变更决策

# 9. 提交代码
git add .
git commit --no-verify -m "feat: 添加用户角色管理功能（已确认修改稳定模块）"
```

### 场景 3：修复 Bug（涉及稳定模块）

```bash
# 1. 接收 Bug 报告
Bug：登录后 Token 过期时间不正确

# 2. 变更影响分析
./scripts/check-stable-zones.sh
# 输出：⚠️ 检测到稳定区域变更：
#       - src/services/auth.service.ts

# 3. 生成影响报告
./scripts/generate-impact-report.sh

# 4. 填写报告
# 风险评估：🟡 间接影响（修复 Bug，不改变接口）
# 建议方案：修改 Token 过期时间配置

# 5. 发送报告给用户
# 用户回复：确认修复

# 6. 修复 Bug
# ... 修改代码 ...

# 7. 重新测试
npm test
npm run e2e

# 8. 更新 MEMORY.md
# 记录 Bug 修复

# 9. 提交代码
git add .
git commit --no-verify -m "fix: 修复登录 Token 过期时间不正确（已确认修改稳定模块）"
```

---

## 🎯 最佳实践

### 1. 及时标记稳定模块

```bash
# 功能开发完成并测试通过后，立即标记为稳定
# 1. 在代码中添加 🔒 STABLE ZONE 注释
# 2. 在 MEMORY.md 中添加稳定模块记录
# 3. 提交代码
```

### 2. 定期审查稳定模块

```bash
# 每月审查一次稳定模块清单
# 1. 检查是否有模块需要解除稳定（需要重构）
# 2. 检查是否有新模块需要标记为稳定
# 3. 更新 MEMORY.md
```

### 3. 变更前必须分析

```bash
# 任何代码修改前，必须执行变更影响分析
./scripts/check-stable-zones.sh
```

### 4. 保持报告简洁

```markdown
# 影响报告应该简洁明了
# ✅ 好的报告：
- 涉及文件：3 个
- 稳定模块影响：1 个（用户登录系统）
- 风险评估：🟡 中等风险
- 建议方案：装饰器模式扩展

# ❌ 不好的报告：
- 涉及文件：很多
- 稳定模块影响：可能有
- 风险评估：不确定
- 建议方案：待定
```

### 5. 用户确认后记录

```markdown
# 在 MEMORY.md 中记录用户确认
## 关键决策记录

| 时间 | 决策 | 原因 | 影响范围 |
|------|------|------|---------|
| 2026-03-08 | 允许修改用户登录系统添加角色功能 | 业务需求 | auth.service.ts |
```

---

## ⚠️ 注意事项

### 1. 不要过度保护

```bash
# ❌ 错误：所有代码都标记为稳定
# 这会导致无法开发

# ✅ 正确：只标记真正稳定的核心模块
# - 用户登录系统
# - 支付系统
# - 订单系统
```

### 2. 不要忽略检查

```bash
# ❌ 错误：每次都使用 --no-verify 跳过检查
git commit --no-verify

# ✅ 正确：只在获得用户确认后使用 --no-verify
# 1. 执行变更影响分析
# 2. 生成影响报告
# 3. 获得用户确认
# 4. 使用 --no-verify 提交
```

### 3. 不要忘记更新 MEMORY.md

```bash
# ❌ 错误：修改了稳定模块，但没有更新 MEMORY.md

# ✅ 正确：修改后立即更新 MEMORY.md
# 1. 记录变更决策
# 2. 更新稳定模块状态
# 3. 记录测试结果
```

---

## 🔗 相关文档

- [系统总则](00-SYSTEM_OVERVIEW.md) - 自动化边界
- [行动准则](01-ACTION_GUIDELINES.md) - 任务执行流程
- [长期记忆管理](11-LONG_TERM_MEMORY.md) - MEMORY.md 规范
- [质量门禁](05-QUALITY_GATE.md) - 质量检查流程

---

## 📝 更新日志

| 日期 | 版本 | 更新内容 | 更新人 |
|------|------|---------|--------|
| 2026-03-08 | 1.0.0 | 初始版本 | Claude |

---

> **核心原则**：
> 1. 稳定优先 - 已稳定的代码不应被轻易修改
> 2. 明确标记 - 所有稳定模块必须明确标记
> 3. 影响分析 - 修改前必须分析影响范围
> 4. 用户确认 - 涉及稳定模块必须用户确认
> 5. 自动保护 - 通过工具自动检测和阻止

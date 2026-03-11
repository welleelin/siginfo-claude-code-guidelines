# Agentation 集成指南

> **版本**：1.0.0
> **最后更新**：2026-03-10
> **用途**：为 Next.js/React 项目添加 UI 设计标注和 AI 协作能力

---

## 📋 概述

### 什么是 Agentation？

Agentation 是一个**UI 设计标注工具**，允许设计师和开发者在网页上直接添加设计反馈标注，并支持与 AI Agent 实时同步。

Agentation 提供**两种集成模式**：

| 模式 | 说明 | 适用场景 |
|------|------|---------|
| **JS 版本（首选）** | 通过 CDN 引入 JavaScript 脚本，零配置 | 快速测试、临时标注、人类介入测试 |
| **MCP 版本（备用）** | 需要配置 MCP 服务器，支持 AI 双向同步 | AI 协作评审、Self-Driving 模式、标注同步 |

```
┌─────────────────────────────────────────────────────────────────┐
│                    Agentation 核心功能                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  🎨 设计标注                                                    │
│  - 在网页上直接点击元素添加批注                                 │
│  - 支持颜色分类（紫色、蓝色、绿色等）                           │
│  - 标注实时显示在页面上                                         │
│                                                                 │
│  🤖 AI 协作（仅 MCP 模式）                                       │
│  - MCP 服务器支持，与 Claude Code 等 Agent 同步                 │
│  - 自动标注模式：AI  autonomously 浏览页面并添加设计 critique    │
│  - 双向同步：标注 → Agent → 代码修复                            │
│                                                                 │
│  📊 开发工作流                                                  │
│  - 仅在开发环境加载（生产环境自动禁用）                         │
│  - 支持 React 18+                                               │
│  - 零配置集成 Next.js App Router / Pages Router / HTML          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎯 使用场景

### 场景 1：人类介入测试阶段的设计反馈

当项目进入**人类介入测试阶段**时，测试人员可以：

1. 打开测试页面
2. 使用 Agentation 工具栏直接在页面上标注问题
3. AI Agent 实时接收标注并生成修复代码

```
测试阶段流程：
人类测试 → 标注问题 → AI 接收 → 生成修复 → 验证通过
```

### 场景 2：AI 自主设计评审（Self-Driving Mode）

AI Agent 可以自主：

1. 打开 headed browser（可见浏览器）
2. 自动浏览页面各个区域
3. 自动添加设计 critique 标注
4. 生成完整的设计改进报告

### 场景 3：设计评审会议

在团队设计评审时：

1. 投影网页，实时添加标注
2. 所有标注自动保存
3. 会后将标注导出为任务列表

---

## 📦 安装与配置

### ⭐ 方式 1：JS 版本（首选，推荐用于测试环节）

**适用场景**：
- ✅ 人类介入测试阶段
- ✅ 快速测试和演示
- ✅ 临时设计评审
- ✅ 无需 AI 协作的场景

**优点**：
- ✅ 零配置，无需安装 npm 包
- ✅ 支持任意 HTML 页面
- ✅ CDN 加载，即用即走
- ✅ 不依赖构建工具

**缺点**：
- ❌ 不支持 MCP AI 协作
- ❌ 标注不同步给 AI Agent
- ❌ 无法使用 Self-Driving 模式

#### 方法 A: HTML 页面直接使用

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>测试页面</title>

  <!-- Agentation Toolbar - JS 版本 (CDN) -->
  <script type="module">
    import 'https://cdn.jsdelivr.net/npm/agentation@latest/dist/agentation-toolbar.js';
  </script>
</head>
<body>
  <!-- 你的页面内容 -->
  <h1>测试页面</h1>
  <p>这是一个测试页面，可以使用 Agentation 进行设计标注。</p>

  <!-- Agentation 工具栏会自动出现在页面右下角 -->
</body>
</html>
```

#### 方法 B: Next.js/React 项目使用

**在 `app/layout.tsx` 或 `pages/_app.tsx` 中添加**：

```tsx
export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="zh-CN">
      <head>
        {/* Agentation JS 版本 (CDN) */}
        <script
          type="module"
          dangerouslySetInnerHTML={{
            __html: `
              import('https://cdn.jsdelivr.net/npm/agentation@latest/dist/agentation-toolbar.js')
                .catch(err => console.warn('Agentation failed to load:', err));
            `,
          }}
        />
      </head>
      <body>
        {children}
      </body>
    </html>
  );
}
```

#### 方法 C: 条件加载（仅测试环境）

```tsx
// 仅在测试环境加载 Agentation
{process.env.NODE_ENV === 'development' && (
  <script
    type="module"
    dangerouslySetInnerHTML={{
      __html: `
        import('https://cdn.jsdelivr.net/npm/agentation@latest/dist/agentation-toolbar.js')
          .catch(err => console.warn('Agentation failed to load:', err));
      `,
    }}
  />
)}
```

---

### 方式 2：npm 包 + MCP 模式（备用，AI 协作）

**适用场景**：
- ✅ AI 协作评审
- ✅ Self-Driving 自主标注模式
- ✅ 标注需要同步给 AI Agent
- ✅ 完整的开发工作流集成

**优点**：
- ✅ 支持 MCP AI 协作
- ✅ 标注实时同步给 AI
- ✅ 支持 Self-Driving 模式
- ✅ 更好的类型支持

**缺点**：
- ❌ 需要安装 npm 包
- ❌ 需要配置 MCP 服务器
- ❌ 配置相对复杂

#### Step 1: 安装 npm 包

```bash
# npm
npm install agentation

# pnpm
pnpm add agentation

# yarn
yarn add agentation
```

#### Step 2: 添加到项目

**Next.js App Router**（`app/layout.tsx`）：

```tsx
import { Agentation } from "agentation";

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="zh-CN">
      <body>
        {children}
        {process.env.NODE_ENV === "development" && <Agentation />}
      </body>
    </html>
  );
}
```

**Next.js Pages Router**（`pages/_app.tsx`）：

```tsx
import { Agentation } from "agentation";
import type { AppProps } from "next/app";

export default function MyApp({ Component, pageProps }: AppProps) {
  return (
    <>
      <Component {...pageProps} />
      {process.env.NODE_ENV === "development" && <Agentation />}
    </>
  );
}
```

#### Step 3: 重启开发服务器

```bash
# 停止当前服务器
Ctrl+C

# 重新启动
npm run dev
```

---

## 🧪 测试环节模式选择策略

### 核心原则：JS 优先，MCP 备用

| 测试阶段 | 推荐模式 | 原因 |
|---------|---------|------|
| **人类介入测试** | ⭐ **JS 版本（首选）** | 零配置，人类测试人员可直接标注 |
| **自动 E2E 测试** | ⭐ **JS 版本（首选）** | 无头模式运行，无需 AI 协作 |
| **设计评审会议** | ⭐ **JS 版本（首选）** | 快速演示，无需复杂配置 |
| **AI 协作评审** | 🔌 **MCP 版本（备用）** | 需要 AI 接收标注并生成修复 |
| **Self-Driving 模式** | 🔌 **MCP 版本（备用）** | AI 自主浏览并添加标注 |

### 决策流程

```
开始测试
   │
   ▼
是否需要 AI 协作？
   │
   ├─ 否 ──▶ 使用 JS 版本（CDN）
   │          └─▶ 人类介入测试
   │          └─▶ 自动 E2E 测试
   │          └─▶ 设计评审会议
   │
   └─ 是 ──▶ 使用 MCP 版本（npm + MCP 服务器）
              └─▶ AI 协作评审
              └─▶ Self-Driving 模式
```

### JS 版本失败时的备用方案

如果 JS 版本（CDN）无法加载，按以下步骤排查：

```bash
# 1. 检查 CDN 是否可访问
curl -I https://cdn.jsdelivr.net/npm/agentation@latest/dist/agentation-toolbar.js

# 2. 检查浏览器控制台错误
# F12 打开开发者工具，查看 Console

# 3. 如果 CDN 被墙，使用备用 CDN
# 方式 A: unpkg
https://unpkg.com/agentation@latest/dist/agentation-toolbar.js

# 方式 B: 本地安装
npm install agentation
# 然后使用本地文件
```

---

## 🔌 MCP 服务器配置（仅当需要 AI 协作时）

### 为什么需要 MCP 服务器？

MCP 服务器是 Agentation 与 AI Agent 之间的桥梁：

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   网页标注    │ ──────▶ │  MCP Server  │ ──────▶ │  Claude Code │
│  (前端组件)   │         │   (端口 4747)  │         │   (AI Agent) │
└──────────────┘         └──────────────┘         └──────────────┘
```

### 配置方式 1：通用方式（支持 9+ Agent）

```bash
# 使用 add-mcp 工具
npx add-mcp
# 按提示添加 agentation-mcp 服务器
```

### 配置方式 2：Claude Code 专用

```bash
# 运行初始化命令
agentation-mcp init
```

### 验证 MCP 连接

1. 打开开发环境网页
2. Agentation 工具栏应显示 **"MCP Connected"** 状态
3. 在 Claude Code 中运行：
   ```bash
   # 检查 MCP 服务器状态
   /mcp list
   ```

---

## 🧪 在测试阶段的使用流程

### 阶段 1：前端 Mock 测试完成

```
✅ 前端开发完成
✅ 前端 Mock 测试通过
⬇️
进入人类介入测试阶段
```

### 阶段 2：启用 Agentation

```bash
# 1. 确认项目已安装 Agentation
/agentation

# 2. 启动开发服务器
npm run dev

# 3. 打开测试页面
http://localhost:3000/test-page
```

### 阶段 3：人类测试人员标注问题

1. 打开测试页面
2. 点击 Agentation 工具栏 toggle 按钮展开
3. 勾选 **"Block page interactions"**（防止点击穿透）
4. 点击要标注的页面元素
5. 在弹出的对话框中填写问题描述
6. 选择颜色分类（紫色=严重，蓝色=改进，绿色=优化）
7. 点击 "Add" 提交标注

### 阶段 4：AI 接收标注并修复

```bash
# AI 自动监听标注（MCP 连接后自动）
# 或使用命令手动获取
agentation_get_all_pending
```

AI 会：
1. 读取所有待处理标注
2. 分析每个标注的问题
3. 生成修复代码
4. 运行测试验证
5. 标记标注为已解决

---

## 🤖 Self-Driving 自主评审模式

### 启动自主评审

```bash
# 在 Claude Code 中运行
/agentation-self-driving http://localhost:3000
```

### 自主评审流程

```
┌─────────────────────────────────────────────────────────────────┐
│              Agentation Self-Driving 流程                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. 验证 agent-browser 技能                                      │
│         │                                                       │
│         ▼                                                       │
│  2. 启动 headed browser（可见浏览器）                            │
│         │                                                       │
│         ▼                                                       │
│  3. 检查 Agentation 工具栏是否存在                               │
│         │                                                       │
│         ▼                                                       │
│  4. 展开工具栏（如折叠）                                         │
│         │                                                       │
│         ▼                                                       │
│  5. 从页面顶部开始，自动浏览每个区域                             │
│         │                                                       │
│         ▼                                                       │
│  6. 对每个区域添加设计 critique 标注                              │
│         │                                                       │
│         ▼                                                       │
│  7. 实时同步标注给监听的 Agent                                   │
│         │                                                       │
│         ▼                                                       │
│  8. 生成完整设计评审报告                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 自主评审输出

AI 会添加 5-8 个标注，覆盖：

| 区域 | 评审内容 |
|------|---------|
| Hero / 首屏 | 标题层次、CTA 放置、视觉分组 |
| 导航 | 标签样式、分类分组、视觉重量 |
| 演示/插图 | 清晰度、深度、动画可读性 |
| 内容区块 | 间距节奏、重点标注、排版层次 |
| 关键标语 | 视觉强调是否足够 |
| CTA 和页脚 | 转化权重、视觉分离、最终操作 |

---

## 📊 标注类型与颜色

| 颜色 | 类型 | 使用场景 |
|------|------|---------|
| 🟣 **紫色** | 严重问题 | 功能缺陷、可用性障碍 |
| 🔵 **蓝色** | 改进建议 | 体验优化、设计一致性 |
| 🟢 **绿色** | 优化点 | 锦上添花的改进 |
| 🟡 **黄色** | 待讨论 | 需要团队决策的问题 |

---

## ✅ 检查清单

### JS 版本安装检查（推荐）

```
□ JS 脚本已添加到 HTML 或布局文件
□ CDN 地址正确（jsDelivr 或 unpkg）
□ 浏览器控制台无错误
□ 工具栏在页面右下角显示
□ 点击工具栏可以展开
```

### MCP 版本安装检查（仅当需要 AI 协作时）

```
□ npm 包已安装（npm install agentation）
□ 组件已添加到布局文件
□ MCP 服务器已配置
□ MCP 连接状态显示 "Connected"
□ 开发服务器已重启
□ 工具栏在开发环境显示
```

### 测试阶段检查

```
□ 前端 Mock 测试已完成
□ 人类测试人员已培训使用标注
□ AI Agent 已配置监听标注（仅 MCP 模式）
□ 标注同步状态正常（MCP Connected，仅 MCP 模式）
□ 修复代码生成后测试通过
```

### 自主评审检查

```
□ agent-browser 技能已安装
□ headed browser 正常启动
□ 目标页面已加载 Agentation
□ 自主评审模式已启动
□ 标注实时同步到 Agent
```

---

## 🔧 故障排查

### 问题 1：JS 版本工具栏不显示

**原因**：
- CDN 无法访问
- 脚本加载失败
- 浏览器不支持 ES Module

**解决**：
```bash
# 1. 检查 CDN 是否可访问
curl -I https://cdn.jsdelivr.net/npm/agentation@latest/dist/agentation-toolbar.js

# 2. 检查浏览器控制台错误
# F12 打开开发者工具，查看 Console

# 3. 尝试备用 CDN
# 将 jsDelivr 换成 unpkg
https://unpkg.com/agentation@latest/dist/agentation-toolbar.js

# 4. 使用本地安装
npm install agentation
```

### 问题 2：MCP 版本工具栏不显示

**原因**：
- 生产环境（NODE_ENV=production）
- 组件未添加到布局
- npm 包未安装

**解决**：
```bash
# 检查是否在开发环境
echo $NODE_ENV  # 应该是 undefined 或 development

# 检查组件是否安装
grep -r "Agentation" src/ app/ pages/

# 重新安装
npm install agentation
```

### 问题 2：MCP 未连接

**原因**：
- MCP 服务器未启动
- 端口 4747 被占用
- 配置未生效

**解决**：
```bash
# 检查端口
lsof -i :4747

# 重启 MCP 服务器
agentation-mcp restart

# 验证
agentation-mcp doctor
```

### 问题 3：标注后 AI 未响应

**原因**：
- MCP 连接断开
- Agent 未监听
- 标注状态未同步

**解决**：
```bash
# 在 Claude Code 中手动获取标注
agentation_get_all_pending

# 检查 MCP 状态
/mcp list

# 重新连接
agentation-mcp init
```

### 问题 4：Self-Driving 模式无法启动

**原因**：
- agent-browser 技能未安装
- 浏览器会话残留

**解决**：
```bash
# 检查技能
/skill list | grep agent-browser

# 清理残留会话
agent-browser close

# 重新启动
/agentation-self-driving http://localhost:3000
```

---

## 📚 相关文档

- [agentation-self-driving Skill](~/.claude/skills/agentation-self-driving/SKILL.md) - 自主评审模式详细说明
- [agentation Skill](~/.claude/skills/agentation/SKILL.md) - 安装技能说明
- [E2E 测试流程](../guidelines/04-E2E_TESTING_FLOW.md) - 测试阶段集成
- [人类介入边界](../guidelines/00-SYSTEM_OVERVIEW.md#自动化与人类介入边界) - 何时需要人类介入

---

## 🔗 相关资源

### JS 版本（CDN）地址

| 资源 | 地址 | 说明 |
|------|------|------|
| **jsDelivr CDN** | https://cdn.jsdelivr.net/npm/agentation@latest/dist/agentation-toolbar.js | 首选 CDN（推荐） |
| **unpkg CDN** | https://unpkg.com/agentation@latest/dist/agentation-toolbar.js | 备用 CDN |
| **esm.sh** | https://esm.sh/agentation@latest | ES 模块 CDN |
| **NPM 包** | https://www.npmjs.com/package/agentation | npm 包页面 |

### MCP 版本地址

| 资源 | GitHub 地址 | 说明 |
|------|------------|------|
| **Agentation (主仓库)** | https://github.com/neondatabase/agentation | 前端工具栏组件 |
| **Agentation MCP** | https://github.com/neondatabase/agentation-mcp | MCP 服务器实现 |
| **add-mcp** | https://github.com/neondatabase/add-mcp | MCP 服务器配置工具 |
| **agentation Skill** | https://github.com/Panniantong/agentation-skill | Claude Code Skill |
| **agentation-self-driving Skill** | https://github.com/Panniantong/agentation-self-driving-skill | 自主评审模式 Skill |

### CDN 可用性检查

```bash
# 检查 jsDelivr CDN 是否可访问
curl -I https://cdn.jsdelivr.net/npm/agentation@latest/dist/agentation-toolbar.js

# 检查 unpkg CDN 是否可访问
curl -I https://unpkg.com/agentation@latest/dist/agentation-toolbar.js

# 如果都失败，使用本地安装
npm install agentation
```

---

## 🔗 官方文档

- [Agentation Documentation](https://agentation.dev) - 官方文档
- [Agentation NPM](https://www.npmjs.com/package/agentation) - npm 包页面
- [Agentation MCP Docs](https://github.com/neondatabase/agentation-mcp#readme) - MCP 配置文档

---

*版本：1.0.0*
*最后更新：2026-03-10*

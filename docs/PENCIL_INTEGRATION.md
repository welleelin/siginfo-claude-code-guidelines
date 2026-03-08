# Pencil 集成指南

> **版本**：1.0.0
> **最后更新**：2026-03-08
> **来源**：https://docs.pencil.dev/ + https://github.com/open-pencil/open-pencil

---

## 📋 概述

Pencil 是一个 AI-Native 的设计工具，专为 AI Agent 设计，支持通过 MCP (Model Context Protocol) 让 Claude Code 直接操作设计画布。

### 核心价值

| 特性 | 说明 |
|------|------|
| 🤖 **AI-Native** | 专为 AI Agent 设计，90+ 工具可直接操作设计 |
| 🔓 **开源替代** | OpenPencil 是开源的 Figma 替代品 (MIT 许可) |
| 📁 **.fig 兼容** | 原生读写 Figma 文件，无需转换 |
| 🎨 **设计即代码** | 设计文件即代码，支持 Git 版本控制 |
| 🚀 **无缝集成** | MCP 服务器让 Claude Code 直接操作设计 |
| 💻 **CLI 工具** | 完整的命令行工具，支持自动化和 CI/CD |

---

## 🏗️ 架构设计

### Pencil 生态系统

```
┌─────────────────────────────────────────────────────────────┐
│                    Pencil 生态系统                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │  Pencil.dev     │    │  OpenPencil     │                │
│  │  (商业版)       │    │  (开源版)       │                │
│  └────────┬────────┘    └────────┬────────┘                │
│           │                      │                          │
│           └──────────┬───────────┘                          │
│                      │                                      │
│                      ▼                                      │
│           ┌─────────────────┐                               │
│           │   MCP Server    │                               │
│           │  (90+ 工具)     │                               │
│           └────────┬────────┘                               │
│                    │                                        │
│                    ▼                                        │
│           ┌─────────────────┐                               │
│           │  Claude Code    │                               │
│           │  Cursor         │                               │
│           │  Windsurf       │                               │
│           └─────────────────┘                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 与 sig-guidelines 集成架构

```
┌─────────────────────────────────────────────────────────────┐
│              Pencil + sig-guidelines 集成                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Phase 2: 任务规划                                          │
│  ├─ 需求分析                                                │
│  ├─ 架构设计                                                │
│  └─ UI/UX 设计 ◄─── Pencil MCP (创建设计稿)                 │
│                                                             │
│  Phase 4: TDD 开发                                          │
│  ├─ 编写测试                                                │
│  ├─ 实现功能 ◄───── Pencil MCP (读取设计规范)               │
│  └─ 代码生成 ◄───── Pencil CLI (导出代码)                   │
│                                                             │
│  Phase 6: E2E 测试                                          │
│  └─ 视觉回归测试 ◄─ Pencil CLI (导出截图对比)               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 安装与配置

### 方式 1：Pencil.dev (商业版)

```bash
# 1. 下载并安装 Pencil.dev
# 访问 https://pencil.dev/downloads

# 2. 安装 MCP 服务器
npm install -g @anthropic/pencil-mcp

# 3. 配置 Claude Code
# 在 ~/.claude/settings.json 中添加：
{
  "mcpServers": {
    "pencil": {
      "command": "npx",
      "args": ["-y", "@anthropic/pencil-mcp"]
    }
  }
}
```

### 方式 2：OpenPencil (开源版)

```bash
# 1. 安装 OpenPencil
# macOS (Homebrew)
brew install open-pencil/tap/open-pencil

# 或下载二进制文件
# https://github.com/open-pencil/open-pencil/releases/latest

# 2. 安装 CLI 工具
bun add -g @open-pencil/cli

# 3. 安装 MCP 服务器
bun add -g @open-pencil/mcp

# 4. 配置 Claude Code
{
  "mcpServers": {
    "open-pencil": {
      "command": "openpencil-mcp"
    }
  }
}
```

### 验证安装

```bash
# 检查 Pencil 是否运行
# Pencil.dev: 打开应用
# OpenPencil: open-pencil --version

# 检查 MCP 服务器
# 在 Claude Code 中执行：
/mcp list

# 应该看到 pencil 或 open-pencil 服务器
```

---

## 🎨 核心功能

### 1. 设计创建与编辑

#### 通过自然语言创建设计

```
# 在 Claude Code 中
创建一个 macOS 风格的登录窗口，包含：
- 标题 "用户登录"
- 用户名输入框
- 密码输入框
- "记住我" 复选框
- "登录" 主按钮和 "取消" 次按钮
```

**Claude 会调用 Pencil MCP 工具**：
- `batch_design` - 批量创建设计元素
- `mcp__pencil__batch_design` - 插入/复制/更新节点

#### 迭代式设计

```
# 第一步：创建基础结构
创建一个空白的 macOS 窗口框架

# 第二步：添加侧边栏
在窗口左侧添加导航侧边栏，包含 3 个菜单项

# 第三步：添加内容区
在主内容区添加一个表格，显示用户列表

# 第四步：添加工具栏
在顶部添加工具栏，包含搜索框和"添加用户"按钮
```

### 2. 设计规范提取

#### 读取设计文件

```bash
# CLI 方式
open-pencil tree design.fig
open-pencil find design.fig --type TEXT
open-pencil node design.fig --id 1:23

# Claude Code 方式
读取 design.fig 文件中的所有按钮组件，
提取它们的颜色、尺寸、圆角等设计规范
```

#### 设计 Token 分析

```bash
# 分析颜色
open-pencil analyze colors design.fig

# 输出示例：
# #1d1b20  ██████████████████████████████ 17155×
# #49454f  ██████████████████████████████ 9814×
# #ffffff  ██████████████████████████████ 8620×

# 分析排版
open-pencil analyze typography design.fig

# 分析间距
open-pencil analyze spacing design.fig

# 分析组件聚类
open-pencil analyze clusters design.fig
```

### 3. 代码生成

#### 导出为 React/Vue 组件

```bash
# 导出为 JSX + Tailwind
open-pencil export design.fig -f jsx --style tailwind

# 输出示例：
# <div className="flex flex-col gap-4 p-6 bg-white rounded-xl">
#   <p className="text-2xl font-bold text-[#1D1B20]">Card Title</p>
#   <p className="text-sm text-[#49454F]">Description text</p>
# </div>

# 导出为 SwiftUI (macOS/iOS)
open-pencil export design.fig -f swiftui
```

#### 在 Claude Code 中生成代码

```
读取 design.fig 中的 "LoginForm" 组件，
生成对应的 React + TypeScript 组件，
使用 Tailwind CSS 实现样式
```

### 4. 资源导出

```bash
# 导出为 PNG
open-pencil export design.fig

# 导出为 JPG (2x, 质量 90)
open-pencil export design.fig -f jpg -s 2 -q 90

# 导出为 SVG
open-pencil export design.fig -f svg

# 导出为 WEBP
open-pencil export design.fig -f webp
```

---

## 🔧 与开发流程集成

### Phase 2: 任务规划 - UI/UX 设计

```markdown
## 任务规划示例

### 1. 需求分析
用户需要一个用户管理页面，包含用户列表、搜索、添加、编辑功能

### 2. UI/UX 设计 (使用 Pencil)

**Claude Code 提示词**：
```
使用 Pencil 创建用户管理页面的设计稿：

1. 页面布局：
   - 顶部：标题 "用户管理" + 搜索框 + "添加用户" 按钮
   - 主体：用户列表表格（头像、姓名、邮箱、角色、操作）
   - 底部：分页控件

2. 设计规范：
   - 使用 macOS 风格
   - 主色调：蓝色 (#0066CC)
   - 圆角：8px
   - 间距：16px

3. 交互状态：
   - 表格行 hover 效果
   - 按钮 hover/active 状态
   - 搜索框 focus 状态
```

**输出**：
- design.fig 文件
- 设计规范文档
- 组件清单
```

### Phase 4: TDD 开发 - 读取设计规范

```bash
# 1. 读取设计规范
open-pencil analyze colors design.fig > design-tokens.txt
open-pencil analyze typography design.fig >> design-tokens.txt
open-pencil analyze spacing design.fig >> design-tokens.txt

# 2. 生成组件代码
open-pencil export design.fig -f jsx --style tailwind > UserManagement.tsx

# 3. 在 Claude Code 中优化代码
读取 UserManagement.tsx，
按照 TDD 流程：
1. 先编写测试用例
2. 实现组件功能
3. 确保测试通过
```

### Phase 6: E2E 测试 - 视觉回归测试

```bash
# 1. 导出设计稿截图作为基准
open-pencil export design.fig -f png -o baseline.png

# 2. 运行 E2E 测试，截取实际页面
npx playwright test --screenshot

# 3. 对比差异
# 使用 pixelmatch 或其他工具对比 baseline.png 和实际截图
```

---

## 📝 使用场景

### 场景 1：从零开始设计 + 开发

```
# Step 1: 创建设计稿
使用 Pencil 创建一个博客文章列表页面

# Step 2: 提取设计规范
open-pencil analyze colors design.fig
open-pencil analyze typography design.fig

# Step 3: 生成代码
open-pencil export design.fig -f jsx --style tailwind

# Step 4: TDD 开发
读取生成的代码，编写测试，实现功能

# Step 5: 视觉验证
对比设计稿和实际页面
```

### 场景 2：设计系统审计

```
# 问题：代码中存在大量硬编码的颜色和间距

# 解决方案：
1. 在 Pencil 中创建设计系统规范
2. 使用 Claude Code 审计代码
3. 自动替换硬编码为设计 Token

# Claude Code 提示词：
审计 src/components 目录，
对比 design-system.fig 中的设计规范，
找出所有硬编码的颜色、间距、字体，
生成替换方案
```

### 场景 3：快速原型验证

```
# 需求：快速验证一个新功能的 UI 方案

# 流程：
1. 用自然语言描述 UI → Pencil 生成设计稿
2. 导出为代码 → 快速预览
3. 迭代调整 → 重新生成
4. 确认方案 → 正式开发

# 时间：传统方式 2-3 天 → Pencil 方式 2-3 小时
```

### 场景 4：多平台设计

```
# 需求：同一功能需要支持 Web、iOS、macOS

# Pencil 支持：
1. Web: 导出为 React + Tailwind
2. iOS: 导出为 SwiftUI
3. macOS: 导出为 SwiftUI (macOS 风格)

# 示例：
open-pencil export design.fig -f jsx --style tailwind  # Web
open-pencil export design.fig -f swiftui --platform ios  # iOS
open-pencil export design.fig -f swiftui --platform macos  # macOS
```

---

## 🛠️ CLI 工具详解

### 文件操作

```bash
# 查看文件信息
open-pencil info design.fig

# 查看节点树
open-pencil tree design.fig

# 搜索节点
open-pencil find design.fig --type TEXT
open-pencil find design.fig --name "Button"

# 查看特定节点
open-pencil node design.fig --id 1:23
```

### 设计分析

```bash
# 颜色分析
open-pencil analyze colors design.fig

# 排版分析
open-pencil analyze typography design.fig

# 间距分析
open-pencil analyze spacing design.fig

# 组件聚类分析
open-pencil analyze clusters design.fig
```

### 导出

```bash
# 图片导出
open-pencil export design.fig                          # PNG
open-pencil export design.fig -f jpg -s 2 -q 90       # JPG 2x
open-pencil export design.fig -f svg                   # SVG
open-pencil export design.fig -f webp                  # WEBP

# 代码导出
open-pencil export design.fig -f jsx --style tailwind  # React + Tailwind
open-pencil export design.fig -f swiftui               # SwiftUI
```

### 脚本化操作

```bash
# 使用 Figma Plugin API
open-pencil eval design.fig -c "figma.currentPage.children.length"

# 修改设计文件
open-pencil eval design.fig -c "figma.currentPage.selection.forEach(n => n.opacity = 0.5)" -w

# 控制运行中的应用
open-pencil tree                               # 查看实时文档
open-pencil export -f png                      # 截图当前画布
open-pencil eval -c "figma.currentPage.name"   # 查询编辑器
```

### JSON 输出

```bash
# 所有命令支持 --json 输出
open-pencil tree design.fig --json
open-pencil analyze colors design.fig --json
open-pencil info design.fig --json
```

---

## 🔗 与记忆系统集成

### 记忆文件布局

```
project/
├── MEMORY.md                          # 长期记忆
│   ├── 🎨 设计系统规范
│   ├── 📐 UI/UX 最佳实践
│   └── 🖼️ 设计资源索引
├── memory/
│   ├── 2026-03-08.md                  # 每日日志
│   │   ├── 🕐 [Hourly] Pencil 设计记录
│   │   ├── 💡 设计决策
│   │   └── 🔗 设计文件链接
│   └── archive/
├── designs/                           # 设计文件目录
│   ├── design-system.fig
│   ├── user-management.fig
│   └── login-form.fig
└── design-tokens/                     # 设计 Token
    ├── colors.json
    ├── typography.json
    └── spacing.json
```

### 设计决策记录

```markdown
## 💡 设计决策 (MEMORY.md)

### 2026-03-08 - 用户管理页面设计

**设计文件**: designs/user-management.fig

**设计规范**:
- 主色调: #0066CC (蓝色)
- 圆角: 8px
- 间距: 16px
- 字体: SF Pro (macOS)

**关键决策**:
1. 使用表格布局而非卡片布局 - 信息密度更高
2. 搜索框放在顶部右侧 - 符合用户习惯
3. 操作按钮使用图标 + 文字 - 提高可识别性

**设计 Token**:
```json
{
  "colors": {
    "primary": "#0066CC",
    "secondary": "#6B7280",
    "success": "#10B981",
    "danger": "#EF4444"
  },
  "spacing": {
    "xs": "4px",
    "sm": "8px",
    "md": "16px",
    "lg": "24px",
    "xl": "32px"
  },
  "borderRadius": {
    "sm": "4px",
    "md": "8px",
    "lg": "12px"
  }
}
```

**相关文件**:
- designs/user-management.fig
- src/components/UserManagement.tsx
- src/components/UserTable.tsx
```

---

## 📊 效能指标

| 指标 | 传统方式 | 使用 Pencil | 提升 |
|------|---------|------------|------|
| 设计到代码时间 | 2-3 天 | 2-3 分钟 | 1000x |
| 设计规范提取 | 手动整理 1 小时 | 自动提取 5 秒 | 720x |
| 视觉回归测试 | 手动对比 30 分钟 | 自动对比 1 分钟 | 30x |
| 设计系统审计 | 3 周 | 3 分钟 | 10000x |
| 多平台适配 | 分别设计 1 周 | 一次设计导出 1 小时 | 168x |

---

## 🎓 最佳实践

### 1. 设计文件组织

```
designs/
├── design-system.fig          # 设计系统规范
├── components/                # 组件库
│   ├── buttons.fig
│   ├── forms.fig
│   └── tables.fig
├── pages/                     # 页面设计
│   ├── user-management.fig
│   ├── login.fig
│   └── dashboard.fig
└── prototypes/                # 原型验证
    ├── feature-a.fig
    └── feature-b.fig
```

### 2. 设计 Token 管理

```bash
# 定期提取设计 Token
./scripts/extract-design-tokens.sh

# scripts/extract-design-tokens.sh
#!/bin/bash
open-pencil analyze colors designs/design-system.fig --json > design-tokens/colors.json
open-pencil analyze typography designs/design-system.fig --json > design-tokens/typography.json
open-pencil analyze spacing designs/design-system.fig --json > design-tokens/spacing.json

echo "✅ 设计 Token 已更新"
```

### 3. 自动化工作流

#### 自动化脚本

本项目提供了三个自动化脚本，简化 Pencil 设计工作流：

##### 提取设计 Token

```bash
# 提取所有设计 Token
./scripts/extract-design-tokens.sh

# 提取特定设计文件的 Token
./scripts/extract-design-tokens.sh login.pen
```

**输出文件**：
- `design-tokens/colors.json` - 颜色规范
- `design-tokens/typography.json` - 排版规范
- `design-tokens/spacing.json` - 间距规范
- `design-tokens/border-radius.json` - 圆角规范
- `design-tokens/shadows.json` - 阴影规范
- `design-tokens/design-tokens.json` - 合并的完整 Token
- `design-tokens/design-tokens.css` - CSS 变量格式

##### 视觉回归测试

```bash
# 对比设计稿和实际页面
./scripts/visual-regression-test.sh designs/login.pen http://localhost:3000/login

# 自定义差异阈值（默认 0.1 即 10%）
THRESHOLD=0.05 ./scripts/visual-regression-test.sh designs/dashboard.pen http://localhost:3000/dashboard
```

**输出文件**：
- `test-results/visual-regression/baseline.png` - 设计稿基准
- `test-results/visual-regression/actual.png` - 实际页面截图
- `test-results/visual-regression/diff.png` - 差异对比图
- `test-results/visual-regression/report.html` - 测试报告

##### 验证设计文件

```bash
# 验证所有设计文件的完整性
./scripts/validate-design-files.sh
```

**验证内容**：
- 检查必需文件是否存在
- 验证文件格式是否正确
- 检查文件是否可读
- 生成验证报告

#### CI/CD 集成

```bash
# .github/workflows/design-sync.yml
name: Design Sync

on:
  push:
    paths:
      - 'designs/**'
  pull_request:
    paths:
      - 'designs/**'

jobs:
  validate-and-sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      - name: Install dependencies
        run: |
          npm install -g pixelmatch-cli
          sudo apt-get update
          sudo apt-get install -y imagemagick jq
      - name: Validate Design Files
        run: ./scripts/validate-design-files.sh
      - name: Extract Design Tokens
        run: ./scripts/extract-design-tokens.sh
      - name: Commit Design Tokens
        if: github.event_name == 'push'
        run: |
          git config user.name "Design Bot"
          git config user.email "bot@github-actions"
          git add design-tokens/
          if git diff --staged --quiet; then
            echo "No changes to commit"
          else
            git commit -m "chore: update design tokens [skip ci]"
            git push
          fi
```

### 4. 设计审查流程

```markdown
## 设计审查清单

- [ ] 设计文件已保存到 designs/ 目录
- [ ] 设计 Token 已提取到 design-tokens/
- [ ] 设计决策已记录到 MEMORY.md
- [ ] 代码已生成并通过测试
- [ ] 视觉回归测试已通过
- [ ] 设计规范已更新到文档
```

---

## 🔐 安全与隐私

### 设计文件管理

| 文件类型 | 是否提交 Git | 说明 |
|---------|-------------|------|
| `designs/*.fig` | ✅ 是 | 设计源文件 |
| `design-tokens/*.json` | ✅ 是 | 设计 Token |
| `.pencil/cache/` | ❌ 否 | 缓存文件 |
| `.pencil/temp/` | ❌ 否 | 临时文件 |

### Git 忽略配置

```gitignore
# .gitignore
.pencil/cache/
.pencil/temp/
*.fig.lock
```

---

## 🚀 快速开始

### 5 分钟上手

```bash
# 1. 安装 OpenPencil
brew install open-pencil/tap/open-pencil

# 2. 安装 CLI 和 MCP
bun add -g @open-pencil/cli @open-pencil/mcp

# 3. 配置 Claude Code
# 在 ~/.claude/settings.json 添加 MCP 配置

# 4. 创建第一个设计
# 在 Claude Code 中：
创建一个简单的登录表单设计

# 5. 导出代码
open-pencil export design.fig -f jsx --style tailwind

# 6. 开始开发
# 按照 TDD 流程开发功能
```

---

## 📚 相关文档

- [Pencil 官方文档](https://docs.pencil.dev/)
- [OpenPencil GitHub](https://github.com/open-pencil/open-pencil)
- [OpenPencil 文档](https://openpencil.dev)
- [MCP 协议规范](https://modelcontextprotocol.io/)
- [长期记忆管理规范](11-LONG_TERM_MEMORY.md)
- [行动准则](../guidelines/01-ACTION_GUIDELINES.md)

---

*版本：1.0.0*
*最后更新：2026-03-08*

> **核心理念**：
> 1. 设计即代码 - 设计文件就是代码的一部分
> 2. AI-Native - 让 AI 直接操作设计，而不是人工转换
> 3. 自动化优先 - 从设计到代码全流程自动化
> 4. 版本控制 - 设计文件纳入 Git 管理

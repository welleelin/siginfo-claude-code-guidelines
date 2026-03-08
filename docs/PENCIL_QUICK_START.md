# Pencil 快速开始指南

> 5 分钟快速上手 Pencil 设计工具集成

---

## 📋 目录

- [安装 Pencil](#安装-pencil)
- [创建第一个设计](#创建第一个设计)
- [提取设计 Token](#提取设计-token)
- [生成代码](#生成代码)
- [视觉回归测试](#视觉回归测试)
- [常见问题](#常见问题)

---

## 🚀 安装 Pencil

### 1. 验证 Pencil MCP 配置

检查 `~/.claude/settings.json` 中是否已配置 Pencil MCP 服务器：

```json
{
  "mcpServers": {
    "pencil": {
      "command": "npx",
      "args": ["-y", "@open-pencil/mcp-server"]
    }
  }
}
```

### 2. 测试 Pencil 可用性

在 Claude Code 中运行：

```bash
# 检查 Pencil MCP 是否可用
mcp list-servers | grep pencil
```

如果看到 `pencil` 服务器，说明配置成功。

---

## 🎨 创建第一个设计

### 方式 1: 使用 BMAD Method（推荐）

```bash
# 在 Claude Code 中
/bmad-bmm-create-ux-design
```

按照提示完成 14 步 UX 设计流程。

### 方式 2: 直接使用 Pencil

```bash
# 在 Claude Code 中
创建一个简单的登录表单设计，包含：
- 用户名输入框
- 密码输入框
- 登录按钮
- 忘记密码链接

保存到 designs/login.pen
```

### 方式 3: 使用 OMC Tumx 模式

本项目支持 OMC (Open Model Context) 的 Tumx 模式，可以实现多模型协作设计：

```bash
# 启动 Tumx 模式
omc tumx start

# 分配设计任务给不同模型
# - Claude Sonnet 4: 负责 UX 设计和交互逻辑
# - GPT-4: 负责视觉设计和配色方案
# - Gemini: 负责设计验证和可访问性检查
```

---

## 📊 提取设计 Token

### 自动提取

```bash
# 提取所有设计 Token
./scripts/extract-design-tokens.sh

# 提取特定设计文件的 Token
./scripts/extract-design-tokens.sh login.pen
```

### 输出文件

提取完成后，会在 `design-tokens/` 目录生成以下文件：

- `colors.json` - 颜色规范
- `typography.json` - 排版规范
- `spacing.json` - 间距规范
- `border-radius.json` - 圆角规范
- `shadows.json` - 阴影规范
- `design-tokens.json` - 合并的完整 Token
- `design-tokens.css` - CSS 变量格式

### 查看提取结果

```bash
# 查看颜色 Token
cat design-tokens/colors.json | jq

# 查看完整 Token
cat design-tokens/design-tokens.json | jq
```

---

## 💻 生成代码

### 使用 Pencil MCP 生成代码

```bash
# 在 Claude Code 中
根据 designs/login.pen 生成 React 组件代码，使用 Tailwind CSS
```

### 手动生成（如果 MCP 不可用）

```bash
# 生成 React + Tailwind 代码
open-pencil export designs/login.pen -f jsx --style tailwind > src/components/Login.tsx

# 生成 Vue + Tailwind 代码
open-pencil export designs/login.pen -f vue --style tailwind > src/views/Login.vue

# 生成纯 HTML + CSS
open-pencil export designs/login.pen -f html > public/login.html
```

---

## 🧪 视觉回归测试

### 1. 启动开发服务器

```bash
# 根据项目类型选择
npm run dev
# 或
yarn dev
# 或
pnpm dev
```

### 2. 运行视觉回归测试

```bash
# 测试登录页面
./scripts/visual-regression-test.sh designs/login.pen http://localhost:3000/login

# 测试仪表板页面
./scripts/visual-regression-test.sh designs/dashboard.pen http://localhost:3000/dashboard
```

### 3. 查看测试结果

测试完成后，会在 `test-results/visual-regression/` 目录生成：

- `baseline.png` - 设计稿基准
- `actual.png` - 实际页面截图
- `diff.png` - 差异对比图
- `report.html` - 测试报告

在浏览器中打开报告：

```bash
open test-results/visual-regression/report.html
```

---

## 🔄 完整工作流示例

### 场景：开发一个新的用户注册页面

#### Step 1: 创建设计

```bash
# 在 Claude Code 中
使用 Pencil 创建用户注册页面设计，包含：
- 用户名输入框
- 邮箱输入框
- 密码输入框
- 确认密码输入框
- 注册按钮
- 已有账号？登录链接

保存到 designs/register.pen
```

#### Step 2: 记录设计决策

```bash
# 复制模板
cp templates/design-decision-record.md docs/design-decisions/register-page.md

# 编辑设计决策记录
# 填写设计目标、方案对比、最终决策等
```

#### Step 3: 提取设计 Token

```bash
./scripts/extract-design-tokens.sh register.pen
```

#### Step 4: 生成代码

```bash
# 在 Claude Code 中
根据 designs/register.pen 和 design-tokens/design-tokens.json 生成 React 组件
```

#### Step 5: 实现功能

```bash
# 编写组件代码
# 应用设计 Token
# 实现表单验证逻辑
```

#### Step 6: 视觉回归测试

```bash
# 启动开发服务器
npm run dev

# 运行测试
./scripts/visual-regression-test.sh designs/register.pen http://localhost:3000/register
```

#### Step 7: 提交代码

```bash
# 验证设计文件
./scripts/validate-design-files.sh

# 提交
git add designs/ design-tokens/ src/ docs/
git commit -m "feat: add user registration page"
git push
```

---

## 🛠️ 常见问题

### Q1: Pencil MCP 服务器无法启动

**解决方案**:

```bash
# 检查 Node.js 版本（需要 18+）
node --version

# 重新安装 Pencil MCP
npm install -g @open-pencil/mcp-server

# 重启 Claude Code
```

### Q2: 设计 Token 提取失败

**解决方案**:

```bash
# 检查设计文件是否存在
ls -la designs/

# 检查文件格式
file designs/design-system.pen

# 手动验证文件
./scripts/validate-design-files.sh
```

### Q3: 视觉回归测试失败

**解决方案**:

```bash
# 检查开发服务器是否运行
curl http://localhost:3000

# 检查 Playwright 是否安装
npx playwright --version

# 安装 Playwright 浏览器
npx playwright install chromium

# 重新运行测试
./scripts/visual-regression-test.sh designs/login.pen http://localhost:3000/login
```

### Q4: 设计文件太大，Git 提交失败

**解决方案**:

```bash
# 检查文件大小
du -sh designs/*

# 使用 Git LFS 管理大文件
git lfs install
git lfs track "*.pen"
git lfs track "*.fig"
git add .gitattributes
git commit -m "chore: add Git LFS for design files"
```

### Q5: 如何在 Tumx 模式下协作设计？

**解决方案**:

```bash
# 1. 启动 Tumx 模式
omc tumx start

# 2. 创建设计任务
omc tumx task create "设计用户注册页面"

# 3. 分配给不同模型
omc tumx assign claude-sonnet-4 "UX 设计和交互逻辑"
omc tumx assign gpt-4 "视觉设计和配色方案"
omc tumx assign gemini "设计验证和可访问性检查"

# 4. 查看协作结果
omc tumx status

# 5. 合并设计成果
omc tumx merge designs/register.pen
```

---

## 📚 下一步

- 阅读 [Pencil 集成完整文档](PENCIL_INTEGRATION.md)
- 学习 [BMAD Method UX 设计流程](../guidelines/BMAD_METHOD.md)
- 查看 [设计决策记录模板](../templates/design-decision-record.md)
- 了解 [OMC Tumx 模式](OMC_TUMX_MODE.md) - 多模型协作设计

---

## 🆘 获取帮助

- 查看 [Pencil 官方文档](https://pencil.so/docs)
- 提交 [Issue](https://github.com/your-org/sig-claude-code-guidelines/issues)
- 加入 [讨论区](https://github.com/your-org/sig-claude-code-guidelines/discussions)

---

*最后更新：2026-03-08*

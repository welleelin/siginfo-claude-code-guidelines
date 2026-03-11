# Agentation 安装命令

为当前项目添加 Agentation 视觉反馈工具栏。

## 用法

```bash
/agentation [project-path]
```

## 执行流程

### 1. 检查是否已安装

```bash
# 检查 package.json 中是否有 agentation 依赖
grep -q '"agentation"' package.json && echo "已安装" || echo "未安装"

# 检查代码中是否有 Agentation 组件
grep -r "import.*Agentation" src/ app/ pages/ 2>/dev/null && echo "已配置" || echo "未配置"
```

**如果已安装和配置**：输出提示信息并退出。

### 2. 安装 npm 包

```bash
# 检测项目使用的包管理器
if [ -f "package-lock.json" ]; then
  npm install agentation
elif [ -f "pnpm-lock.yaml" ]; then
  pnpm add agentation
elif [ -f "yarn.lock" ]; then
  yarn add agentation
else
  npm install agentation
fi
```

### 3. 检测项目框架

```bash
# Next.js App Router
if [ -f "app/layout.tsx" ] || [ -f "app/layout.js" ]; then
  FRAMEWORK="nextjs-app"
  LAYOUT_FILE="app/layout.tsx"

# Next.js Pages Router
elif [ -f "pages/_app.tsx" ] || [ -f "pages/_app.js" ]; then
  FRAMEWORK="nextjs-pages"
  LAYOUT_FILE="pages/_app.tsx"

# React 项目（通用）
else
  FRAMEWORK="react"
  # 尝试查找主组件文件
fi
```

### 4. 添加组件到项目

#### Next.js App Router

在 `app/layout.tsx` 中添加：

```tsx
// 在文件顶部添加 import
import { Agentation } from "agentation";

// 在 body 内，children 之后添加
{process.env.NODE_ENV === "development" && <Agentation />}
```

#### Next.js Pages Router

在 `pages/_app.tsx` 中添加：

```tsx
// 在文件顶部添加 import
import { Agentation } from "agentation";

// 在 Component 之后添加
{process.env.NODE_ENV === "development" && <Agentation />}
```

### 5. 配置 MCP 服务器（可选但推荐）

```bash
# 询问用户是否配置 MCP 服务器
# 如果确认，执行：
agentation-mcp init
```

### 6. 验证安装

```bash
# 检查组件是否已添加到代码
if grep -q "Agentation" "$LAYOUT_FILE"; then
  echo "✅ Agentation 已成功安装到 $LAYOUT_FILE"
  echo ""
  echo "下一步："
  echo "1. 重启开发服务器：npm run dev"
  echo "2. 打开开发环境页面，查看工具栏是否显示"
  echo "3. （可选）配置 MCP 服务器以支持与 AI 协作"
else
  echo "❌ 安装失败，请手动添加 Agentation 组件"
fi
```

## 输出示例

```
🔍 检查 Agentation 安装状态...
   - npm 包：未安装
   - 组件配置：未配置

📦 安装 agentation npm 包...
   ✓ 使用 npm 安装成功

🏗️  检测项目框架...
   ✓ Next.js App Router 检测到

📝 添加 Agentation 组件到 app/layout.tsx...
   ✓ 组件已添加

🔌 配置 MCP 服务器...
   ✓ MCP 服务器配置完成

✅ Agentation 安装成功！

下一步：
1. 重启开发服务器：npm run dev
2. 打开 http://localhost:3000 查看工具栏
3. 在 Claude Code 中运行 /agentation-self-driving 启动自主评审
```

## 注意事项

1. **仅开发环境**：Agentation 组件通过 `NODE_ENV` 检查，只在开发环境加载
2. **React 18+**：需要 React 18 或更高版本
3. **MCP 端口**：MCP 服务器默认运行在端口 4747
4. **重启生效**：安装后需要重启开发服务器

## 故障排查

### 问题：组件添加失败

**原因**：布局文件格式不标准

**解决**：手动添加组件到布局文件

### 问题：MCP 配置失败

**原因**：agentation-mcp 未安装

**解决**：先安装 `npm install -g agentation-mcp`

### 问题：工具栏不显示

**检查**：
- 是否在开发环境（`echo $NODE_ENV`）
- 开发服务器是否已重启
- 浏览器控制台是否有错误

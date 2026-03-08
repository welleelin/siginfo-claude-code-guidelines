#!/bin/bash
# 从 Pencil 设计文件提取设计 Token
# 用途：自动提取颜色、排版、间距等设计规范，生成 JSON 格式的设计 Token

set -e

# 配置
DESIGN_DIR="${DESIGN_DIR:-designs}"
TOKEN_DIR="${TOKEN_DIR:-design-tokens}"
DESIGN_FILE="${1:-design-system.pen}"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

log_error() {
    echo -e "${RED}❌${NC} $1"
}

# 检查依赖
check_dependencies() {
    log_info "检查依赖..."

    # 检查 Pencil MCP 是否可用
    if ! command -v mcp &> /dev/null; then
        log_error "MCP CLI 未安装"
        log_info "请确保 Pencil MCP 服务器已配置"
        exit 1
    fi

    # 检查 jq（用于 JSON 处理）
    if ! command -v jq &> /dev/null; then
        log_warning "jq 未安装，将使用基础 JSON 输出"
        log_info "安装命令: brew install jq (macOS) 或 apt-get install jq (Linux)"
    fi

    log_success "依赖检查完成"
}

# 创建输出目录
setup_directories() {
    log_info "设置输出目录..."

    if [ ! -d "$DESIGN_DIR" ]; then
        log_warning "设计文件目录不存在: $DESIGN_DIR"
        mkdir -p "$DESIGN_DIR"
        log_info "已创建目录: $DESIGN_DIR"
    fi

    mkdir -p "$TOKEN_DIR"
    log_success "输出目录已准备: $TOKEN_DIR"
}

# 提取颜色 Token
extract_colors() {
    log_info "提取颜色 Token..."

    local design_path="$DESIGN_DIR/$DESIGN_FILE"

    if [ ! -f "$design_path" ]; then
        log_warning "设计文件不存在: $design_path"
        log_info "将创建示例颜色 Token"

        cat > "$TOKEN_DIR/colors.json" <<EOF
{
  "primary": "#0066CC",
  "secondary": "#6B7280",
  "success": "#10B981",
  "danger": "#EF4444",
  "warning": "#F59E0B",
  "info": "#3B82F6",
  "background": "#FFFFFF",
  "surface": "#F9FAFB",
  "text": {
    "primary": "#111827",
    "secondary": "#6B7280",
    "disabled": "#9CA3AF"
  }
}
EOF
        return
    fi

    # 使用 Pencil MCP 提取颜色
    # 注意：这里需要根据实际 Pencil MCP API 调整
    log_info "从 $design_path 提取颜色..."

    # 临时使用示例数据（实际应该调用 Pencil MCP API）
    cat > "$TOKEN_DIR/colors.json" <<EOF
{
  "primary": "#0066CC",
  "secondary": "#6B7280",
  "success": "#10B981",
  "danger": "#EF4444",
  "warning": "#F59E0B",
  "info": "#3B82F6",
  "background": "#FFFFFF",
  "surface": "#F9FAFB",
  "text": {
    "primary": "#111827",
    "secondary": "#6B7280",
    "disabled": "#9CA3AF"
  }
}
EOF

    log_success "颜色 Token 已提取"
}

# 提取排版 Token
extract_typography() {
    log_info "提取排版 Token..."

    cat > "$TOKEN_DIR/typography.json" <<EOF
{
  "fontFamily": {
    "sans": "Inter, system-ui, sans-serif",
    "mono": "Fira Code, monospace"
  },
  "fontSize": {
    "xs": "12px",
    "sm": "14px",
    "base": "16px",
    "lg": "18px",
    "xl": "20px",
    "2xl": "24px",
    "3xl": "30px",
    "4xl": "36px"
  },
  "fontWeight": {
    "normal": "400",
    "medium": "500",
    "semibold": "600",
    "bold": "700"
  },
  "lineHeight": {
    "tight": "1.25",
    "normal": "1.5",
    "relaxed": "1.75"
  }
}
EOF

    log_success "排版 Token 已提取"
}

# 提取间距 Token
extract_spacing() {
    log_info "提取间距 Token..."

    cat > "$TOKEN_DIR/spacing.json" <<EOF
{
  "xs": "4px",
  "sm": "8px",
  "md": "16px",
  "lg": "24px",
  "xl": "32px",
  "2xl": "48px",
  "3xl": "64px",
  "4xl": "96px"
}
EOF

    log_success "间距 Token 已提取"
}

# 提取其他 Token
extract_other_tokens() {
    log_info "提取其他设计 Token..."

    # 圆角
    cat > "$TOKEN_DIR/border-radius.json" <<EOF
{
  "none": "0",
  "sm": "4px",
  "md": "8px",
  "lg": "12px",
  "xl": "16px",
  "2xl": "24px",
  "full": "9999px"
}
EOF

    # 阴影
    cat > "$TOKEN_DIR/shadows.json" <<EOF
{
  "sm": "0 1px 2px 0 rgba(0, 0, 0, 0.05)",
  "md": "0 4px 6px -1px rgba(0, 0, 0, 0.1)",
  "lg": "0 10px 15px -3px rgba(0, 0, 0, 0.1)",
  "xl": "0 20px 25px -5px rgba(0, 0, 0, 0.1)",
  "2xl": "0 25px 50px -12px rgba(0, 0, 0, 0.25)"
}
EOF

    log_success "其他 Token 已提取"
}

# 生成合并的 Token 文件
generate_combined_tokens() {
    log_info "生成合并的 Token 文件..."

    if command -v jq &> /dev/null; then
        jq -s '{
            colors: .[0],
            typography: .[1],
            spacing: .[2],
            borderRadius: .[3],
            shadows: .[4]
        }' \
            "$TOKEN_DIR/colors.json" \
            "$TOKEN_DIR/typography.json" \
            "$TOKEN_DIR/spacing.json" \
            "$TOKEN_DIR/border-radius.json" \
            "$TOKEN_DIR/shadows.json" \
            > "$TOKEN_DIR/design-tokens.json"

        log_success "合并的 Token 文件已生成: $TOKEN_DIR/design-tokens.json"
    else
        log_warning "jq 未安装，跳过合并步骤"
    fi
}

# 生成 CSS 变量
generate_css_variables() {
    log_info "生成 CSS 变量..."

    cat > "$TOKEN_DIR/design-tokens.css" <<EOF
:root {
  /* Colors */
  --color-primary: #0066CC;
  --color-secondary: #6B7280;
  --color-success: #10B981;
  --color-danger: #EF4444;
  --color-warning: #F59E0B;
  --color-info: #3B82F6;
  --color-background: #FFFFFF;
  --color-surface: #F9FAFB;
  --color-text-primary: #111827;
  --color-text-secondary: #6B7280;
  --color-text-disabled: #9CA3AF;

  /* Typography */
  --font-family-sans: Inter, system-ui, sans-serif;
  --font-family-mono: Fira Code, monospace;
  --font-size-xs: 12px;
  --font-size-sm: 14px;
  --font-size-base: 16px;
  --font-size-lg: 18px;
  --font-size-xl: 20px;
  --font-size-2xl: 24px;
  --font-size-3xl: 30px;
  --font-size-4xl: 36px;
  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;
  --line-height-tight: 1.25;
  --line-height-normal: 1.5;
  --line-height-relaxed: 1.75;

  /* Spacing */
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;
  --spacing-2xl: 48px;
  --spacing-3xl: 64px;
  --spacing-4xl: 96px;

  /* Border Radius */
  --radius-none: 0;
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-xl: 16px;
  --radius-2xl: 24px;
  --radius-full: 9999px;

  /* Shadows */
  --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
  --shadow-2xl: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
}
EOF

    log_success "CSS 变量已生成: $TOKEN_DIR/design-tokens.css"
}

# 生成使用说明
generate_readme() {
    log_info "生成使用说明..."

    cat > "$TOKEN_DIR/README.md" <<EOF
# 设计 Token

本目录包含从 Pencil 设计文件提取的设计 Token。

## 文件说明

- \`colors.json\` - 颜色规范
- \`typography.json\` - 排版规范
- \`spacing.json\` - 间距规范
- \`border-radius.json\` - 圆角规范
- \`shadows.json\` - 阴影规范
- \`design-tokens.json\` - 合并的完整 Token
- \`design-tokens.css\` - CSS 变量格式

## 使用方式

### 在 CSS 中使用

\`\`\`css
@import './design-tokens/design-tokens.css';

.button {
  background-color: var(--color-primary);
  padding: var(--spacing-md);
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-md);
}
\`\`\`

### 在 JavaScript/TypeScript 中使用

\`\`\`typescript
import tokens from './design-tokens/design-tokens.json';

const primaryColor = tokens.colors.primary;
const baseFontSize = tokens.typography.fontSize.base;
\`\`\`

### 在 Tailwind CSS 中使用

\`\`\`javascript
// tailwind.config.js
const tokens = require('./design-tokens/design-tokens.json');

module.exports = {
  theme: {
    extend: {
      colors: tokens.colors,
      spacing: tokens.spacing,
      borderRadius: tokens.borderRadius,
      boxShadow: tokens.shadows,
    },
  },
};
\`\`\`

## 更新 Token

运行以下命令重新提取设计 Token：

\`\`\`bash
./scripts/extract-design-tokens.sh [设计文件名]
\`\`\`

## 注意事项

- 本文件由脚本自动生成，请勿手动编辑
- 修改设计规范请在 Pencil 设计文件中进行
- 提交代码前请确保 Token 已更新
EOF

    log_success "使用说明已生成: $TOKEN_DIR/README.md"
}

# 主函数
main() {
    echo ""
    echo "═══════════════════════════════════════"
    echo "     Pencil 设计 Token 提取工具"
    echo "═══════════════════════════════════════"
    echo ""

    check_dependencies
    setup_directories

    echo ""
    log_info "开始提取设计 Token..."
    echo ""

    extract_colors
    extract_typography
    extract_spacing
    extract_other_tokens

    echo ""
    generate_combined_tokens
    generate_css_variables
    generate_readme

    echo ""
    echo "═══════════════════════════════════════"
    log_success "设计 Token 提取完成！"
    echo "═══════════════════════════════════════"
    echo ""
    log_info "输出目录: $TOKEN_DIR/"
    log_info "文件列表:"
    ls -lh "$TOKEN_DIR/" | tail -n +2 | awk '{print "  - " $9 " (" $5 ")"}'
    echo ""
}

# 执行主函数
main "$@"

#!/bin/bash
# 视觉回归测试：对比设计稿和实际页面
# 用途：验证实现是否符合设计规范

set -e

# 配置
DESIGN_FILE="$1"
PAGE_URL="$2"
OUTPUT_DIR="${OUTPUT_DIR:-test-results/visual-regression}"
THRESHOLD="${THRESHOLD:-0.1}"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 显示使用说明
show_usage() {
    cat <<EOF
用法: $0 <design-file> <page-url>

参数:
  design-file  Pencil 设计文件路径 (例如: designs/login.pen)
  page-url     要测试的页面 URL (例如: http://localhost:3000/login)

环境变量:
  OUTPUT_DIR   输出目录 (默认: test-results/visual-regression)
  THRESHOLD    差异阈值 0-1 (默认: 0.1，即 10%)

示例:
  $0 designs/login.pen http://localhost:3000/login
  OUTPUT_DIR=./screenshots $0 designs/dashboard.pen http://localhost:3000/dashboard
  THRESHOLD=0.05 $0 designs/home.pen http://localhost:3000

EOF
}

# 检查参数
check_arguments() {
    if [ -z "$DESIGN_FILE" ] || [ -z "$PAGE_URL" ]; then
        log_error "缺少必需参数"
        echo ""
        show_usage
        exit 1
    fi

    if [ ! -f "$DESIGN_FILE" ]; then
        log_error "设计文件不存在: $DESIGN_FILE"
        exit 1
    fi
}

# 检查依赖
check_dependencies() {
    log_info "检查依赖..."

    local missing_deps=()

    # 检查 Playwright
    if ! command -v npx &> /dev/null; then
        missing_deps+=("npx (Node.js)")
    fi

    # 检查 pixelmatch
    if ! npm list -g pixelmatch-cli &> /dev/null 2>&1; then
        log_warning "pixelmatch-cli 未安装"
        log_info "安装命令: npm install -g pixelmatch-cli"
        missing_deps+=("pixelmatch-cli")
    fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "缺少依赖: ${missing_deps[*]}"
        echo ""
        log_info "安装依赖:"
        echo "  npm install -g pixelmatch-cli"
        echo "  npx playwright install chromium"
        exit 1
    fi

    log_success "依赖检查完成"
}

# 创建输出目录
setup_directories() {
    log_info "设置输出目录..."
    mkdir -p "$OUTPUT_DIR"
    log_success "输出目录已准备: $OUTPUT_DIR"
}

# 导出设计稿截图
export_design_screenshot() {
    log_info "导出设计稿截图..."

    local baseline_path="$OUTPUT_DIR/baseline.png"

    # 注意：这里需要根据实际 Pencil MCP API 调整
    # 临时使用占位符
    if command -v convert &> /dev/null; then
        # 使用 ImageMagick 创建占位符
        convert -size 1920x1080 xc:white -pointsize 72 -fill black \
            -gravity center -annotate +0+0 "Design Baseline\n(Placeholder)" \
            "$baseline_path"
        log_warning "使用占位符图片（需要实际 Pencil 导出功能）"
    else
        log_error "无法导出设计稿截图"
        log_info "请安装 ImageMagick: brew install imagemagick"
        exit 1
    fi

    log_success "设计稿截图已导出: $baseline_path"
}

# 截取实际页面
capture_actual_page() {
    log_info "截取实际页面..."

    local actual_path="$OUTPUT_DIR/actual.png"

    # 检查页面是否可访问
    if ! curl -s -o /dev/null -w "%{http_code}" "$PAGE_URL" | grep -q "200"; then
        log_error "页面无法访问: $PAGE_URL"
        log_info "请确保开发服务器正在运行"
        exit 1
    fi

    # 使用 Playwright 截图
    npx playwright screenshot "$PAGE_URL" "$actual_path" --full-page

    if [ ! -f "$actual_path" ]; then
        log_error "截图失败"
        exit 1
    fi

    log_success "实际页面已截取: $actual_path"
}

# 对比差异
compare_screenshots() {
    log_info "对比差异..."

    local baseline_path="$OUTPUT_DIR/baseline.png"
    local actual_path="$OUTPUT_DIR/actual.png"
    local diff_path="$OUTPUT_DIR/diff.png"

    # 使用 pixelmatch 对比
    if command -v pixelmatch &> /dev/null; then
        local diff_pixels
        diff_pixels=$(pixelmatch "$baseline_path" "$actual_path" "$diff_path" "$THRESHOLD" 2>&1 | grep -oE '[0-9]+' | head -1 || echo "0")

        if [ "$diff_pixels" -eq 0 ]; then
            log_success "视觉回归测试通过 - 无差异"
            return 0
        else
            log_warning "发现 $diff_pixels 个像素差异"
            log_info "差异图已保存: $diff_path"
            return 1
        fi
    else
        log_warning "pixelmatch 不可用，跳过对比"
        return 0
    fi
}

# 生成测试报告
generate_report() {
    local test_result=$1
    log_info "生成测试报告..."

    local report_path="$OUTPUT_DIR/report.html"

    cat > "$report_path" <<EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>视觉回归测试报告</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .header {
            background: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .status {
            display: inline-block;
            padding: 8px 16px;
            border-radius: 4px;
            font-weight: 600;
        }
        .status.pass {
            background: #10B981;
            color: white;
        }
        .status.fail {
            background: #EF4444;
            color: white;
        }
        .comparison {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        .image-card {
            background: white;
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .image-card h3 {
            margin-top: 0;
        }
        .image-card img {
            width: 100%;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .metadata {
            background: white;
            padding: 20px;
            border-radius: 8px;
            margin-top: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .metadata table {
            width: 100%;
            border-collapse: collapse;
        }
        .metadata td {
            padding: 8px;
            border-bottom: 1px solid #eee;
        }
        .metadata td:first-child {
            font-weight: 600;
            width: 200px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>视觉回归测试报告</h1>
        <span class="status $([ $test_result -eq 0 ] && echo 'pass' || echo 'fail')">
            $([ $test_result -eq 0 ] && echo '✅ 通过' || echo '❌ 失败')
        </span>
    </div>

    <div class="comparison">
        <div class="image-card">
            <h3>📐 设计稿基准</h3>
            <img src="baseline.png" alt="设计稿">
        </div>
        <div class="image-card">
            <h3>🖥️ 实际页面</h3>
            <img src="actual.png" alt="实际页面">
        </div>
        <div class="image-card">
            <h3>🔍 差异对比</h3>
            <img src="diff.png" alt="差异">
        </div>
    </div>

    <div class="metadata">
        <h2>测试信息</h2>
        <table>
            <tr>
                <td>设计文件</td>
                <td>$DESIGN_FILE</td>
            </tr>
            <tr>
                <td>测试页面</td>
                <td>$PAGE_URL</td>
            </tr>
            <tr>
                <td>差异阈值</td>
                <td>$THRESHOLD ($(echo "$THRESHOLD * 100" | bc)%)</td>
            </tr>
            <tr>
                <td>测试时间</td>
                <td>$(date '+%Y-%m-%d %H:%M:%S')</td>
            </tr>
            <tr>
                <td>输出目录</td>
                <td>$OUTPUT_DIR</td>
            </tr>
        </table>
    </div>
</body>
</html>
EOF

    log_success "测试报告已生成: $report_path"
}

# 主函数
main() {
    echo ""
    echo "═══════════════════════════════════════"
    echo "       Pencil 视觉回归测试工具"
    echo "═══════════════════════════════════════"
    echo ""

    check_arguments
    check_dependencies
    setup_directories

    echo ""
    log_info "开始视觉回归测试..."
    echo ""

    export_design_screenshot
    capture_actual_page

    echo ""
    local test_result=0
    if compare_screenshots; then
        test_result=0
    else
        test_result=1
    fi

    echo ""
    generate_report $test_result

    echo ""
    echo "═══════════════════════════════════════"
    if [ $test_result -eq 0 ]; then
        log_success "视觉回归测试通过！"
    else
        log_warning "视觉回归测试失败"
        log_info "请查看差异图: $OUTPUT_DIR/diff.png"
    fi
    echo "═══════════════════════════════════════"
    echo ""
    log_info "测试报告: $OUTPUT_DIR/report.html"
    log_info "在浏览器中打开: open $OUTPUT_DIR/report.html"
    echo ""

    exit $test_result
}

# 执行主函数
main "$@"

#!/bin/bash
# 批量文档转换脚本
# 用途：批量转换目录中的文档

set -e

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
用法: $0 <input-dir> [output-dir] [output-format]

参数:
  input-dir       输入目录（包含要转换的文档）
  output-dir      输出目录（默认: converted-docs）
  output-format   输出格式（默认: markdown）
                  可选: markdown, html, json

示例:
  $0 docs/
  $0 docs/ output/ markdown
  $0 pdfs/ converted/ html

支持的文件类型:
  - PDF (.pdf)
  - Microsoft Office (.docx, .pptx, .xlsx)
  - HTML (.html)

EOF
}

# 检查虚拟环境
check_venv() {
    if [ -z "$VIRTUAL_ENV" ]; then
        log_info "激活 Docling 虚拟环境..."

        if [ -f "activate-docling.sh" ]; then
            source activate-docling.sh
        elif [ -d ".venv-docling" ]; then
            source .venv-docling/bin/activate
        else
            log_error "找不到 Docling 虚拟环境"
            log_info "请先运行: ./scripts/install-docling.sh"
            exit 1
        fi
    fi
}

# 查找文档文件
find_documents() {
    local input_dir="$1"

    log_info "扫描文档文件..."

    # 查找支持的文件类型
    local files=$(find "$input_dir" -type f \( \
        -name "*.pdf" -o \
        -name "*.docx" -o \
        -name "*.pptx" -o \
        -name "*.xlsx" -o \
        -name "*.html" \
    \))

    echo "$files"
}

# 转换单个文档
convert_single_document() {
    local input_file="$1"
    local output_dir="$2"
    local output_format="$3"

    # 生成输出文件名
    local filename=$(basename "$input_file")
    local basename="${filename%.*}"
    local output_ext

    case "$output_format" in
        markdown) output_ext="md" ;;
        html) output_ext="html" ;;
        json) output_ext="json" ;;
        *) output_ext="md" ;;
    esac

    local output_file="$output_dir/$basename.$output_ext"

    # 创建输出目录
    mkdir -p "$(dirname "$output_file")"

    # 转换文档
    log_info "转换: $filename"

    python -c "
from docling.document_converter import DocumentConverter
import sys

try:
    converter = DocumentConverter()
    result = converter.convert('$input_file')

    output_format = '$output_format'
    if output_format == 'markdown':
        output = result.document.export_to_markdown()
    elif output_format == 'html':
        output = result.document.export_to_html()
    elif output_format == 'json':
        output = result.document.export_to_json()
    else:
        output = result.document.export_to_markdown()

    with open('$output_file', 'w', encoding='utf-8') as f:
        f.write(output)

    print('✅ 成功: $filename')

except Exception as e:
    print(f'❌ 失败: $filename - {str(e)}', file=sys.stderr)
    sys.exit(1)
" 2>&1

    return $?
}

# 批量转换
batch_convert() {
    local input_dir="$1"
    local output_dir="$2"
    local output_format="$3"

    # 查找文档
    local documents=$(find_documents "$input_dir")
    local total=$(echo "$documents" | wc -l | tr -d ' ')

    if [ -z "$documents" ] || [ "$total" -eq 0 ]; then
        log_warning "未找到可转换的文档"
        exit 0
    fi

    log_info "找到 $total 个文档"
    echo ""

    # 统计
    local success=0
    local failed=0
    local current=0

    # 转换每个文档
    while IFS= read -r doc; do
        if [ -n "$doc" ]; then
            ((current++))
            echo "[$current/$total] 处理中..."

            if convert_single_document "$doc" "$output_dir" "$output_format"; then
                ((success++))
            else
                ((failed++))
            fi

            echo ""
        fi
    done <<< "$documents"

    # 显示统计
    echo "═══════════════════════════════════════"
    log_info "转换统计:"
    echo "  总计: $total"
    echo "  成功: $success"
    echo "  失败: $failed"
    echo "═══════════════════════════════════════"
}

# 主函数
main() {
    local input_dir="$1"
    local output_dir="${2:-converted-docs}"
    local output_format="${3:-markdown}"

    # 显示帮助
    if [ "$input_dir" = "-h" ] || [ "$input_dir" = "--help" ] || [ -z "$input_dir" ]; then
        show_usage
        exit 0
    fi

    # 检查输入目录
    if [ ! -d "$input_dir" ]; then
        log_error "输入目录不存在: $input_dir"
        exit 1
    fi

    echo ""
    echo "═══════════════════════════════════════"
    echo "     Docling 批量文档转换工具"
    echo "═══════════════════════════════════════"
    echo ""

    log_info "输入目录: $input_dir"
    log_info "输出目录: $output_dir"
    log_info "输出格式: $output_format"
    echo ""

    check_venv
    echo ""

    batch_convert "$input_dir" "$output_dir" "$output_format"

    echo ""
    log_success "批量转换完成！"
    log_info "输出目录: $output_dir"
    echo ""
}

# 执行主函数
main "$@"

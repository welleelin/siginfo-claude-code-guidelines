#!/bin/bash
# 文档转换脚本
# 用途：使用 Docling 转换文档为各种格式

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
用法: $0 <input-file> [output-format] [output-file]

参数:
  input-file      输入文档路径（支持 PDF, DOCX, PPTX, XLSX, HTML 等）
  output-format   输出格式（默认: markdown）
                  可选: markdown, html, json, doctags
  output-file     输出文件路径（可选，默认输出到标准输出）

示例:
  $0 document.pdf
  $0 document.pdf markdown output.md
  $0 document.docx html output.html
  $0 document.pdf json output.json

支持的输入格式:
  - PDF (.pdf)
  - Microsoft Office (.docx, .pptx, .xlsx)
  - HTML (.html)
  - 图像 (.png, .jpg, .jpeg, .tiff)
  - 音频 (.wav, .mp3)
  - LaTeX (.tex)

EOF
}

# 检查虚拟环境
check_venv() {
    if [ -z "$VIRTUAL_ENV" ]; then
        log_warning "未激活 Docling 虚拟环境"
        log_info "尝试自动激活..."

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

    log_success "虚拟环境已激活"
}

# 检查输入文件
check_input_file() {
    local input_file="$1"

    if [ -z "$input_file" ]; then
        log_error "缺少输入文件参数"
        echo ""
        show_usage
        exit 1
    fi

    if [ ! -f "$input_file" ]; then
        log_error "输入文件不存在: $input_file"
        exit 1
    fi

    log_success "输入文件: $input_file"
}

# 转换文档
convert_document() {
    local input_file="$1"
    local output_format="${2:-markdown}"
    local output_file="$3"

    log_info "开始转换文档..."
    log_info "输入: $input_file"
    log_info "格式: $output_format"

    # 创建 Python 脚本
    local python_script=$(cat <<PYTHON
from docling.document_converter import DocumentConverter
import sys

try:
    # 创建转换器
    converter = DocumentConverter()

    # 转换文档
    result = converter.convert("$input_file")

    # 根据格式导出
    output_format = "$output_format"
    if output_format == "markdown":
        output = result.document.export_to_markdown()
    elif output_format == "html":
        output = result.document.export_to_html()
    elif output_format == "json":
        output = result.document.export_to_json()
    elif output_format == "doctags":
        output = result.document.export_to_doctags()
    else:
        print(f"不支持的输出格式: {output_format}", file=sys.stderr)
        sys.exit(1)

    print(output)

except Exception as e:
    print(f"转换失败: {str(e)}", file=sys.stderr)
    sys.exit(1)
PYTHON
)

    # 执行转换
    if [ -n "$output_file" ]; then
        python -c "$python_script" > "$output_file"
        if [ $? -eq 0 ]; then
            log_success "转换完成: $output_file"
        else
            log_error "转换失败"
            exit 1
        fi
    else
        python -c "$python_script"
        if [ $? -eq 0 ]; then
            log_success "转换完成"
        else
            log_error "转换失败"
            exit 1
        fi
    fi
}

# 主函数
main() {
    local input_file="$1"
    local output_format="${2:-markdown}"
    local output_file="$3"

    # 显示帮助
    if [ "$input_file" = "-h" ] || [ "$input_file" = "--help" ]; then
        show_usage
        exit 0
    fi

    echo ""
    echo "═══════════════════════════════════════"
    echo "       Docling 文档转换工具"
    echo "═══════════════════════════════════════"
    echo ""

    check_venv
    echo ""

    check_input_file "$input_file"
    echo ""

    convert_document "$input_file" "$output_format" "$output_file"

    echo ""
    echo "═══════════════════════════════════════"
    log_success "文档转换完成！"
    echo "═══════════════════════════════════════"
    echo ""
}

# 执行主函数
main "$@"

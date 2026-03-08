#!/bin/bash
# 验证设计文件完整性
# 用途：检查设计文件是否存在、格式是否正确

set -e

# 配置
DESIGN_DIR="${DESIGN_DIR:-designs}"

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

# 检查设计目录
check_design_directory() {
    log_info "检查设计目录..."

    if [ ! -d "$DESIGN_DIR" ]; then
        log_error "设计目录不存在: $DESIGN_DIR"
        log_info "创建目录: mkdir -p $DESIGN_DIR"
        exit 1
    fi

    log_success "设计目录存在: $DESIGN_DIR"
}

# 检查必需文件
check_required_files() {
    log_info "检查必需文件..."

    local required_files=(
        "design-system.pen"
    )

    local missing_files=()

    for file in "${required_files[@]}"; do
        local file_path="$DESIGN_DIR/$file"
        if [ ! -f "$file_path" ]; then
            missing_files+=("$file")
            log_warning "缺失文件: $file"
        else
            log_success "找到文件: $file"
        fi
    done

    if [ ${#missing_files[@]} -gt 0 ]; then
        log_error "缺失 ${#missing_files[@]} 个必需文件"
        echo ""
        log_info "缺失文件列表:"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        echo ""
        log_info "请在 $DESIGN_DIR 目录中创建这些文件"
        return 1
    fi

    log_success "所有必需文件都存在"
    return 0
}

# 验证文件格式
validate_file_format() {
    local file_path="$1"
    local file_name=$(basename "$file_path")

    log_info "验证文件格式: $file_name"

    # 检查文件大小
    local file_size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null)
    if [ "$file_size" -eq 0 ]; then
        log_error "文件为空: $file_name"
        return 1
    fi

    # 检查文件扩展名
    if [[ ! "$file_name" =~ \.(pen|fig)$ ]]; then
        log_warning "文件扩展名不是 .pen 或 .fig: $file_name"
    fi

    # 尝试读取文件（基础验证）
    if ! head -c 100 "$file_path" &> /dev/null; then
        log_error "文件无法读取: $file_name"
        return 1
    fi

    log_success "文件格式有效: $file_name"
    return 0
}

# 验证所有设计文件
validate_all_files() {
    log_info "验证所有设计文件..."

    local total_files=0
    local valid_files=0
    local invalid_files=()

    # 查找所有 .pen 和 .fig 文件
    while IFS= read -r -d '' file; do
        ((total_files++))
        if validate_file_format "$file"; then
            ((valid_files++))
        else
            invalid_files+=("$(basename "$file")")
        fi
    done < <(find "$DESIGN_DIR" -type f \( -name "*.pen" -o -name "*.fig" \) -print0)

    echo ""
    log_info "验证统计:"
    echo "  总文件数: $total_files"
    echo "  有效文件: $valid_files"
    echo "  无效文件: ${#invalid_files[@]}"

    if [ ${#invalid_files[@]} -gt 0 ]; then
        echo ""
        log_error "以下文件验证失败:"
        for file in "${invalid_files[@]}"; do
            echo "  - $file"
        done
        return 1
    fi

    log_success "所有文件验证通过"
    return 0
}

# 检查设计文件元数据
check_metadata() {
    log_info "检查设计文件元数据..."

    local metadata_file="$DESIGN_DIR/.metadata.json"

    if [ ! -f "$metadata_file" ]; then
        log_warning "元数据文件不存在: $metadata_file"
        log_info "创建元数据文件..."

        cat > "$metadata_file" <<EOF
{
  "version": "1.0.0",
  "lastUpdated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "files": []
}
EOF
        log_success "元数据文件已创建"
    else
        log_success "元数据文件存在"
    fi
}

# 生成验证报告
generate_report() {
    local validation_result=$1
    log_info "生成验证报告..."

    local report_file="$DESIGN_DIR/.validation-report.txt"

    cat > "$report_file" <<EOF
═══════════════════════════════════════
    Pencil 设计文件验证报告
═══════════════════════════════════════

验证时间: $(date '+%Y-%m-%d %H:%M:%S')
设计目录: $DESIGN_DIR

验证结果: $([ $validation_result -eq 0 ] && echo '✅ 通过' || echo '❌ 失败')

文件列表:
$(find "$DESIGN_DIR" -type f \( -name "*.pen" -o -name "*.fig" \) -exec ls -lh {} \; | awk '{print "  " $9 " (" $5 ")"}')

═══════════════════════════════════════
EOF

    log_success "验证报告已生成: $report_file"
}

# 主函数
main() {
    echo ""
    echo "═══════════════════════════════════════"
    echo "     Pencil 设计文件验证工具"
    echo "═══════════════════════════════════════"
    echo ""

    local validation_result=0

    check_design_directory

    echo ""
    if ! check_required_files; then
        validation_result=1
    fi

    echo ""
    if ! validate_all_files; then
        validation_result=1
    fi

    echo ""
    check_metadata

    echo ""
    generate_report $validation_result

    echo ""
    echo "═══════════════════════════════════════"
    if [ $validation_result -eq 0 ]; then
        log_success "所有设计文件验证通过！"
    else
        log_error "设计文件验证失败"
        log_info "请修复上述问题后重新验证"
    fi
    echo "═══════════════════════════════════════"
    echo ""

    exit $validation_result
}

# 执行主函数
main "$@"

#!/bin/bash

# scan-mock-interfaces.sh
# 扫描 Mock 接口标记脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 默认扫描目录
SCAN_DIR="${1:-.}"

log_info "扫描 Mock 接口标记..."
echo "═══════════════════════════════════════"
echo "  Mock 接口清单"
echo "  扫描目录：${SCAN_DIR}"
echo "═══════════════════════════════════════"
echo ""

# 查找已标记的 Mock
log_info "已标记的 Mock："
MARKED_COUNT=0

# 查找包含 "⚠️ MOCK:" 标记的文件
while IFS= read -r file; do
    if [ -f "$file" ]; then
        while IFS= read -r line; do
            # 提取接口路径
            if echo "$line" | grep -q "⚠️ MOCK:"; then
                INTERFACE=$(echo "$line" | grep -oE '/(api|v1|v2)/[^ ]*' | head -1)
                REASON=$(echo "$line" | sed 's/.*⚠️ MOCK: //' | sed 's/,.*//')

                if [ -n "$INTERFACE" ]; then
                    log_success "${INTERFACE} - ${REASON}"
                    ((MARKED_COUNT++))
                fi
            fi
        done < "$file"
    fi
done < <(find "$SCAN_DIR" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) 2>/dev/null)

echo ""

# 查找可能未标记的 Mock（启发式检测）
log_info "可能未标记的 Mock："
UNMARKED_COUNT=0

# 检测模式：
# 1. MSW handlers (rest.get, rest.post, etc.)
# 2. jest.mock()
# 3. nock()
# 4. fetch mock

while IFS= read -r file; do
    if [ -f "$file" ]; then
        # 检查是否包含 Mock 代码但没有标记
        if grep -qE "(rest\.(get|post|put|delete|patch)|jest\.mock|nock\(|fetchMock)" "$file"; then
            # 检查是否有标记
            if ! grep -q "⚠️ MOCK:" "$file"; then
                # 提取可能的接口路径
                INTERFACES=$(grep -oE "['\"](/api/[^'\"]+)['\"]" "$file" | sed "s/['\"]//g" | sort -u)

                if [ -n "$INTERFACES" ]; then
                    while IFS= read -r interface; do
                        log_warning "${interface} - 未找到标记 (${file})"
                        ((UNMARKED_COUNT++))
                    done <<< "$INTERFACES"
                fi
            fi
        fi
    fi
done < <(find "$SCAN_DIR" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) 2>/dev/null)

echo ""
echo "═══════════════════════════════════════"
echo "  统计"
echo "═══════════════════════════════════════"
echo "已标记：${MARKED_COUNT} 个"
echo "可能未标记：${UNMARKED_COUNT} 个"

if [ $UNMARKED_COUNT -gt 0 ]; then
    MARK_RATE=$((MARKED_COUNT * 100 / (MARKED_COUNT + UNMARKED_COUNT)))
else
    MARK_RATE=100
fi

echo "标记率：${MARK_RATE}%"
echo ""

# 建议
if [ $UNMARKED_COUNT -gt 0 ]; then
    log_warning "建议："
    echo "  1. 为未标记的 Mock 接口添加标记"
    echo "  2. 标记格式：// ⚠️ MOCK: <原因>，预计 <时间> 替换"
    echo "  3. 示例：// ⚠️ MOCK: 认证 API 未开发，预计 2026-03-10 替换"
    echo ""
fi

# 返回状态码
if [ $UNMARKED_COUNT -gt 0 ]; then
    exit 1
else
    log_success "所有 Mock 接口已标记"
    exit 0
fi

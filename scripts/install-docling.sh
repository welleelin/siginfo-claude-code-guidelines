#!/bin/bash
# Docling 安装脚本
# 用途：在虚拟环境中安装 Docling 及其依赖

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

# 检查 Python 版本
check_python_version() {
    log_info "检查 Python 版本..."

    if ! command -v python3 &> /dev/null; then
        log_error "Python 3 未安装"
        exit 1
    fi

    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
    PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

    if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 10 ]); then
        log_error "Docling 需要 Python 3.10+，当前版本：$PYTHON_VERSION"
        exit 1
    fi

    log_success "Python 版本：$PYTHON_VERSION"
}

# 创建虚拟环境
create_venv() {
    log_info "创建虚拟环境..."

    VENV_DIR=".venv-docling"

    if [ -d "$VENV_DIR" ]; then
        log_warning "虚拟环境已存在：$VENV_DIR"
        read -p "是否删除并重新创建？(y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$VENV_DIR"
        else
            log_info "使用现有虚拟环境"
            return
        fi
    fi

    python3 -m venv "$VENV_DIR"
    log_success "虚拟环境已创建：$VENV_DIR"
}

# 激活虚拟环境
activate_venv() {
    log_info "激活虚拟环境..."

    VENV_DIR=".venv-docling"
    source "$VENV_DIR/bin/activate"

    log_success "虚拟环境已激活"
}

# 安装 Docling
install_docling() {
    log_info "安装 Docling..."

    pip install --upgrade pip
    pip install docling

    log_success "Docling 安装完成"
}

# 验证安装
verify_installation() {
    log_info "验证安装..."

    python -c "from docling.document_converter import DocumentConverter; print('Docling 安装成功')"

    if [ $? -eq 0 ]; then
        log_success "Docling 验证通过"
    else
        log_error "Docling 验证失败"
        exit 1
    fi
}

# 创建激活脚本
create_activation_script() {
    log_info "创建激活脚本..."

    cat > activate-docling.sh << 'EOF'
#!/bin/bash
# 激活 Docling 虚拟环境

VENV_DIR=".venv-docling"

if [ ! -d "$VENV_DIR" ]; then
    echo "❌ 虚拟环境不存在，请先运行 ./scripts/install-docling.sh"
    exit 1
fi

source "$VENV_DIR/bin/activate"
echo "✅ Docling 虚拟环境已激活"
echo "💡 使用 'deactivate' 退出虚拟环境"
EOF

    chmod +x activate-docling.sh
    log_success "激活脚本已创建：activate-docling.sh"
}

# 生成使用说明
generate_usage_guide() {
    log_info "生成使用说明..."

    cat > DOCLING_SETUP.md << 'EOF'
# Docling 安装和使用说明

## 安装

```bash
# 运行安装脚本
./scripts/install-docling.sh
```

## 激活虚拟环境

```bash
# 方式 1：使用激活脚本
source activate-docling.sh

# 方式 2：手动激活
source .venv-docling/bin/activate
```

## 验证安装

```bash
python -c "from docling.document_converter import DocumentConverter; print('OK')"
```

## 基本使用

```python
from docling.document_converter import DocumentConverter

# 创建转换器
converter = DocumentConverter()

# 转换文档
result = converter.convert("document.pdf")

# 导出为 Markdown
markdown = result.document.export_to_markdown()
print(markdown)
```

## 退出虚拟环境

```bash
deactivate
```

## 卸载

```bash
# 删除虚拟环境
rm -rf .venv-docling activate-docling.sh
```
EOF

    log_success "使用说明已生成：DOCLING_SETUP.md"
}

# 主函数
main() {
    echo ""
    echo "═══════════════════════════════════════"
    echo "       Docling 安装脚本"
    echo "═══════════════════════════════════════"
    echo ""

    check_python_version
    echo ""

    create_venv
    echo ""

    activate_venv
    echo ""

    install_docling
    echo ""

    verify_installation
    echo ""

    # 退出虚拟环境（为了创建激活脚本）
    deactivate

    create_activation_script
    echo ""

    generate_usage_guide
    echo ""

    echo "═══════════════════════════════════════"
    log_success "Docling 安装完成！"
    echo "═══════════════════════════════════════"
    echo ""
    log_info "下一步："
    echo "  1. 激活虚拟环境: source activate-docling.sh"
    echo "  2. 查看使用说明: cat DOCLING_SETUP.md"
    echo "  3. 运行测试: ./scripts/test-docling.sh"
    echo ""
}

# 执行主函数
main "$@"

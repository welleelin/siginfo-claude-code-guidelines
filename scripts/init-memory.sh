#!/bin/bash

# init-memory.sh - 长期记忆系统初始化脚本
# 用于在新项目中快速搭建记忆系统

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 获取项目根目录
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"

# 获取项目名称
PROJECT_NAME=$(basename "$PROJECT_ROOT")

# 显示使用说明
usage() {
    cat << EOF
用法：$0 [选项]

选项:
  -p, --path <路径>     项目根目录（默认当前目录）
  -n, --name <名称>     项目名称（默认目录名）
  --skip-templates      跳过模板复制
  --skip-git            跳过 Git 配置
  --skip-cron           跳过 Cron 配置
  -h, --help            显示帮助

说明:
  初始化长期记忆系统，包括:
  1. 创建目录结构
  2. 复制模板文件
  3. 配置 Git 忽略
  4. 配置 Cron 定时任务
  5. 创建初始化文件

示例:
  $0                              # 在当前目录初始化
  $0 -p /path/to/project          # 在指定目录初始化
  $0 --skip-cron                  # 不配置 Cron

EOF
}

# 创建目录结构
create_directories() {
    info "创建目录结构..."

    local dirs=(
        "memory"
        "checkpoints"
        ".memory-archive"
    )

    for dir in "${dirs[@]}"; do
        if [ ! -d "${PROJECT_ROOT}/${dir}" ]; then
            mkdir -p "${PROJECT_ROOT}/${dir}"
            success "创建目录：${dir}"
        else
            info "目录已存在：${dir}"
        fi
    done
}

# 复制模板文件
copy_templates() {
    info "复制模板文件..."

    # 获取脚本所在目录
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local templates_dir="${script_dir}/../templates"

    # 检查模板目录是否存在
    if [ ! -d "$templates_dir" ]; then
        # 尝试从 sig-claude-code-guidelines 项目复制
        local guidelines_dir="${HOME}/Documents/projects/Claude/sig-claude-code-guidelines/templates"
        if [ -d "$guidelines_dir" ]; then
            templates_dir="$guidelines_dir"
        else
            warning "未找到模板目录，跳过模板复制"
            return 0
        fi
    fi

    # 复制模板文件
    local templates=(
        "MEMORY.md.template:MEMORY.md"
        "AGENTS.md.template:AGENTS.md"
        "HEARTBEAT.md.template:HEARTBEAT.md"
        "memory-template.md:memory/template.md"
    )

    for template in "${templates[@]}"; do
        local src="${template%%:*}"
        local dst="${template##*:}"

        if [ -f "${templates_dir}/${src}" ]; then
            # 替换项目名称
            sed "s/{PROJECT_NAME}/${PROJECT_NAME}/g" "${templates_dir}/${src}" > "${PROJECT_ROOT}/${dst}"
            # 替换时间戳
            sed -i'' "s/{TIMESTAMP}/$(date -Iseconds)/g" "${PROJECT_ROOT}/${dst}" 2>/dev/null || \
            sed -i "s/{TIMESTAMP}/$(date -Iseconds)/g" "${PROJECT_ROOT}/${dst}"
            success "创建文件：${dst}"
        else
            warning "模板文件不存在：${src}"
        fi
    done
}

# 创建今日日志
create_daily_log() {
    local today=$(date +%Y-%m-%d)
    local daily_file="${PROJECT_ROOT}/memory/${today}.md"

    if [ ! -f "$daily_file" ]; then
        info "创建今日日志..."
        cat > "$daily_file" << EOF
# 记忆日志 - ${today}

> 创建时间：$(date -Iseconds)
> 状态：active

---

## 📋 今日任务

| 任务 ID | 任务标题 | 状态 | 进度 | 备注 |
|--------|---------|------|------|------|
| - | - | pending | 0% | - |

---

## 🕐 Hourly 层 - 实时记录

> 每小时同步一次，记录当前会话的技术决策和实时问题。

### 待更新

---

## 💡 技术决策

> 待更新

---

## 🐛 问题解决

> 待更新

---

## 📝 临时笔记

> 待更新

---

## ✅ 今日完成

- [ ] 待更新

---

## 🔄 待办事项

- [ ] 待更新

---

## 📊 会话摘要

| 会话 ID | 开始时间 | 结束时间 | 主要活动 | 关键产出 |
|--------|---------|---------|---------|---------|
| - | - | - | - | - |

---

## 🌟 今日亮点

> 待更新

---

## 🔗 相关文件

- 修改文件：-
- 新增文件：-
- 删除文件：-

---

> **日终归档提醒**：
> - [ ] 检查所有任务状态是否已更新
> - [ ] 确认关键决策已记录
> - [ ] 清理临时笔记
> - [ ] 准备明日待办
> - [ ] 23:00 执行 \`../scripts/archive-daily.sh\` 归档

EOF
        success "创建今日日志：memory/${today}.md"
    else
        info "今日日志已存在"
    fi
}

# 配置 Git 忽略
configure_gitignore() {
    info "配置 Git 忽略..."

    local gitignore="${PROJECT_ROOT}/.gitignore"
    local entries=(
        "# Memory System"
        ".heartbeat-status.json"
        "checkpoints/*.json"
        "memory/.archive/"
        "*.local"
        ""
        "# Sensitive"
        ".env"
        ".env.local"
        "*.key"
        "*.pem"
        ".secrets/"
    )

    # 如果 .gitignore 不存在，创建它
    if [ ! -f "$gitignore" ]; then
        touch "$gitignore"
    fi

    # 添加条目（避免重复）
    for entry in "${entries[@]}"; do
        if ! grep -qF "$entry" "$gitignore" 2>/dev/null; then
            echo "$entry" >> "$gitignore"
        fi
    done

    success "已更新 .gitignore"
}

# 配置 Cron 定时任务
configure_cron() {
    info "配置 Cron 定时任务..."

    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local cron_entries=(
        "0 * * * * ${script_dir}/sync-hourly.sh >> /tmp/memory-hourly.log 2>&1"
        "0 23 * * * ${script_dir}/archive-daily.sh >> /tmp/memory-daily.log 2>&1"
        "0 22 * * 0 ${script_dir}/summarize-weekly.sh >> /tmp/memory-weekly.log 2>&1"
    )

    # 检查 crontab 是否可用
    if ! command -v crontab &> /dev/null; then
        warning "crontab 不可用，跳过 Cron 配置"
        warning "请手动配置定时任务，参考以下配置:"
        for entry in "${cron_entries[@]}"; do
            echo "  $entry"
        done
        return 0
    fi

    # 获取当前 crontab
    local current_crontab=$(crontab -l 2>/dev/null || echo "")

    # 检查是否已配置
    local already_configured=true
    for entry in "${cron_entries[@]}"; do
        if ! echo "$current_crontab" | grep -qF "$entry"; then
            already_configured=false
            break
        fi
    done

    if [ "$already_configured" = true ]; then
        info "Cron 任务已配置"
        return 0
    fi

    # 显示配置提示
    echo ""
    echo "以下 Cron 配置将被添加:"
    for entry in "${cron_entries[@]}"; do
        echo "  $entry"
    done
    echo ""

    # 询问用户确认
    echo "是否添加到 crontab? (y/N)"
    read -r confirm

    if [[ $confirm =~ ^[Yy]$ ]]; then
        # 添加新的 Cron 条目
        {
            echo "$current_crontab"
            printf '%s\n' "${cron_entries[@]}"
        } | crontab -

        success "已配置 Cron 定时任务"
    else
        info "已跳过 Cron 配置"
        warning "请手动添加以下 Cron 条目:"
        for entry in "${cron_entries[@]}"; do
            echo "  $entry"
        done
    fi
}

# 创建心跳状态文件
create_status_file() {
    local status_file="${PROJECT_ROOT}/.heartbeat-status.json"

    if [ ! -f "$status_file" ]; then
        info "创建心跳状态文件..."
        cat > "$status_file" << EOF
{
  "hourly": {
    "lastCheck": "$(date -Iseconds)",
    "status": "initialized"
  },
  "daily": {
    "lastCheck": "never",
    "status": "pending"
  },
  "weekly": {
    "lastCheck": "never",
    "status": "pending"
  }
}
EOF
        success "创建心跳状态文件"
    fi
}

# 显示后续步骤
show_next_steps() {
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "              🎉 初始化完成！                              "
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "项目：${PROJECT_NAME}"
    echo "位置：${PROJECT_ROOT}"
    echo ""
    echo "📁 已创建的文件和目录:"
    echo "  - memory/           (每日日志)"
    echo "  - checkpoints/      (状态检查点)"
    echo "  - .memory-archive/  (归档日志)"
    echo "  - MEMORY.md         (长期记忆)"
    echo "  - AGENTS.md         (行为规范)"
    echo "  - HEARTBEAT.md      (检查任务)"
    echo "  - memory/$(date +%Y-%m-%d).md  (今日日志)"
    echo ""
    echo "🔧 可用命令:"
    echo "  ./scripts/checkpoint.sh start <task_id>    # 开始任务"
    echo "  ./scripts/save-state.sh <原因>             # 保存状态"
    echo "  ./scripts/restore-state.sh <id>            # 恢复状态"
    echo "  ./scripts/sync-hourly.sh                   # 小时同步"
    echo "  ./scripts/archive-daily.sh                 # 日终归档"
    echo "  ./scripts/summarize-weekly.sh              # 周度总结"
    echo ""
    echo "📋 下一步:"
    echo "  1. 编辑 MEMORY.md 填写项目信息"
    echo "  2. 编辑 AGENTS.md 配置行为规范"
    echo "  3. 编辑 HEARTBEAT.md 配置定期检查"
    echo "  4. 运行 ./scripts/checkpoint.sh start <task_id> 开始任务"
    echo ""
    echo "═══════════════════════════════════════════════════════════"
}

# 主函数
main() {
    local skip_templates=false
    local skip_git=false
    local skip_cron=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--path)
                PROJECT_ROOT="$2"
                shift 2
                ;;
            -n|--name)
                PROJECT_NAME="$2"
                shift 2
                ;;
            --skip-templates)
                skip_templates=true
                shift
                ;;
            --skip-git)
                skip_git=true
                shift
                ;;
            --skip-cron)
                skip_cron=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                error "未知选项：$1"
                usage
                exit 1
                ;;
        esac
    done

    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "         长期记忆系统初始化                                "
    echo "═══════════════════════════════════════════════════════════"
    echo ""

    create_directories

    if [ "$skip_templates" = false ]; then
        copy_templates
        create_daily_log
        create_status_file
    fi

    if [ "$skip_git" = false ]; then
        configure_gitignore
    fi

    if [ "$skip_cron" = false ]; then
        configure_cron
    fi

    show_next_steps
}

main "$@"

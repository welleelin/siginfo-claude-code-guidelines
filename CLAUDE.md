# sig-claude-code-guidelines

> 一套经过实战验证的 AI 辅助软件开发规范，让团队开发像流水线一样高效

**仓库地址**:
- GitHub: `https://github.com/your-org/sig-claude-code-guidelines`
- 本地 Git: `/Users/cloud/Documents/projects/Claude/sig-claude-code-guidelines`

---

## 📦 安装方式

### 方式一：作为子项目使用（推荐）

```bash
# 在你的项目中添加为 submodule
cd your-project
git submodule add https://github.com/your-org/sig-claude-code-guidelines.git .guidelines

# 复制模板到项目根目录
cp .guidelines/templates/* ./
```

### 方式二：复制使用

```bash
# 克隆本项目
git clone https://github.com/your-org/sig-claude-code-guidelines.git

# 复制需要的文件
cp -r sig-claude-code-guidelines/guidelines ~/.claude/rules/
cp -r sig-claude-code-guidelines/templates/* your-project/
```

---

## 📋 核心文档

| 文档 | 用途 |
|------|------|
| [README.md](README.md) | 项目总览和快速开始 |
| [guidelines/00-SYSTEM_OVERVIEW.md](guidelines/00-SYSTEM_OVERVIEW.md) | 系统总则 - 核心规范 |
| [docs/API_INTEGRATION.md](docs/API_INTEGRATION.md) | 与 claude-monitor-ui 的 API 接口 |

---

## 🔗 相关项目

- **claude-monitor-ui** - 任务监督与通知平台
  - PM Agent 自动监督
  - 多渠道通知
  - 确认反馈处理

---

*版本：1.0.0*
*最后更新：2026-03-03*

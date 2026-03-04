# /memory-search - 记忆搜索命令

## 功能描述

搜索项目记忆文件，支持语义搜索和关键词匹配。

## 用法

```bash
/memory-search <查询关键词> [选项]
```

## 选项

| 选项 | 说明 |
|------|------|
| `--type <type>` | 搜索类型：semantic（语义）/ keyword（关键词）/ hybrid（混合），默认 hybrid |
| `--file <file>` | 指定搜索文件：MEMORY.md / daily / all |
| `--days <n>` | 搜索最近 n 天的日志 |
| `--limit <n>` | 限制返回结果数量，默认 5 |
| `--tags <tags>` | 按标签过滤 |

## 示例

```bash
# 搜索部署相关问题
/memory-search 部署问题

# 搜索最近 7 天的日志
/memory-search API 错误 --days 7

# 按标签搜索
/memory-search 配置 --tags deployment,error

# 仅搜索长期记忆
/memory-search 用户偏好 --file MEMORY.md

# 语义搜索
/memory-search 如何解决服务器连接问题 --type semantic
```

## 输出格式

```
🔍 搜索结果："部署问题"

[1] memory/2026-03-04.md (得分：0.92)
    ## 问题解决 - 部署时 dist 文件丢失
    - 问题：dist 文件夹未提交导致服务器拉取失败
    - 解决：build 后必须 git add dist/
    - 来源：memory/2026-03-04.md:45

[2] MEMORY.md (得分：0.87)
    ## 经验教训 - 2026-02-13
    - 部署脚本需要检查 dist 是否已提交
    - 来源：MEMORY.md:120

共找到 2 条相关记忆
```

## 相关命令

- `/memory-list` - 列出记忆文件
- `/save-state` - 保存状态
- `/restore-state` - 恢复状态

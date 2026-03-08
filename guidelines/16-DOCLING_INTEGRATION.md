# Docling 集成指南

> **版本**：1.0.0
> **最后更新**：2026-03-08
> **来源**：https://github.com/docling-project/docling

---

## 📋 概述

Docling 是一个由 IBM Research 开发的文档处理工具，专为 AI 应用设计。本项目已集成 Docling，提供强大的文档解析和转换能力。

### 核心价值

| 特性 | 说明 |
|------|------|
| 🗂️ **多格式支持** | PDF, DOCX, PPTX, XLSX, HTML, 音频, 图像等 |
| 📑 **高级 PDF 理解** | 布局分析、表格提取、公式识别、OCR |
| 🧬 **统一表示** | DoclingDocument 格式，保留结构和语义 |
| ↪️ **多种导出** | Markdown, HTML, JSON, DocTags |
| 🔒 **本地执行** | 支持离线运行，适合敏感数据 |
| 🤖 **AI 集成** | LangChain, LlamaIndex, MCP Server |

---

## 🚀 快速开始

### 1. 安装 Docling

```bash
# 运行安装脚本（会创建虚拟环境）
./scripts/install-docling.sh
```

**安装内容**：
- 创建 `.venv-docling` 虚拟环境
- 安装 Docling 及其依赖
- 创建 `activate-docling.sh` 激活脚本
- 生成 `DOCLING_SETUP.md` 使用说明

### 2. 激活虚拟环境

```bash
# 激活 Docling 虚拟环境
source activate-docling.sh
```

### 3. 转换文档

```bash
# 转换 PDF 为 Markdown
./scripts/convert-document.sh document.pdf

# 转换为 HTML
./scripts/convert-document.sh document.pdf html output.html

# 转换为 JSON
./scripts/convert-document.sh document.docx json output.json
```

---

## 📚 使用场景

### 场景 1：处理技术文档

```bash
# 转换 PDF 技术文档为 Markdown
./scripts/convert-document.sh docs/architecture.pdf markdown docs/architecture.md

# 提取内容用于知识库
./scripts/convert-document.sh docs/api-spec.pdf json knowledge-base/api-spec.json
```

### 场景 2：构建 RAG 知识库

```python
from docling.document_converter import DocumentConverter
from langchain.text_splitter import RecursiveCharacterTextSplitter

# 转换文档
converter = DocumentConverter()
result = converter.convert("document.pdf")
markdown = result.document.export_to_markdown()

# 分割文本
splitter = RecursiveCharacterTextSplitter(chunk_size=1000)
chunks = splitter.split_text(markdown)

# 存储到向量数据库
# ...
```

### 场景 3：批量处理文档

```bash
# 批量转换 PDF 文档
for pdf in docs/*.pdf; do
    output="${pdf%.pdf}.md"
    ./scripts/convert-document.sh "$pdf" markdown "$output"
done
```

### 场景 4：提取表格数据

```python
from docling.document_converter import DocumentConverter

converter = DocumentConverter()
result = converter.convert("report.pdf")

# 导出为 JSON，包含表格结构
json_output = result.document.export_to_json()

# 解析表格数据
import json
data = json.loads(json_output)
tables = [item for item in data if item['type'] == 'table']
```

---

## 🔧 高级功能

### 1. 使用 VLM 模式

```bash
# 使用 GraniteDocling 视觉语言模型
docling --pipeline vlm --vlm-model granite_docling document.pdf
```

**优势**：
- 更好的布局理解
- 图表和图像理解
- 复杂文档处理

### 2. OCR 支持

```python
from docling.document_converter import DocumentConverter
from docling.datamodel.pipeline_options import PdfPipelineOptions

# 启用 OCR
pipeline_options = PdfPipelineOptions()
pipeline_options.do_ocr = True

converter = DocumentConverter(pipeline_options=pipeline_options)
result = converter.convert("scanned.pdf")
```

### 3. 自定义导出选项

```python
from docling.document_converter import DocumentConverter
from docling.datamodel.export_options import MarkdownExportOptions

# 自定义 Markdown 导出
export_options = MarkdownExportOptions(
    image_mode="embedded",  # 嵌入图像
    table_mode="markdown"   # 表格使用 Markdown 格式
)

converter = DocumentConverter()
result = converter.convert("document.pdf")
markdown = result.document.export_to_markdown(export_options)
```

### 4. 批量处理优化

```python
from docling.document_converter import DocumentConverter
from concurrent.futures import ThreadPoolExecutor

def convert_document(doc_path):
    converter = DocumentConverter()
    return converter.convert(doc_path)

# 并行处理
documents = ["doc1.pdf", "doc2.pdf", "doc3.pdf"]
with ThreadPoolExecutor(max_workers=4) as executor:
    results = list(executor.map(convert_document, documents))
```

---

## 🔌 集成点

### 1. 与 BMAD Method 集成

在 Phase 2（任务规划）中使用 Docling 处理需求文档：

```bash
# Phase 2: 任务规划
/plan "实现用户管理功能"

# 处理需求文档
./scripts/convert-document.sh requirements.pdf markdown requirements.md

# 提取关键信息用于规划
# ...
```

### 2. 与 Agent 集成

创建文档处理 Agent：

```markdown
# Document Processor Agent

## 能力
- 使用 Docling 解析各种格式文档
- 提取文档结构和内容
- 转换为 AI 友好的格式

## 工具
- Docling DocumentConverter
- 文本分割器
- 向量数据库
```

### 3. 与 MCP Server 集成

配置 Docling MCP Server：

```json
{
  "mcpServers": {
    "docling": {
      "command": "python",
      "args": ["-m", "docling.mcp_server"],
      "env": {
        "DOCLING_CACHE_DIR": ".docling/cache"
      }
    }
  }
}
```

### 4. 与知识库集成

构建项目知识库：

```bash
# 1. 转换所有文档
./scripts/build-knowledge-base.sh

# 2. 向量化
# 3. 存储到向量数据库
# 4. 提供检索接口
```

---

## 📊 支持的格式

### 输入格式

| 类型 | 格式 | 说明 |
|------|------|------|
| **文档** | PDF, DOCX, PPTX, XLSX | Office 文档 |
| **网页** | HTML | 网页内容 |
| **图像** | PNG, JPEG, TIFF | 图像文件（需 OCR） |
| **音频** | WAV, MP3 | 音频转文本 |
| **字幕** | WebVTT | 视频字幕 |
| **代码** | LaTeX | LaTeX 文档 |
| **专业** | USPTO, JATS, XBRL | 专业格式 |

### 输出格式

| 格式 | 说明 | 用途 |
|------|------|------|
| **Markdown** | 通用文本格式 | 文档展示、RAG |
| **HTML** | 网页格式 | 网页展示 |
| **JSON** | 结构化数据 | 数据处理、API |
| **DocTags** | 语义标签 | 深度分析 |

---

## 🛠️ 自动化脚本

### 1. 安装脚本

**文件**：`scripts/install-docling.sh`

**功能**：
- 检查 Python 版本（需要 3.10+）
- 创建虚拟环境
- 安装 Docling
- 验证安装
- 生成使用说明

### 2. 转换脚本

**文件**：`scripts/convert-document.sh`

**功能**：
- 转换单个文档
- 支持多种输出格式
- 自动激活虚拟环境
- 错误处理

**用法**：
```bash
./scripts/convert-document.sh <input> [format] [output]
```

### 3. 批量处理脚本

**文件**：`scripts/batch-convert-documents.sh`（待创建）

**功能**：
- 批量转换目录中的文档
- 并行处理
- 进度显示
- 错误汇总

---

## 🔍 故障排查

### Q1: Python 版本不符合要求

**问题**：Docling 需要 Python 3.10+

**解决方案**：
```bash
# 检查 Python 版本
python3 --version

# 安装 Python 3.10+
brew install python@3.10

# 或使用 pyenv
pyenv install 3.10.0
pyenv local 3.10.0
```

### Q2: 虚拟环境激活失败

**问题**：无法激活虚拟环境

**解决方案**：
```bash
# 手动激活
source .venv-docling/bin/activate

# 或重新安装
rm -rf .venv-docling
./scripts/install-docling.sh
```

### Q3: 转换失败

**问题**：文档转换失败

**解决方案**：
```bash
# 检查文件格式
file document.pdf

# 检查文件大小
ls -lh document.pdf

# 尝试使用 VLM 模式
docling --pipeline vlm document.pdf

# 启用 OCR（扫描 PDF）
# 在 Python 中设置 do_ocr=True
```

### Q4: 内存不足

**问题**：处理大文档时内存不足

**解决方案**：
```bash
# 分页处理
# 减少并行数
# 使用更小的模型
```

---

## 📈 性能优化

### 1. 缓存机制

```python
import hashlib
import pickle
from pathlib import Path

def convert_with_cache(doc_path, cache_dir=".docling/cache"):
    cache_dir = Path(cache_dir)
    cache_dir.mkdir(parents=True, exist_ok=True)

    # 计算文档哈希
    with open(doc_path, 'rb') as f:
        doc_hash = hashlib.md5(f.read()).hexdigest()

    cache_file = cache_dir / f"{doc_hash}.pkl"

    # 检查缓存
    if cache_file.exists():
        with open(cache_file, 'rb') as f:
            return pickle.load(f)

    # 转换并缓存
    converter = DocumentConverter()
    result = converter.convert(doc_path)

    with open(cache_file, 'wb') as f:
        pickle.dump(result, f)

    return result
```

### 2. 并行处理

```python
from concurrent.futures import ThreadPoolExecutor

def batch_convert(documents, max_workers=4):
    converter = DocumentConverter()

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        results = list(executor.map(converter.convert, documents))

    return results
```

### 3. 内存管理

```python
# 处理大文档时释放内存
import gc

result = converter.convert("large_document.pdf")
markdown = result.document.export_to_markdown()

# 释放内存
del result
gc.collect()
```

---

## 🔐 安全考虑

### 1. 敏感数据处理

**本地执行**：
- Docling 支持完全本地运行
- 不需要上传文档到云端
- 适合处理敏感数据

### 2. 文件验证

```python
import os

def safe_convert(doc_path, max_size_mb=100):
    # 检查文件存在
    if not os.path.exists(doc_path):
        raise FileNotFoundError(f"文件不存在: {doc_path}")

    # 检查文件大小
    file_size = os.path.getsize(doc_path) / (1024 * 1024)
    if file_size > max_size_mb:
        raise ValueError(f"文件过大: {file_size:.2f}MB > {max_size_mb}MB")

    # 检查文件类型
    allowed_extensions = ['.pdf', '.docx', '.pptx', '.xlsx']
    if not any(doc_path.endswith(ext) for ext in allowed_extensions):
        raise ValueError(f"不支持的文件类型: {doc_path}")

    # 转换
    converter = DocumentConverter()
    return converter.convert(doc_path)
```

### 3. 输出清理

```python
import re

def sanitize_output(text):
    # 移除敏感信息
    text = re.sub(r'\b\d{3}-\d{2}-\d{4}\b', '[SSN]', text)  # SSN
    text = re.sub(r'\b\d{16}\b', '[CARD]', text)  # 信用卡号
    text = re.sub(r'\b[\w\.-]+@[\w\.-]+\.\w+\b', '[EMAIL]', text)  # 邮箱

    return text
```

---

## 📚 相关文档

- [Docling 官方文档](https://docling-project.github.io/docling/)
- [Docling GitHub](https://github.com/docling-project/docling)
- [Docling 技术报告](https://arxiv.org/abs/2408.09869)
- [Docling 分析报告](DOCLING_ANALYSIS.md)

---

## 🎯 下一步

1. ✅ 安装 Docling
2. ✅ 测试基本转换
3. ⏳ 创建批量处理脚本
4. ⏳ 集成到 RAG 流程
5. ⏳ 配置 MCP Server
6. ⏳ 创建文档处理 Agent

---

*最后更新：2026-03-08*

> **核心理念**：
> 1. 本地执行 - 保护数据隐私
> 2. 高质量输出 - 保留文档结构
> 3. AI 友好 - 无缝集成 AI 生态
> 4. 简单易用 - 开箱即用

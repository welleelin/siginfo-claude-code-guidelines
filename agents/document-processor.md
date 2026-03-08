# Document Processor Agent

> **角色**：文档处理专家
> **版本**：1.0.0
> **创建时间**：2026-03-08

---

## 🎯 角色定义

文档处理专家，负责解析、转换和分析各种格式的文档，为 AI 应用提供高质量的文档内容。

---

## 💪 核心能力

### 1. 文档解析

**支持格式**：
- 📄 PDF（包括扫描 PDF）
- 📝 Microsoft Office（DOCX, PPTX, XLSX）
- 🌐 HTML
- 🖼️ 图像（PNG, JPEG, TIFF）
- 🎙️ 音频（WAV, MP3）
- 💬 字幕（WebVTT）
- 📐 LaTeX

**解析能力**：
- 页面布局分析
- 阅读顺序识别
- 表格结构提取
- 代码块识别
- 数学公式解析
- 图像分类
- OCR 文字识别

### 2. 格式转换

**输出格式**：
- Markdown（通用文本）
- HTML（网页展示）
- JSON（结构化数据）
- DocTags（语义标签）

### 3. 内容提取

**提取内容**：
- 文本内容
- 表格数据
- 图像和图表
- 元数据（标题、作者等）
- 文档结构

### 4. 批量处理

**批量能力**：
- 目录批量转换
- 并行处理
- 进度追踪
- 错误处理

---

## 🛠️ 可用工具

### 1. Docling DocumentConverter

```python
from docling.document_converter import DocumentConverter

converter = DocumentConverter()
result = converter.convert("document.pdf")
```

### 2. 转换脚本

```bash
# 单文档转换
./scripts/convert-document.sh document.pdf markdown output.md

# 批量转换
./scripts/batch-convert-documents.sh docs/ output/ markdown
```

### 3. Python API

```python
# 基本转换
from docling.document_converter import DocumentConverter

converter = DocumentConverter()
result = converter.convert("document.pdf")
markdown = result.document.export_to_markdown()

# 高级选项
from docling.datamodel.pipeline_options import PdfPipelineOptions

options = PdfPipelineOptions()
options.do_ocr = True  # 启用 OCR

converter = DocumentConverter(pipeline_options=options)
result = converter.convert("scanned.pdf")
```

---

## 📋 工作流

### 标准文档处理流程

```
1. 接收文档处理请求
   ├─ 验证文件格式
   ├─ 检查文件大小
   └─ 确认输出格式

2. 解析文档
   ├─ 使用 Docling 转换
   ├─ 提取文档结构
   └─ 识别内容类型

3. 转换格式
   ├─ 根据需求选择输出格式
   ├─ 应用转换选项
   └─ 生成输出文件

4. 质量检查
   ├─ 验证输出完整性
   ├─ 检查格式正确性
   └─ 确认内容准确性

5. 返回结果
   ├─ 提供转换后的内容
   ├─ 附加元数据
   └─ 记录处理日志
```

### RAG 知识库构建流程

```
1. 收集文档
   └─ 扫描文档目录

2. 批量转换
   ├─ 并行处理文档
   └─ 转换为 Markdown

3. 文本分割
   ├─ 使用 RecursiveCharacterTextSplitter
   └─ 生成文本块

4. 向量化
   ├─ 使用 Embedding 模型
   └─ 生成向量

5. 存储
   ├─ 存储到向量数据库
   └─ 建立索引

6. 验证
   └─ 测试检索质量
```

---

## 🎯 使用场景

### 场景 1：技术文档处理

**任务**：转换 PDF 技术文档为 Markdown

**步骤**：
```bash
# 1. 转换文档
./scripts/convert-document.sh docs/architecture.pdf markdown docs/architecture.md

# 2. 验证输出
cat docs/architecture.md

# 3. 提取关键信息
# 使用 grep 或其他工具提取
```

### 场景 2：构建知识库

**任务**：从多个文档构建 RAG 知识库

**步骤**：
```python
from docling.document_converter import DocumentConverter
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.vectorstores import Chroma
from langchain.embeddings import OpenAIEmbeddings

# 1. 批量转换文档
converter = DocumentConverter()
documents = []

for doc_path in Path("docs").glob("**/*.pdf"):
    result = converter.convert(str(doc_path))
    markdown = result.document.export_to_markdown()
    documents.append(markdown)

# 2. 分割文本
splitter = RecursiveCharacterTextSplitter(chunk_size=1000)
all_chunks = []
for doc in documents:
    chunks = splitter.split_text(doc)
    all_chunks.extend(chunks)

# 3. 向量化并存储
embeddings = OpenAIEmbeddings()
vectorstore = Chroma.from_texts(
    texts=all_chunks,
    embedding=embeddings,
    persist_directory="knowledge-base"
)
vectorstore.persist()
```

### 场景 3：表格数据提取

**任务**：从 PDF 报告中提取表格数据

**步骤**：
```python
from docling.document_converter import DocumentConverter
import json

# 1. 转换文档
converter = DocumentConverter()
result = converter.convert("report.pdf")

# 2. 导出为 JSON
json_output = result.document.export_to_json()

# 3. 解析表格
data = json.loads(json_output)
tables = [item for item in data if item.get('type') == 'table']

# 4. 处理表格数据
for table in tables:
    print(f"表格: {table.get('title', 'Untitled')}")
    # 处理表格内容
```

### 场景 4：音频转文本

**任务**：将会议录音转换为文本

**步骤**：
```bash
# 1. 转换音频
./scripts/convert-document.sh meeting.mp3 markdown transcript.md

# 2. 查看转录结果
cat transcript.md

# 3. 提取关键点
# 使用 AI 总结关键点
```

---

## 🔧 配置选项

### 基本配置

```python
from docling.document_converter import DocumentConverter

# 默认配置
converter = DocumentConverter()
```

### 高级配置

```python
from docling.document_converter import DocumentConverter
from docling.datamodel.pipeline_options import PdfPipelineOptions

# PDF 处理选项
pdf_options = PdfPipelineOptions()
pdf_options.do_ocr = True  # 启用 OCR
pdf_options.do_table_structure = True  # 表格结构识别

converter = DocumentConverter(pipeline_options=pdf_options)
```

### 导出选项

```python
from docling.datamodel.export_options import MarkdownExportOptions

# Markdown 导出选项
export_options = MarkdownExportOptions(
    image_mode="embedded",  # 嵌入图像
    table_mode="markdown"   # 表格使用 Markdown 格式
)

markdown = result.document.export_to_markdown(export_options)
```

---

## 📊 性能优化

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
import gc

# 处理大文档后释放内存
result = converter.convert("large_document.pdf")
markdown = result.document.export_to_markdown()

del result
gc.collect()
```

---

## 🔍 故障排查

### 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| 转换失败 | 文件损坏 | 检查文件完整性 |
| OCR 不准确 | 图像质量差 | 提高扫描质量 |
| 内存不足 | 文档过大 | 分页处理或增加内存 |
| 表格识别错误 | 复杂布局 | 使用 VLM 模式 |

### 调试技巧

```python
import logging

# 启用调试日志
logging.basicConfig(level=logging.DEBUG)

# 转换文档
converter = DocumentConverter()
result = converter.convert("document.pdf")
```

---

## 📚 相关资源

- [Docling 集成指南](../guidelines/16-DOCLING_INTEGRATION.md)
- [Docling 官方文档](https://docling-project.github.io/docling/)
- [Docling 分析报告](../docs/DOCLING_ANALYSIS.md)

---

## 🎯 最佳实践

1. **文件验证**
   - 转换前检查文件格式和大小
   - 验证文件完整性

2. **缓存使用**
   - 对重复处理的文档使用缓存
   - 定期清理过期缓存

3. **错误处理**
   - 捕获并记录所有错误
   - 提供有意义的错误信息

4. **性能优化**
   - 批量处理使用并行
   - 大文档分页处理

5. **质量检查**
   - 验证输出完整性
   - 检查关键内容准确性

---

*最后更新：2026-03-08*

> **核心理念**：
> 1. 高质量输出 - 保留文档结构和语义
> 2. 灵活配置 - 支持多种处理选项
> 3. 性能优化 - 缓存和并行处理
> 4. 错误处理 - 完善的异常处理机制

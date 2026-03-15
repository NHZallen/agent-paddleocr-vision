# Agent PaddleOCR Vision

**Turn documents into actionable instructions for your AI agent.** Powered by PaddleOCR cloud API with automatic document classification and action suggestion.

> 🌐 多語言文件：[中文](docs/README.zh.md) · [English](docs/README.en.md) · [Español](docs/README.es.md) · [العربية](docs/README.ar.md)

## ✨ Features

- 11 document types (invoice, business card, receipt, table, contract, ID card, passport, bank statement, driver's license, tax form, general)
- Batch processing
- Searchable PDF generation
- Agent-friendly JSON output with `agent_prompt`

## Quick Start

```bash
pip3 install -r scripts/requirements.txt
export PADDLEOCR_DOC_PARSING_API_URL=...
export PADDLEOCR_ACCESS_TOKEN=...
python3 scripts/doc_vision.py --file-path ./doc.jpg --pretty
```

See detailed documentation in your preferred language under `docs/`.

---

**Made for OpenClaw.** Let your agent see and act.

# Agent Vision — OCR with Agent Actions

**Turn documents into actionable instructions for your AI agent.** Automatically detect document type and provide tailored prompts and suggested actions.

## ✨ Features

- ✅ **Multiple OCR backends**: PaddleOCR cloud (high accuracy) or Tesseract offline (free)
- ✅ **11 document types**: invoice, business card, receipt, table, contract, ID card, passport, bank statement, driver's license, tax form, general
- ✅ **Action suggestion engine**: extracts key fields + produces ready-to-use instructions
- ✅ **Batch processing**: process entire directories
- ✅ **Searchable PDF generation**: embed selectable text layer (real OCR, not images)
- ✅ **Agent-friendly**: `agent_prompt` can be fed directly to LLMs

## 📦 Installation

### 1. System dependencies (Linux/macOS)

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y python3 python3-pip tesseract-ocr tesseract-ocr-chi-sim tesseract-ocr-chi-tra poppler-utils

# macOS
brew install python tesseract poppler
```

### 2. Python packages

```bash
cd skills/agent-vision
pip3 install -r scripts/requirements.txt
```

### 3. Configure OCR backend

**Option A: PaddleOCR Cloud (default)**

```bash
export PADDLEOCR_DOC_PARSING_API_URL=https://your-api.paddleocr.com/layout-parsing
export PADDLEOCR_ACCESS_TOKEN=your_token
```

**Option B: Tesseract Offline**

```bash
export OCR_BACKEND=tesseract
export TESSERACT_LANG=chi_tra+eng  # or chi_sim+eng, eng, etc.
```

## 🚀 Quick Start

### Single file

```bash
# Cloud OCR (PaddleOCR)
python3 scripts/doc_vision.py --file-path ./invoice.jpg --pretty

# Offline OCR (Tesseract)
OCR_BACKEND=tesseract python3 scripts/doc_vision.py --file-path ./business_card.png

# Generate searchable PDF
python3 scripts/doc_vision.py --file-path ./document.pdf --make-searchable-pdf --output result.json
```

### Batch processing

```bash
python3 scripts/doc_vision.py --batch-dir ./inbox --output-dir ./out
```

### Docker

```bash
docker build -t agent-vision:latest skills/agent-vision
docker run --rm -v $(pwd)/docs:/data \
  -e PADDLEOCR_DOC_PARSING_API_URL -e PADDLEOCR_ACCESS_TOKEN \
  agent-vision:latest \
  --file-path /data/invoice.jpg --pretty --make-searchable-pdf
```

## 📤 Output Example

```json
{
  "ok": true,
  "document_type": "invoice",
  "confidence": 0.94,
  "text": "Full extracted text...",
  "pruned_result": { ... raw provider response ... },
  "suggested_actions": [
    {
      "action": "create_expense",
      "description": "Create an expense entry in your accounting system",
      "parameters": {
        "amount": "1200",
        "vendor": "某某科技有限公司",
        "date": "2025-03-15",
        "tax_id": "12345678"
      },
      "confidence": 0.92
    },
    {
      "action": "archive",
      "description": "Archive this invoice to documents",
      "parameters": {},
      "confidence": 0.96
    }
  ],
  "agent_prompt": "You are a financial assistant. The user has provided an invoice...",
  "top_action": "create_expense",
  "metadata": {
    "pages": 1,
    "backend": "paddleocr",
    "source": "/path/to/invoice.jpg"
  },
  "searchable_pdf": "/path/to/invoice.searchable.pdf"
}
```

## 🤖 Agent Integration

Use `agent_prompt` directly as system message or show `suggested_actions` as interactive buttons. See [SKILL.md](SKILL.md) for detailed integration patterns.

## 🔍 Searchable PDF

The `--make-searchable-pdf` flag creates a PDF with embedded OCR text layer aligned using bounding boxes from the OCR engine. Requires `pdf2image` + `poppler` and `reportlab` + `pypdf`.

## 📚 Supported Document Types

| Type | Detected By | Actions |
|------|-------------|---------|
| Invoice | amounts, tax labels | create_expense, archive, tax_report |
| Business Card | name+phone+email patterns | add_contact, save_vcard |
| Receipt | merchant + total + date | create_expense, split_bill |
| Table | grid structure | export_csv, analyze_data |
| Contract | clauses, signatures | summarize, extract_dates, flag_obligations |
| ID Card | ID number, name, DOB | extract_id_info, verify_age |
| Passport | passport no., nationality, expiry | store_passport_info, check_validity |
| Bank Statement | account, balance, period | categorize_transactions, generate_report |
| Driver License | license no., class, expiry | store_license_info, check_expiry |
| Tax Form | tax year, income, payable | summarize_tax, suggest_deductions |
| General | fallback | summarize, translate, search_keywords |

## 🛠️ Troubleshooting

| Issue | Solution |
|-------|----------|
| `ModuleNotFoundError` | Install requirements: `pip3 install -r scripts/requirements.txt` |
| PaddleOCR 403/404 | Check API URL ends with `/layout-parsing` and token valid |
| Searchable PDF fails | Install `reportlab`, `pypdf`, `pdf2image` and system `poppler` |
| Tesseract not detecting | Install language packs (`tesseract-ocr-chi-sim` / `chi-tra`) and set `TESSERACT_LANG` |

## 📖 Full Documentation

See [SKILL.md](SKILL.md) for architecture, development guide, and API reference.

## License

Apache 2.0 (pending). Derived from PaddleOCR Document Parsing Skill.

---

**Made for OpenClaw.** Let your agent see and act.

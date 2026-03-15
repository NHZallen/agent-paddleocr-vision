# Agent PaddleOCR Vision — Document Understanding with Agent Actions

**Turn documents into actionable instructions for your AI agent.** Powered exclusively by PaddleOCR cloud API.

## Features

- PaddleOCR cloud OCR with high accuracy (tables, formulas, multi-language)
- Automatic classification of 11 document types
- Action suggestion with structured parameters
- Batch processing of entire directories
- Searchable PDF generation (bbox-aligned text layer)
- `agent_prompt` ready for LLM integration

## Installation

### System dependencies

Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install -y python3 python3-pip poppler-utils
```

macOS:

```bash
brew install python poppler
```

### Python packages

```bash
cd skills/agent-paddleocr-vision
pip3 install -r scripts/requirements.txt
```

### Configuration

Set required environment variables:

```bash
export PADDLEOCR_DOC_PARSING_API_URL=https://your-api.paddleocr.com/layout-parsing
export PADDLEOCR_ACCESS_TOKEN=your_token
```

## Usage

### Single file

```bash
# Basic processing
python3 scripts/doc_vision.py --file-path ./invoice.jpg --pretty

# With searchable PDF
python3 scripts/doc_vision.py --file-path ./document.pdf --make-searchable-pdf --output result.json

# Text only
python3 scripts/doc_vision.py --file-path ./doc.pdf --format text
```

### Batch processing

```bash
python3 scripts/doc_vision.py --batch-dir ./inbox --output-dir ./out
```

### Docker

```bash
docker build -t agent-paddleocr-vision:latest .
docker run --rm -v $(pwd)/data:/data \
  -e PADDLEOCR_DOC_PARSING_API_URL -e PADDLEOCR_ACCESS_TOKEN \
  agent-paddleocr-vision:latest \
  --file-path /data/invoice.jpg --pretty --make-searchable-pdf
```

## Output JSON schema

```json
{
  "ok": true,
  "document_type": "invoice",
  "confidence": 0.94,
  "text": "Full extracted text...",
  "pruned_result": { ... raw PaddleOCR response ... },
  "suggested_actions": [
    {
      "action": "create_expense",
      "description": "Create an expense entry",
      "parameters": { "amount": "1200", "vendor": "Example Inc.", "date": "2025-03-15" },
      "confidence": 0.92
    },
    { "action": "archive", "description": "Archive this document", "parameters": {}, "confidence": 0.96 }
  ],
  "agent_prompt": "You are a financial assistant. The user has provided an invoice...",
  "top_action": "create_expense",
  "metadata": { "pages": 1, "backend": "paddleocr", "source": "/path/to/file.jpg" },
  "searchable_pdf": "/path/to/file.searchable.pdf"
}
```

### Field reference

- `document_type` — one of: invoice, business_card, receipt, table, contract, id_card, passport, bank_statement, driver_license, tax_form, general
- `suggested_actions` — list of possible actions; each includes `parameters` already extracted
- `agent_prompt` — ready-to-use system message for the agent
- `searchable_pdf` — present only when `--make-searchable-pdf` is used

## Supported document types and actions

| Type | Actions |
|------|---------|
| Invoice | create_expense, archive, tax_report |
| Business Card | add_contact, save_vcard |
| Receipt | create_expense, split_bill |
| Table | export_csv, analyze_data |
| Contract | summarize, extract_dates, flag_obligations |
| ID Card | extract_id_info, verify_age |
| Passport | store_passport_info, check_validity |
| Bank Statement | categorize_transactions, generate_report |
| Driver License | store_license_info, check_expiry |
| Tax Form | summarize_tax, suggest_deductions |
| General | summarize, translate, search_keywords |

## Searchable PDF

With `--make-searchable-pdf`, the tool embeds a selectable text layer aligned to the original document using bounding boxes from PaddleOCR. Requires `pdf2image` + `poppler` (system) and `reportlab` + `pypdf` (Python).

If bounding boxes are unavailable, it falls back to overlaying full-page text at the bottom.

## Troubleshooting

**API 403/404**  
Check that `PADDLEOCR_DOC_PARSING_API_URL` ends with `/layout-parsing` and the token is valid.

**Searchable PDF fails**  
Ensure `reportlab`, `pypdf`, `pdf2image` are installed and `poppler` is in PATH.

**Poor OCR quality**  
Use higher resolution source (300 DPI), ensure good lighting and contrast.

## Architecture

- `doc_vision.py` — main CLI
- `ocr_engine.py` — PaddleOCR API wrapper
- `classify.py` — document type classifier (heuristic patterns)
- `actions.py` — parameter extraction and action generation
- `templates/` — Jinja2 templates for `agent_prompt`
- `make_searchable_pdf.py` — searchable PDF generation

## License

MIT-0

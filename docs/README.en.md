# Agent PaddleOCR Vision — OCR with Agent Actions (PaddleOCR only)

**Turn documents into actionable instructions for your AI agent.** Uses PaddleOCR cloud API exclusively.

## ✨ Features

- PaddleOCR cloud (high accuracy, supports tables, formulas, multi-language)
- 11 document types: invoice, business card, receipt, table, contract, ID card, passport, bank statement, driver's license, tax form, general
- Action suggestion with structured parameters
- Batch processing
- Searchable PDF generation (bbox-aligned text layer)

## 📦 Installation

```bash
pip3 install -r scripts/requirements.txt
# System: poppler-utils (Linux) or brew install poppler (macOS)
```

## Configuration

Set environment variables:

```bash
export PADDLEOCR_DOC_PARSING_API_URL=https://your-api.paddleocr.com/layout-parsing
export PADDLEOCR_ACCESS_TOKEN=your_token
```

## 🚀 Quick Start

```bash
# Single file
python3 scripts/doc_vision.py --file-path ./invoice.jpg --pretty --make-searchable-pdf

# Batch
python3 scripts/doc_vision.py --batch-dir ./inbox --output-dir ./out
```

## Output

See `docs/README.zh.md` for full JSON schema and integration patterns.

## Supported Types

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

`--make-searchable-pdf` embeds OCR text layer using bounding boxes from PaddleOCR. Requires `pdf2image` + `poppler` and `reportlab` + `pypdf`.

## License

MIT-0
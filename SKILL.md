---
name: agent-ocr-vision
description: Multi-OCR document understanding for AI agents
metadata:
  openclaw:
    requires:
      env:
        - PADDLEOCR_DOC_PARSING_API_URL  # optional if using Tesseract only
        - PADDLEOCR_ACCESS_TOKEN         # optional if using Tesseract only
      bins:
        - python
        - tesseract  # optional, if user wants offline OCR
    primaryEnv: PADDLEOCR_ACCESS_TOKEN
    emoji: "👁️"
    homepage: https://github.com/NHZallen/agent-ocr-vision
---

# Agent Vision Skill

**Turn documents into agent actions.** Automatically detects document type and provides actionable prompts for AI agents.

## What It Does

- **OCR extraction** from images/PDFs (PaddleOCR cloud or Tesseract offline)
- **Automatic document classification** (11 types: invoice, business card, receipt, table, contract, ID card, passport, bank statement, driver’s license, tax form, general)
- **Action suggestion** — concise, agent-friendly instructions with extracted parameters
- **Searchable PDF output** — embeds OCR text layer with proper positioning (when bbox data available)

## Quick Example

```bash
# Single file (cloud OCR)
export PADDLEOCR_DOC_PARSING_API_URL=https://your-api.paddleocr.com/layout-parsing
export PADDLEOCR_ACCESS_TOKEN=your_token

python scripts/doc_vision.py --file-path invoice.jpg --pretty

# Output (abbreviated):
# {
#   "document_type": "invoice",
#   "confidence": 0.94,
#   "text": "...",
#   "suggested_actions": [
#     {"action": "create_expense", "parameters": {"amount": "1200", "vendor": "某某", ...}}
#   ],
#   "agent_prompt": "You are a financial assistant. The user has provided an invoice..."
# }
```

## Supported Document Types

| Type | Detected By | Primary Actions |
|------|--------------|-----------------|
| **Invoice** | Keywords, amounts, tax labels | `create_expense`, `archive`, `tax_report` |
| **Business Card** | Name + phone + email patterns | `add_contact`, `save_vcard` |
| **Receipt** | Merchant + total + date | `create_expense`, `split_bill` |
| **Table** | Grid structure, headers | `export_csv`, `analyze_data` |
| **Contract** | Clauses, signatures, parties | `summarize`, `extract_dates`, `flag_obligations` |
| **ID Card** | ID number, name, DOB | `extract_id_info`, `verify_age` |
| **Passport** | Passport no., nationality, expiry | `store_passport_info`, `check_validity` |
| **Bank Statement** | Account, balance, period | `categorize_transactions`, `generate_report` |
| **Driver License** | License no., class, expiry | `store_license_info`, `check_expiry` |
| **Tax Form** | Tax year, income, payable | `summarize_tax`, `suggest_deductions` |
| **General** | Fallback | `summarize`, `translate`, `search_keywords` |

## Installation

### 1. System Dependencies

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y python3 python3-pip tesseract-ocr tesseract-ocr-chi-sim poppler-utils

# macOS
brew install python tesseract poppler
```

### 2. Python Packages

```bash
cd skills/agent-vision
pip3 install -r scripts/requirements.txt
```

**Minimum required packages** (always install):
- `httpx` — PaddleOCR API client
- `jinja2` — template rendering
- `pydantic` — data validation (optional but recommended)
- `pillow` — image handling
- `python-magic` — file type detection

**Optional for additional features**:
- `pdf2image` — PDF to image conversion (searchable PDF)
- `reportlab` — PDF generation (searchable PDF)
- `pypdf` — PDF manipulation
- `pytesseract` — offline Tesseract backend

### 3. OCR Backend Configuration

**Option A: PaddleOCR Cloud (default, requires API)**

Edit your OpenClaw config or environment:
```bash
export PADDLEOCR_DOC_PARSING_API_URL=https://your-api.paddleocr.com/layout-parsing
export PADDLEOCR_ACCESS_TOKEN=your_access_token
export PADDLEOCR_DOC_PARSING_TIMEOUT=600  # optional, seconds
```

You can also set these in OpenClaw's plugin env (`.openclaw/openclaw.json` under `skills.entries.paddleocr-doc-parsing.env`).

**Option B: Tesseract Offline (free, no internet)**

```bash
# Install Tesseract and Chinese language packs (see above)
export OCR_BACKEND=tesseract
export TESSERACT_LANG=chi_tra+eng  # or chi_sim+eng for Simplified
```

Note: Tesseract works with image files only (PDFs must be converted first). The skill will automatically convert PDFs to images if `pdf2image` is installed.

## Usage

### Single Document

```bash
# Cloud OCR (PaddleOCR)
python3 scripts/doc_vision.py --file-path "./invoice.jpg" --pretty

# Offline OCR (Tesseract)
OCR_BACKEND=tesseract python3 scripts/doc_vision.py --file-path "./business_card.png"

# Remote URL
python3 scripts/doc_vision.py --file-url "https://example.com/doc.pdf" --output result.json

# Text only output (no JSON)
python3 scripts/doc_vision.py --file-path doc.pdf --format text

# Generate searchable PDF (embeds OCR text layer)
python3 scripts/doc_vision.py --file-path invoice.pdf --make-searchable-pdf

# Combined
python3 scripts/doc_vision.py --file-path contract.pdf --pretty --make-searchable-pdf --output contract_result.json
```

### Batch Processing

```bash
# Process all supported files in a directory
python3 scripts/doc_vision.py --batch-dir ./inbox --output-dir ./results

# Output: a summary JSON (batch_summary + per-file results) plus individual JSON files in ./results/
```

### Output JSON Schema

```json
{
  "ok": true,
  "document_type": "invoice",
  "confidence": 0.94,
  "text": "Full extracted text...",
  "pruned_result": { ... raw API output ... },
  "suggested_actions": [
    {
      "action": "create_expense",
      "description": "將此發票金額記入帳務系統",
      "parameters": { "amount": "1200", "vendor": "某某公司", ... },
      "confidence": 0.9
    }
  ],
  "agent_prompt": "You are a financial assistant. The user has provided an invoice...",
  "top_action": "create_expense",
  "metadata": {
    "pages": 1,
    "backend": "paddleocr",
    "source": "/path/to/invoice.jpg"
  },
  "searchable_pdf": "/path/to/invoice.searchable.pdf"  // only if --make-searchable-pdf
}
```

## Agent Integration Guide

When an agent receives this result, it can:

1. **Use `agent_prompt` directly** — it’s a ready-to-use instruction tailored to the document type with extracted values.
2. **Read `suggested_actions`** to offer buttons or quick replies to the user.
3. **Extract structured data** from `suggested_actions[0].parameters` for downstream automation (e.g., create_expense → bookkeeping API).

Example agent logic:

```python
result = vision_skill_output
if result["document_type"] == "invoice":
    # Offer actions
    for action in result["suggested_actions"]:
        show_button(action["description"], callback_data=action["action"])
    # Or auto-execute top action with user confirmation
```

## Searchable PDF

The `--make-searchable-pdf` option creates a PDF where the OCR text is embedded as a selectable/searchable layer aligned with the original image.

**How it works**:
- For PDF input: original pages are rendered to images at 200 DPI, then overlaid with invisible text using bounding boxes from `prunedResult`.
- For image input: converts image to PDF and adds text layer.
- If bounding boxes are missing (some OCR APIs don’t provide them), falls back to full-page text overlay at the bottom.

**Requirements**:
- `pdf2image` + system `poppler` (for PDF → images)
- `reportlab` + `pypdf` + `pillow` (PDF generation)

**Limitations**:
- Text layer positions are approximate; extremely small fonts or rotated text may misalign.
- Multi-column layouts may have overlapping text boxes.

## Troubleshooting

### “ModuleNotFoundError: No module named ‘httpx’”
Install requirements: `pip3 install -r scripts/requirements.txt`

### “PaddleOCR API error (403/404)”
Check API URL and token. The URL must end with `/layout-parsing` and be accessible.

### “pdf2image not found / poppler error”
Install poppler: `apt-get install poppler-utils` (Ubuntu) or `brew install poppler` (macOS).

### “No document type matched (confidence < 0.3)”
The document may be unclear or language mismatch. The classifier will fall back to `general` but confidence may be low. Check OCR text quality.

### Searchable PDF not created
- Ensure `reportlab` and `pypdf` are installed.
- For PDFs, `pdf2image` and `poppler` are required.
- Check stderr for warnings (e.g., missing bounding boxes).

### Tesseract backend not detecting text
Verify Tesseract is installed: `tesseract --version`.
Install language packs: `tesseract-ocr-chi-sim` (Simplified) or `tesseract-ocr-chi-tra` (Traditional).
Set `TESSERACT_LANG=chi_sim+eng`.

## Developing New Document Types

1. Add patterns in `scripts/classify.py`:
   ```python
   DOC_TYPE_MY_TYPE = "my_type"
   def match_my_type(text: str) -> float:
       patterns = [r"關鍵字1", r"關鍵字2"]
       matches = sum(1 for p in patterns if re.search(p, text, re.IGNORECASE))
       return min(matches / len(patterns), 1.0)
   ```
2. Add action generator in `scripts/actions.py`:
   ```python
   def suggest_my_type(text: str, metadata) -> List[Action]:
       # Extract fields and return actions
       ...
   SUGGESTION_DISPATCH[DOC_TYPE_MY_TYPE] = suggest_my_type
   ```
3. Create `templates/my_type.md` with agent instructions.
4. Add to `classify()`’s scores dict.

## File Structure

```
skills/agent-vision/
├── SKILL.md               # This file
├── _meta.json             # Skill metadata
├── requirements.txt       # Python dependencies
├── .env.example           # Environment variable template (to be added)
├── Dockerfile             # Containerized deployment (to be added)
├── README.md              # Quick reference (to be added)
└── scripts/
    ├── run               # Tool entrypoint for OpenClaw
    ├── doc_vision.py     # Main CLI (single + batch)
    ├── classify.py       # Document type classifier
    ├── actions.py        # Action suggestion engine
    ├── ocr_engine.py     # OCR backend wrapper (PaddleOCR)
    ├── make_searchable_pdf.py  # PDF generation
    └── smoke_test.py     # Basic tests
└── templates/
    ├── invoice.md
    ├── business_card.md
    ├── receipt.md
    ├── table.md
    ├── contract.md
    ├── id_card.md
    ├── passport.md
    ├── bank_statement.md
    ├── driver_license.md
    ├── tax_form.md
    └── general.md
```

## Performance Notes

- Batch mode processes files sequentially; for parallel processing, run multiple instances or wrap in GNU parallel.
- Searchable PDF generation can be memory-intensive for large PDFs (>100 pages). Monitor memory usage.
- Cloud OCR (PaddleOCR) may have rate limits; check provider quota.
- Tesseract is slower but free and privacy-preserving.

## License

[To be determined — inherit from original PaddleOCR skill or choose a license]

---

**Ready to use.** Install dependencies, set credentials, and run `doc_vision.py`. For issues, check `stderr` logs or run `scripts/smoke_test.py`.

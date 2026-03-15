# Agent PaddleOCR Vision —— Document Understanding and Agent Actions with PaddleOCR

**Transform documents into actionable instructions for AI agents.** This skill exclusively supports PaddleOCR cloud API, automatically classifying document types and providing structured parameter suggestions and prompts.

## Features Overview

- OCR using PaddleOCR cloud API (supports tables, formulas, multi-language)
- Automatic classification into 11 document types: invoice, business_card, receipt, table, contract, id_card, passport, bank_statement, driver_license, tax_form, general
- Generates suggested actions for each type (create_expense, add_contact, summarize, etc.)
- Batch processing of entire directories
- Generates searchable PDFs (embeds text layer based on bounding boxes, supports text selection and search)
- Outputs `agent_prompt` ready for use as LLM system message

## Installation

### System Dependencies

Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install -y python3 python3-pip poppler-utils
```

macOS:

```bash
brew install python poppler
```

### Python Packages

```bash
cd skills/agent-paddleocr-vision
pip3 install -r scripts/requirements.txt
```

### PaddleOCR API Configuration

Two environment variables must be set:

```bash
export PADDLEOCR_DOC_PARSING_API_URL=https://your-api.paddleocr.com/layout-parsing
export PADDLEOCR_ACCESS_TOKEN=your_access_token
```

*Note: API URL must end with `/layout-parsing`.*

## Usage

### Single Document

```bash
# Basic usage: process image or PDF, output pretty JSON
python3 scripts/doc_vision.py --file-path ./invoice.jpg --pretty

# Also generate searchable PDF
python3 scripts/doc_vision.py --file-path ./document.pdf --make-searchable-pdf --output result.json

# Text only
python3 scripts/doc_vision.py --file-path ./doc.pdf --format text
```

### Batch Processing

```bash
# Process all supported files in a directory (.pdf, .png, .jpg, .jpeg, .bmp, .tiff, .webp)
python3 scripts/doc_vision.py --batch-dir ./inbox --output-dir ./out
```

Batch results:
- Produces a summary JSON (total count, success/failure numbers, statistics by type)
- Each file gets an individual JSON in `--output-dir`

### Docker

```bash
docker build -t agent-paddleocr-vision:latest .
docker run --rm -v $(pwd)/data:/data \
  -e PADDLEOCR_DOC_PARSING_API_URL -e PADDLEOCR_ACCESS_TOKEN \
  agent-paddleocr-vision:latest \
  --file-path /data/invoice.jpg --pretty --make-searchable-pdf
```

## Output Format

```json
{
  "ok": true,
  "document_type": "invoice",
  "confidence": 0.94,
  "text": "Full extracted text content (pages separated by double newlines)",
  "pruned_result": { ... raw PaddleOCR API response structure ... },
  "suggested_actions": [
    {
      "action": "create_expense",
      "description": "Record this invoice amount in the accounting system",
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
      "description": "Archive this invoice to document library",
      "parameters": {},
      "confidence": 0.96
    },
    {
      "action": "tax_report",
      "description": "Include in current tax report",
      "parameters": { "tax_period": "2025-03" },
      "confidence": 0.78
    }
  ],
  "agent_prompt": "You are a financial assistant. The user has provided an invoice.\nExtracted data:\n- Amount: 1200\n- Vendor: 某某科技有限公司\n...\nPossible actions: create_expense, archive, tax_report\nRespond appropriately based on user's goal.",
  "top_action": "create_expense",
  "metadata": {
    "pages": 1,
    "backend": "paddleocr",
    "source": "/absolute/path/to/invoice.jpg"
  },
  "searchable_pdf": "/absolute/path/to/invoice.searchable.pdf"
}
```

### Field Reference

| Field | Description |
|------|-------------|
| ok | Whether processing succeeded |
| document_type | Document type (invoice, business_card, …) |
| confidence | Classification confidence score (0–1) |
| text | All extracted text from all pages (Markdown format) |
| pruned_result | Raw API response containing per-page layoutParsingResults for advanced processing |
| suggested_actions | List of suggested actions, sorted by confidence |
| agent_prompt | Tailored prompt that can be sent directly to an LLM |
| top_action | Name of the highest confidence action |
| metadata | Includes page count, backend used, source path, etc. |
| searchable_pdf | Path to searchable PDF (only present when `--make-searchable-pdf` is used) |

## Agent Integration Guidelines

1. **Use `agent_prompt` directly**: Send `agent_prompt` as a system message or user-provided context; the LLM will generate appropriate responses based on the extracted data and actions.
2. **Provide interactive buttons**: Convert `suggested_actions` into quick reply buttons for user selection.
3. **Auto-execute**: After user confirmation, automatically call the corresponding function (e.g., `create_expense` with the provided `parameters`).

Example (Node.js-style pseudo-code):

```javascript
const result = await callAgentVision({ 'file-path': '/path/to/doc.pdf' });
if (result.document_type === 'invoice') {
  for (const act of result.suggested_actions) {
    showButton(act.description, { action: act.action, params: act.parameters });
  }
}
```

## Searchable PDF Details

`--make-searchable-pdf` creates a new PDF with a selectable, searchable text layer. How it works:

1. Each page of the input PDF is rasterized to a 200 DPI bitmap (using `pdf2image` and system `poppler`)
2. Based on fragment `bbox` coordinates from PaddleOCR's `layoutParsingResults[].prunedResult`, invisible text is placed at the corresponding positions (using `reportlab`)
3. The image is kept as background; text layer is overlaid. PDF readers will match searches against the embedded text

If the API does not return any bounding box data, a fallback version overlays full-page text at the bottom; searchable but not position-accurate.

### Required Software

- System: `poppler-utils` (Ubuntu: `apt-get install poppler-utils`; macOS: `brew install poppler`)
- Python: `reportlab`, `pypdf`, `pillow`, `pdf2image`

## Document Type Reference

| Type | Identification Keywords/Structure | Suggested Actions |
|------|-----------------------------------|-------------------|
| Invoice | invoice number, amount, tax ID, seller/buyer | create_expense, archive, tax_report |
| Business Card | name, phone, email, job title | add_contact, save_vcard |
| Receipt | merchant name, amount paid, transaction date | create_expense, split_bill |
| Table | grid lines, multi-column alignment, header row | export_csv, analyze_data |
| Contract | clause numbers, signatures, effective date | summarize, extract_dates, flag_obligations |
| ID Card | ID number, name, date of birth, gender | extract_id_info, verify_age |
| Passport | passport number, nationality, issue/expiry dates | store_passport_info, check_validity |
| Bank Statement | account number, statement period, balance, transaction history | categorize_transactions, generate_report |
| Driver License | license number, class, expiry, address | store_license_info, check_expiry |
| Tax Form | tax year, total income, tax payable, deductions | summarize_tax, suggest_deductions |
| General | no specific pattern | summarize, translate, search_keywords |

## Troubleshooting

### PaddleOCR API returns 403 or 404

Check:
- `PADDLEOCR_DOC_PARSING_API_URL` is correct and ends with `/layout-parsing`
- `PADDLEOCR_ACCESS_TOKEN` is valid and not expired
- Network connectivity to the API endpoint

### Searchable PDF generation fails

Ensure installed:
```bash
pip3 show reportlab pypdf pdf2image
```
And system `poppler`:
```bash
which pdftoppm  # should exist
```

If still failing, check `stderr` for errors; common causes:
- Input PDF corrupt or encrypted
- Bounding box data missing (will still generate but text placement may be approximate)

### Poor OCR quality

- Ensure document is sharp, well-lit, high contrast
- For Chinese, PaddleOCR handles it; other languages usually auto-detected
- Increase source DPI (300+ recommended)

### Batch processing is slow

- Consider parallel processing (e.g., GNU parallel)
- If using cloud API, respect rate limits; increase timeout or split into smaller batches

## Architecture

```
doc_vision.py  →  main entry point
   ├─ ocr_engine.py      → calls PaddleOCR API, returns text + pruned_result
   ├─ classify.py        → classifies document type based on text content
   ├─ actions.py         → extracts parameters and generates suggested action list
   ├─ templates/         → Jinja2 templates for agent_prompt
   └─ make_searchable_pdf.py → generates searchable PDF using bbox data
```

## Developing New Document Types

1. In `scripts/classify.py`, add a matching function and constant:
   ```python
   DOC_TYPE_MY_TYPE = "my_type"
   def match_my_type(text: str) -> float:
       patterns = [r"keyword1", r"keyword2"]
       return sum(bool(re.search(p, text, re.IGNORECASE)) for p in patterns) / len(patterns)
   ```
   Then add `DOC_TYPE_MY_TYPE: match_my_type(text)` to the `scores` dict in `classify()`.

2. In `scripts/actions.py`, add a generator function:
   ```python
   def suggest_my_type(text: str, metadata) -> List[Action]:
       # extract params, return Action list
       ...
   SUGGESTION_DISPATCH[DOC_TYPE_MY_TYPE] = suggest_my_type
   ```

3. Add `templates/my_type.md` (Jinja2 template) containing instructions and parameters for the agent.

4. Add a row to the “Document Type Reference” table in `docs/README.zh.md`.

## Performance & Resources

- Typical request latency: 2–15 seconds (depending on page count and API speed)
- Memory usage: up to 2–3× file size when processing PDFs
- Batch mode does not include built-in parallelism; wrap with multiprocessing if needed

## License

MIT-0

## Version History

- v1.0.0 — Initial release (2025-03-15)

---

**Problems?** Check `stderr` output or open an issue on GitHub.

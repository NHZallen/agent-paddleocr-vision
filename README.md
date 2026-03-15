# Agent Vision

OCR that thinks for your AI agent. Upload any document → get type detection + suggested actions.

```
  ┌────────────┐
  │ Document   │──► OCR (PaddleOCR/Tesseract)
  └────────────┘                  │
                                  ▼
                        ┌─────────────────────┐
                        │  Classify + Extract │
                        └─────────────────────┘
                                  │
                                  ▼
                        ┌─────────────────────┐
                        │ Suggested Actions   │──► Agent decides
                        └─────────────────────┘
```

## One-liner

```bash
docker run --rm -v $(pwd)/docs:/data -e PADDLEOCR_DOC_PARSING_API_URL -e PADDLEOCR_ACCESS_TOKEN agent-vision:latest --file-path /data/invoice.jpg --pretty
```

## Prerequisites

- Python 3.10+ and pip (if running locally)
- For cloud OCR: PaddleOCR API credentials (`API_URL`, `ACCESS_TOKEN`)
- For offline OCR: Tesseract + language packs

## Quick Start

```bash
# 1. Install deps
pip3 install -r scripts/requirements.txt

# 2. Set credentials (or use OCR_BACKEND=tesseract)
export PADDLEOCR_DOC_PARSING_API_URL=https://...
export PADDLEOCR_ACCESS_TOKEN=...

# 3. Run
python3 scripts/doc_vision.py --file-path ./invoice.jpg --pretty
```

## Batch

```bash
python3 scripts/doc_vision.py --batch-dir ./inbox --output-dir ./out
```

## Searchable PDF

```bash
python3 scripts/doc_vision.py --file-path ./doc.pdf --make-searchable-pdf
# Output: doc.searchable.pdf (text layer selectable)
```

## Need Help?

See full documentation in [SKILL.md](SKILL.md).

## Supported Types

Invoices, business cards, receipts, tables, contracts, ID cards, passports, bank statements, driver licenses, tax forms.

Each comes with ready-to-use agent prompts.

---

**Made for OpenClaw agents.** Let your AI see and act.

# Agent PaddleOCR Vision —— 用 PaddleOCR 讓 AI 看懂文件

**把文件變成 AI 的行動指引。** 僅支援 PaddleOCR 雲端 API，上傳任何圖片或 PDF，自動判斷文件類型，告訴 AI 能做什麼、該怎麼處理。

## ✨ 有哪些功能？

- ✅ **PaddleOCR 雲端 OCR**：高精度，支援表格、公式、多語言
- ✅ **11 種文件自動分類**：發票、名片、收據、表格、合約、身分證、護照、銀行對帳單、駕照、稅表、一般文件
- ✅ **行動建議引擎**：提取關鍵欄位 + 生成可用按鈕/指令
- ✅ **批量處理**：一次掃描整個資料夾
- ✅ **可搜尋 PDF 輸出**：為掃描檔加上可複製選取的文字層（真正 OCR 而非圖片）
- ✅ **Agent 友好**：輸出 `agent_prompt` 可直接丟給 LLM 使用

## 📦 安裝步驟

### 1. 系統依賴（Linux/macOS）

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y python3 python3-pip poppler-utils

# macOS
brew install python poppler
```

### 2. Python 套件

```bash
cd skills/agent-paddleocr-vision
pip3 install -r scripts/requirements.txt
```

### 3. PaddleOCR API 設定

你需要 PaddleOCR 的 API 端點與 Token：

```bash
export PADDLEOCR_DOC_PARSING_API_URL=https://your-api.paddleocr.com/layout-parsing
export PADDLEOCR_ACCESS_TOKEN=your_token_string
```

或在 OpenClaw 設定中，為 `agent-paddleocr-vision` 技能加入環境變數。

## 🚀 快速開始

### 單一文件

```bash
# 處理發票（雲端 OCR）
python3 scripts/doc_vision.py --file-path ./發票.jpg --pretty

# 並產生可搜尋版 PDF
python3 scripts/doc_vision.py --file-path ./文件.pdf --make-searchable-pdf --output result.json

# 只取得純文字
python3 scripts/doc_vision.py --file-path ./doc.pdf --format text
```

### 批次處理

```bash
python3 scripts/doc_vision.py --batch-dir ./待處理 --output-dir ./結果
```

### Docker

```bash
docker build -t agent-paddleocr-vision:latest .
docker run --rm -v $(pwd)/docs:/data \
  -e PADDLEOCR_DOC_PARSING_API_URL -e PADDLEOCR_ACCESS_TOKEN \
  agent-paddleocr-vision:latest \
  --file-path /data/invoice.jpg --pretty --make-searchable-pdf
```

## 📤 輸出範例

```json
{
  "ok": true,
  "document_type": "invoice",
  "confidence": 0.94,
  "text": "發票號碼: AB12345678\n統一編號: 12345678\n金額: NT$ 1,200\n...",
  "pruned_result": { ...原始 PaddleOCR 回傳... },
  "suggested_actions": [
    {
      "action": "create_expense",
      "description": "將此發票金額記入帳務系統",
      "parameters": { "amount": "1200", "vendor": "某某科技", "date": "2025-03-15" },
      "confidence": 0.92
    },
    { "action": "archive", "description": "將此發票歸檔", "parameters": {}, "confidence": 0.96 },
    { "action": "tax_report", "description": "加入本期稅務報表", "parameters": {}, "confidence": 0.78 }
  ],
  "agent_prompt": "You are a financial assistant. The user has provided an invoice...",
  "top_action": "create_expense",
  "metadata": { "pages": 1, "backend": "paddleocr", "source": "/path/to/發票.jpg" },
  "searchable_pdf": "/path/to/發票.searchable.pdf"
}
```

## 🤖 Agent 整合

- 使用 `agent_prompt` 作為 system message
- 或用 `suggested_actions` 產生按鈕讓使用者選擇

## 🔍 可搜尋 PDF

`--make-searchable-pdf` 會根據 PaddleOCR 回傳的 bbox 座標，在對應位置加入可選取的文字層。需 `pdf2image` + `poppler` 與 `reportlab`、`pypdf`。

## 🛠️ 文件類型一覽

| 類型 | 建議動作 |
|------|----------|
| 發票 | create_expense, archive, tax_report |
| 名片 | add_contact, save_vcard |
| 收據 | create_expense, split_bill |
| 表格 | export_csv, analyze_data |
| 合約 | summarize, extract_dates, flag_obligations |
| 身分證 | extract_id_info, verify_age |
| 護照 | store_passport_info, check_validity |
| 銀行對帳單 | categorize_transactions, generate_report |
| 駕照 | store_license_info, check_expiry |
| 稅表 | summarize_tax, suggest_deductions |
| 一般 | summarize, translate, search_keywords |

## 🔧 常見問題

- **API 403/404**：確認 `PADDLEOCR_DOC_PARSING_API_URL` 以 `/layout-parsing` 結尾，且 Token 有效。
- **Searchable PDF 失敗**：檢查 `reportlab`、`pypdf`、`pdf2image` 及系統 `poppler` 是否安裝。
- **辨識率不佳**：確認輸入文件清晰、語言正確（PaddleOCR 自動偵測）。

## 📚 完整文件

其他語言版本：
- English: `docs/README.en.md`
- Español: `docs/README.es.md`
- العربية: `docs/README.ar.md`

## License

MIT-0
# Agent Vision —— 讓 AI 看報告、做決定

**把文件變成 AI 的行動指引。** 上傳任何圖片或 PDF，自動判斷文件類型，告訴 AI 能做什麼、該怎麼處理。

## ✨ 有哪些功能？

- ✅ **多源 OCR**：PaddleOCR 雲端 API（高精度）或 Tesseract 離線（免費）
- ✅ **11 種文件自動分類**：發票、名片、收據、表格、合約、身分證、護照、銀行對帳單、駕照、稅表、一般文件
- ✅ **行動建議引擎**：提取關鍵欄位 + 生成可用按鈕/指令
- ✅ **批量處理**：一次掃描整個資料夾
- ✅ **可搜尋 PDF 輸出**：為掃描檔加上可複製選取的文字層（真正 OCR 而非圖片）
- ✅ **Agent 友好**：輸出 `agent_prompt` 可直接丟給 LLM 使用

## 📦 安裝步驟

### 第一步：系統依賴（Linux/macOS）

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y python3 python3-pip tesseract-ocr tesseract-ocr-chi-sim tesseract-ocr-chi-tra poppler-utils

# macOS
brew install python tesseract poppler
```

### 第二步：Python 套件

```bash
cd skills/agent-vision
pip3 install -r scripts/requirements.txt
```

如果出現錯誤，請檢查 pip 版本或改用 `pip install --user -r ...`。

### 第三步：OCR 後端設定

**方案一：使用 PaddleOCR 雲端 API（預設）**

你需要申請 API 金鑰（據官方說明）。設定環境變數：

```bash
export PADDLEOCR_DOC_PARSING_API_URL=https://your-api.paddleocr.com/layout-parsing
export PADDLEOCR_ACCESS_TOKEN=your_token_string
```

或者在 OpenClaw 的 `openclaw.json` 中，`skills.entries.paddleocr-doc-parsing.env` 加入這兩項。

**方案二：使用 Tesseract 離線（完全免費）**

```bash
export OCR_BACKEND=tesseract
export TESSERACT_LANG=chi_tra+eng   # 繁體+英文；簡體可改用 chi_sim+eng
```

請確保已安裝 `tesseract-ocr` 及中文語言包。

## 🚀 快速開始

### 單一文件

```bash
# 使用 PaddleOCR 處理發票
python3 scripts/doc_vision.py --file-path ./發票.jpg --pretty

# 使用 Tesseract 處理名片
OCR_BACKEND=tesseract python3 scripts/doc_vision.py --file-path ./名片.png

# 並產生可搜尋版 PDF
python3 scripts/doc_vision.py --file-path ./文件.pdf --make-searchable-pdf --output result.json

# 只取得純文字（用於管道）
python3 scripts/doc_vision.py --file-path ./doc.pdf --format text | some-command
```

### 批次處理

把一堆文件丢進去，一次搞定：

```bash
python3 scripts/doc_vision.py --batch-dir ./待處理 --output-dir ./結果
```

結果會產生：
- `batch_summary.json`：統計總計與各類型數量
- `./結果/` 目錄下各別 JSON 檔

### Docker 方式（完全隔離）

```bash
# 建立映像
docker build -t agent-vision:latest skills/agent-vision

# 執行（掛載本地目錄，傳入環境變數）
docker run --rm \
  -v $(pwd)/docs:/data \
  -e PADDLEOCR_DOC_PARSING_API_URL \
  -e PADDLEOCR_ACCESS_TOKEN \
  agent-vision:latest \
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
      "description": "將此發票歸檔至文件庫",
      "parameters": {},
      "confidence": 0.96
    },
    {
      "action": "tax_report",
      "description": "加入本期稅務報表",
      "parameters": { "tax_period": "2025-03" },
      "confidence": 0.78
    }
  ],
  "agent_prompt": "You are a financial assistant. The user has provided an invoice.\nExtracted data:\n- Amount: 1200\n- Vendor: 某某科技有限公司\n...\nPossible actions: create_expense, archive, tax_report\nRespond appropriately based on user's goal.",
  "top_action": "create_expense",
  "metadata": {
    "pages": 1,
    "backend": "paddleocr",
    "source": "/absolute/path/to/發票.jpg"
  },
  "searchable_pdf": "/absolute/path/to/發票.searchable.pdf"  // 只在使用 --make-searchable-pdf 時出現
}
```

## 🤖 如何整合到 Agent？

Agent 拿到這個 JSON 後，可以：

- **直接使用 `agent_prompt`**：把這段文字當作 system prompt 的一部分，讓 LLM 知道該如何處理
- **顯示 action 按鈕**：根據 `suggested_actions` 生成快速回復按鈕，讓用戶點選
- **自動執行頂層 action**：在取得用戶確認後，呼叫對應的函數（如 `create_expense`）

範例（OpenClaw Node.js）：

```javascript
const result = await toolCall('agent-vision', { 'file-path': '/path/to/doc.pdf' });
if (result.document_type === 'invoice') {
  for (const act of result.suggested_actions) {
    await showButton(act.description, { action: act.action, params: act.parameters });
  }
}
```

### 提示

`agent_prompt` 已經根據文件類型與抽取的參數Individualized（個人化），可以直接餵給 LLM 作為 context。LLM 會知道「這是一張發票，金額 1200 元」並建議使用者操作。

## 🔍 可搜尋 PDF 詳細說明

### 如何運作？

1. 將輸入 PDF 每一頁轉為 200 DPI 的圖片（使用 `pdf2image` + poppler）
2. 根據 PaddleOCR 回傳的 `prunedResult` 中的 `bbox` 座標，在圖片上對應位置放上「不可見」的文字層
3. 如果是圖片輸入，直接將圖片轉 PDF 再加文字層

生成的 `*.searchable.pdf` 可在任何 PDF 閱讀器（Adobe Reader、Preview、瀏覽器）中選取文字、搜尋關鍵字。

### 限制

- 如果 OCR API 沒有回傳 bounding boxes，則改為頁面底部整段文字疊加（搜尋可用，但位置不精確）
- 手寫體或極小字體可能對齊不準
- 多欄版面的文字框可能重疊，但不影響搜尋

### 所需套件

```bash
pip install reportlab pypdf pillow pdf2image
# 系統: poppler-utils ( Ubuntu ) 或 brew install poppler (macOS)
```

## 🛠️ 文件類型對照表

| 類型 | 辨識依據 | 建議動作 |
|------|----------|----------|
| 發票 (invoice) | 發票號碼、金額、統一編號、稅額 | `create_expense`（記帳）、`archive`（歸檔）、`tax_report`（稅務報表） |
| 名片 (business_card) | 姓名+電話+Email 同時出現 | `add_contact`（新增聯絡人）、`save_vcard`（下載 vCard） |
| 收據 (receipt) | 商店名稱、實付金額、交易日期 | `create_expense`、`split_bill`（分帳） |
| 表格 (table) | 表格線條或多欄排列 | `export_csv`、`analyze_data` |
| 合約 (contract) | 條款編號、簽署人、簽名欄 | `summarize`（摘要）、`extract_dates`（日期清單）、`flag_obligations`（義務條款） |
| 身分證 (id_card) | 身分證字號、姓名、出生日期 | `extract_id_info`（提取身份資訊）、`verify_age`（檢查年龄） |
| 護照 (passport) | 護照號碼、國籍、有效期 | `store_passport_info`、`check_validity` |
| 銀行對帳單 (bank_statement) | 帳戶號碼、期初/期末餘額、交易明細 | `categorize_transactions`、`generate_report` |
| 駕照 (driver_license) | 駕照編號、車類別、有效期 | `store_license_info`、`check_expiry` |
| 稅表 (tax_form) | 稅年度、總收入、應納稅額 | `summarize_tax`、`suggest_deductions` |
| 一般 (general) | 未明確匹配 | `summarize`、`translate`、`search_keywords` |

## 🔧 常見問題

### 安裝 `pdf2image` 失敗？

需要系統的 poppler，Ubuntu: `apt-get install poppler-utils`；macOS: `brew install poppler`。

### 使用 PaddleOCR 出現 403/404？

檢查 API URL 是否正確且以 `/layout-parsing` 結尾，Token 是否有效。

### 搜索 PDF 無法產生？

- 確認 `reportlab` 與 `pypdf` 已安裝
- 檢查 `stderr` 是否有警告（例如 bbox 缺失）

### Tesseract 辨識率低？

1. 確認 language pack 已安裝：`tesseract-ocr-chi-sim` 或 `tesseract-ocr-chi-tra`
2. 調整 `TESSERACT_LANG` 環境變數（例如 `chi_sim+eng`）
3. 提高 DPI（不可行，Tesseract 自行調整）

### 批次處理速度慢？

可考慮：
- 增加平行處理（例如 GNU parallel）
- 使用雲端 OCR 通常較快（但有速率 limit）

## 📚 更多資訊

完整 API 說明與開發指南，請參閱 [SKILL.md](SKILL.md)。

## 版本與授權

- 版本：0.1.0
- 改編自 [PaddleOCR Document Parsing Skill](https://github.com/PaddlePaddle/PaddleOCR/tree/main/skills/paddleocr-doc-parsing)
- _base 授權：Apache 2.0（具體以 LICENSE 檔案為準，待補）

## 貢獻

欢迎提交 Issue 與 Pull Request。請確保遵守原專案的授權條款。

---

**讓你的 AI 看懂文件，從此自動化。**

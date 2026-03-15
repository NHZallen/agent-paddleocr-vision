# Agent PaddleOCR Vision — OCR مع إجراءات للعامل

حوّل المستندات إلى إجراءات قابلة للتنفيذ للذكاء الاصطناعي. يعتمد فقط على PaddleOCR السحابي.

## الميزات

- دقة عالية باستخدام PaddleOCR (يدعم الجداول والمعادلات)
- تصنيف تلقائي لـ 11 نوع مستند
- اقتراح إجراءات مع معلمات منظمة
- معالجة دفعات (batch)
- إنشاء PDF ذو طبقة نصية قابلة للبحث
- `agent_prompt` جاهز للتكامل مع LLM

## التثبيت

### متطلبات النظام

Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install -y python3 python3-pip poppler-utils
```

macOS:

```bash
brew install python poppler
```

### حزم Python

```bash
cd skills/agent-paddleocr-vision
pip3 install -r scripts/requirements.txt
```

### الإعداد

متغيرات البيئة المطلوبة:

```bash
export PADDLEOCR_DOC_PARSING_API_URL=https://your-api.paddleocr.com/layout-parsing
export PADDLEOCR_ACCESS_TOKEN=your_token
```

## الاستخدام

### معالجة ملف واحد

```bash
python3 scripts/doc_vision.py --file-path فاتورة.jpg --pretty
python3 scripts/doc_vision.py --file-path مستند.pdf --make-searchable-pdf --output نتيجة.json
python3 scripts/doc_vision.py --file-path مستند.pdf --format text
```

### المعالجة بالدفعات

```bash
python3 scripts/doc_vision.py --batch-dir ./inbox --output-dir ./out
```

### Docker

```bash
docker build -t agent-paddleocr-vision:latest .
docker run --rm -v $(pwd)/data:/data \
  -e PADDLEOCR_DOC_PARSING_API_URL -e PADDLEOCR_ACCESS_TOKEN \
  agent-paddleocr-vision:latest \
  --file-path /data/فاتورة.jpg --pretty
```

## مخرجات JSON

انظر `docs/README.en.md` للحصول على المخطط الكامل ومعلومات الحقول.

## أنواع المستندات والإجراءات

| النوع | الإجراءات |
|------|----------|
| فاتورة (invoice) | create_expense, archive, tax_report |
| بطاقة عمل (business_card) | add_contact, save_vcard |
| إيصال (receipt) | create_expense, split_bill |
| جدول (table) | export_csv, analyze_data |
| عقد (contract) | summarize, extract_dates, flag_obligations |
| بطاقة هوية (id_card) | extract_id_info, verify_age |
| جواز سفر (passport) | store_passport_info, check_validity |
| كشف حساب (bank_statement) | categorize_transactions, generate_report |
| رخصة قيادة (driver_license) | store_license_info, check_expiry |
| نموذج ضريبي (tax_form) | summarize_tax, suggest_deductions |
| عام (general) | summarize, translate, search_keywords |

## PDF قابل للبحث

يؤدي `--make-searchable-pdf` إلى إنشاء PDF ذات طبقة نصية محاذاة حسب الإحداثيات من PaddleOCR. يتطلب `poppler` و `reportlab` و `pypdf` و `pdf2image`.

## استكشاف الأخطاء

- **403/404**: تأكد من صحة الرابط وأنه ينتهي بـ `/layout-parsing` وأن Token صالح.
- **فشل إنشاء PDF**: تأكد من تثبيت `poppler` والحزم Python.
- **جودة OCR منخفضة**: استخدم مستندات ذات دقة 300 DPI أو أعلى، إضاءة جيدة.

## الترخيص

MIT-0

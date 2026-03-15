# Agent PaddleOCR Vision — OCR مع إجراءات (PaddleOCR فقط)

حوّل الوثائق إلى تعليمات قابلة للتنفيذ للذكاء الاصطناعي. يعتمد فقط على PaddleOCR السحابي.

## الميزات

- دعم PaddleOCR السحابي
- 11 نوع مستند
- إنشاء PDF قابلة للبحث
- معالجة دفعات
- مخرجات agent_prompt جاهزة للLLM

## التثبيت

```bash
pip3 install -r scripts/requirements.txt
# النظام: poppler-utils
```

## الإعداد

```bash
export PADDLEOCR_DOC_PARSING_API_URL=https://your-api.paddleocr.com/layout-parsing
export PADDLEOCR_ACCESS_TOKEN=your_token
```

## الاستخدام

```bash
python3 scripts/doc_vision.py --file-path فاتورة.jpg --pretty --make-searchable-pdf
python3 scripts/doc_vision.py --batch-dir ./inbox --output-dir ./out
```

## أنواع المستندات

| النوع | الإجراءات |
|------|----------|
| الفاتورة | create_expense, archive, tax_report |
| بطاقة العمل | add_contact, save_vcard |
| الإيصال | create_expense, split_bill |
| الجدول | export_csv, analyze_data |
| العقد | summarize, extract_dates, flag_obligations |
| بطاقة الهوية | extract_id_info, verify_age |
| جواز السفر | store_passport_info, check_validity |
| كشف الحساب | categorize_transactions, generate_report |
| رخصة القيادة | store_license_info, check_expiry |
| النموذج الضريبي | summarize_tax, suggest_deductions |
| عام | summarize, translate, search_keywords |

## PDF قابل للبحث

يتيح `--make-searchable-pdf` إضافة طبقة نصية قابلة للاختيار باستخدام إحداثيات PaddleOCR.

## الرخصة

MIT-0
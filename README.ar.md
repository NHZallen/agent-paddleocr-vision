# Agent Vision — OCR مع إجراءات للعامل

**حوّل الوثائق إلى تعليمات قابلة للتنفيذ للذكاء الاصطناعي.** اكتشف نوع الوثيقة تلقائيًا وقدم قائمة بالإجراءات المقترحة.

## ✨ الميزات

- دعم محركات OCR متعددة: PaddleOCR سحابي أو Tesseract محلي (مجاني)
- 11 نوع مستند: الفواتير، بطاقات العمل، الإيصالات، الجداول، العقود، بطاقات الهوية، جوازات السفر، كشوف الحساب، رخص القيادة، النماذج الضريبية، عام
- إنشاء PDF قابلة للبحث مع طبقة نص حقيقية
- معالجة دفعات (Batch)
- مخرجات جاهزة للعامل ( `agent_prompt` )

## 🚀 البدء السريع

```bash
# تثبيت المتطلبات
pip3 install -r scripts/requirements.txt
apt-get install poppler-utils tesseract-ocr tesseract-ocr-chi-sim

# ضبط البيئة
export PADDLEOCR_DOC_PARSING_API_URL=https://...
export PADDLEOCR_ACCESS_TOKEN=...
# أو
export OCR_BACKEND=tesseract
export TESSERACT_LANG=chi_sim+eng

# التشغيل
python3 scripts/doc_vision.py --file-path فاتورة.jpg --pretty
```

## 📤 مثال الإخراج

النتيجة JSON تحتوي على:
- `document_type`
- `suggested_actions`
- `agent_prompt` (جاهز للLLM)
- `searchable_pdf` عند استخدام `--make-searchable-pdf`

## 🔧 استكشاف الأخطاء

- إذا ظهر خطأ في استيراد الوحدات: راجع تثبيت المتطلبات.
- خطأ 403 من PaddleOCR: تحقق من صحة الرابط والتوكن.
- فشل إنشاء PDF قابلة للبحث: تأكد من تثبيت `reportlab` و `pypdf` و `poppler`.

## 📚 الوثائق الكاملة

انظر [SKILL.md](SKILL.md) للتفاصيل.

**صُنع لـ OpenClaw.**

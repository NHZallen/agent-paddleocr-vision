# Agent PaddleOCR Vision — OCR con Acciones (solo PaddleOCR)

Convierte documentos en instrucciones accionables para tu IA. Usa únicamente PaddleOCR en la nube.

## Características

- OCR con PaddleOCR (alta precisión)
- 11 tipos de documentos
- Generación de PDF buscable
- Procesamiento por lotes
- Salida `agent_prompt` lista para LLM

## Instalación

```bash
pip3 install -r scripts/requirements.txt
# Sistema: poppler-utils
```

## Configuración

```bash
export PADDLEOCR_DOC_PARSING_API_URL=https://tu-api.com/layout-parsing
export PADDLEOCR_ACCESS_TOKEN=tu_token
```

## Uso

```bash
python3 scripts/doc_vision.py --file-path factura.jpg --pretty --make-searchable-pdf
python3 scripts/doc_vision.py --batch-dir ./entrada --output-dir ./salida
```

## Tipos de Documentos

| Tipo | Acciones |
|------|----------|
| Factura | create_expense, archive, tax_report |
| Tarjeta de visita | add_contact, save_vcard |
| Recibo | create_expense, split_bill |
| Tabla | export_csv, analyze_data |
| Contrato | summarize, extract_dates, flag_obligations |
| DNI | extract_id_info, verify_age |
| Pasaporte | store_passport_info, check_validity |
| Estado de cuenta | categorize_transactions, generate_report |
| Licencia de conducir | store_license_info, check_expiry |
| Formulario fiscal | summarize_tax, suggest_deductions |
| General | summarize, translate, search_keywords |

## PDF Buscable

`--make-searchable-pdf` crea una capa de texto seleccionable usando bounding boxes de PaddleOCR.

## Licencia

MIT-0
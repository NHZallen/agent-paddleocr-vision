# Agent Vision — OCR con Acciones para Agentes

**Convierte documentos en instrucciones accionables para tu IA.** Detecta automáticamente el tipo de documento y proporciona sugerencias listas para usar.

## 🌟 Características

- Múltiples motores OCR: PaddleOCR en la nube o Tesseract offline (gratuito)
- 11 tipos de documentos: facturas, tarjetas de visita, recibos, tablas, contratos, DNI, pasaportes, estados de cuenta, licencias de conducir, formularios fiscales, general
- Generación de PDF buscable con capa de texto real
- Procesamiento por lotes
- Salida `agent_prompt` lista para LLM

## 🚀 Inicio Rápido

```bash
# Instalar dependencias
pip3 install -r scripts/requirements.txt
apt-get install poppler-utils tesseract-ocr tesseract-ocr-chi-sim

# Configurar OCR (nube o local)
export PADDLEOCR_DOC_PARSING_API_URL=https://tu-api.com/layout-parsing
export PADDLEOCR_ACCESS_TOKEN=tu_token
# o
export OCR_BACKEND=tesseract
export TESSERACT_LANG=chi_sim+eng

# Ejecutar
python3 scripts/doc_vision.py --file-path factura.jpg --pretty
```

## 📤 Ejemplo de Salida JSON

```json
{
  "ok": true,
  "document_type": "invoice",
  "suggested_actions": [
    { "action": "create_expense", "description": "Registrar gasto", "parameters": { "amount": "1200" } }
  ],
  "agent_prompt": "You are a financial assistant..."
}
```

## 🔧 Troubleshooting

- `ModuleNotFoundError`: ejecute `pip3 install -r scripts/requirements.txt`
- Error 403 PaddleOCR: verifique URL y token
- PDF buscable no generado: instale `reportlab`, `pypdf`, `poppler-utils`

## 📚 Documentación Completa

Consulte [SKILL.md](SKILL.md) para más detalles.

**Hecho para OpenClaw.**

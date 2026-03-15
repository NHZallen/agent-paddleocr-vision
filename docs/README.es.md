# Agent PaddleOCR Vision — OCR con Acciones para Agentes

Convierte documentos en instrucciones que tu IA puede ejecutar. Utiliza únicamente PaddleOCR en la nube.

## Características

- OCR en la nube con PaddleOCR (alta precisión, soporta tablas y fórmulas)
- Clasificación automática en 11 tipos de documentos
- Sugerencias de acciones con parámetros estructurados
- Procesamiento por lotes (batch)
- Generación de PDF con capa de texto seleccionable
- `agent_prompt` listo para integrar en LLM

## Instalación

### Dependencias del sistema

Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install -y python3 python3-pip poppler-utils
```

macOS:

```bash
brew install python poppler
```

### Paquetes Python

```bash
cd skills/agent-paddleocr-vision
pip3 install -r scripts/requirements.txt
```

### Configuración

Variables de entorno obligatorias:

```bash
export PADDLEOCR_DOC_PARSING_API_URL=https://tu-api.com/layout-parsing
export PADDLEOCR_ACCESS_TOKEN=tu_token
```

## Uso

### Archivo único

```bash
python3 scripts/doc_vision.py --file-path factura.jpg --pretty
python3 scripts/doc_vision.py --file-path documento.pdf --make-searchable-pdf --output resultado.json
python3 scripts/doc_vision.py --file-path doc.pdf --format text
```

### Procesamiento por lotes

```bash
python3 scripts/doc_vision.py --batch-dir ./entrada --output-dir ./salida
```

### Docker

```bash
docker build -t agent-paddleocr-vision:latest .
docker run --rm -v $(pwd)/data:/data \
  -e PADDLEOCR_DOC_PARSING_API_URL -e PADDLEOCR_ACCESS_TOKEN \
  agent-paddleocr-vision:latest \
  --file-path /data/factura.jpg --pretty
```

## Formato de salida

Ver `docs/README.en.md` para el esquema JSON completo y ejemplos.

## Tipos de documentos y acciones

| Tipo | Acciones |
|------|----------|
| Factura (invoice) | create_expense, archive, tax_report |
| Tarjeta de visita (business_card) | add_contact, save_vcard |
| Recibo (receipt) | create_expense, split_bill |
| Tabla (table) | export_csv, analyze_data |
| Contrato (contract) | summarize, extract_dates, flag_obligations |
| ID (id_card) | extract_id_info, verify_age |
| Pasaporte (passport) | store_passport_info, check_validity |
| Estado de cuenta (bank_statement) | categorize_transactions, generate_report |
| Licencia de conducir (driver_license) | store_license_info, check_expiry |
| Formulario fiscal (tax_form) | summarize_tax, suggest_deductions |
| General | summarize, translate, search_keywords |

## PDF con capa de texto

`--make-searchable-pdf` crea un PDF con texto seleccionable usando las coordenadas de PaddleOCR. Requiere `poppler` en el sistema y los paquetes Python `reportlab`, `pypdf`, `pdf2image`.

## Solución de problemas

- **Error 403/404**: Verifica que la URL termine en `/layout-parsing` y que el token sea válido.
- **PDF no generado**: Comprueba que `poppler` esté instalado y que los paquetes Python estén presentes.
- **Baja calidad OCR**: Usa documentos con 300 DPI o más, buena iluminación.

## Licencia

MIT-0

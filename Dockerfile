# Agent PaddleOCR Vision — Docker Image
# Build: docker build -t agent-paddleocr-vision:latest .
# Run: docker run --rm -e PADDLEOCR_DOC_PARSING_API_URL -e PADDLEOCR_ACCESS_TOKEN agent-paddleocr-vision:latest --file-path /data/doc.pdf --pretty

FROM python:3.11-slim

# System dependencies (only poppler for pdf2image)
RUN apt-get update && apt-get install -y --no-install-recommends \
    poppler-utils \
    && rm -rf /var/lib/apt/lists/*

# Workdir
WORKDIR /app

# Copy requirements
COPY skills/agent-paddleocr-vision/scripts/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy skill files
COPY skills/agent-paddleocr-vision/scripts/ scripts/
COPY skills/agent-paddleocr-vision/templates/ templates/
COPY skills/agent-paddleocr-vision/SKILL.md .
COPY skills/agent-paddleocr-vision/docs/ docs/

ENTRYPOINT ["python3", "scripts/doc_vision.py"]
CMD ["--help"]
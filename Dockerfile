# Agent Vision — Docker Image
# Build: docker build -t agent-vision:latest .
# Run: docker run --rm -e PADDLEOCR_DOC_PARSING_API_URL=... -e PADDLEOCR_ACCESS_TOKEN=... agent-vision:latest --file-path /data/doc.pdf --pretty

FROM python:3.11-slim

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    tesseract-ocr \
    tesseract-ocr-chi-sim \
    tesseract-ocr-chi-tra \
    poppler-utils \
    && rm -rf /var/lib/apt/lists/*

# Workdir
WORKDIR /app

# Copy requirements first for better caching
COPY skills/agent-vision/scripts/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy skill files
COPY skills/agent-vision/scripts/ scripts/
COPY skills/agent-vision/templates/ templates/
COPY skills/agent-vision/SKILL.md .

# Entrypoint wrapper
ENTRYPOINT ["python3", "scripts/doc_vision.py"]

# Default to help
CMD ["--help"]

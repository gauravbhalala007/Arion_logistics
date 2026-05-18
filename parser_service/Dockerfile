# Dockerfile fuer Firebase Cloud Run (europe-west3)
# Parser-Service: PDF + XLSX → JSON (Scorecard, POD Quality, Concessions)
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PORT=8080

WORKDIR /app

# System-Dependencies fuer pdfplumber + pandas
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py .

# Cloud Run setzt $PORT zur Laufzeit — uvicorn nimmt es entgegen.
CMD exec uvicorn app:app --host 0.0.0.0 --port ${PORT}

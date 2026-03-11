FROM python:3.11-slim

LABEL author="Jimmy John" \
      project="Saffron and Sage Reservations" \
      version="1.0"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV FLASK_ENV=production \
    PORT=5000 \
    DB_HOST=db \
    DB_PORT=5432 \
    DB_NAME=restaurant \
    DB_USER=postgres \
    DB_PASS=secret

RUN useradd -m flaskuser && \
    chown -R flaskuser:flaskuser /app

USER flaskuser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=10s \
    CMD curl -f http://localhost:5000/health || exit 1

CMD ["python", "app.py"]

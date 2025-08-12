# ---- 1) Build stage: compile wheels so the final image doesn't need build tools
FROM python:3.12-slim AS builder

ENV PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# System deps needed only to build wheels (kept out of final image)
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential gcc && \
    rm -rf /var/lib/apt/lists/*

# Leverage Docker cache: copy only requirements first
COPY requirements.txt .
RUN python -m pip install --upgrade pip setuptools wheel && \
    pip wheel --no-deps --wheel-dir /wheels -r requirements.txt

# ---- 2) Runtime stage: minimal, no compilers/tools
FROM python:3.12-slim AS runtime

ENV PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH="/app"

# Optional tini for proper signal handling (tiny footprint)
RUN apt-get update && \
    apt-get install -y --no-install-recommends tini && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd --create-home --shell /bin/bash appuser
WORKDIR /app

# Copy prebuilt wheels + requirements and install offline
COPY --from=builder /wheels /wheels
COPY requirements.txt .
RUN pip install --no-index --find-links=/wheels -r requirements.txt && \
    rm -rf /wheels

# Copy application code (after deps for better caching)
COPY --chown=appuser:appuser . .

USER appuser
EXPOSE 8000

# Use gunicorn with uvicorn worker for prod
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "main:app", "--bind", "0.0.0.0:8000", "--workers", "2", "--threads", "8", "--timeout", "60"]

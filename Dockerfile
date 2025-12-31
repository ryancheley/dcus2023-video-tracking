# Build stage
FROM python:3.14-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy project files
COPY pyproject.toml requirements.txt* ./

# Install dependencies
RUN pip install --user --no-cache-dir -r requirements.txt 2>/dev/null || \
    pip install --user --no-cache-dir -e .

# Production stage
FROM python:3.14-slim

WORKDIR /app

# Copy Python packages from builder to app directory
COPY --from=builder /root/.local /app/.local

# Copy application code and database
COPY program.py .
RUN mkdir -p /app/data && cp views.db* /app/data/ 2>/dev/null || true

# Create non-root user
RUN useradd -m appuser && chown -R appuser:appuser /app

# Update PATH and PYTHONPATH to use installed packages
ENV PATH=/app/.local/bin:$PATH
ENV PYTHONPATH=/app/.local/lib/python3.14/site-packages:$PYTHONPATH
ENV PYTHONUNBUFFERED=1

# Switch to non-root user
USER appuser

# Expose datasette port
EXPOSE 8001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD ["/app/.local/bin/datasette", "/app/data/views.db"]

# Start datasette
CMD ["/app/.local/bin/datasette", "/app/data/views.db", "-h", "0.0.0.0", "-p", "8001"]

# Stage 1: Build frontend assets with Bun
FROM oven/bun:1-alpine AS frontend-builder

WORKDIR /frontend

# Copy package files
COPY package.json bun.lock ./

# Install dependencies
RUN bun install --frozen-lockfile

# Copy frontend source files
COPY vite.config.js ./
COPY assets ./assets

# Build frontend assets
RUN bun run build

# Stage 2: Python application
FROM python:3.12-alpine3.21

ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /code

# Install system dependencies (including wget for healthcheck)
RUN apk add --no-cache \
    gcc \
    musl-dev \
    postgresql-dev \
    wget

# Copy Python dependency files
COPY pyproject.toml uv.lock ./

# Install uv and Python dependencies
RUN pip install --upgrade pip uv && \
    uv pip install --system --no-cache -r pyproject.toml

# Copy entrypoint script
COPY entrypoint.prod.sh .
RUN chmod +x /code/entrypoint.prod.sh

# Copy application code
COPY . .

# Copy built frontend assets from frontend-builder stage
COPY --from=frontend-builder /frontend/static ./static

# Create necessary directories with proper permissions
RUN mkdir -p /code/db.sqlite3 \
    /code/static_root \
    /code/mediafiles \
    /code/dynamic && \
    chmod -R 755 /code

# Expose port for Coolify
EXPOSE 8000

ENTRYPOINT ["/code/entrypoint.prod.sh"]
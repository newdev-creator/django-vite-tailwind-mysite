FROM python:3.12-alpine3.21

ENV PIP_DISABLE_PIP_VERSION_CHECK 1
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /code

# Install system dependencies for Node.js and build tools
RUN apk add --no-cache \
    bash \
    build-base \
    gcc \
    git \
    libffi-dev \
    musl-dev \
    nodejs \
    npm \
    openssl-dev \
    postgresql-dev \
    python3-dev

# Copy entrypoint script first (before other files)
COPY entrypoint.prod.sh ./
RUN chmod +x /code/entrypoint.prod.sh

# Copy pyproject.toml for dependency installation
COPY pyproject.toml ./

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -e .

# Copy specific files and directories (excluding entrypoint to avoid overwrite)
COPY manage.py ./
COPY main.py ./
COPY project/ ./project/
COPY assets/ ./assets/
COPY static/ ./static/
COPY templates/ ./templates/
COPY package.json ./
COPY package-lock.json ./
COPY vite.config.js ./
COPY .env.production ./
COPY README.md ./
COPY LICENSE ./

# Install Node.js dependencies
RUN npm install

# Build Vite assets
RUN npm run build

# Verify entrypoint exists and is executable
RUN ls -la /code/entrypoint.prod.sh && echo "Entrypoint is ready"

ENTRYPOINT ["/code/entrypoint.prod.sh"]
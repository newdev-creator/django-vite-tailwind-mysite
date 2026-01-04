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

# Copy pyproject.toml for dependency installation
COPY pyproject.toml ./

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -e .

# Copy entrypoint script
COPY entrypoint.prod.sh .
RUN chmod +x /code/entrypoint.prod.sh

# Copy the rest of the application
COPY . .

# Install Node.js dependencies
RUN npm install

# Build Vite assets
RUN npm run build

ENTRYPOINT ["/code/entrypoint.prod.sh"]
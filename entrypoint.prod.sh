#!/bin/sh

set -e

echo "========================================"
echo "Starting Django Vite App - Coolify"
echo "========================================"

# Create necessary directories
echo "Creating directories..."
mkdir -p /code/data /code/staticfiles /code/mediafiles /code/dynamic

# Set proper permissions for database directory
echo "Setting permissions..."
chmod -R 755 /code/data

# Wait for database if PostgreSQL is configured
if [ -n "$POSTGRES_HOST" ]; then
    echo "Waiting for PostgreSQL at $POSTGRES_HOST:$POSTGRES_PORT..."
    timeout=30
    while ! nc -z "$POSTGRES_HOST" "$POSTGRES_PORT" 2>/dev/null; do
        timeout=$((timeout - 1))
        if [ $timeout -le 0 ]; then
            echo "Warning: Database connection timeout. Continuing anyway..."
            break
        fi
        sleep 1
    done
    echo "Database connection ready!"
fi

# Run migrations
echo "Running database migrations..."
python manage.py migrate --noinput

# Collect static files (Vite assets already built and copied during Docker build)
echo "Collecting static files..."
python manage.py collectstatic --noinput --clear

# Compress static files if django-compressor is installed
if python -c "import compressor" 2>/dev/null; then
    echo "Compressing static files..."
    python manage.py compress --force
fi

# Generate Coolify proxy configuration if command exists
if python manage.py help generate_proxy_config >/dev/null 2>&1; then
    echo "Generating Coolify proxy configuration..."
    python manage.py generate_proxy_config
else
    echo "Proxy config generation command not found, skipping..."
fi

# Optional: Create superuser from environment variables
# Set DJANGO_SUPERUSER_USERNAME, DJANGO_SUPERUSER_EMAIL, DJANGO_SUPERUSER_PASSWORD in Coolify
if [ -n "$DJANGO_SUPERUSER_USERNAME" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ]; then
    echo "Checking for superuser..."
    python manage.py shell -c "
from django.contrib.auth import get_user_model;
User = get_user_model();
if not User.objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists():
    User.objects.create_superuser('$DJANGO_SUPERUSER_USERNAME', '${DJANGO_SUPERUSER_EMAIL:-admin@example.com}', '$DJANGO_SUPERUSER_PASSWORD');
    print('Superuser created successfully')
else:
    print('Superuser already exists')
" 2>/dev/null || echo "Superuser setup skipped"
fi

echo "========================================"
echo "Startup complete! 🚀"
echo "App running on port 8000"
echo "========================================"

# Execute the main command (gunicorn)
exec "$@"
#!/bin/sh

# Ensure directories exist
mkdir -p /code/staticfiles
mkdir -p /code/db
chmod -R 755 /code/staticfiles
chmod -R 755 /code/db

# Wait for database to be ready
echo 'Waiting for database to be ready...'
until nc -z -v -w30 db 5432; do
  echo 'Waiting for database connection...'
  sleep 5
done

echo 'Database is ready, running migrations...'
python manage.py migrate

echo 'Collecting static files...'
python manage.py collectstatic --noinput --clear

echo 'Building Vite assets...'
npm run build

# Copy Vite manifest to staticfiles directory for Django
cp -f static/manifest.json staticfiles/manifest.json

echo 'Starting Gunicorn...'
exec gunicorn --workers=3 project.wsgi:application --bind 0.0.0.0:8000
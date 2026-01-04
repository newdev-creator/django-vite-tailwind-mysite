#!/bin/sh

# Ensure directories exist
mkdir -p /code/staticfiles
mkdir -p /code/db
chmod -R 755 /code/staticfiles
chmod -R 755 /code/db

echo 'Running database migrations...'
python manage.py migrate

echo 'Collecting static files...'
python manage.py collectstatic --noinput --clear

echo 'Building Vite assets...'
npm run build

echo 'Starting application...'
exec "$@"
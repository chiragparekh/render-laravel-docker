#!/usr/bin/env sh
set -e

echo "Running composer"
composer install --no-dev --working-dir=/var/www/html

echo "Installing npm dependencies"
npm install

echo  "generating build"
npm run build

echo "Caching config..."
php artisan config:cache

echo "Caching routes..."
php artisan route:cache

echo "Running migrations..."
php artisan migrate --force

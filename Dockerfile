# Use an official PHP runtime as a parent image
FROM php:8.2-fpm-alpine

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apk add --no-cache \
    nginx \
    redis \
    git \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    oniguruma-dev \
    libxml2-dev \
    zip \
    unzip \
    postgresql-dev \
    supervisor

# Install Node.js (version 20.x in this example)
RUN curl -fsSL https://unofficial-builds.nodejs.org/download/release/v20.0.0/node-v20.0.0-linux-x64-musl.tar.xz | tar -xJf - -C /usr/local --strip-components=1

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install mbstring exif pcntl bcmath gd

RUN docker-php-ext-install pdo pdo_pgsql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Check and remove existing www-data user and group
RUN if id www-data; then deluser www-data; fi && \
    if getent group www-data; then delgroup www-data; fi

# Add www-data group and user with specific UID/GID
RUN addgroup -g 1000 www-data && \
    adduser -D -u 1000 -G www-data -s /bin/sh www-data

# Copy application code
COPY . /var/www/html

# Set permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Nginx configuration
COPY ./docker/nginx/conf.d/default.conf /etc/nginx/http.d/default.conf

COPY ./docker/entrypoint.sh /etc/entrypoint.sh

# Set permissions and ownership for www-data
RUN chown -R www-data:www-data /var/www/html

# Expose ports
EXPOSE 80 443

# Start Supervisor to run multiple services
ENTRYPOINT ["sh", "/etc/entrypoint.sh"]
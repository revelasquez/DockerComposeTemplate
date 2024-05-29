# Use PHP 8 FPM Alpine as base image
FROM php:8-fpm-alpine

# Arguments for UID and GID (default to 1000 if not provided)
ARG UID=1000
ARG GID=1000

# Ensure www-data user and group are replaced with laravel user and group
RUN sed -i "s/user = www-data/user = laravel/g" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i "s/group = www-data/group = laravel/g" /usr/local/etc/php-fpm.d/www.conf

# Install required PHP extensions and packages
RUN apk add --no-cache \
        postgresql-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql \
    && mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/5.3.4.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-install redis

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Create laravel user and group with specified UID and GID
RUN addgroup -g ${GID} --system laravel \
    && adduser -u ${UID} -G laravel --system -D -s /bin/sh laravel

# Set working directory
WORKDIR /var/www/html

# Change ownership of working directory to laravel user
RUN chown -R laravel:laravel /var/www/html

# Ensure Laravel user is used for subsequent commands
USER laravel

# Default command to start PHP-FPM
CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]

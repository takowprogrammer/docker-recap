# Multi-stage build for production-ready webapp
FROM php:8.4-apache as builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-install zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy composer files
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Production stage
FROM php:8.4-apache

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libzip4 \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod rewrite headers

# Copy PHP extensions from builder
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/

# Copy application code
COPY . /var/www/html/

# Copy Composer autoloader
COPY --from=builder /var/www/html/vendor/ /var/www/html/vendor/

# Create non-root user
RUN groupadd -r webuser && useradd -r -g webuser webuser

# Set proper permissions
RUN chown -R webuser:webuser /var/www/html
RUN chmod -R 755 /var/www/html

# Switch to non-root user
USER webuser

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health.php || exit 1

# Start Apache
CMD ["apache2-foreground"]

# Use the official PHP image with Apache
FROM php:7.4-apache

# Copy the website files to the Apache document root
COPY . /var/www/html/

# Enable the PHP module for making HTTP requests
RUN docker-php-ext-install pdo pdo_mysql
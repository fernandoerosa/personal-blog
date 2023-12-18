#!/bin/bash

php composer.phar update && \
    chown -R www-data:www-data /var/www/storage && \
    npm i && \
    php artisan migrate && \
    php artisan storage:link && \
    php-fpm

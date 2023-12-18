FROM php:7.4-fpm

# Instala os pacotes necessários
RUN apt-get update && \
    apt-get install -y \
    git \
    nodejs \
    npm \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    wkhtmltopdf \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) \
    gd \
    mysqli \
    pdo \
    pdo_mysql \
    mbstring \
    zip \
    exif \
    pcntl \
    bcmath \
    sockets

RUN yes | pecl install xdebug-2.9.0 \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini

# Define o diretório de trabalho
WORKDIR /var/www

# Copia os arquivos necessários para a imagem
COPY . .

# Copia o arquivo de configuração Nginx
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# Limpa o cache do sistema
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN touch /var/www/storage/logs/laravel.log

# Define as permissões dos arquivos
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap /var/www/storage/logs/laravel.log

RUN chown -R 777 /var/www/storage

RUN chmod -R 777 /var/www/storage

# Expose port 9000 and start php-fpm server
EXPOSE 9000

# Inicia o servidor PHP-FPM
ENTRYPOINT ["sh",  "./docker/entrypoint.sh"]

# Define a imagem base
ARG ALPINE_VERSION=3.14

FROM alpine:${ALPINE_VERSION}
LABEL Maintainer="Fernando Rosa"
LABEL Description="Lightweight container with Nginx 1.24 & PHP 8.2 based on Alpine Linux."

# Setup document root
WORKDIR /var/www

# Install packages and remove default server definition
RUN apk add --no-cache \
  openjdk11 \
  curl \
  nginx \
  php7 \
  php7-ctype \
  php7-curl \
  php7-dom \
  php7-fpm \
  php7-gd \
  php7-intl \
  php7-mbstring \
  php7-mysqli \
  php7-opcache \
  php7-openssl \
  php7-phar \
  php7-session \
  php7-xml \
  php7-xmlreader \
  php7-fileinfo \
  php7-simplexml \
  php7-xmlwriter \
  php7-zip \
  php7-tokenizer \
  postgresql-dev \
  php7-pdo \
  php7-pdo_pgsql \
  php7-json \
  php7-exif \
  supervisor

# Configure nginx - http
COPY docker/nginx.conf /etc/nginx/nginx.conf
# Configure nginx - default server
COPY docker/conf.d /etc/nginx/conf.d/

# Configure PHP-FPM
ENV PHP_INI_DIR /etc/php7
COPY docker/fpm-pool.conf ${PHP_INI_DIR}/php-fpm.d/www.conf
COPY docker/php.ini ${PHP_INI_DIR}/conf.d/custom.ini

# Configure supervisord
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /var/www /run /var/lib/nginx /var/log/nginx

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping

COPY . /var/www/

RUN chown -R nobody.nobody  /var/www/storage
RUN chown -R nobody.nobody  /var/www/
RUN chmod -R 775 /var/www/storage
RUN chmod -R 775 /var/www/

# Instala as dependências do projeto usando o composer.phar
RUN php composer.phar update --no-interaction

# Define a porta que o container deve expor
EXPOSE 8080

USER nobody

# Executa o servidor PHP-FPM
ENTRYPOINT ["sh",  "/var/www/docker/entrypoint.sh"]

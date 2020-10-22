ARG PHP_VERSION=7.4
ARG ALPINE_VERSION=3.12
ARG SYMFONY_SKIP_REGISTRATION=1
FROM php:${PHP_VERSION}-fpm-alpine${ALPINE_VERSION}

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    TERM="xterm" \
    DEBIAN_FRONTEND="noninteractive" \
    COMPOSER_ALLOW_SUPERUSER=1

RUN apk add --no-cache oniguruma-dev libzip-dev bash wkhtmltopdf rabbitmq-c rabbitmq-c-dev

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY etc/php.ini /usr/local/etc/php/php.ini

RUN apk add --update && \
        apk add --no-cache --virtual .build-deps \
        vim \
        curl \
        tzdata \
        wget \
        libxml2 \
        zlib \
        libpng \
        libmcrypt \
        unzip \
        oniguruma-dev \
        libzip-dev \
        bash \
        wkhtmltopdf \
        rabbitmq-c \
        rabbitmq-c-dev && \
    apk del .build-deps

RUN buildDeps=" build-base re2c file readline-dev autoconf binutils bison \
        libxml2-dev curl-dev freetype-dev openssl-dev \
        libjpeg-turbo-dev libpng-dev libwebp-dev libmcrypt-dev \
        gmp-dev icu-dev libmemcached-dev linux-headers" \
    && apk --update add $buildDeps

RUN printf "yes\n" | pecl install amqp mcrypt

# Install php extensions
RUN docker-php-ext-install -j$(nproc) iconv mbstring xml zip soap sockets && \
    docker-php-ext-configure gd && \
    docker-php-ext-enable amqp mcrypt mongodb

# Symfony CLI
RUN wget https://get.symfony.com/cli/installer -O - | bash && \
  mv /root/.symfony/bin/symfony /usr/local/bin/symfony


WORKDIR /var/www/html

ENTRYPOINT ["bash", "/var/www/scripts/message_script.sh"]

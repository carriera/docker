ARG PHP_VERSION=7.2
ARG ALPINE_VERSION=3.7
FROM php:${PHP_VERSION}-fpm-alpine${ALPINE_VERSION}

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    TERM="xterm" \
    DEBIAN_FRONTEND="noninteractive" \
    COMPOSER_ALLOW_SUPERUSER=1

RUN apk add --no-cache git

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY php/php.ini /usr/local/etc/php/php.ini

WORKDIR /var/www/symfony

# Prevent Symfony Flex from generating a project ID at build time
ARG SYMFONY_SKIP_REGISTRATION=1

RUN apk add --update && \
        apk add --no-cache --virtual .build-deps \
        cron \
        curl \
        nano \
        git \
        php-apcu \
        php-uuid \
        redis-server \
        supervisor \
        tzdata \
        wget \
        unzip \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        zlib1g-dev \
        wkhtmltopdf && \

    apk del .build-deps \

    cp /usr/share/zoneinfo/Europe/Warsaw /etc/localtime && echo "Europe/Warsaw" > /etc/timezone && \

    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install php extensions
RUN apt-get install -y \
    && docker-php-ext-install -j$(nproc) iconv mbstring pdo_mysql soap zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

COPY . ./

RUN mkdir -p var/cache var/logs var/sessions \
	&& composer dump-autoload --classmap-authoritative --no-dev \
	&& chown -R www-data var

COPY /php/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

# Install phpunit
RUN wget https://phar.phpunit.de/phpunit-6.8.phar \
    && chmod +x phpunit-6.8.phar \
    && mv phpunit-6.8.phar /usr/local/bin/phpunit

RUN rm -rf /var/cache/apk/* && rm -rf /tmp/*

WORKDIR /var/www/symfony

ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]

EXPOSE 9000

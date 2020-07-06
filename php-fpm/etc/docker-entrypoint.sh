#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

if [ "$1" = 'php-fpm' ] || [ "$1" = 'bin/console' ]; then
	if [ "$APP_ENV" != 'prod' ]; then
		adduser -S -D -H _www && addgroup -S _www && mkdir var/log && mkdir -p var/cache/dev && touch var/log/dev.log && chown -R _www:_www var
		[ -f .messenger_enabled ] && symfony run -d --watch=config,src,templates,vendor symfony console messenger:consume async
		symfony serve --allow-http --no-tls --port=8000
	else
		composer install --prefer-dist --no-progress --no-suggest --no-interaction
		php bin/console assets:install
		php bin/console doctrine:schema:update -f
		[ -f .messenger_enabled ] && symfony run -d --watch=config,src,templates,vendor symfony console messenger:consume async
		[ -f .crontab ] && crontab .crontab && crond -f -L /dev/stdout &
		chown -R www-data var
		exec docker-php-entrypoint "$@" 
	fi
fi

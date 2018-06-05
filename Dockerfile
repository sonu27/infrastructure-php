FROM php:7.2.6-fpm-alpine3.7

ENV COMPOSER_DISABLE_XDEBUG_WARN=1 COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_NO_INTERACTION=1

COPY ./zz-override.ini $PHP_INI_DIR/conf.d/
COPY ./install.sh /

RUN sh /install.sh && rm /install.sh

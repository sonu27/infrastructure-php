#!/usr/bin/env sh
set -ex

# dependencies required for building
apk --no-cache add --virtual build-dependencies \
    build-base \
    autoconf \
    zlib-dev \
    libmemcached-dev \
    cyrus-sasl-dev \
    file \
    libtool \
    pcre-dev

# dependencies for general use
apk --no-cache add \
    bash \
    git \
    zlib \
    libmemcached \
    pcre \
    make \
    sed \
    icu-dev

# compilation optimisations and no debug symbols
export CFLAGS="-O2 -g"

# install php extensions
docker-php-ext-install \
    pdo \
    pdo_mysql \
    opcache \
    intl

# compile custom php extensions
pecl install xdebug
pecl install igbinary
pecl install msgpack
pecl install ds

# make sure these are loaded before everything else
docker-php-ext-enable --ini-name 00-igbinary.ini igbinary
docker-php-ext-enable --ini-name 00-msgpack.ini msgpack
docker-php-ext-enable ds

# enable igbinary for Redis; unfortunately, PECL sucks at unattended installations
pecl bundle -d /tmp redis
docker-php-ext-configure /tmp/redis --enable-redis-igbinary
docker-php-ext-install /tmp/redis

# enable igbinary and msgpack for Memcached (same as above)
pecl bundle -d /tmp memcached
docker-php-ext-configure /tmp/memcached --enable-memcached-igbinary \
    --enable-memcached-msgpack \
    --enable-memcached-json \
    --disable-memcached-sasl
docker-php-ext-install /tmp/memcached

# delete build dependencies
docker-php-source delete
apk del --no-cache .phpize-deps-configure || true
apk del --no-cache .phpize-deps || true
apk del --no-cache build-dependencies || true

# install composer
curl -L -o /usr/local/bin/composer https://getcomposer.org/composer.phar
chmod +x /usr/local/bin/composer

# disable access log
sed -i '/access.log/d' /usr/local/etc/php-fpm.d/docker.conf

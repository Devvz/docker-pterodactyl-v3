FROM php:7.0-fpm

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libxml2-dev \
        libcurl4-openssl-dev \
        supervisor \
        unzip \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd opcache pdo mbstring tokenizer bcmath \
    && ln -s /usr/bin/php70 /usr/bin/php \
    && ln -s /usr/bin/php70-phar /usr/bin/php-phar

WORKDIR /var/www/pterodactyl/html

RUN curl -Lo v0.5.5.tar.gz https://github.com/Pterodactyl/Panel/archive/v0.5.5.tar.gz \
    && tar --strip-components=1 -xzvf v0.5.5.tar.gz \
    && rm v0.5.5.tar.gz \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer install --ansi --no-dev \
    && mkdir -p /var/www/pterodactyl/logs \
    && useradd -ms /bin/bash nginx \
    && chown -R nginx:nginx *

# The HTML directory was created in the pterodactyl folder. Should this be /var/www/pterodactyl/html instead?
ENTRYPOINT ["/var/www/html/entrypoint.sh"]

CMD ["supervisord", "-n"]

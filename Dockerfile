FROM php:8.2-apache

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        libpng-dev \
        libzip-dev \
        npm \
        locales \
        sudo \
        unzip \
        vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo "ja_JP.UTF-8 UTF-8" >/etc/locale.gen \
    && locale-gen

RUN docker-php-ext-install bcmath gd mysqli pdo pdo_mysql zip
RUN pecl install xdebug && docker-php-ext-enable xdebug && pecl install redis-5.3.4 && \
    docker-php-ext-enable redis

RUN adduser --disabled-password --gecos '' laravel \
    && adduser laravel sudo \
    && adduser laravel www-data \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN sed -ri -e 's!/var/www/html!/home/laravel/project/public!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!/home/laravel/project/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

COPY ./infra/docker/000-default.conf /etc/apache2/sites-available/000-default.conf

RUN a2enmod rewrite headers

COPY ./infra/docker/php/php.ini-xdebug "$PHP_INI_DIR/php.ini-xdebug"
RUN cat "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini-xdebug" > "$PHP_INI_DIR/php.ini"

COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer

COPY ./backend /var/www/project

WORKDIR /var/www/project

RUN sudo npm install -g n
RUN sudo n stable

RUN [ ! -d "node_modules" ] && npm install
RUN [ ! -d "vendor" ] && composer install

RUN grep -q '^APP_KEY=$' .env && php artisan key:generate

RUN chmod -R a+x node_modules

RUN npm run prod

RUN sudo find . -type f -exec chmod 664 {} \;
RUN sudo find . -type d -exec chmod 775 {} \;

RUN sudo chgrp -R www-data storage bootstrap/cache
RUN sudo chmod -R ug+rwx storage bootstrap/cache
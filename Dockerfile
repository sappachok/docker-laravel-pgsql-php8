FROM php:8.1.19-fpm
LABEL maintainer "Sappachok Singhasuwan <suppachok_sin@nstru.ac.th>"

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
        libz-dev \
        libpq-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libssl-dev \
        libmcrypt-dev \
        zlib1g-dev \
        libxml2-dev \
        libonig-dev \
        zip \
        curl \
        libmemcached-dev \
        build-essential \
        libaio1 \
        libzip-dev \
    && docker-php-ext-configure gd \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install zip \
    && docker-php-source delete \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql

RUN docker-php-ext-enable opcache

# install & enable memcached

# RUN pecl install memcached-3.1.5 && docker-php-ext-enable memcached

# copy dev php.ini

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN php -v

RUN ldconfig -v

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- \
        --install-dir=/usr/local/bin \
        --filename=composer


#RUN a2ensite default-ssl
#RUN a2enmod ssl
#RUN a2enmod rewrite

WORKDIR /var/www

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Add user for laravel application
#RUN groupadd -g 1000 www

RUN useradd -G www-data,root -u 1000 -d /var/www www

#RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
#COPY . /var/www

# Copy existing application directory permissions
#COPY --chown=www:www . /var/www

RUN mkdir -p /var/www/.composer
RUN chown -R www:www /var/www

# Change current user to www
USER www

EXPOSE 9000
#EXPOSE 8000

CMD ["php-fpm"]
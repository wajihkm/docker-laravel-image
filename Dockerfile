FROM php:8-apache

# SSL setup

RUN openssl req -x509 -nodes -days 999 -newkey rsa:2048 \
    -keyout /etc/ssl/private/cert-selfsigned.key \
    -out /etc/ssl/certs/cert-selfsigned.crt \
    -subj "/C=AE/ST=Dubai/L=Dubai/O=Local Company/OU=Web Apps/CN=localhost/"

COPY ./assets/sites/default-ssl.conf /etc/apache2/sites-available/

# SSL Setup

# Server setup

RUN apt update && apt install -y \
    git zip unzip wget \
    libzip-dev \
    libpng-dev libjpeg-dev libfreetype6-dev libjpeg62-turbo-dev \
    libbz2-dev \
    libicu-dev \
    libxml2-dev libxslt-dev \
    libsodium-dev

# Server setup

# PHP extensions setup

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure opcache --enable-opcache

RUN docker-php-ext-install -j$(nproc) \
    bcmath \
    bz2 \
    gd \
    intl \
    pdo_mysql \
    opcache \
    soap \
    sockets \
    sodium \
    simplexml \
    xsl \
    zip \
    mysqli \
    exif

RUN docker-php-ext-enable \
    bcmath \
    bz2 \
    gd \
    intl \
    pdo_mysql \
    opcache \
    soap \
    sockets \
    sodium \
    simplexml \
    xsl \
    zip \
    mysqli \
    exif

# PHP extensions setup

# Install xDebug

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

RUN cat > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini <<EOF
xdebug.mode=debug
xdebug.start_with_request=yes
xdebug.client_port=9003
EOF

# Install xDebug

# Apache Server setup

RUN cd /etc/apache2/sites-available \
    && a2enmod ssl \
    && a2enmod rewrite \
    && a2ensite default-ssl \
    && service apache2 restart

# Apache Server setup

# Composer installtion
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer


# Website take over

WORKDIR /var/www/html/

RUN mkdir public

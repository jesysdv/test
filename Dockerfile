FROM alpine:3.15 AS drupal-base
LABEL Maintainer="Luis Villamil <luis.villamil@nivelics.co>" \
    Description="Lightweight container with Nginx 1.18 & PHP-FPM 7 based on Alpine Linux."

ARG PHP_VERSION="7.4.15-r0"
ARG ENVIRONMENT_NAME="local"
RUN echo $ENVIRONMENT_NAME

# Install packages and remove default server definition
RUN apk --no-cache add php7>${PHP_VERSION} \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-exif \
    php7-fileinfo \
    php7-fpm \
    php7-gd \
    php7-iconv \
    php7-intl \
    php7-mbstring \
    php7-mysqli \
    php7-opcache \
    php7-openssl \
    php7-pecl-imagick \
    php7-pecl-redis \
    php7-pecl-apcu \
    php7-phar \
    php7-session \
    php7-simplexml \
    php7-soap \
    php7-xml \
    php7-xmlreader \
    php7-zip \
    php7-zlib \
    php7-pdo \
    php7-xmlwriter \
    php7-tokenizer \
    php7-pdo_mysql \
    php7-ldap libldap php-ldap  openldap-clients openldap openldap-back-mdb \
    nginx nginx-mod-http-headers-more nginx-mod-http-cache-purge supervisor curl tzdata htop mysql-client dcron \
    gnupg unixodbc-dev git imagemagick-libs patch

# Install PHP tools
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Install Drush
RUN composer --no-interaction --no-progress --ansi global require drush/drush && \
    composer --no-interaction --no-progress --ansi global update

# Setup document root
RUN mkdir -p /opt/drupal/web
RUN mkdir /.composer/

WORKDIR /opt/drupal/web
RUN set -eux; \
    export COMPOSER_HOME="$(mktemp -d)";

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /opt/drupal && \
    chown -R nobody.nobody /run && \
    chown -R nobody.nobody /.composer && \
    chown -R nobody.nobody /var/www && \
    chown -R nobody.nobody /var/lib/nginx && \
    chown -R nobody.nobody /var/log/nginx

# Switch to use a non-root user from here on
USER nobody
WORKDIR /opt/drupal/web

RUN mkdir -p /opt/drupal/web/sites/default/files  &&  \
    mkdir -p /opt/drupal/web/vendor &&  \
    mkdir -p /opt/drupal/docker/config/sync &&  \
    touch /opt/drupal/web/sites/default/files/dummy.txt  && \
    chmod -R 775 /opt/drupal/web/sites/default/files

ENV PATH="/opt/drupal/web/vendor/bin:/opt/drupal/vendor/bin:${PATH}":

RUN chown -R nobody:nobody /opt/drupal/web

RUN find . -type d -exec chmod u=rwx,g=rx,o= '{}' \;
RUN find . -type f -exec chmod u=rw,g=r,o= '{}' \;
RUN chmod -R 777 /opt/drupal/web/sites/default/files
# RUN chmod +x vendor/bin/drush

# Expose the port nginx is reachable on
EXPOSE 8080

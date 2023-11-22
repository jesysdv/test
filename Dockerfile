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

#RUN rm /etc/nginx/conf.d/default.conf

# Symlink php7 => php
#RUN ln -s /usr/bin/php7 /usr/bin/php

# Install PHP tools
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Install Drush
RUN composer --no-interaction --no-progress --ansi global require drush/drush && \
    composer --no-interaction --no-progress --ansi global update

# Configure nginx
COPY docker/config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY docker/config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY docker/config/php.ini /etc/php7/conf.d/custom.ini

# Configure supervisord
COPY docker/config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

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

# TODO: REVISAR ESTO
COPY --chown=nobody:nobody src/ /opt/drupal/web/

# TODO: DOCKERIGNORE -> NO COPIAR EL VENDOR
RUN mkdir -p /opt/drupal/web/sites/default/files  &&  \
    mkdir -p /opt/drupal/web/vendor &&  \
    mkdir -p /opt/drupal/docker/config/sync &&  \
    touch /opt/drupal/web/sites/default/files/dummy.txt  && \
    chmod -R 775 /opt/drupal/web/sites/default/files

# RUN composer --no-interaction --no-progress --ansi install

ENV PATH="/opt/drupal/web/vendor/bin:/opt/drupal/vendor/bin:${PATH}":

# COPY --chown=nobody:nobody src/citytv/docker/config/sync /opt/drupal/docker/config/sync/

# COPY --chown=nobody:nobody src/docker/config/sites.php /opt/drupal/web/sites/sites.php
COPY --chown=nobody:nobody docker/drupal/settings.php /opt/drupal/web/sites/default/settings.php
# COPY --chown=nobody:nobody docker/config/multisite_settings.php /opt/drupal/web/sites/default/settings.php

RUN chown -R nobody:nobody /opt/drupal/web

RUN find . -type d -exec chmod u=rwx,g=rx,o= '{}' \;
RUN find . -type f -exec chmod u=rw,g=r,o= '{}' \;
RUN chmod +x vendor/bin/drush

# COPY --chown=nobody:nobody extras/scripts/ vendor/bin/
# RUN chmod +x vendor/bin/config_sync.sh

# COPY --chown=nobody:nobody src/root .

RUN chmod -R 777 /opt/drupal/web/sites/default/files

# Date
RUN date > build-date.txt

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
# HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:80/fpm-ping
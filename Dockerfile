FROM alpine:latest

# Essentials
RUN echo "UTC" > /etc/timezone
RUN apk add --no-cache zip unzip curl sqlite nginx supervisor

# Installing PHP
RUN apk add --no-cache php82 \
  php82-common \
  php82-intl \
  php82-fpm \
  php82-pdo \
  php82-opcache \
  php82-zip \
  php82-phar \
  php82-iconv \
  php82-cli \
  php82-curl \
  php82-openssl \
  php82-mbstring \
  php82-tokenizer \
  php82-fileinfo \
  php82-json \
  php82-xml \
  php82-xmlwriter \
  php82-simplexml \
  php82-dom \
  php82-tokenizer \
  php82-pecl-xdebug

RUN ln -s /usr/bin/php82 /usr/bin/php

# Create alias for php-fpm to ensure compatibility
RUN ln -s /usr/sbin/php-fpm82 /usr/sbin/php-fpm



# Installing composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm -rf composer-setup.php

# Configure supervisor
RUN mkdir -p /etc/supervisor.d/
COPY .docker/supervisord.ini /etc/supervisor.d/supervisord.ini

# Ensure php-fpm is correctly configured in supervisor
RUN printf "[program:php-fpm]\n\
command=/usr/sbin/php-fpm82 --nodaemonize --fpm-config /etc/php82/php-fpm.conf\n\
autostart=true\n\
autorestart=true\n\
stdout_logfile=/var/log/php-fpm.log\n\
stderr_logfile=/var/log/php-fpm.error.log\n" > /etc/supervisor.d/php-fpm.ini

# Configure PHP
RUN mkdir -p /run/php/
RUN touch /run/php/php8.2-fpm.pid

COPY .docker/php-fpm.conf /etc/php82/php-fpm.conf
COPY .docker/php.ini /etc/php82/php.ini

# Configure nginx
COPY .docker/nginx.conf /etc/nginx/

RUN mkdir -p /run/nginx/
RUN touch /run/nginx/nginx.pid

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# Building process
COPY .  /var/www/
# Instalar dependencias
#RUN cd /var/www/ && composer install;

WORKDIR /var/www/public

EXPOSE 80
EXPOSE 9000

CMD ["supervisord", "-c", "/etc/supervisor.d/supervisord.ini"]

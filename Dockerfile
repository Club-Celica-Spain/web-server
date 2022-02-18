ARG ALPINE_VERSION=3.14
FROM alpine:${ALPINE_VERSION}
LABEL Maintainer="github.com/xaabi6"
LABEL Description="Lightweight container with Nginx 1.20 & PHP 7.4 based on Alpine Linux."

# Install packages and remove default server definition
RUN apk add --no-cache \
	curl \
	nginx \
	php7 \
	php7-bcmath \
	php7-bz2 \
	php7-ctype \
	php7-curl \
	php7-pdo \
	php7-pdo_mysql \
	php7-dom \
	php7-exif \
	php7-fpm \
	php7-fileinfo \
	php7-gd \
	php7-gettext \
	php7-intl \
	php7-json \
	php7-mbstring \
	php7-mysqli \
	php7-opcache \
	php7-openssl \
	php7-phar \
	php7-session \
	php7-xml \
	php7-xmlreader \
	php7-zlib \
	supervisor \
	aspell

# Configure nginx
COPY ./config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY ./config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY ./config/php.ini /etc/php7/conf.d/custom.ini

# Configure supervisord
COPY ./config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root and temp files folders
RUN mkdir -p /srv/www/html \
	mkdir -p /tmp/session \
	mkdir -p /tmp/upload

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /srv/www/html /run /var/lib/nginx /var/log/nginx /tmp

# Switch to use a non-root user from here on
USER nobody

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping

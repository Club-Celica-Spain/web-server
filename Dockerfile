FROM alpine:3.8
LABEL Maintainer="github.com/xaabi6"
LABEL Description="Lightweight container with Nginx 1.14.2 & PHP 5.6.40 based on Alpine Linux."

# Install packages and remove default server definition
RUN apk --no-cache add \
	curl \
	nginx \
	php5 \
	php5-bcmath \
	php5-bz2 \
	php5-ctype \
	php5-curl \
	php5-pdo \
	php5-pdo_mysql \
	php5-dom \
	php5-exif \
	php5-fpm \
	php5-gd \
	php5-gettext \
	php5-intl \
	php5-json \
	php5-mysqli \
	php5-opcache \
	php5-openssl \
	php5-phar \
	php5-xml \
	php5-xmlreader \
	php5-zlib \
	supervisor \
	aspell

# Configure nginx
COPY ./config/nginx.conf /etc/nginx/nginx.conf
RUN rm /etc/nginx/conf.d/default.conf

# Configure PHP-FPM
COPY ./config/fpm-pool.conf /etc/php5/fpm.d/www.conf
COPY ./config/php.ini /etc/php5/conf.d/custom.ini

# Configure supervisord
COPY ./config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root and temp files folders
RUN mkdir -p /srv/www/html \
	mkdir -p /tmp/session \
	mkdir -p /tmp/upload

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /srv/www/html && \
	chown -R nobody.nobody /run && \
	chown -R nobody.nobody /var/lib/nginx && \
	chown -R nobody.nobody /var/log && \
	chown -R nobody.nobody /tmp

# Switch to use a non-root user from here on
USER nobody

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping

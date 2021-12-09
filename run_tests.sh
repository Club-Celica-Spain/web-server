#!/usr/bin/env sh
apk --no-cache add curl
curl --silent --fail http://nginx-php:8080 | grep 'PHP 7.4'

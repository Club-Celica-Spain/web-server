#!/bin/sh
# Options
NOW=$(date '+%F')
PATH=/srv/backup/www/
FILE=${PATH}backup-www_${NOW}.tar.gz

# Clean old files before generating a new one
find ${PATH} -mindepth 1 -mtime +7 -delete

cd /srv/www/
tar -zcf ${FILE} html

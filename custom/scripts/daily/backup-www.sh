#!/bin/sh
# Options
NOW=$(date '+%F')
FILE=/srv/backup/www/backup-www_${NOW}.tar.gz

cd /srv/www/
tar -zcf ${FILE} html

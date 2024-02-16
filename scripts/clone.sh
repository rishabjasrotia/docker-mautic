#!/bin/bash

printf "Clone Mautic for $1\n"
#composer install

printf "Copy local files $1\n"
cp ./local.config.base.php.dist ./config/local-$1.php
sed -i -e "s/MAUTIC_SUB_TENANT/$1/g" ./config/local-$1.php

# Temporrary swap the base local.php with new tenant-local.php
mv ./config/local.php ./config/local_bk.php
mv ./config/local-$1.php ./config/local.php

printf "Create Empty mautic_database_user $1\n"

mysql -h host.docker.internal -P 3306 --protocol=tcp -u root --password="$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $1";

#printf "MYSQL Dump Base Database mautic.sql\n"

#mysqldump --max-allowed-packet=1073741824 -h host.docker.internal -P 3306 --protocol=tcp -u root --password="$MYSQL_ROOT_PASSWORD" mautic > mautic.sql
#sed -i 's/GENERATED ALWAYS AS .* VIRTUAL/NOT NULL/' mautic.sql

#printf "Import Dump Base Database mautic.sql to $1\n"

#mysql -h host.docker.internal -P 3306 --protocol=tcp -u root --password="$MYSQL_ROOT_PASSWORD" $1 < mautic.sql;


#mysql -h host.docker.internal -P 3306 --protocol=tcp -u root --password="$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON $1.* TO '$MYSQL_USER'@'%'"

printf "Cache Rebuild Mautic\n"
./bin/console mautic:install "https://$1.mautic-test.com" -f
./bin/console cache:warmup --no-interaction --env=dev

# Fix the swap from tenant-local.php with to base local.php
mv ./config/local.php ./config/local-$1.php 
mv ./config/local_bk.php ./config/local.php

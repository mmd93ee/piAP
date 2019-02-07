#!/usr/bin/env bash

cd ~

# Check for old and delete if exist
if [ -e /var/lib/squidguard/db/blacklists ]
then
  rm -rf /var/lib/squidguard/db/blacklists
fi

# Download new blacklists
wget http://dsi.ut-capitole.fr/blacklists/download/blacklists.tar.gz
tar -zxvf blacklists.tar.gz
rm blacklists.tar.gz

# Apply new files
squidGuard -C all
chown -R proxy:proxy /var/lib/squidguard/db/

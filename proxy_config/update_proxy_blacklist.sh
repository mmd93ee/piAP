#!/usr/bin/env bash

cd ~

# Check for old and delete if exist
if [ -e /var/lib/squidguard/db/blacklists ]
then
  sudo rm -rf /var/lib/squidguard/db/blacklists
fi

# If we crashed out then the new download has a different name, check if we already have the download and remove it
if [ -e blacklists.tar.gz ]
then
  rm -f blacklists.tar.gz
fi

# Download new blacklists
wget http://dsi.ut-capitole.fr/blacklists/download/blacklists.tar.gz
tar -zxvf blacklists.tar.gz
rm blacklists.tar.gz
sudo mv -fv ./blacklists /var/lib/squidguard/db/

# Apply new files
sudo squidGuard -d -b -P -C all
sudo chown -R proxy:proxy /var/lib/squidguard/db/

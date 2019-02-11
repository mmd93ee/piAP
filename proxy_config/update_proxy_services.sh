#!/usr/bin/env bash
cd ~

# Proxy .pac file, mime.types and block page
echo "Updating pac, mime.types and block files..."
sudo cp -f ./piproxy/proxy_config/mime.types /etc/nginx/
sudo cp -f ./piproxy/proxy_config/proxy.pac /var/www/html/proxy.pac
sudo cp -f ./piproxy/proxy_config/block.html /var/www/html/block.html

# Squid Proxy Config File
sudo cp -f ./piproxy/proxy_config/squid.conf /etc/squid/squid.conf

# Update squidguard post updates, this takes some time...
if [ -e ./status/squidguard_updated ]
then
  echo "SquidGuard update not needed, skipping..."
else
  sudo cp -f ./piproxy/proxy_config/squidGuard.conf /etc/squidguard/squidGuard.conf
  sudo squidGuard -d -b -P -C all
  sudo chown -R proxy:proxy /var/lib/squidguard/db/
  touch ./status/squidguard_updated
fi

# nginx Config File
echo "Updating nginx config file..."
sudo cp -f ./piproxy/proxy_config/nginx.conf /etc/nginx/

# Fix file permissions
sudo chmod 0755 /var/www/html/proxy.pac
sudo chmod 0755 /var/www/html/block.html

# Copy the blacklist updater to cron.daily
echo "Updating cron.daily with proxy update script..."
sudo cp -f ./piproxy/proxy_config/update_proxy_blacklist.sh /etc/cron.daily/

# Set up Calamaris and Squid log chopper
if [ -e /var/lib/calamaris/reports/ ]
then
    echo "Calamaris report folder exists, not recreating..."
else
    sudo mkdir -p /var/lib/calamaris/reports/daily/previous
    sudo mkdir -p /var/lib/calamaris/reports/weekly/previous
    sudo mkdir -p /var/lib/calamaris/reports/monthly/previous
    sudo mkdir -p /var/lib/calamaris/cache
fi

#!/usr/bin/env bash
cd ~

# Proxy .pac file, mime.types and block page
echo "Updating pac, mime.types, squid.conf, squidguard.conf  and block files..."
sudo cp -f ./piproxy/proxy_config/mime.types /etc/nginx/
sudo cp -f ./piproxy/proxy_config/proxy.pac /var/www/html/
sudo cp -f ./piproxy/proxy_config/block.html /var/www/html/
sudo cp -f ./piproxy/proxy_config/squidGuard.conf /etc/squidguard/
sudo cp -f ./piproxy/proxy_config/squid.conf /etc/squid/
sudo cp -f ./piproxy/proxy_config/nginx.conf /etc/nginx/

# Fix file permissions
sudo chmod 0755 /var/www/html/proxy.pac
sudo chmod 0755 /var/www/html/block.html


# Update squidguard post updates, this takes some time...
if [ -e ./status/squidguard_updated ]
then
  echo "SquidGuard update not needed, skipping..."
else

  # Update DB
  ./piproxy/proxy_config/update_proxy_blacklist.sh

  # Fix permissions and then update DB
  sudo chown proxy:proxy /var/log/squidguard
  sudo chmod 0775 /var/log/squidguard/
  sudo chown -R proxy:proxy /var/lib/squidguard/db/

  sudo squidGuard -d -b -P -C all
  touch ./status/squidguard_updated
fi

# Copy the blacklist updater to cron.daily
echo "Updating cron.daily with proxy update script..."
sudo cp -f ./piproxy/proxy_config/update_proxy_blacklist.sh /etc/cron.daily/

# Set up Calamaris and Squid logs

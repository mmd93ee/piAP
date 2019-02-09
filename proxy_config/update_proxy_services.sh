#!/usr/bin/env bash
cd ~

# Proxy .pac file
sudo cp -f ./piproxy/proxy_config/proxy.pac /usr/share/nginx/html/proxy.pac
sudo cp -f ./piproxy/proxy_config/proxy.pac /var/www/html/proxy.pac
sudo cp -f ./piproxy/proxy_config/block.html /var/www/html/block.html
sudo chmod 0755 /usr/share/nginx/html/proxy.pac
sudo chmod 0755 /var/www/html/proxy.pac
sudo chmod 0755 /var/www/html/block.html

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


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
echo "Updating nginx config file amd adding lightsquid..."
sudo cp -f ./piproxy/proxy_config/nginx.conf /etc/nginx/
sudo cp -f ./piproy/proy_config/lightsquid /etc/nginx/sites-enabled/
sudo cp -f ./piproy/proy_config/lightsquid.cfg /etc/lightsquid/lightsquid.cfg

# LightSquid installation


# Fix file permissions
sudo chmod 0755 /var/www/html/proxy.pac
sudo chmod 0755 /var/www/html/block.html

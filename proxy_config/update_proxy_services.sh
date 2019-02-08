#!/usr/bin/env bash

# Proxy .pac file
sudo cp -f ./piproxy/proxy_config/proxy.pac /usr/share/nginx/html/proxy.pac
sudo chmod 0755 /usr/share/nginx/html/proxy.pac

# Squid Proxy and Guard Config File
sudo cp -f ./piproxy/proxy_config/squid.conf /etc/squid/squid.conf
sudo cp -f ./piproxy/proxy_config/squidGuard.conf /etc/squidguard/squidGuard.conf

# Update squidguard post updates
sudo squidGuard -d -b -P -C all
sudo chown -R proxy:proxy /var/lib/squidguard/db/


# nginx Config File


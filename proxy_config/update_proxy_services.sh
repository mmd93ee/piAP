#!/usr/bin/env bash

# Proxy .pac file
sudo cp -f ./piproxy/proxy_config/proxy.pac /usr/share/nginx/html/proxy.pac
sudo chmod 0755 /usr/share/nginx/html/proxy.pac

# Squid Proxy Config File
sudo cp -f ./piproxy/proxy_config/squid.conf /etc/squid/squid.conf

# nginx Config File


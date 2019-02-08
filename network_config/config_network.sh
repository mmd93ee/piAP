#!/usr/bin/env bash

# Set up the Pi routes to make sure it acts as a transparent router

# Update DNS, this should be on the router but this is good 'ol BT...

if [ -e ./status/dns_client_installed ]
then
  echo "DNS client IP updates set, skipping ddclient install..."
else
  sudo apt-get install -y ddclient
  touch ./status/dns_client_installed
fi

# Update resolv.conf anyway to allow remote fix
sudo cp ./piproxy/network_config/resolv.conf /etc/resolv.conf

#!/usr/bin/env bash
cd ~

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
sudo cp -f ./piproxy/network_config/resolv.conf /etc/resolv.conf

if [ -e ./status/network_updated ]
then
    echo "No need to update network at the moment..."
else
    sudo cat /etc/dhcpcd.conf ./piproxy/network_config/network_config > /etc/dhcpcd.conf
    touch ./status/network_updated
fi

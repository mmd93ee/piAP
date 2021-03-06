#!/usr/bin/env bash

# Script to install base packages and updates to vanilla Pi deployment
# Assumption is git is already installed :-)

# Update the OS and Install WittyPi2 and other base packages if not already installed.
cd ~

if [ -e ./status ]
then
  echo "Status folder exists, ignoring creating a new one..."
else
  mkdir status
fi

if [ -e ./status/os_updated ]
then
  echo "Initial OS update completed, skipping..."
else
  sudo apt-get -y update; sudo apt-get -y upgrade
  touch ./status/os_updated
fi

if [ -e ./status/witty_installed ]
then
  echo "WittyPi installed, skipping..."
else
  wget http://www.uugear.com/repo/WittyPi2/installWittyPi.sh
  sudo sh ./installWittyPi.sh
  sudo apt-get -y upgrade
  touch ./status/witty_installed
fi

if [ -e ./status/proxy_software_installed ]
then
  echo "SquidGuard, nginx, calamaris and goaccess installed, skipping..."
else
  sudo apt --fix-broken install -y
  sudo apt-get install -y squid squidguard nginx calamaris
  touch ./status/proxy_software_installed
fi

if [ -e ./status/post_install_reboot ]
then
  echo "Post install reboot occurred, skipping another one..."
else
  touch ./status/post_install_reboot
  wait
  shutdown -r 0
fi

# Update nginx, squid and calamaris configurations
echo "Updating nginx, calamaris and squid configuration..."
./piproxy/proxy_config/update_proxy_services.sh

# Apply blacklists
echo "Updating blacklist of websites..."
./piproxy/proxy_config/update_proxy_blacklist.sh

# Update network settings
echo "Network configuration..."
./piproxy/network_config/config_network.sh



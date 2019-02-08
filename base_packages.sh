#!/usr/bin/env bash

# Script to install base packages and updates to vanilla Pi deployment
# Assumption is git is already installed :-)

# Update the OS and Install WittyPi2 and other base packages if not already installed.
cd ~
mkdir status

if [ -e ./status/os_updated ]
then
  echo "Initial OS update completed, skipping..."
else
  sudo sed -i -e 's/# deb-src/deb-src/' /etc/apt/sources.list
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

if [ -e ./status/post_install_reboot ]
then
  echo "Post install reboot occured, skipping another one..."
else
  touch ./status/post_install_reboot
  wait
  shutdown -r 0
fi

if [ -e ./status/proxy_installed ]
then
  echo "SquidGuard, nginx and Calamaris installed, skipping..."
else
  ./squid_build/build_squid.sh
  sudo apt-get install -y squidguard calamaris nginx openssl
  touch ./status/proxy_installed
fi

# Install latest nginx, squid and calamaris configurations
echo "Updating nginx, calamaris and squid configuration..."
./piproxy/update_proxy_services.sh

# Apply or Reapplying all configuration settings
echo "Updating blacklist of websites..."
./piproxy/update_proxy_blacklist.sh


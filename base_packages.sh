#!/bin/sh

# Script to install base packages and updates to vanilla Pi deployment
# Assumption is git is already installed :-)

# Update the OS and Install WittyPi2 and other base packages if not already installed.
cd ~
mkdir status

if [ -e ./status/os_updated ]
then
  echo "Initial OS update completed, skipping..."
else
  sudo apt-get - yupdate; sudo apt-get -y upgrade
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
  echo "Squid, SquidGuard, nginx and Calamaris installed, skipping..."
else
  sudo apt-get install -y squid, squidguard, calamaris, nginx
  touch ./status/proxy_installed
fi



# Apply or Reapplying all configuration settings
echo "Updating blacklist of websites..."
sudo ./piproxy/update_proxy_blacklist.sh

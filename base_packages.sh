#!/bin/sh

# Script to install base packages and updates to vanilla Pi deployment
# Assumption is git is already installed :-)

# Update the OS and Install WittyPi2 if not already installed.
cd ~

if [ -e os_updated ]
then
  echo "Initial OS update completed, skipping..."
else
  sudo apt-get - yupdate; sudo apt-get -y upgrade
  touch os_updated
fi

if [ -e witty_installed ]
then
  echo "WittyPi installed, skipping..."
else
  wget http://www.uugear.com/repo/WittyPi2/installWittyPi.sh
  sudo sh ./installWittyPi.sh
  sudo apt-get -y upgrade
  touch witty_installed
fi

if [ -e post_install_reboot ]
then
  touch post_install_reboot
  shutdown -r 0
fi

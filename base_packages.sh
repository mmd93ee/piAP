#!/bin/sh

# Script to install base packages and updates to vanilla Pi deployment
# Assumption is git is already installed :-)
cd ~

if [ -e os_updated ]
then
  echo "Initial OS Update Completed"
else
  sudo apt-get update; sudo apt-get upgrade
  touch os_updated
fi

if [ -e witty_installed ]
then
  echo "WittyPi installed, skipping..."
else
  wget http://www.uugear.com/repo/WittyPi2/installWittyPi.sh
  sudo ./installWittyPi.sh
  touch witty_installed
fi




#!/bin/sh

# Script to install base packages and updates to vanilla Pi deployment
# Assumption is git is already installed :-)
cd ~
if [ %1 = os_update ]
then
  sudo apt-get update; sudo apt-get upgrade
fi

if [ -e witty_installed ]
then
  echo "WittyPi installed, skipping..."
else
  wget http://www.uugear.com/repo/WittyPi2/installWittyPi.sh
  sudo ./installWittyPi.sh
  cd ~
  touch witty_installed
fi




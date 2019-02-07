#!/bin/sh

# Script to install base packages and updates to vanilla Pi deployment
# Assumption is git is already installed :-)
cd ~
if [ %1 = os_update ]
  sudo apt-get update; sudo apt-get upgrade


wget http://www.uugear.com/repo/WittyPi2/installWittyPi.sh
sudo ./installWittyPi.sh


apt-get install
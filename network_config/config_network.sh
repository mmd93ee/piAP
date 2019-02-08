#!/usr/bin/env bash

# Set up the Pi routes to make sure it acts as a transparent router

# Update DNS
sudo cp ./piproxy/network_config/resolv.conf /etc/resolv.conf

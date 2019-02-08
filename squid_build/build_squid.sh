#!/usr/bin/env bash

# Drop squid3 build folder
if [ -e build/squid3 ]
then
  sudo rm -R build/squid3
fi

# We will be working in a subfolder make it
mkdir -p build/squid3

# Descend into working directory
pushd build/squid3

# Add sources, download and build
sudo sed -i -e 's/#deb-src/deb-src/' /etc/apt/sources.list
sudo apt-get update
apt-get -y build-dep squid3
apt-get -y source squid3

# Reset the sources.list
sudo sed -i -e 's/deb-src /#deb-src /' /etc/apt/sources.list
sudo apt-get update
cd squid3-3*

# modify configure options in debian/rules, add --enable-ssl --enable-ssl-crtd
patch ./debian/rules < ~/piproxy/squid_build/rules.patch

# modify control file, drop explicitly specified debhelper version
patch ./debian/control < ~/piproxy/squid_build/control.patch

sudo ./configure
sudo make & sudo make install

# Return to home
popd


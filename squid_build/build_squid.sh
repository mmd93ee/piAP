#!/usr/bin/env bash

# Drop squid3 build folder
rm -R build/squid3

# We will be working in a subfolder make it
mkdir -p build/squid3

# Copy the patches to the working folder
cp rules.patch build/squid3/rules.patch
cp control.patch build/squid3/control.patch

# Descend into working directory
pushd build/squid3

# Download and build
apt-get build-dep squid3
apt-get source squid3
./configure --enable-esi \
 		--enable-icmp \
 		--enable-zph-qos \
		--enable-ecap \
		--enable-ssl \
		--enable-ssl-crtd \
		--with-openssl \
 		--disable-translation \
 		--with-swapdir=/var/spool/squid \
 		--with-logdir=/var/log/squid
make & make install

# Return to home
popd


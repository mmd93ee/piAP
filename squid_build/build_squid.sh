#!/usr/bin/env bash

# Drop squid3 build folder
if [ -e build/squid3 ]
then
  rm -R build/squid3
fi

# We will be working in a subfolder make it
mkdir -p build/squid3

# Descend into working directory
pushd build/squid3

# Download and build
apt-get build-dep squid3
apt-get source squid3

cd build/squid3/squid3-3.5.23
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


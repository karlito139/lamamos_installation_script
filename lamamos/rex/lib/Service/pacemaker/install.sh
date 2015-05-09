#!/bin/bash

apt-get install -y build-essential automake autoconf libtool pkg-config uuid-dev libglib2.0-dev libxml2-dev libxslt1-dev libbz2-dev libncurses5-dev libcpg-dev libcfg-dev corosync-dev


wget https://github.com/ClusterLabs/libqb/archive/v0.17.1.tar.gz

tar -xvf v0.17.1.tar.gz

cd libqb-0.17.1
echo "0.17.0" > .tarball-version
./autogen.sh
./configure
make -j 2
make install

cd ..
rm -r libqb-0.17.1
rm v0.17.1.tar.gz

wget https://github.com/ClusterLabs/pacemaker/archive/Pacemaker-1.1.13-rc2.tar.gz
tar -xvf Pacemaker-1.1.13-rc2.tar.gz

cd pacemaker-Pacemaker-1.1.13-rc2
./autogen.sh
./configure
make -j 2
make install

cd ..
rm -r pacemaker-Pacemaker-1.1.13-rc2
rm Pacemaker-1.1.13-rc2.tar.gz

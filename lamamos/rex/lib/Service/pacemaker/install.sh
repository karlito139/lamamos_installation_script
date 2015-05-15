#!/bin/bash

apt-get install -y build-essential automake autoconf pkg-config uuid-dev libglib2.0-dev libxml2-dev libxslt1-dev libbz2-dev libncurses5-dev libcpg-dev libcfg-dev python-lxml cluster-glue cluster-glue-dev libaio-dev libnss3-dev groff rpm

addgroup --system haclient
adduser --system --no-create-home --ingroup haclient hacluster



# Install : LIBQB
wget https://github.com/ClusterLabs/libqb/archive/v0.17.1.tar.gz

tar -xvf v0.17.1.tar.gz

cd libqb-0.17.1
echo "0.17.1" > .tarball-version
./autogen.sh
./configure
make -j 2
make install

cd ..
rm -r libqb-0.17.1
rm v0.17.1.tar.gz


# Install : corosync
wget https://github.com/corosync/corosync/archive/v2.3.4.tar.gz

tar -xvf v2.3.4.tar.gz

cd corosync-2.3.4
echo "2.3.4" > .tarball-version
./autogen.sh
./configure
make -j 2
make install

cd ..
rm -r corosync-2.3.4
rm v2.3.4.tar.gz




#lib-tool
wget ftp://ftp.gnu.org/pub/gnu/libtool/libtool-2.4.2.tar.xz

tar -xvf libtool-2.4.2.tar.xz
cd libtool-2.4.2
./configure
make -j 2
make install

cd ..
rm -r libtool-2.4.2
rm libtool-2.4.2.tar.xz





# Install : cluster-glue
wget http://hg.linux-ha.org/glue/archive/glue-1.0.12.tar.bz2

tar -xvf glue-1.0.12.tar.bz2

cd Reusable-Cluster-Components-glue--glue-1.0.12
./autogen.sh
./configure --enable-fatal-warnings=no
make -j 2
make install

cd ..
rm -r Reusable-Cluster-Components-glue--glue-1.0.12
rm glue-1.0.12.tar.bz2






# Install ressource agent
wget https://github.com/ClusterLabs/resource-agents/archive/v3.9.6.tar.gz

tar -xvf v3.9.6.tar.gz

cd resource-agents-3.9.6
echo "3.9.6" > .tarball-version
./autogen.sh
./configure
make -j 2
make install

cd ..
rm -r resource-agents-3.9.6
rm v3.9.6.tar.gz




# Install : PACEMAKER
wget https://github.com/ClusterLabs/pacemaker/archive/Pacemaker-1.1.13-rc3.tar.gz
tar -xvf Pacemaker-1.1.13-rc3.tar.gz

cd pacemaker-Pacemaker-1.1.13-rc3
./autogen.sh
./configure
make -j 2
make install

cd ..
rm -r pacemaker-Pacemaker-1.1.13-rc2
rm Pacemaker-1.1.13-rc2.tar.gz




# Install : CRMSH
wget https://github.com/ClusterLabs/crmsh/archive/2.1.0.tar.gz
tar -xvf 2.1.0.tar.gz

cd crmsh-2.1.0
./autogen.sh
./configure
make -j 2
make install

cd ..
rm -r crmsh-2.1.0
rm 2.1.0.tar.gz


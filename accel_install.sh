#!/bin/sh
###Instalando dependencias e Criando diretorios
apt-get update
apt-get -y install git vlan cmake libpcre3 libpcre3-dev libssl-dev liblua5.1 libsnmp-dev linux-headers-$(uname -r) 


ACCELSRC=/usr/src/accel-ppp-code
ACCELBUILD=/usr/src/accel-ppp

if [ ! -d "$ACCELSRC" ]; then
        git clone https://git.code.sf.net/p/accel-ppp/code /usr/src/accel-ppp-code
else
        cd /usr/src/accel-ppp-code
        git pull
fi
if [ ! -d "$ACCELBUILD" ]; then
        mkdir /usr/src/accel-ppp
fi

rm -rf /usr/src/accel-ppp/*
cd /usr/src/accel-ppp/
cmake -DRADIUS=TRUE -DSHAPER=TRUE -DBUILD_IPOE_DRIVER=TRUE -DBUILD_VLAN_MON_DRIVER=TRUE -DKDIR=/usr/src/linux-headers-`uname -r` -DNETSNMP=TRUE -D LUA=TRUE -DLOG_PGSQL=FALSE /usr/src/accel-ppp-code/

make
make install
mkdir -p /lib/modules/$(uname -r)/kernel/extra
cp ./drivers/ipoe/driver/ipoe.ko /lib/modules/$(uname -r)/kernel/extra
cp ./drivers/vlan_mon/driver/vlan_mon.ko /lib/modules/$(uname -r)/kernel/extra
depmod -a
modprobe ipoe
modprobe vlan_mon
echo "8021q" >> /etc/modules
echo "ipoe" >> /etc/modules
echo "vlan_mon" >> /etc/modules

cp dictionary /usr/src/accel-ppp/accel-pppd/
cp etc/accel-* /etc/
cp init.d/accel-ppp /etc/init.d/
chmod 775 /etc/init.d/accel-ppp
./etc/init.d/accel-ppp start
#!/bin/bash
KEYPATH=/etc/openvpn/easy-rsa/keys
cd /etc/openvpn/easy-rsa && \
source vars && \
KEY_EMAIL=$1@pilgrim ./pkitool $1

cd /etc/openvpn/easy-rsa/keys

dev=`ip route sh|grep default|awk '{print $5}'`
ip=`ip addr sh dev $dev |grep inet |grep $dev |tr '/' ' '|awk '{print $2}'`


echo "client" > $KEYPATH/$1.ovpn
echo "proto udp" >> $KEYPATH/$1.ovpn
echo "remote $ip" >> $KEYPATH/$1.ovpn
echo "port 1194" >> $KEYPATH/$1.ovpn
echo "dev tun" >> $KEYPATH/$1.ovpn
echo "nobind" >> $KEYPATH/$1.ovpn
echo "comp-lzo" >> $KEYPATH/$1.ovpn

echo "<ca>" >> $KEYPATH/$1.ovpn
sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' $KEYPATH/ca.crt >> $KEYPATH/$1.ovpn
echo "</ca>" >> $KEYPATH/$1.ovpn

echo "<cert>" >> $KEYPATH/$1.ovpn
sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' $KEYPATH/$1.crt >> $KEYPATH/$1.ovpn
echo "</cert>" >> $KEYPATH/$1.ovpn

echo "<key>" >> $KEYPATH/$1.ovpn
sed -n '/-----BEGIN PRIVATE KEY-----/,/-----END PRIVATE KEY-----/p' $KEYPATH/$1.key >> $KEYPATH/$1.ovpn
echo "</key>" >> $KEYPATH/$1.ovpn

zip $1.zip $KEYPATH/$1.ovpn $KEYPATH/$1.key $KEYPATH/$1.crt $KEYPATH/ca.crt && \
mv $1.zip /tmp

ln -s /etc/openvpn/ccd/routes /etc/openvpn/ccd/$1

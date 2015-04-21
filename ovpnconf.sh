#!/bin/bash

mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun

ssh-keygen -b 1024 -t rsa -f /etc/ssh/ssh_host_rsa_key -q -N ""
ssh-keygen -b 1024 -t dsa -f /etc/ssh/ssh_host_dsa_key -q -N ""
ssh-keygen -b 256 -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -q -N ""
ssh-keygen -b 256 -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -q -N ""

echo -e "dockvpn\ndockvpn" | (passwd root)

cd /etc/openvpn/easy-rsa && \
source vars && \
./clean-all && \
./build-dh && \
KEY_EMAIL=ca@openvpn ./pkitool --initca && \
KEY_EMAIL=server@pilgrim ./pkitool --server server && \
KEY_EMAIL=client@pilgrim ./pkitool client && \
KEY_EMAIL=revoked@pilgrim ./pkitool revoked && \
./revoke-full revoked && \
#openvpn --genkey --secret keys/ta.key

sleep 4
service openvpn start

sed -i 's/\[program:ovpnconf\]//g' /etc/supervisor/conf.d/supervisord.conf
sed -i 's/command=\/etc\/openvpn\/ovpnconf.sh//g' /etc/supervisor/conf.d/supervisord.conf

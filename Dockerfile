# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
FROM phusion/baseimage

# Use baseimage-docker's init system.
#CMD ["/sbin/my_init"]
CMD ["/usr/bin/supervisord"]

# ...put your own build instructions here...


EXPOSE 22 1149

# Clean up APT when done.
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y zip openvpn easy-rsa quagga tcpdump iptables openssh-server supervisor && \
  mkdir -p /var/run/sshd /var/log/supervisor && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -p /etc/openvpn/easy-rsa/keys && \
  mkdir -p /dev/net && \
  mkdir -p /etc/openvpn/ccd && \
  touch /etc/openvpn/ccd/routes
  mknod /dev/net/tun c 10 200 && \
  chmod 600 /dev/net/tun 

COPY create-route-tables /etc/dhcp/dhclient-exit-hooks.d/
COPY openvpn-push-routes /etc/dhcp/dhclient-exit-hooks.d/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY server.conf /etc/openvpn/
COPY interface-config /etc/openvpn/
COPY ovpnconf.sh /etc/openvpn/
COPY createtun.sh /etc/openvpn/
COPY createcert.sh /etc/openvpn/
COPY easy-rsa2/* /etc/openvpn/easy-rsa/
COPY rt_tables /etc/iproute2/

#!/usr/bin/env bash
set -e

[ "$(id -u)" = "0" ] || { echo "Run as root"; exit 1; }

apt update
apt install -y xfce4 xfce4-goodies xrdp curl

adduser nrb --disabled-password --gecos ""
echo "nrb:NRB@12345" | chpasswd

usermod -aG ssl-cert xrdp
echo xfce4-session > /home/nrb/.xsession
chown nrb:nrb /home/nrb/.xsession

systemctl enable xrdp
systemctl restart xrdp

IP=$(curl -4 -fsSL https://api.ipify.org || hostname -I | awk '{print $1}')

echo
echo "================================"
echo " Ubuntu RDP Ready"
echo "================================"
echo "IP: $IP"
echo "Port: 3389"
echo "Username: nrb"
echo "Password: NRB@12345"
echo "================================"

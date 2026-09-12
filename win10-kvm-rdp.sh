#!/usr/bin/env bash
set -e

echo "===== NRB RDP V1 ====="

[ "$(id -u)" = "0" ] || { echo "Run as root"; exit 1; }

apt update
apt install -y \
  xfce4 xfce4-goodies \
  xrdp \
  openjdk-21-jre \
  wine64 \
  curl wget git unzip

# VS Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >/usr/share/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" >/etc/apt/sources.list.d/vscode.list
apt update
apt install -y code

# Google Chrome
wget -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt install -y /tmp/chrome.deb || apt --fix-broken install -y

# User
id nrb >/dev/null 2>&1 || useradd -m -s /bin/bash nrb
echo "nrb:NRB@12345" | chpasswd

echo xfce4-session >/home/nrb/.xsession
chown nrb:nrb /home/nrb/.xsession

systemctl enable xrdp
systemctl restart xrdp

mkdir -p /opt/nrb
cat >/opt/nrb/launcher.sh <<'EOF'
#!/bin/bash
code &
google-chrome &
EOF
chmod +x /opt/nrb/launcher.sh

IP=$(curl -4 -fsSL https://api.ipify.org || hostname -I | awk '{print $1}')

echo
echo "================================"
echo " NRB RDP V1 READY"
echo "================================"
echo "IP: $IP"
echo "Port: 3389"
echo "Username: nrb"
echo "Password: NRB@12345"
echo "Apps:"
echo " - VS Code"
echo " - Chrome"
echo " - Java"
echo " - Wine"
echo "================================"

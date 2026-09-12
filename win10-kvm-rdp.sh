#!/usr/bin/env bash
set -e

echo "=================================="
echo "      NRB Windows 10 KVM RDP"
echo "=================================="

if [ "$(id -u)" != "0" ]; then
  echo "Run as root."
  exit 1
fi

if [ ! -e /dev/kvm ]; then
  echo "KVM not found (/dev/kvm)."
  exit 1
fi

apt update
apt install -y qemu-kvm qemu-utils ovmf wget curl iptables

mkdir -p /opt/nrb/windows
cd /opt/nrb/windows

# Windows 10 image (replace with your own ISO if needed)
if [ ! -f win10.iso ]; then
  wget -O win10.iso "https://software.download.prss.microsoft.com/dbazure/Win10_22H2_English_x64.iso"
fi

# Virtual disk
[ -f win10.qcow2 ] || qemu-img create -f qcow2 win10.qcow2 50G

# NAT RDP forwarding
iptables -t nat -C PREROUTING -p tcp --dport 3389 -j REDIRECT --to-ports 3389 2>/dev/null || \
iptables -t nat -A PREROUTING -p tcp --dport 3389 -j REDIRECT --to-ports 3389

# Start VM
nohup qemu-system-x86_64 \
-enable-kvm \
-machine q35 \
-cpu host \
-smp 4 \
-m 4096 \
-drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd \
-drive if=pflash,format=raw,file=/usr/share/OVMF/OVMF_VARS.fd \
-drive file=win10.qcow2,if=virtio \
-cdrom win10.iso \
-netdev user,id=net0,hostfwd=tcp::3389-:3389 \
-device virtio-net-pci,netdev=net0 \
-vga virtio \
-daemonize

IP=$(curl -4 -s ifconfig.me || hostname -I | awk '{print $1}')

echo
echo "=================================="
echo " Windows 10 VM Started"
echo "=================================="
echo "RDP Address: ${IP}:3389"
echo "=================================="
echo "Install Windows first, then connect."

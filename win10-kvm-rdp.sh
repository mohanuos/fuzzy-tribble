#!/usr/bin/env bash
set -e

echo "========== NRB Windows 10 KVM RDP =========="

[ "$(id -u)" = "0" ] || { echo "Run as root."; exit 1; }
[ -e /dev/kvm ] || { echo "KVM not available."; exit 1; }

apt update
apt install -y qemu-kvm qemu-utils ovmf curl wget iptables

mkdir -p /opt/nrb/windows
cd /opt/nrb/windows

[ -f win10.qcow2 ] || qemu-img create -f qcow2 win10.qcow2 50G

if [ ! -f win10.iso ]; then
    echo
    echo "Windows 10 ISO is required."
    echo "Download it from the official Microsoft page:"
    echo "https://www.microsoft.com/en-in/software-download/windows10iso"
    echo
    echo "Upload it as: /opt/nrb/windows/win10.iso"
    exit 1
fi

cp /usr/share/OVMF/OVMF_VARS.fd OVMF_VARS.fd 2>/dev/null || true

nohup qemu-system-x86_64 \
-enable-kvm \
-machine q35 \
-cpu host \
-smp 4 \
-m 4096 \
-drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd \
-drive if=pflash,format=raw,file=/opt/nrb/windows/OVMF_VARS.fd \
-drive file=win10.qcow2,if=virtio \
-cdrom win10.iso \
-netdev user,id=n1,hostfwd=tcp::3389-:3389 \
-device virtio-net-pci,netdev=n1 \
-vga virtio \
-daemonize

PUBLIC_IP=$(curl -4 -fsSL https://api.ipify.org || hostname -I | awk '{print $1}')

echo
echo "========== VM STARTED =========="
echo "RDP: ${PUBLIC_IP}:3389"
echo "Username: Administrator (after Windows setup)"
echo "Password: Set during Windows installation."
echo "================================"

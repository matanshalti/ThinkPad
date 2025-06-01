#!/bin/bash
echo "[!] Stopping hotspot..."
sudo pkill hostapd || true
sudo pkill dnsmasq || true
sudo iptables -t nat -D POSTROUTING -o enp0s25 -j MASQUERADE || true
sudo ip addr flush dev wlp3s0
sudo systemctl start systemd-resolved || true
echo "✅ Hotspot stopped and cleaned up."

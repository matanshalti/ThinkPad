#!/bin/bash

# Stop ThinkPad Hotspot
# Gracefully stops hostapd, dnsmasq, and NAT configuration

IF_WLAN="wlp3s0"
IF_ETH="enp0s25"

echo "[!] Stopping hotspot services..."

# Kill AP and DHCP
sudo pkill -f hostapd || true
sudo pkill -f dnsmasq || true

# Flush IP address on Wi-Fi interface
sudo ip addr flush dev "$IF_WLAN"

# Remove NAT rule (if present)
sudo iptables -t nat -D POSTROUTING -o "$IF_ETH" -j MASQUERADE 2>/dev/null || true

# Restart resolved if we had disabled it
sudo systemctl restart systemd-resolved || true

echo "✅ Hotspot services stopped."

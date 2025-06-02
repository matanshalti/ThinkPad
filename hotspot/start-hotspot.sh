#!/bin/bash

# Wi-Fi Hotspot Setup Script - Final Version
# Matan's ThinkPad W541 | Ubuntu Server 24.04

set -e

# === CONFIG ===
IF_WLAN="wlp3s0"
IF_ETH="enp0s25"
SSID="ThinkpadHotspot"
PASSWORD="ThinkpadSecure123"
GATEWAY="192.168.50.1"
DHCP_START="192.168.50.10"
DHCP_END="192.168.50.100"
DNS1="1.1.1.1"
DNS2="8.8.8.8"
# ==============

echo "[+] Bringing up Wi-Fi interface $IF_WLAN..."
sudo ip link set "$IF_WLAN" up || true
sudo ip addr flush dev "$IF_WLAN"
sudo ip addr add "$GATEWAY"/24 dev "$IF_WLAN"

echo "[+] Disabling systemd-resolved (to free port 53)..."
sudo systemctl stop systemd-resolved || true

echo "[+] Writing dnsmasq config..."
cat <<EOF | sudo tee /tmp/dnsmasq-hotspot.conf >/dev/null
interface=$IF_WLAN
bind-interfaces
dhcp-range=$DHCP_START,$DHCP_END,12h
dhcp-option=3,$GATEWAY
dhcp-option=6,$DNS1,$DNS2
log-queries
log-dhcp
EOF

echo "[+] Writing hostapd config..."
cat <<EOF | sudo tee /tmp/hostapd-hotspot.conf >/dev/null
interface=$IF_WLAN
driver=nl80211
ssid=$SSID
hw_mode=g
channel=7
wmm_enabled=0
auth_algs=1
wpa=2
wpa_passphrase=$PASSWORD
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
EOF

echo "[+] Killing previous dnsmasq/hostapd (if any)..."
sudo pkill dnsmasq || true
sudo pkill hostapd || true

echo "[+] Starting dnsmasq..."
sudo dnsmasq --conf-file=/tmp/dnsmasq-hotspot.conf &

echo "[+] Starting hostapd..."
sudo hostapd /tmp/hostapd-hotspot.conf > /var/log/hostapd-hotspot.log 2>&1 &

echo "[+] Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1

echo "[+] Setting up NAT with iptables..."
sudo iptables -t nat -C POSTROUTING -o "$IF_ETH" -j MASQUERADE 2>/dev/null || \
sudo iptables -t nat -A POSTROUTING -o "$IF_ETH" -j MASQUERADE

# === UFW RULES (safe reapplication) ===
echo "[+] Configuring UFW rules..."
sudo ufw allow in on "$IF_WLAN" || true
sudo ufw allow out on "$IF_ETH" || true
sudo ufw route allow in on "$IF_WLAN" out on "$IF_ETH" || true
sudo ufw route allow in on "$IF_ETH" out on "$IF_WLAN" || true
sudo ufw reload

echo ""
echo "✅ Hotspot '$SSID' is now active!"
echo "📡 Connect using password: $PASSWORD"

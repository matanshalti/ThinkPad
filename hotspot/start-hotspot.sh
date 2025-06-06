#!/bin/bash

# Wi-Fi Hotspot Setup Script - Optimized
# ThinkPad W541 | Ubuntu Server 24.04

set -e

# === CONFIG ===
source /opt/hotspot/hotspot.env
source "$(dirname "$0")/hotspot.env"
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
channel=6
ieee80211n=1
wmm_enabled=1
auth_algs=1
wpa=2
wpa_passphrase=$PASSWORD
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
ht_capab=[HT40+][SHORT-GI-40][DSSS_CCK-40]
max_num_sta=4
EOF

echo "[+] Killing previous dnsmasq/hostapd (if any)..."
sudo pkill dnsmasq || true
sudo pkill hostapd || true

echo "[+] Starting dnsmasq..."
sudo dnsmasq --conf-file=/tmp/dnsmasq-hotspot.conf &

echo "[+] Starting hostapd..."
sudo hostapd /tmp/hostapd-hotspot.conf > "$LOG_HAPD" 2>&1 &

echo "[+] Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1

echo "[+] Tuning NAT performance..."
echo 262144 | sudo tee /proc/sys/net/netfilter/nf_conntrack_max > /dev/null

echo "[+] Disabling IPv6 (improves speed for some clients)..."
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 > /dev/null
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1 > /dev/null

echo "[+] Setting up NAT with iptables..."
sudo iptables -t nat -C POSTROUTING -o "$IF_ETH" -j MASQUERADE 2>/dev/null || \
sudo iptables -t nat -A POSTROUTING -o "$IF_ETH" -j MASQUERADE

echo "[+] Configuring UFW rules..."
sudo ufw allow in on "$IF_WLAN" || true
sudo ufw allow out on "$IF_ETH" || true
sudo ufw route allow in on "$IF_WLAN" out on "$IF_ETH" || true
sudo ufw route allow in on "$IF_ETH" out on "$IF_WLAN" || true
sudo ufw reload

echo ""
echo "✅ Hotspot '$SSID' is now active!"
echo "📡 Connect using password: $PASSWORD"
echo "📋 Log: tail -f $LOG_HAPD"

# ThinkPad Hotspot

Scripts for turning my ThinkPad running Ubuntu Server into a Wi-Fi access point.

## Files
- `start-hotspot.sh`: Sets up Wi-Fi AP, routing, NAT, and firewall rules
- `stop-hotspot.sh`: Stops all services and cleans up

## Requirements
- Ubuntu Server 24.04
- Wi-Fi interface that supports AP mode (e.g. `wlp3s0`)
- Ethernet uplink (e.g. `enp0s25`)
- Installed: `hostapd`, `dnsmasq`, `iptables`, `ufw`

## Usage
```bash
sudo ./start-hotspot.sh
sudo ./stop-hotspot.sh
```

## Author
Created by [matanshalti](https://github.com/matanshalti)

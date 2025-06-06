# ThinkPad Hotspot

A lightweight set of Bash scripts to turn my ThinkPad running Ubuntu Server into a functional Wi-Fi access point.

## Files
- `start-hotspot.sh`: Sets up Wi-Fi AP, NAT, DNS/DHCP, firewall rules
- `stop-hotspot.sh`: Stops all hotspot services and cleans up
- `deploy.sh`: Copies the `start-hotspot.sh` to `/opt/hotspot/` for secure use with systemd
- `hotspot.service`: `systemd` unit file for auto-start on boot

## Requirements
- Ubuntu Server 24.04
- `hostapd`, `dnsmasq`, `iptables`, `ufw`
- One Wi-Fi interface with AP support (e.g. `wlp3s0`)
- One Ethernet interface for internet uplink (e.g. `enp0s25`)

## Usage

### Manual Start/Stop
```bash
sudo ./start-hotspot.sh
sudo ./stop-hotspot.sh
```

### Deploy for systemd
```bash
./deploy.sh
sudo systemctl enable --now hotspot.service
```

## Installation notes
### Ensure `hostapd`, `dnsmasq`, and `iptables` are installed.
### Check your interface with  `ip a`

## Author
Created by [matanshalti](https://github.com/matanshalti)

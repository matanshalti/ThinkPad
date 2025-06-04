# ThinkPad Ubuntu Server Security Setup

This document outlines the current security configuration applied to the ThinkPad running Ubuntu Server 24.04 (headless).

---

## 🔐 SSH Hardening

- **Root login:** Disabled  
  (`PermitRootLogin no` in `/etc/ssh/sshd_config`)
- **Password login:** Disabled  
  (`PasswordAuthentication no`)
- **Key-based login:** Enforced  
  Authorized key is stored in `~/.ssh/authorized_keys`
- **SSH Port:** Default (22), limited to LAN access via firewall

---

## 🧱 Firewall (UFW)

- **Default policy:**  
  - Incoming: `deny`  
  - Outgoing: `allow`
- **SSH:** Allowed from LAN only (`192.168.1.0/24`)
- **Samba (file sharing):** Allowed on LAN (ports 137–139, 445)
- **Streaming stack (Docker):** LAN-only access for:
  - Jellyfin (`8096`)
  - Sonarr (`8989`)
  - Radarr (`7878`)
  - Jackett (`9117`)
  - qBittorrent / web UI (`8080`, `8999`)
  - Bazarr (`6767`)
  - Systemd/web (`9090`)

---

## 🛡️ Intrusion Protection

- **fail2ban:** Installed and active  
  - Monitoring `sshd` jail  
  - Automatically bans repeated failed login attempts

---

## 🌐 Router Configuration

- **UPnP:** Disabled via router admin interface  
  - Prevents auto port-forwarding by apps like AnyDesk or Giraffic  
  - Verified existing UPnP clients:
    - `192.168.1.186`: Samsung Smart TV
    - `192.168.1.149`: Windows PC running AnyDesk (offline)
- **Next step:** Monitor for issues; re-enable or manually forward ports only if necessary

---

## ✅ Last Audit: 2025-06-04

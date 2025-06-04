#!/bin/bash

# Hotspot Deployment Script
# Copies script and secrets to /opt and restarts service

SOURCE_SCRIPT="$HOME/Git/ThinkPad/hotspot/start-hotspot.sh"
SOURCE_ENV="$HOME/Git/ThinkPad/hotspot/hotspot.env"
DEST_DIR="/opt/hotspot"
DEST_SCRIPT="$DEST_DIR/start-hotspot.sh"
DEST_ENV="$DEST_DIR/hotspot.env"

echo "[+] Deploying updated hotspot script..."

# Ensure /opt/hotspot exists
sudo mkdir -p "$DEST_DIR"

# Copy and secure the script
sudo cp "$SOURCE_SCRIPT" "$DEST_SCRIPT"
sudo chmod +x "$DEST_SCRIPT"
sudo chown root:root "$DEST_SCRIPT"

# Copy and secure the .env file
if [ -f "$SOURCE_ENV" ]; then
  echo "[+] Deploying environment file..."
  sudo cp "$SOURCE_ENV" "$DEST_ENV"
  sudo chmod 600 "$DEST_ENV"
  sudo chown root:root "$DEST_ENV"
else
  echo "[!] WARNING: Environment file not found at $SOURCE_ENV"
fi

# Reload systemd
sudo systemctl daemon-reload

# Restart service if it's already enabled
if systemctl is-enabled --quiet hotspot.service; then
    echo "[+] Restarting hotspot service..."
    sudo systemctl restart hotspot.service
else
    echo "[!] hotspot.service not enabled. To enable:"
    echo "    sudo systemctl enable --now hotspot.service"
fi

echo "✅ Deploy complete."

#!/usr/bin/env bash
# Automated startup script for Grizzarch live environment

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    Welcome to Grizzarch                       ║"
echo "║          Arch Linux with Sway, LVM on LUKS encryption         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Installation options:"
echo ""
echo "  1. archinstall                  - Guided installation with grizzarch profile"
echo "  2. archinstall --config /root/grizzarch.json --creds /root/grizzarch-creds.json"
echo "                                  - Automated installation (⚠️ wipes /dev/sda!)"
echo "  3. Manual installation          - Use scripts in /root/grizzarch-scripts/"
echo ""
echo "⚠️  IMPORTANT: Edit /root/grizzarch-creds.json before automated install!"
echo "    Default passwords are 'testpass12' - change them immediately."
echo ""
echo "Networking:"
echo "  - Wired (DHCP):  sudo systemctl start systemd-networkd"
echo "  - WiFi:          iwctl"
echo ""
echo "Once installed, remember to change passwords on first boot:"
echo "  - User password:    passwd"
echo "  - LUKS passphrase:  cryptsetup luksChangeKey /dev/sda2"
echo ""

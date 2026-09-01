#!/usr/bin/env bash
# Post-installation script for grizzarch archinstall
# This runs after archinstall completes to apply grizzarch-specific configurations

set -e

TARGET_USER="${1:-testuser}"
TARGET_MOUNT="${2:-/mnt}"

echo "==> Applying grizzarch post-install configuration..."

# Copy Sway configuration
mkdir -p "$TARGET_MOUNT/home/$TARGET_USER/.config/sway"
mkdir -p "$TARGET_MOUNT/home/$TARGET_USER/.config/foot"
mkdir -p "$TARGET_MOUNT/home/$TARGET_USER/.config/i3status"
mkdir -p "$TARGET_MOUNT/home/$TARGET_USER/.config/wallpapers"

# Copy configs from grizzarch-scripts
cp /root/grizzarch-scripts/sway_conf "$TARGET_MOUNT/home/$TARGET_USER/.config/sway/config"
cp /root/grizzarch-scripts/foot.ini "$TARGET_MOUNT/home/$TARGET_USER/.config/foot/foot.ini"
cp /root/grizzarch-scripts/i3status_conf_vb "$TARGET_MOUNT/home/$TARGET_USER/.config/i3status/config"
cp /root/grizzarch-scripts/.bash_profile "$TARGET_MOUNT/home/$TARGET_USER/.bash_profile"

# Set up skel directory for new users
mkdir -p "$TARGET_MOUNT/etc/skel_grizzarch/.config"
cp -a "$TARGET_MOUNT/home/$TARGET_USER/.config" "$TARGET_MOUNT/etc/skel_grizzarch/"
cp "$TARGET_MOUNT/home/$TARGET_USER/.bash_profile" "$TARGET_MOUNT/etc/skel_grizzarch/"

# Update useradd defaults
cp /root/grizzarch-scripts/useradd_conf "$TARGET_MOUNT/etc/default/useradd"

# Fix ownership
arch-chroot "$TARGET_MOUNT" chown -R "$TARGET_USER:$TARGET_USER" "/home/$TARGET_USER"

echo "==> Grizzarch configuration complete!"
echo ""
echo "⚠️  IMPORTANT: On first boot, change your passwords:"
echo "    passwd"
echo "    sudo cryptsetup luksChangeKey /dev/sda2"

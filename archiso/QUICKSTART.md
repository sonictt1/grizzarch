# Grizzarch Quick Reference

## Installation from Live ISO

### Automated install (⚠️ WIPES /dev/sda)
```bash
# 1. Edit credentials first!
vim /root/grizzarch-creds.json

# 2. Run automated install
archinstall --config /root/grizzarch.json --creds /root/grizzarch-creds.json
```

### Guided install (recommended)
```bash
archinstall
# Select "grizzarch" profile when prompted
```

### Manual install
```bash
# Use the scripts in /root/grizzarch-scripts/
# Follow the same sequence as the Packer build
```

## Post-Installation

### Change passwords (CRITICAL!)
```bash
# User password
passwd

# LUKS encryption passphrase
sudo cryptsetup luksChangeKey /dev/sda2
```

### Optional: Remove keyfile for maximum security
```bash
sudo rm /boot/keyfile
sudo vim /etc/default/grub
# Remove rd.luks.key parameter
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## Networking

### Wired (DHCP)
```bash
sudo systemctl start systemd-networkd
sudo systemctl enable systemd-networkd
```

### WiFi
```bash
iwctl
# device list
# station wlan0 scan
# station wlan0 get-networks
# station wlan0 connect SSID
```

## Sway Window Manager

### Key bindings
- `Super + Enter` - Terminal
- `Super + d` - Application launcher
- `Super + Shift + q` - Kill window
- `Super + Shift + e` - Exit Sway
- `Super + Shift + c` - Reload config
- `Super + m` - Display mode menu (VirtualBox resolution)
- `Super + 1-9` - Switch workspace
- `Super + Shift + 1-9` - Move window to workspace

### Volume controls (PipeWire)
```bash
pactl set-sink-volume @DEFAULT_SINK@ +10%
pactl set-sink-volume @DEFAULT_SINK@ -10%
pactl set-sink-mute @DEFAULT_SINK@ toggle
```

## AUR Helper (optional)
```bash
/root/grizzarch-scripts/install_yay.sh -u $(whoami)
```

## Default Setup

- **Bootloader**: GRUB (UEFI)
- **Encryption**: LVM on LUKS (`/dev/sda2`)
- **Volume group**: `GrizzVolGrp`
  - `root` - 8GB ext4 mounted at `/`
  - `home` - remaining space ext4 mounted at `/home`
- **Boot partition**: `/dev/sda1` (1GB FAT32, unencrypted)
- **Keyfile**: `/boot/keyfile` (auto-unlocks LUKS, mode 0400)
- **Networking**: NetworkManager
- **Window manager**: Sway (Wayland)
- **Terminal**: foot
- **Launcher**: wofi
- **Audio**: PipeWire with PulseAudio compatibility

## Troubleshooting

### Can't boot after install
- Verify UEFI boot mode is enabled
- Check boot order in BIOS/UEFI
- Use fallback kernel: Select "Arch Linux (fallback initramfs)" in GRUB

### Sway won't start
```bash
# Check for errors
journalctl -xe | grep sway

# VirtualBox: ensure software rendering is set
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER=pixman
sway
```

### Network not working
```bash
# Check interface name
ip link

# Enable NetworkManager
sudo systemctl start NetworkManager
sudo systemctl enable NetworkManager
```

# Grizzarch Archiso - Bootable Installation Media

This directory contains the archiso profile for creating a bootable Grizzarch installation USB/ISO.

## What's included

- **archinstall** guided installer (official Arch installer)
- Pre-configured **grizzarch.json** profile for automated/guided installation
- Same encryption, LVM, and Sway setup as the Packer build
- All grizzarch configuration files embedded in the ISO

## Prerequisites

You need an Arch Linux system with `archiso` installed:

```bash
sudo pacman -S --needed archiso
```

## Building the ISO

From the repository root:

```bash
cd archiso/profile
sudo mkarchiso -v -w ../work -o ../out .
```

The ISO will be created in `archiso/out/`.

## Using the ISO

1. **Write to USB** (replace `/dev/sdX` with your USB device):
   ```bash
   sudo dd if=archiso/out/grizzarch-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
   ```

2. **Boot from USB** and choose one of these installation methods:

### Option A: Guided installation (recommended)
```bash
archinstall
```
Then select the "grizzarch" profile from the menu.

### Option B: Automated installation
```bash
archinstall --config /root/grizzarch.json --creds /root/grizzarch-creds.json
```
**Warning**: This will wipe `/dev/sda` and install immediately. Edit credentials first!

### Option C: Manual installation
Use the embedded scripts in `/root/grizzarch-scripts/` following the same process as the Packer build.

## Customization

Edit these files before building:

- `profile/airootfs/root/grizzarch.json` - Installation profile
- `profile/airootfs/root/grizzarch-creds.json` - Default credentials (⚠️ change these!)
- `profile/packages.x86_64` - Packages included in the live environment
- `profile/profiledef.sh` - ISO metadata (name, version, etc.)

## Post-installation

After first boot, **change your passwords**:

```bash
# Change user password
passwd

# Change LUKS encryption passphrase
sudo cryptsetup luksChangeKey /dev/sda2
```

The `/boot/keyfile` auto-unlocks the encrypted disk. For maximum security, remove it and configure a boot passphrase prompt instead.

# Copilot Instructions for grizzarch

## Repository Overview

`grizzarch` is a personal, automated Arch Linux build system. It uses [Packer](https://www.packer.io/) to produce a fully-configured, encrypted VirtualBox image (`.ovf`/`.ova`) from a raw Arch ISO. The long-term goal is for the same scripts to also support installation on physical hardware via ARCHISO.

## Core Philosophy

> **"Default first"** — use stock defaults until there is a specific reason not to. Favour `systemd` components (`networkd`, `resolved`, etc.) over third-party equivalents.

Security note: default credentials (`arch_user`, `arch_pass`, `encryption_pass`) in `arch.pkr.hcl` are intentionally insecure placeholders. Always change them after first boot.

---

## Repository Structure

```
grizzarch/
├── arch.pkr.hcl                  # Packer HCL2 build template (migrated from arch.json)
├── http/                         # Files served via Packer's built-in HTTP server
│   │                             # (downloaded with curl during live-ISO boot phase)
│   ├── set_up_drives_LVM_on_LUKS.sh   # Partition, LUKS-encrypt, create LVM PV/VG/LVs
│   ├── arch-install.sh                # pacstrap base system, generate fstab
│   ├── configure-arch.sh              # chroot: locale, hostname, network, GRUB, mkinitcpio
│   ├── setup-arch-user.sh             # chroot: create user, configure sshd, sudoers
│   ├── swap-file-setup.sh             # chroot: create swapfile
│   ├── move_files_to_new_install.sh   # Move staged scripts into /mnt before chroot
│   ├── mkinitcpio-custom.conf         # Custom initramfs hooks (systemd + sd-encrypt + sd-lvm2)
│   ├── linux.preset                   # mkinitcpio preset for the linux kernel
│   └── sfdisk_input.conf              # Partition layout (1 GB EFI + rest for LUKS)
│
└── ssh/                          # Files deployed by Packer over SSH after first boot
    ├── other_packages.sh              # Install Sway, foot, wofi, PipeWire, git, vim, etc.
    ├── create_directories_user.sh     # Scaffold per-user config dirs (sway, foot, i3status)
    ├── create_directories_root.sh     # Scaffold system dirs (/etc/skel, etc.)
    ├── download_wallpaper.sh          # Optional: curl a wallpaper URL
    ├── install_yay.sh                 # AUR helper (not wired into arch.pkr.hcl by default)
    ├── sway_conf                      # Sway window manager config (keybinds, gaps, bar, output modes)
    ├── foot.ini                       # foot terminal config (colours, font, scrollback)
    ├── i3status_conf_vb               # i3status config for VirtualBox (no CPU temp, used with swaybar)
    ├── i3status_conf_native           # i3status config for physical hardware (with CPU temp)
    ├── .bash_profile                  # Auto-starts Sway on TTY1; sets VirtualBox Wayland env vars
    └── useradd_conf                   # /etc/default/useradd override (sets SKEL to skel_grizzarch)
```

---

## Build Pipeline

The Packer build follows this sequence:

1. **Boot phase** (`boot_command` in `arch.pkr.hcl`)
   - Packer boots the Arch live ISO in VirtualBox.
   - Scripts are downloaded from Packer's built-in HTTP server (`http/` directory).
   - `set_up_drives_LVM_on_LUKS.sh` partitions `/dev/sda`, formats, encrypts with LUKS, and creates the LVM layout.
   - `arch-install.sh` runs `pacstrap`, copies the custom mkinitcpio config.
   - `move_files_to_new_install.sh` copies scripts into `/mnt` for the chroot phase.
   - `arch-chroot /mnt` is entered; `configure-arch.sh`, `swap-file-setup.sh`, `setup-arch-user.sh` run inside the chroot.
   - `virtualbox-guest-utils` is installed and the machine reboots into the new install.

2. **SSH provisioner phase** (`build` block in `arch.pkr.hcl`)
   - Packer connects over SSH to the new install.
   - Shell scripts in `ssh/` install packages, create directories, and configure the desktop.
   - File provisioners upload config files (Sway config, foot config, `.bash_profile`, etc.).

### Key Packer Variables

| Variable | Default | Purpose |
|---|---|---|
| `arch_user` | `testuser` | Primary user account name |
| `arch_pass` | `testpass12` | User + sudo password |
| `encryption_pass` | `testpass12` | LUKS encryption passphrase |
| `hostname` | `grizzarch` | Machine hostname |
| `arch_vol_grp_name` | `GrizzVolGrp` | LVM volume group name |
| `root_size` | `8GB` | Size of root LV |
| `memory` / `cpus` | `4096` / `2` | VirtualBox VM resources |
| `wallpaper_url` | _(empty)_ | Optional URL for wallpaper download |

---

## Encryption Architecture

- **Scheme**: LVM on LUKS ([ArchWiki ref](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS))
- `/dev/sda1` — 1 GB EFI partition (FAT32/vfat, mounted at `/boot`)
- `/dev/sda2` — Remainder, LUKS-encrypted, containing an LVM PV
  - `GrizzVolGrp/root` — root filesystem (ext4, configurable size)
  - `GrizzVolGrp/home` — home filesystem (ext4, remainder)
- A **keyfile** (`/boot/keyfile`, mode `0400`) is used so the bootloader can unlock LUKS without a passphrase prompt at every boot.
- **mkinitcpio hooks** (`mkinitcpio-custom.conf`): `base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt sd-lvm2 filesystems fsck`
- GRUB passes `rd.luks.name`, `rd.luks.options`, `rd.luks.key`, and `root=` kernel parameters.

> **Never remove or alter the LUKS/LVM/mkinitcpio setup without thoroughly testing the result boots.** The keyfile path in `/boot` must remain consistent with the GRUB kernel parameters.

---

## Current Desktop Stack

| Component | Package | Notes |
|---|---|---|
| Display protocol | Wayland | Via wlroots (Sway's compositor) |
| X11 compatibility | `xorg-xwayland` | For X11 apps that don't support Wayland |
| Window manager | `sway` | Config at `~/.config/sway/config` |
| Status bar | `swaybar` + `i3status` | i3status format is identical for swaybar |
| Terminal | `foot` | Wayland-native; config at `~/.config/foot/foot.ini` |
| App launcher | `wofi` | `$mod+d`; Wayland-native dmenu replacement |
| Audio | `pipewire` + `pipewire-pulse` | `pactl` still works for volume control |
| Font | `ttf-droid` | Droid Sans Mono |

---

## VirtualBox Wayland Compatibility

Sway/wlroots requires two env vars to work correctly in VirtualBox. These are set in `ssh/.bash_profile` before `exec sway`:

```bash
export WLR_NO_HARDWARE_CURSORS=1   # Prevents cursor rendering issues
export WLR_RENDERER=pixman         # Software rendering (VirtualBox lacks Wayland GPU support)
```

> On physical hardware, `WLR_RENDERER=pixman` uses software rendering (slower). Remove this line when running on real hardware with a compatible GPU.

In the Sway config, VirtualBox output names are `Virtual-1`, `Virtual-2`, `Virtual-3` (Wayland/Sway naming convention). Use `swaymsg -t get_outputs` to confirm.

---

## Resolved Items

These items from the previous audit have been fixed:

| # | Item | Resolution |
|---|---|---|
| 1 | `termite` (deprecated, removed from repos) | Replaced with `foot` |
| 2 | Packer JSON template format deprecated | Migrated to `arch.pkr.hcl` (HCL2) |
| 3 | `iso_checksum_url` / `iso_checksum_type` deprecated fields | Replaced with `iso_checksum = "file:..."` using sha256sums.txt |
| 4 | `i3-gaps` replaced by Sway | Complete: Sway + Wayland stack installed |
| 5 | fstab `/boot` entry listed as `ext4` (should be `vfat`) | Fixed in `configure-arch.sh` |
| 6 | `NETDEVNAME=$(ls /sys/class/net)` captures `lo` | Fixed: uses `grep -v lo \| head -1` |
| 7 | `ssh_timeout = "1m"` too short | Changed to `"20m"` |
| 8 | `vb_x_conf_file_name` stale variable | Removed (X11 configs removed with Wayland migration) |
| 9 | `mkfs.ext4 /dev/sda2` before LUKS is a no-op | Removed from `set_up_drives_LVM_on_LUKS.sh` |
| 10 | `pacman -Sy` without `-u` is dangerous | Changed to `pacman -Syu` |
| 11 | `xcompmgr`, `.xinitrc`, X11 conf files | Removed with Wayland migration |

---

## Remaining / Future Work

| # | Item | Notes |
|---|---|---|
| 1 | ARCHISO physical hardware installer | Create `archiso/` profile packaging the install scripts for USB boot |
| 2 | `user-setup.sh` ghost curl in boot_command | Was removed in HCL2 migration (didn't exist in http/) |
| 3 | `pacman -Sy` in boot_command for `virtualbox-guest-utils` | Minor: this is in the live ISO context before chroot, less risky but could be `-Syu` |
| 4 | `WLR_RENDERER=pixman` for physical hardware | Should be removed for physical installs (software renderer is slow) |

---

## Coding Conventions

- **Shell scripts**: plain bash, POSIX-compatible where possible. Use `getopts` for argument parsing (existing pattern).
- **No package manager other than `pacman`** for base install scripts. AUR helpers (`yay`) are post-install only.
- **Self-documenting scripts**: comment non-obvious steps; the goal is that scripts can be run manually without Packer.
- **Idempotency is not guaranteed**: scripts are designed for a single run during image build.
- **Secrets**: never hard-code credentials in scripts; always read them from Packer variables passed as arguments.
- **Packer template**: HCL2 format (`arch.pkr.hcl`). Do not create a new `arch.json`.

---

## How to Build

```bash
# Install Packer first: https://developer.hashicorp.com/packer/install
packer build ./arch.pkr.hcl

# With custom credentials:
packer build \
  -var 'arch_user=myuser' \
  -var 'arch_pass=mysecurepass' \
  -var 'encryption_pass=myencpass' \
  ./arch.pkr.hcl
```

Output goes to `output-virtualbox-iso/`. Import the `.ovf` into VirtualBox.

> The `packer_cache/` and `output-virtualbox-iso/` directories are `.gitignore`d to prevent accidental VHD commits.

---

## Security Reminders

- Change `arch_pass` (user password) and `encryption_pass` (LUKS passphrase) **before** any real use.
- The keyfile at `/boot/keyfile` unlocks LUKS automatically. Anyone with physical access to the boot partition can unlock the disk. Keep this in mind for threat modelling.
- `PasswordAuthentication yes` is set in `sshd_config` for the build; disable it or restrict it after initial setup.


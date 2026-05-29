# Welcome to grizzarch

`grizzarch` is a personal, automated Arch Linux build system. It uses [Packer](https://www.packer.io/) to produce a fully-configured, encrypted VirtualBox image from a raw Arch ISO — no manual install steps required.

> **⚠️ This repo is currently undergoing a major modernization.** Several packages are deprecated and the desktop stack is being migrated from i3/X11 to Sway/Wayland. See the [open issues](../../issues) for the full plan.

> **🔐 CHANGE THE LUKS AND USER PASSWORD AFTER FIRST BOOT.** Default credentials are intentionally insecure. [See security notes.](#security)

---

## Philosophy

> **"Default first"** — use stock defaults until there is a specific reason not to.

With Arch there isn't much that comes standard, but `systemd` covers a lot of ground. `systemd-networkd` and `systemd-resolved` handle networking instead of third-party tools.

---

## What's in the box

| Component | Package | Notes |
|---|---|---|
| Bootloader | GRUB (UEFI, `--removable`) | Produces a portable `.ovf` |
| Encryption | LVM on LUKS | `/dev/sda2` encrypted; keyfile in `/boot` |
| Init / networking | systemd, networkd, resolved | No NetworkManager |
| Window manager | Sway (Wayland) *(in progress — currently i3)* | |
| Status bar | swaybar / i3status | |
| Terminal | foot *(in progress — currently termite)* | |
| App launcher | wofi *(in progress — currently dmenu)* | |
| Wallpaper | swaybg *(in progress — currently feh)* | |

New users inherit the default config via `/etc/skel_grizzarch/`. The standard `/etc/skel/` is left intact.

---

## Prerequisites

- [Packer](https://developer.hashicorp.com/packer/install) ≥ 1.7 (HCL2 template support)
- [VirtualBox](https://www.virtualbox.org/) ≥ 6.1
- An internet connection (the build downloads the Arch ISO and packages)

---

## Quick start

### 1. Clone the repo

```bash
git clone https://github.com/sonictt1/grizzarch.git
cd grizzarch
```

### 2. (Optional) Customise the build variables

Open `arch.json` and edit the `variables` block. The most important ones:

| Variable | Default | What it controls |
|---|---|---|
| `arch_user` | `testuser` | Primary username |
| `arch_pass` | `testpass12` | User password (change this!) |
| `encryption_pass` | `testpass12` | LUKS passphrase (change this!) |
| `hostname` | `grizzarch` | Machine hostname |
| `memory` | `4096` | VM RAM in MB |
| `cpus` | `2` | VM CPU count |
| `root_size` | `8GB` | Size of the root logical volume |
| `wallpaper_url` | *(empty)* | URL to download a wallpaper image |

You can also override variables at build time without editing the file:

```bash
packer build \
  -var 'arch_user=myuser' \
  -var 'arch_pass=mysecurepass' \
  -var 'encryption_pass=myencpass' \
  ./arch.json
```

### 3. Run the build

```bash
packer build ./arch.json
```

The build will:
1. Download the Arch ISO.
2. Boot it in VirtualBox and run the install scripts from `http/`.
3. Partition `/dev/sda`, set up LVM on LUKS, run `pacstrap`, configure GRUB.
4. Reboot into the new install and run the provisioner scripts from `ssh/`.
5. Export a `.ovf` file to `output-virtualbox-iso/`.

A full build takes roughly 15–30 minutes depending on your machine and internet speed.

### 4. Import the image

Open VirtualBox → File → Import Appliance → select the `.ovf` from `output-virtualbox-iso/`.

### 5. Change your passwords after first boot

```bash
# Change LUKS passphrase
cryptsetup luksChangeKey /dev/sda2

# Change user password
passwd
```

---

## Repository layout

```
grizzarch/
├── arch.json          # Packer build template
├── http/              # Scripts/files downloaded via curl during live-ISO phase
│   ├── set_up_drives_LVM_on_LUKS.sh
│   ├── arch-install.sh
│   ├── configure-arch.sh
│   ├── setup-arch-user.sh
│   ├── swap-file-setup.sh
│   ├── move_files_to_new_install.sh
│   ├── mkinitcpio-custom.conf
│   ├── linux.preset
│   └── sfdisk_input.conf
└── ssh/               # Scripts/configs deployed over SSH after first boot
    ├── other_packages.sh
    ├── create_directories_user.sh
    ├── create_directories_root.sh
    ├── download_wallpaper.sh
    ├── install_yay.sh
    ├── i3_conf / sway_conf (→ in progress)
    ├── i3status_conf_vb / i3status_conf_native
    ├── term_conf
    ├── .bash_profile
    ├── .xinitrc (→ being replaced by Wayland session)
    └── useradd_conf
```

See [`.github/copilot-instructions.md`](.github/copilot-instructions.md) for the full technical reference used by GitHub Copilot.

---

## Encryption architecture

- **Scheme**: [LVM on LUKS](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS)
- `/dev/sda1` — 1 GB EFI partition (FAT32, mounted at `/boot`)
- `/dev/sda2` — LUKS-encrypted physical volume containing an LVM volume group
  - `GrizzVolGrp/root` — root filesystem (configurable size, default 8 GB)
  - `GrizzVolGrp/home` — home filesystem (remainder of disk)
- A **keyfile** at `/boot/keyfile` (mode `0400`) allows LUKS to unlock at boot without a manual passphrase.
- **mkinitcpio hooks**: `base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt sd-lvm2 filesystems fsck`
- GRUB kernel parameters: `rd.luks.name`, `rd.luks.options`, `rd.luks.key`, `root=`

---

## Decisions

- **No XDG default folders** — I'm particular about home directory organisation; XDG defaults get in the way.
- **systemd-first** — `systemd-networkd` and `systemd-resolved` instead of NetworkManager or dhcpcd.
- **Scripts over config management** — plain bash scripts so the install can be reproduced without Packer.

---

## Security

**Default credentials (change immediately after first boot):**

| Variable in `arch.json` | What it sets |
|---|---|
| `arch_pass` | User login password |
| `encryption_pass` | LUKS disk encryption passphrase |

```bash
# Change LUKS passphrase
cryptsetup luksChangeKey /dev/sda2

# Change user password
passwd
```

> The keyfile at `/boot/keyfile` auto-unlocks the encrypted disk. Anyone with access to the boot partition can decrypt the disk. This is a convenience trade-off — for high-security scenarios, remove the keyfile and use a passphrase prompt instead.

> `PasswordAuthentication yes` is set in `sshd_config` for the Packer build to connect. Disable it or switch to key-based auth after setup.

---

## Future plans

- Steam + Proton
- Android Studio
- Plug-and-play `/home/$USER` on a separate VHD
- ARCHISO image for installing to physical hardware from a USB drive

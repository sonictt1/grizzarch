# arch.pkr.hcl — Packer HCL2 template for grizzarch
# Migrated from arch.json (Packer legacy JSON format deprecated in Packer ≥ 1.7)
#
# Usage:
#   packer build ./arch.pkr.hcl
#   packer build -var 'arch_pass=mysecurepass' -var 'encryption_pass=myencpass' ./arch.pkr.hcl

locals {
  year_month  = formatdate("YYYY.MM", timestamp())
  year_month_us = formatdate("YYYY_MM", timestamp())

  iso_url = "https://mirrors.ocf.berkeley.edu/archlinux/iso/${local.year_month}.01/archlinux-${local.year_month}.01-x86_64.iso"

  # Use sha256sums.txt (sha1sums.txt is deprecated on Arch mirrors)
  iso_checksum = "file:https://mirrors.ocf.berkeley.edu/archlinux/iso/${local.year_month}.01/sha256sums.txt"

  vm_name              = "grizzarch-automated-${formatdate("YYYY-MM-DD-hhmmss", timestamp())}"
  arch_iso_target_path = "${var.arch_iso_path}/${var.arch_iso_filename}_${local.year_month_us}_01.iso"
}

# ─────────────────────────────────────────────
# Variables
# ─────────────────────────────────────────────

variable "ssh_timeout" {
  type    = string
  default = "20m"
  description = "How long Packer waits for SSH after reboot. Keep at 20m minimum."
}

variable "ssh_port" {
  type    = string
  default = "22"
}

variable "country" {
  type    = string
  default = "US"
  description = "Timezone continent (e.g. US, Europe)"
}

variable "region" {
  type    = string
  default = "Central"
  description = "Timezone region (e.g. Central, London)"
}

variable "headless" {
  type    = bool
  default = false
  description = "Run VirtualBox without a GUI window"
}

variable "arch_user" {
  type    = string
  default = "testuser"
  description = "Primary Linux user account name"
}

variable "arch_pass" {
  type      = string
  default   = "testpass12"
  sensitive = true
  description = "User password — CHANGE THIS before any real use"
}

variable "encryption_pass" {
  type      = string
  default   = "testpass12"
  sensitive = true
  description = "LUKS encryption passphrase — CHANGE THIS before any real use"
}

variable "arch_iso_filename" {
  type    = string
  default = "arch_amd64"
  description = "Base filename for the cached Arch ISO (date is appended automatically)"
}

variable "arch_iso_path" {
  type    = string
  default = "packer_cache"
  description = "Directory in which to cache the downloaded Arch ISO"
}

variable "output_path" {
  type    = string
  default = "output-virtualbox-iso"
  description = "Directory where the final .ovf image is written"
}

variable "memory" {
  type    = number
  default = 4096
  description = "VM RAM in MB"
}

variable "cpus" {
  type    = number
  default = 2
  description = "VM CPU count"
}

variable "root_size" {
  type    = string
  default = "8GB"
  description = "Size of the LVM root logical volume"
}

variable "hostname" {
  type    = string
  default = "grizzarch"
  description = "Machine hostname"
}

variable "arch_vol_grp_name" {
  type    = string
  default = "GrizzVolGrp"
  description = "LVM volume group name"
}

variable "temp_install_script_folder_name" {
  type    = string
  default = "temp_install_scripts"
  description = "Folder inside /mnt used to stage chroot scripts"
}

variable "skip_export" {
  type    = bool
  default = false
  description = "If true, skip exporting the .ovf (useful for local testing)"
}

variable "vbox_graphics_controller" {
  type    = string
  default = "vmsvga"
  description = "VirtualBox graphics controller type"
}

variable "vbox_vram_mb" {
  type    = number
  default = 16
  description = "VirtualBox video RAM in MB"
}

variable "wallpaper_url" {
  type    = string
  default = ""
  description = "Optional URL to download a wallpaper image"
}

variable "mkinitcpio_filename" {
  type    = string
  default = "mkinitcpio-custom.conf"
  description = "Custom mkinitcpio config filename"
}

variable "mkinitcpio_pacman_preset_filename" {
  type    = string
  default = "linux.preset"
  description = "mkinitcpio pacman preset filename"
}

# ─────────────────────────────────────────────
# Source
# ─────────────────────────────────────────────

source "virtualbox-iso" "grizzarch" {
  iso_url              = local.iso_url
  iso_checksum         = local.iso_checksum
  iso_target_path      = local.arch_iso_target_path
  guest_os_type        = "ArchLinux_64"
  guest_additions_mode = "disable"
  http_directory       = "http"
  boot_wait            = "3s"
  disk_size            = 20480
  hard_drive_interface = "sata"
  ssh_username         = var.arch_user
  ssh_password         = var.arch_pass
  ssh_timeout          = var.ssh_timeout
  shutdown_command     = "echo '${var.arch_pass}' | sudo -S shutdown now"
  headless             = var.headless
  cpus                 = var.cpus
  memory               = var.memory
  vm_name              = local.vm_name
  output_directory     = var.output_path
  skip_export          = var.skip_export

  # Boot sequence: download scripts over Packer's HTTP server, run the install pipeline
  boot_command = [
    "<up><up><enter><wait50>",
    "/usr/bin/curl -O http://${build.PackerHTTPIP}:${build.PackerHTTPPort}/set_up_drives_LVM_on_LUKS.sh<enter><wait3>",
    "/usr/bin/curl -O http://${build.PackerHTTPIP}:${build.PackerHTTPPort}/arch-install.sh<enter><wait3>",
    "/usr/bin/curl -O http://${build.PackerHTTPIP}:${build.PackerHTTPPort}/sfdisk_input.conf<enter><wait3>",
    "/usr/bin/curl -O http://${build.PackerHTTPIP}:${build.PackerHTTPPort}/mkinitcpio-custom.conf<enter><wait3>",
    "/usr/bin/curl -O http://${build.PackerHTTPIP}:${build.PackerHTTPPort}/configure-arch.sh<enter><wait3>",
    "/usr/bin/curl -O http://${build.PackerHTTPIP}:${build.PackerHTTPPort}/setup-arch-user.sh<enter><wait3>",
    "/usr/bin/curl -O http://${build.PackerHTTPIP}:${build.PackerHTTPPort}/swap-file-setup.sh<enter><wait3>",
    "/usr/bin/curl -O http://${build.PackerHTTPIP}:${build.PackerHTTPPort}/move_files_to_new_install.sh<enter><wait3>",
    "/usr/bin/curl -O http://${build.PackerHTTPIP}:${build.PackerHTTPPort}/linux.preset<enter><wait3>",
    "chown root ./*.sh<enter><wait2>",
    "chmod 744 ./*.sh<enter><wait2>",
    "/usr/bin/bash ./set_up_drives_LVM_on_LUKS.sh -p ./sfdisk_input.conf -g ${var.arch_vol_grp_name} -d \"/dev/sda\" -r \"${var.root_size}\" -P ${var.encryption_pass}<enter><wait15>",
    "/usr/bin/bash ./arch-install.sh -f '${var.mkinitcpio_filename}' -p \".\" -c \".\" -n '${var.mkinitcpio_pacman_preset_filename}'<wait1><enter><wait145>",
    "/usr/bin/bash ./move_files_to_new_install.sh -n ${var.temp_install_script_folder_name}<enter><wait3>",
    "arch-chroot /mnt<enter><wait3>",
    "./${var.temp_install_script_folder_name}/configure-arch.sh -c '${var.country}' -r '${var.region}' -h ${var.hostname} -g ${var.arch_vol_grp_name} -m ${var.mkinitcpio_filename}<enter><wait30>",
    "./${var.temp_install_script_folder_name}/swap-file-setup.sh<enter><wait3>",
    "./${var.temp_install_script_folder_name}/setup-arch-user.sh -s ${var.ssh_port} -u ${var.arch_user} -p ${var.arch_pass}<enter><wait10>",
    "rm -r ${var.temp_install_script_folder_name}<enter><wait5>",
    "pacman -Sy --noconfirm virtualbox-guest-utils<enter><wait60>",
    "exit<enter><wait5>",
    "efibootmgr --bootnum 0001 --inactive<enter><wait4>",
    "reboot now<enter><wait100>"
  ]

  # Force EFI boot (required for the GRUB --removable install)
  vboxmanage = [
    ["modifyvm", "${local.vm_name}", "--firmware", "efi64"]
  ]

  # Set graphics controller and VRAM after build (vmsvga required for VirtualBox additions)
  vboxmanage_post = [
    ["modifyvm", "${local.vm_name}", "--graphicscontroller", "${var.vbox_graphics_controller}", "--vram", "${var.vbox_vram_mb}"]
  ]
}

# ─────────────────────────────────────────────
# Build
# ─────────────────────────────────────────────

build {
  sources = ["source.virtualbox-iso.grizzarch"]

  # Create per-user config directories
  provisioner "shell" {
    script          = "ssh/create_directories_user.sh"
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} {{ .Path }} -u ${var.arch_user}"
  }

  # Create system-level directories and install all packages
  provisioner "shell" {
    scripts = [
      "ssh/create_directories_root.sh",
      "ssh/other_packages.sh"
    ]
    execute_command = "chmod +x {{ .Path }}; echo '${var.arch_pass}' | sudo -S {{ .Vars }} {{ .Path }}"
  }

  # Optionally download a wallpaper
  provisioner "shell" {
    script          = "ssh/download_wallpaper.sh"
    execute_command = "chmod +x {{ .Path }}; echo '${var.arch_pass}' | sudo -S {{ .Vars }} {{ .Path }} -u ${var.arch_user} -p ${var.wallpaper_url}"
  }

  # Shell login profile (auto-starts Sway on TTY1)
  provisioner "file" {
    source      = "ssh/.bash_profile"
    destination = "/home/${var.arch_user}/.bash_profile"
  }

  # Sway window manager config
  provisioner "file" {
    source      = "ssh/sway_conf"
    destination = "/home/${var.arch_user}/.config/sway/config"
  }

  # foot terminal config
  provisioner "file" {
    source      = "ssh/foot.ini"
    destination = "/home/${var.arch_user}/.config/foot/foot.ini"
  }

  # i3status config for swaybar — VirtualBox variant (no CPU temperature)
  provisioner "file" {
    source      = "ssh/i3status_conf_vb"
    destination = "/home/${var.arch_user}/.config/i3status/config"
    only        = ["virtualbox-iso.grizzarch"]
  }

  # useradd defaults (sets SKEL to /etc/skel_grizzarch so new users inherit config)
  provisioner "file" {
    source      = "ssh/useradd_conf"
    destination = "/home/${var.arch_user}/useradd"
  }

  provisioner "shell" {
    inline          = ["mv /home/${var.arch_user}/useradd /etc/default/useradd"]
    execute_command = "chmod +x {{ .Path }}; echo '${var.arch_pass}' | sudo -S {{ .Vars }} {{ .Path }}"
  }

  # Enable VirtualBox guest services (VirtualBox builds only)
  provisioner "shell" {
    only            = ["virtualbox-iso.grizzarch"]
    inline          = ["systemctl enable vboxservice"]
    execute_command = "chmod +x {{ .Path }}; echo '${var.arch_pass}' | sudo -S {{ .Vars }} {{ .Path }}"
  }

  # Copy the user's config to /etc/skel_grizzarch/ so new users inherit it
  provisioner "shell" {
    inline          = ["cp -a /home/${var.arch_user}/. /etc/skel_grizzarch/"]
    execute_command = "chmod +x {{ .Path }}; echo '${var.arch_pass}' | sudo -S {{ .Vars }} {{ .Path }}"
  }
}

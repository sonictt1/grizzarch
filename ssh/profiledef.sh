#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="grizzarch"
iso_label="GRIZZARCH_$(date +%Y%m)"
iso_publisher="Nic"
iso_application="grizzarch install media"
iso_version="$(date +%Y.%m.%d)"
install_dir="grizzarch"
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"

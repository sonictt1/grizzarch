#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="grizzarch"
iso_label="GRIZZARCH_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="grizzarch <https://github.com/sonictt1/grizzarch>"
iso_application="Grizzarch Live/Install ISO"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
           'uefi-ia32.grub.esp' 'uefi-x64.systemd-boot.esp'
           'uefi-ia32.grub.eltorito' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--long' '-19')
file_permissions=(
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/grizzarch.json"]="0:0:644"
  ["/root/grizzarch-creds.json"]="0:0:600"
  ["/root/grizzarch-scripts"]="0:0:755"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
)

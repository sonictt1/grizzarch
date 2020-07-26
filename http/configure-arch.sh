while getopts c:r:h:g: option
    do 
        case "${option}"
            in
                c) COUNTRY=${OPTARG};;
                r) REGION=${OPTARG};;
                h) HOSTNAME=${OPTARG};;
                g) VOLGRPNAME=${OPTARG};;
        esac
    done

# Update pacman stuff
pacman -Syu --noconfirm

# Add mappers to fstab
echo "/dev/mapper/root	/	ext4	defaults	0	1" >> /etc/fstab
echo "/dev/sda1	/boot	ext4	defaults	0	2" >> /etc/fstab
# echo "/dev/mapper/tmp	/tmp	tmpfs	defaults	0	0" >> /etc/fstab
# echo "tmp	/dev/$VOLGRPNAME/crypttmp	/dev/urandom	tmp,cipher=aes-xts-plain64,size=256" >> /etc/crypttab

# Set the time zone
ln -sf /usr/share/zoneinfo/$COUNTRY/$REGION /etc/localtime
hwclock --systohc

# Set locale
echo "Backing up locale file"
cp /etc/locale.gen /etc/locale_backup.gen

echo "Touching locale.conf"
touch /etc/locale.conf

echo "Writing to locale.gen"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen

echo "Writing to locale.conf"
echo "LANG=\"en_US.UTF-8\"" >> /etc/locale.conf

echo "running locale-gen"
locale-gen

# Set hostname
# touch /etc/hostname
echo $HOSTNAME >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1  localhost" >> /etc/hosts
echo "127.0.0.1 $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts
# cat /etc/hosts

NETDEVNAME=$(ls /sys/class/net)
systemctl enable systemd-networkd
systemctl enable systemd-resolved
echo "[Match]" >> /etc/systemd/network/default-vbox-wired.network
echo "Name=$NETDEVNAME" >> /etc/systemd/network/default-vbox-wired.network
echo "\n" >> /etc/systemd/network/default-vbox-wired.network
echo "[Network]" >> /etc/systemd/network/default-vbox-wired.network
echo "DHCP=yes" >> /etc/systemd/network/default-vbox-wired.network

echo "------------- Install grub and set-up boot process ------------"
# Add encryption kernel params to bootloader 

# Get UUID for root 
SDABOOTUUID=$(blkid -s UUID -o value /dev/sda2)

LUKSNAME="rd.luks.name=$SDABOOTUUID=cryptlvm"
LUKSOPTIONS="rd.luks.options=$SDABOOTUUID=options"
LUKSROOTFS="root=/dev/$VOLGRPNAME/root"
LUKSKEY="rd.luks.key=$SDABOOTUUID=/boot/keyfile"

# Install grub 
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --removable
echo "GRUB_CMDLINE_LINUX_DEFAULT=\"$LUKSNAME $LUKSOPTIONS $LUKSROOTFS $LUKSKEY\"" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Move keyfile to boot partition
mv /keyfile /boot/keyfile

# Create empty vconsole config to avoid mkinitcpio error
touch /etc/vconsole.conf

# Regenerate mkinitcpio image and replace the default
KERNELVER=$(ls /lib/modules/)
mkinitcpio -c /etc/mkinitcpio-custom.conf -k $KERNELVER -g /boot/initramfs-linux.img

chmod 0400 /boot/keyfile
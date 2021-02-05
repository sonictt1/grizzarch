while getopts f:p:c:n: option
    do 
        case "${option}"
            in
                f) MKINITCPIOCONFNAME=${OPTARG};;
                p) MKINITCPIOCONFPATH=${OPTARG};;
                c) MKINITCPIOPACMANPRESETPATH=${OPTARG};;
                n) MKINITCPIOPACMANPRESETNAME=${OPTARG};;
        esac
    done

# Bootstrap Arch
echo "------------- Beginning Arch bootstrap now -------------"
pacstrap /mnt base linux linux-firmware base-devel grub efibootmgr lvm2 sudo openssh devtools go

# Generate fstab
echo "------------- pacstrap complete, moving/generating config files ------------"
genfstab -U /mnt >> /mnt/etc/fstab

# Move our early ramfs config from staging to the new arch install
mv $MKINITCPIOCONFPATH/$MKINITCPIOCONFNAME /mnt/etc/$MKINITCPIOCONFNAME
mv -f $MKINITCPIOPACMANPRESETPATH/$MKINITCPIOPACMANPRESETNAME /mnt/etc/mkinitcpio.d/linux.preset
sed -i "s/{mkinitcpio-name}/$MKINITCPIOCONFNAME/g" /mnt/etc/mkinitcpio.d/linux.preset
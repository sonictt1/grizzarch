while getopts p:P:g:d:r: option
    do 
        case "${option}"
            in
                p) SFD_FP=${OPTARG};;
                P) ENPASS=${OPTARG};;
                g) VOLGROUPNAME=${OPTARG};;
                d) TARGETDEVICE=${OPTARG};;
                r) ROOTSIZE=${OPTARG};;
        esac
    done

# Write starting LUKS key to keyfile
echo $ENPASS >> /root/keyfile

# Partition drives 
sfdisk $TARGETDEVICE < $SFD_FP

# touch /keyfile
# dd if=/dev/urandom of=/keyfile bs=1024 count=4
chown $USER /root/keyfile

# Format & encrypt physical volume
mkfs.ext4 /dev/sda2
cryptsetup -q --key-file /root/keyfile luksFormat /dev/sda2
cryptsetup -q --key-file /root/keyfile open /dev/sda2 cryptlvm
pvcreate /dev/mapper/cryptlvm

# Create volume group
vgcreate $VOLGROUPNAME /dev/mapper/cryptlvm

# Create logical columes inside volume group
lvcreate -L $ROOTSIZE $VOLGROUPNAME -n root
lvcreate -l 100%FREE $VOLGROUPNAME -n home

# Format logical volumes 
mkfs.ext4 /dev/$VOLGROUPNAME/root
mkfs.ext4 /dev/$VOLGROUPNAME/home

# Make home dir and mount logical volumes
mount /dev/$VOLGROUPNAME/root /mnt
mkdir /mnt/home
mount /dev/$VOLGROUPNAME/home /mnt/home

# Prepare boot partition
mkdir /mnt/boot
mkfs.fat -F32 /dev/sda1
mount /dev/sda1 /mnt/boot

# Move keyfile into 
cp /root/keyfile /mnt/keyfile

# Clean-up
rm -r /mnt/lost+found/
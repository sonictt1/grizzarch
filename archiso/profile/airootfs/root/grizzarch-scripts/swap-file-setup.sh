#########################################################
#### Intended to be ran as root before user creation ####
######## Sets up a swapfile (no swap partition) #########
#########################################################

# Allocate space for swapfile in root
fallocate -l 1.5G /swapfile

# Wrench down permissions of swapfile
chmod 600 /swapfile

# Format file for swap
mkswap /swapfile

# Edit fstab file for swapfile
echo "# Swapfile" >> /etc/fstab
echo "/swapfile none swap defaults 0 0" >> /etc/fstab
echo ""  >> /etc/fstab
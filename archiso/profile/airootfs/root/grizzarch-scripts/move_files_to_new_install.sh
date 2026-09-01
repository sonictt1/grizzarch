while getopts n: option
    do 
        case "${option}"
            in
                n) FLDRNM=${OPTARG};;
        esac
    done

mkdir /mnt/$FLDRNM
mv ./configure-arch.sh /mnt/$FLDRNM/configure-arch.sh
mv ./setup-arch-user.sh /mnt/$FLDRNM/setup-arch-user.sh
mv ./swap-file-setup.sh /mnt/$FLDRNM/swap-file-setup.sh
while getopts u: option
    do 
        case "${option}"
            in
                u) USERNAME=${OPTARG};;
        esac
    done

# fetch pkgbuild
cd /home/$USERNAME/ 
git clone https://aur.archlinux.org/yay.git
# build software
cd yay/
makepkg -si --noconfirm

cp *.pkg.tar.zst /home/$USERNAME/built_pkgs/
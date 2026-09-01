while getopts u: option
    do 
        case "${option}"
            in
                u) USER=${OPTARG};;
        esac
    done

git clone https://aur.archlinux.org/yay-git.git

sudo chown -R $USER:$USER ./yay-git

cd yay-git && makepkg -sic
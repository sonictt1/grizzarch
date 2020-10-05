while getopts u: option
    do 
        case "${option}"
            in
                u) USRNM=${OPTARG};;
        esac
    done

mkdir -p /home/$USRNM/.config/i3/
mkdir -p /home/$USRNM/.config/termite/
mkdir -p /home/$USRNM/.config/wallpapers/
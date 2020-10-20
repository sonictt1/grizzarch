while getopts u: option
    do 
        case "${option}"
            in
                u) USRNM=${OPTARG};;
        esac
    done

# The user will already be created so we need to 
# make these spaces ourselves
mkdir -p /home/$USRNM/.config/i3/
mkdir -p /home/$USRNM/.config/termite/
mkdir -p /home/$USRNM/.config/wallpapers/
mkdir -p /home/$USRNM/.config/i3status/
while getopts u:p: option
    do 
        case "${option}"
            in
                p) URL=${OPTARG};;
				u) USRNM=${OPTARG};;
        esac
    done

curl -o /home/$USRNM/.config/wallpapers/wallpaper.png $URL
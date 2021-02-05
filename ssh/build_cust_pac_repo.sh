while getopts u: option
    do 
        case "${option}"
            in
                u) USERNAME=${OPTARG};;
        esac
    done

dirlist=(`ls /home/$USERNAME/built_pkgs/`)
#Loop through list and add to database
for blt_pkg in ${dirlist[*]}
do
	repo-add -n /home/$USERNAME/grizzarch-repo.db.tar.gz /home/$USERNAME/built_pkgs/$blt_pkg
done


while getopts u: option
    do 
        case "${option}"
            in
                u) USERNAME=${OPTARG};;
        esac
    done

cp -r /usr/share/archiso/configs/releng/ /home/$USERNAME/grizzarch_mkiso/

ln -s /usr/lib/systemd/system/sshd.service /home/$USERNAME/grizzarch_mkiso/releng/airootfs/etc/systemd/system/multi-user.target.wants/
ln -s /usr/lib/systemd/system/systemd-networkd.service /home/$USERNAME/grizzarch_mkiso/releng/airootfs/etc/systemd/system/multi-user.target.wants/
ln -s /usr/lib/systemd/system/systemd-resolved.service /home/$USERNAME/grizzarch_mkiso/releng/airootfs/etc/systemd/system/multi-user.target.wants/
ln -s /usr/lib/systemd/system/vboxservice.service /home/$USERNAME/grizzarch_mkiso/releng/airootfs/etc/systemd/system/multi-user.target.wants/


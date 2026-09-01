######################################################
#   PLEASE NOTE: Change the user password on first   #
#      login. This password will not be secure.      #
######################################################

while getopts u:p:s: option
    do 
        case "${option}"
            in
                u) USERNAME=${OPTARG};;
                p) STARTPASS=${OPTARG};;
				s) SSHPORT=${OPTARG};;
        esac
    done

useradd -m $USERNAME
echo "$USERNAME:$STARTPASS" | chpasswd
echo "%$USERNAME ALL=(ALL) ALL" >> /etc/sudoers


systemctl enable sshd
echo "AllowUsers $USERNAME" >> /etc/ssh/sshd_config
echo "AllowAgentForwarding yes" >> /etc/ssh/sshd_config
echo "X11Forwarding yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

iptables -I INPUT 1 -p tcp --dport $SSHPORT -j ACCEPT
echo "DNSSEC=no" >> /etc/systemd/resolved.conf
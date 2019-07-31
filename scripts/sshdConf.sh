#!/bin/sh

# sources :
#
# - https://www.alsacreations.com/tuto/lire/622-Securite-firewall-iptables.html
#
#


TXTNORMAL="\033[0m"
TXTBLUE="\033[1;34m"
TXTRED="\033[1;31m"
TXTGREEN="\033[1;32m"

echo

# --------------------------------------------------------------------------------------------------------------
#                                   Activation nouveau ssh port
# --------------------------------------------------------------------------------------------------------------

if [ $# -ge 1 ]
then
    ENABLED_PORT=$1
else
    printf "Please enter port number to enable: "
    read ENABLED_PORT
fi

printf "*** Enable Port: $ENABLED_PORT: $TXTGREEN sudo semanage port -a -t ssh_port_t -p tcp $ENABLED_PORT\n$TXTNORMAL"
sudo yum install -y policycoreutils-python
sudo semanage port -a -t ssh_port_t -p tcp $ENABLED_PORT

#echo
#printf "Press any key to continue"
#read anyKey
echo

# --------------------------------------------------------------------------------------------------------------
#                                           Configuration SSH. Fichier /etc/ssh/sshd_config
# --------------------------------------------------------------------------------------------------------------
# Afin de sécuriser l'accès SSH au serveur, éditons le fichier /etc/ssh/sshd_config. Nous allons changer le port 
# de connexion par défaut pour éviter quelques attaques par bruteforce sur le port 22, qui est bien connu pour héberger
# ce service.

echo
printf "*** Starting SSH configuration\n"
echo

# Disable Root Logins
printf "  .Disable Root Logins: set $TXTGREEN PermitRootLogin no$TXTNORMAL in /etc/ssh/sshd_config\n"
sudo sed -i -e "s/^[#\t ]*PermitRootLogin[\t ]*.*\$/PermitRootLogin no/" '/etc/ssh/sshd_config'
echo

# Limit User Logins
#printf "Please enter authorized user list (user1 user2 ...): "
#read USER_LIST
#printf "  .Limit User Logins: set $TXTGREEN AllowUsers $USERLIST $TXTNORMAL  in /etc/ssh/sshd_config\n"
#sudo sed -i -e "s/^[#\t ]*AllowUsers[\t ]*.*\$/AllowUsers $USER_LIST/" '/etc/ssh/sshd_config'

# Disable Protocol 1 that is less secure than protocol 2
printf "  .Disable  Protocol 1: set $TXTGREEN Protocol 2$TXTNORMAL in /etc/ssh/sshd_config\n"
sudo sed -i -e "s/^[#\t ]*Protocol[\t ]*.*\$/Protocol 2/" '/etc/ssh/sshd_config'
echo

printf "  .Use a Non-Standard Port: $ENABLED_PORT set $TXTGREEN Port=$ENABLED_PORT $TXTNORMAL in /etc/ssh/sshd_config\n"
sudo sed -i -e "s/^[#\t ]*Port[\t ]*.*\$/Port=$ENABLED_PORT/" '/etc/ssh/sshd_config'

# Enable Public key Authentication
printf "  .Enable Public key Authentication: set $TXTGREEN PubkeyAuthentication yes$TXTNORMAL in /etc/ssh/sshd_config\n"
sudo sed -i -e "s/^[#\t ]*PubkeyAuthentication[\t ]*.*\$/PubkeyAuthentication yes/" '/etc/ssh/sshd_config'
echo

# Redémarrage du service SSH après ces modifications :
printf "*** Restarting SSH service: $TXTGREEN sudo systemctl start sshd\n$TXTNORMAL"
sudo systemctl restart sshd
echo

#echo
#printf "Press any key to continue"
#read anyKey
echo

# --------------------------------------------------------------------------------------------------------------
#                                   Change Firewalld ssh service
# --------------------------------------------------------------------------------------------------------------
printf "*** Changing Firewalld's ssh.xml to ssh-custom.xml:\n $TXTGREEN cp /usr/lib/firewalld/services/ssh.xml /etc/firewalld/services/ssh-custom.xml$TXTNORMAL"
sudo cp /usr/lib/firewalld/services/ssh.xml /etc/firewalld/services/ssh-custom.xml
echo

printf "Change the port line in ssh-custom.xml:\nset $TXTGREEN <port protocol=tcp port=$ENABLED_PORT> $TXTNORMAL in /etc/firewalld/services/ssh-custom.xml\n"
sudo sed -i -e "s/^[#\t ]*<port protocol[\t ]*.*\$/<port protocol=tcp port=$ENABLED_PORT>/" '/etc/firewalld/services/ssh-custom.xml'
echo

printf "Remove the ssh service: $TXTGREEN firewall-cmd --permanent --remove-service='ssh'\n"$TXTNORMAL
sudo firewall-cmd --permanent --remove-service='ssh'
echo

printf "Add the ssh-custom service: $TXTGREEN\tfirewall-cmd --permanent --add-service='ssh-custom'\n"$TXTNORMAL
sudo firewall-cmd --permanent --add-service='ssh-custom'
echo

printf "Reload firewalld: $TXTGREEN\tfirewall-cmd --reload\n"$TXTNORMAL
sudo firewall-cmd --reload
echo

#echo
#printf "Press any key to continue"
#read anyKey
echo

# --------------------------------------------------------------------------------------------------------------
#                                   Add an iptables rule to open the new ssh port
# --------------------------------------------------------------------------------------------------------------

printf "*** Add an iptables rule to open the new ssh port: $TXTGREEN iptables -I INPUT -p tcp --dport $ENABLED_PORT -j ACCEPT$TXTNORMAL"
sudo iptables -I INPUT -p tcp --dport $ENABLED_PORT -j ACCEPT
echo

printf "*** Reject port 22: $TXTGREEN sudo iptables -D INPUT -p tcp --dport 22 -j REJECT$TXTNORMAL"
sudo iptables -I INPUT -p tcp --dport 22 -j REJECT

echo
printf "\nDone...\nPress any key to continue"
read anyKey

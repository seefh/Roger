#!/bin/sh

# sources
# 
# https://www.it-connect.fr/appliquer-des-regles-iptables-au-demarrage/
# 
# 

TXTNORMAL="\033[0m"
TXTBLUE="\033[1;34m"
TXTRED="\033[1;31m"
TXTGREEN="\033[1;32m"

echo
echo

printf "*** Starting NAT / DNAT activation\n"
echo


# get public network interface
PUBLIC_IF=$(ip route | grep "10.*.254.254" | grep default | awk '{print $5}' | cut -d ':' -f1)
printf "Public Interface : $PUBLIC_IF\n"


# get private network interface
PRIVATE_IF=$(ip a | grep BROADCAST | grep -v $PUBLIC_IF | awk -F ": " '{print $2}' | cut -d ':' -f1)
printf "Private Interface : $PRIVATE_IF\n"


# Activate NAT
printf "\n*** NAT activation : $TXTGREEN iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE\n"$TXTNORMAL
#sudo iptables -t nat -F  # supprimer tables 
#sudo iptables -t nat -X  # supprimer rules
sudo iptables -t nat -A POSTROUTING -o $PUBLIC_IF -j MASQUERADE
echo

printf "*** Save iptables rules configuration : ? (y/n) : "
read answer
if [ $answer = "y" ]
then
	printf $TXTGREEN"\tiptables-save > /etc/iptables_rules.save\n"$TXTNORMAL
	sudo iptables-save > /etc/iptables_rules.save
	printf "iptables rules successfully saved in $TXTBLUE/etc/iptables_rules.save\n$TXTNORMAL"
	#printf "iptables-restore  /etc/iptables_rules.save"
fi

printf "\n*** Enabling Web Server Forwarding SSHD port : $TXTGREEN iptables -t nat -A PREROUTING -p tcp --dport $WEBSERVER_PORT -j DNAT --to-destination $WEBSERVER_IP:$WEBSERVER_PORT\n"$TXTNORMAL
printf "Please enter web server ip address : "
read WEBSERVER_IP
printf "Please enter web server enabled SSHD port : "
read WEBSERVER_PORT
sudo iptables -t nat -A PREROUTING -p tcp --dport $WEBSERVER_PORT -j DNAT --to-destination $WEBSERVER_IP:$WEBSERVER_PORT

echo
printf "NAT / DNAT configuration done"

echo
echo

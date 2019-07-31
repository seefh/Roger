#!/bin/sh

TXTNORMAL="\033[0m"
TXTBLUE="\033[1;34m"
TXTRED="\033[1;31m"
TXTGREEN="\033[1;32m"

echo
printf "*** iptables configuration\n"
echo

if [ $# -ge 1 ]
then
    ENABLED_PORT=$1
else
    printf "Please enter ssh port number to enable: "
    read ENABLED_PORT
fi

# Supprimer toutes les regles
sudo iptables -F ; iptables -X

# Flooding of RST packets, smurf attack Rejection
sudo iptables -A INPUT -p tcp -m tcp --tcp-flags RST RST -m limit --limit 2/second --limit-burst 2 -j ACCEPT

# Protecting portscans
# Attacking IP will be locked for one hour (3600 x 1 = 3600 Seconds)
sudo sudo iptables -A INPUT -m recent --name portscan --rcheck --seconds 3600 -j DROP
sudo iptables -A FORWARD -m recent --name portscan --rcheck --seconds 3600 -j DROP

# Remove attacking IP after 1 hour
sudo iptables -A INPUT -m recent --name portscan --remove
sudo iptables -A FORWARD -m recent --name portscan --remove

# Thes rules add scanners to the portscan list, and log the attempt.
sudo iptables -A INPUT -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOG --log-prefix "portscan:"
sudo iptables -A INPUT -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP

sudo iptables -A FORWARD -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOG --log-prefix "portscan:"
sudo iptables -A FORWARD -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP

#//////////////////////////////
# conflict with fail2ban
#//////////////////////////////
sudo iptables -A INPUT -p tcp -m multiport --dports $ENABLED_PORT -m set --match-set fail2ban-sshd src -j REJECT --reject-with icmp-port-unreachable
#//////////////////////////////

sudo iptables -A INPUT -p tcp -m multiport --dports 80 -m set --match-set fail2ban-http src -j REJECT --reject-with icmp-port-unreachable
sudo iptables -A INPUT -p tcp -m multiport --dports 443 -m set --match-set fail2ban-https src -j REJECT --reject-with icmp-port-unreachable

# Autoriser les echanges sur les ports de la tables "filter" chain INPUT 
# reject default port
sudo iptables -t filter -A INPUT -p tcp --dport 22 -j REJECT
# accept Enabled port
sudo iptables -t filter -A INPUT -p tcp --dport $ENABLED_PORT -j ACCEPT

sudo iptables -t filter -A INPUT -p tcp --dport 25 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 21 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --sport 25 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 53 -j ACCEPT
sudo iptables -t filter -A INPUT -p udp --dport 67 -j ACCEPT
sudo iptables -t filter -A INPUT -p udp --dport 68 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 69 -j ACCEPT
sudo iptables -t filter -A INPUT -p udp --dport 69 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
#sudo iptables -t filter -A INPUT -p tcp --dport 587 -j ACCEPT
#sudo iptables -t filter -A INPUT -p udp --dport 587 -j ACCEPT
sudo iptables -t filter -A INPUT -p udp --dport 4011 -j ACCEPT


# Autoriser les echanges sur les ports de la tables "filter" chain OUTPUT 
sudo iptables -t filter -A OUTPUT -p tcp --sport 22 -j ACCEPT
#sudo iptables -t filter -A OUTPUT -p tcp --dport 53 -j ACCEPT
#sudo iptables -t filter -A OUTPUT -p tcp --dport 25 -j ACCEPT
sudo iptables -t filter -A OUTPUT -p udp --dport 67 -j ACCEPT
sudo iptables -t filter -A OUTPUT -p tcp --sport 80 -j ACCEPT
sudo iptables -t filter -A OUTPUT -p tcp --sport 443 -j ACCEPT
sudo iptables -t filter -A OUTPUT -p tcp --sport $ENABLED_PORT -j ACCEPT

# Refuser tout le reste
# iptables -t filter -A INPUT -j DROP
# iptables -t filter -A OUTPUT -j DROP

# Afficher les regles mises en place
sudo iptables -L
sudo iptables -t nat -L

echo
printf "\nDone...\nPress any key to continue"
read anyKey

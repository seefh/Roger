
#!/bin/sh

TXTNORMAL="\033[0m"
TXTBLUE="\033[1;34m"
TXTRED="\033[1;31m"
TXTGREEN="\033[1;32m"


echo
printf "Please enter hostname: "
read HOST_NAME
sudo hostnamectl set-hostname $HOST_NAME --static
echo

# Getting private network interface
PRIVATE_IF=$(ip a | grep enp0 | head -n 1 | awk '{print $2}' | cut -d ':' -f1)

sudo nmcli con del $(nmcli connection show | grep -v NAME | awk -F "  " '{print $1,$2,$3," "}') > /dev/null 2>&1

# Getting private ip address, CIDR, gateway address
printf "Please enter private ip address (format: w.x.y.z) : "
read PRIVATE_IP

printf "Please Enter netmask IP CIDR (30) : "
read CIDR
echo

printf "Please enter gateway ip address (format: w.x.y.z) : "
read GATEWAY_IP
echo

printf "*** static interface configuration :\n"
sudo nmcli con add con-name eth0 ifname $PRIVATE_IF type ethernet ip4 $PRIVATE_IP/$CIDR gw4 $GATEWAY_IP
sudo nmcli con mod eth0 ipv4.dns "10.51.1.42 10.51.1.43"
sudo nmcli con up eth0

echo
printf "\nDone...\nPress any key to continue"
read anyKey

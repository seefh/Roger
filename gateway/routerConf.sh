#!/bin/sh

TXTNORMAL="\033[0m"
TXTBLUE="\033[1;34m"
TXTRED="\033[1;31m"
TXTGREEN="\033[1;32m"

echo
echo

printf "*** Starting Router configuration\n"
echo


#printf "*** Set hostname to router : $TXTGREEN sudo hostnamectl set-hostname rs1_Gateway --static\n$TXTNORMAL"
printf "\nPlease enter hostname: "
read HOST_NAME
sudo hostnamectl set-hostname $HOST_NAME --static
echo


# get public network interface
PUBLIC_IF=$(ip route | grep "10.*.254.254" | grep default | awk '{print $5}' | cut -d ':' -f1)
printf "Public Interface : $PUBLIC_IF\n"


# get private network interface
PRIVATE_IF=$(ip a | grep BROADCAST | grep -v $PUBLIC_IF | awk -F ": " '{print $2}' | cut -d ':' -f1)
printf "Private Interface : $PRIVATE_IF\n"


# remove existing interfaces
sudo nmcli con del $(nmcli connection show | grep -v NAME | awk -F "  " '{print $1,$2,$3," "}') > /dev/null 2>&1


# get private ip address and CIDR
printf "\nPlease enter Gateway private ip address (format: w.x.y.z) : "
read PRIVATE_IP
printf "Please Enter Gateway netmask IP CIDR (30) : "
read CIDR
echo


printf "*** static interface configuration :"
echo $TXTGREEN"\nsudo nmcli con add con-name eth1 ifname $PRIVATE_IF type ethernet ip4 $PRIVATE_IP/$CIDR"$TXTNORMAL
sudo nmcli con add con-name eth1 ifname $PRIVATE_IF type ethernet ip4 $PRIVATE_IP/$CIDR
sudo nmcli con up eth1
echo


printf "*** dynamic interface configuration :"
echo $TXTGREEN"\nsudo nmcli con add con-name eth0 ifname $PUBLIC_IF type ethernet ipv4.method auto"$TXTNORMAL
sudo nmcli con add con-name eth0 ifname $PUBLIC_IF type ethernet ipv4.method auto
sudo nmcli con up eth0
echo

#printf "*** ipv6 desactivation :"
#sudo ./desactive-ipv6
#echo

# Actvate router mode
printf "*** Router mode activation :\n"
printf ". Enabling packet forwarding for ipv4 : $TXTGREEN net.ipv4.ip_forward = 1$TXTNORMAL  in /etc/sysctl.conf"
sudo sed -i -e "s/^[#\t ]*net.ipv4.ip_forward[\t ]*.*\$/net.ipv4.ip_forward=1/"	'/etc/sysctl.conf'
echo


# Activate packet forwarding
printf ". Activating packet forwarding for ipv4$TXTGREEN sysctl -p /etc/sysctl.conf"$TXTNORMAL
sudo sysctl -p /etc/sysctl.conf > /dev/null 2>&1
ROUTAGE=$?
#if [ $ROUTAGE -eq 0 ]
if [ $ROUTAGE -ne 0 ]
then
	echo $TXTRED"...Warning: Packet forwarding Inactive"$TXTNORMAL
fi
echo




# Activate NAT
echo $0 > d0
pathname=$(sed "s/routerConf/natConf/" 'd0')
rm d0
sh $pathname

echo
printf "Router configuration done"

echo
echo

#!/bin/bash

# Sources
#
# https://www.howtoforge.com/tutorial/how-to-install-fail2ban-on-centos/
#
#

TXTNORMAL="\033[0m"
TXTBLUE="\033[1;34m"
TXTRED="\033[1;31m"
TXTGREEN="\033[1;32m"



printf "Voulez-vous configurer fail2ban ? (y/n) "
read answer
if [ $answer = "y" ]
then
    echo
    echo
    printf "*** fail2ban configuration... please wait\n"
    echo
    echo

    # fail2ban Installation
    sudo yum install -y epel-release #> /dev/null
    sudo yum install -y fail2ban #> /dev/null

    # Update the SELinux policies:
    sudo yum update -y selinux-policy*  #> /dev/null

    # Configure settings for Fail2Ban
    # Once installed, we will have to configure and customize the software with a jail.local configuration file. The jail.local file overrides the jail.conf file and is used to make your custom configuration update safe.
    # Make a copy of the jail.conf file and save it with the name jail.local:
    #sudo cp -pf /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

    # Open the jail.local file for editing the following command  in /etc/fail2ban/jail.local

    #
    # Configuring /etc/fail2ban/jail.local
    #

    if [ $# -ge 1 ]
    then
        ENABLED_PORT=$1
    else
        printf "Please enter port number to enable: "
        read ENABLED_PORT
    fi

if [ ! -e /etc/fail2ban/jail.local ]
then 
    sudo touch /etc/fail2ban/jail.local
fi
sudo chmod 646 /etc/fail2ban/jail.local
sudo printf "
[DEFAULT]
# ignoreip can be an IP address, a CIDR mask or a DNS host. Fail2ban will not  ban a host which matches an address in this list.
# Several addresses can be defined using space (and/or comma) separator.
ignoreip = 127.0.0.1/8

# External command that will take an tagged arguments to ignore, e.g. <ip>,
# and return true if the IP is to be ignored. False otherwise.
# ignorecommand = /path/to/command <ip>
ignorecommand =

# bantime is the number of seconds that a host is banned.
bantime  = 600

# A host is banned if it has generated maxretry during the last findtime seconds.
findtime  = 600

# maxretry is the number of failures before a host get banned.
maxretry = 3

[sshd]
enabled=true
"> /etc/fail2ban/jail.local

#
# Configuring /etc/fail2ban/jail.d/sshd.local
#
echo
sudo chmod 644 /etc/fail2ban/jail.local


if [ ! -e /etc/fail2ban/jail.d/sshd.local ]
then 
    sudo touch /etc/fail2ban/jail.d/sshd.local
fi
sudo chmod 646 /etc/fail2ban/jail.d/sshd.local
sudo printf "
# Ignoreip is used to set the list of IPs which will not be banned. The list of IP addresses should be given with a space separator.
# This parameter is used to set your personal IP address (if you access the server from a fixed IP).
# Bantime parameter is used to set the duration of seconds for which a host needs to be banned.
# Findtime is the parameter which is used to check if a host must be banned or not. When the host generates maxrety in its last findtime,
# it is banned. Maxretry is the parameter used to set the limit for the number of retry's by a host, upon exceeding this limit,
# the host is banned. Add a jail file to protect SSH: /etc/fail2ban/jail.d/sshd.local. To the above file, add the following lines of code.

[sshd]
enabled = true
port = $ENABLED_PORT
#action = firewallcmd-ipset
logpath = %%(sshd_log)s
maxretry = 3
bantime = 3600
"> /etc/fail2ban/jail.d/sshd.local
sudo chmod 644 /etc/fail2ban/jail.d/sshd.local

    # redemarrer firewalld
    sudo systemctl enable firewalld
    sudo systemctl restart firewalld

    # Execute the following lines of command to run the protective Fail2Ban software on the server.
    sudo systemctl enable fail2ban
    sudo systemctl restart fail2ban 

    #echo
    # printf "\nDone...\nPress any key to continue"
    #read anyKey
fi

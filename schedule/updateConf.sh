#!/bin/sh

TXTNORMAL="\033[0m"
TXTBLUE="\033[1;34m"
TXTRED="\033[1;31m"
TXTGREEN="\033[1;32m"


# --------------------------------------------------------------------------------------------------------------
#    mise a jour des sources des packages et des logue dans /var/log/update_script.log
# --------------------------------------------------------------------------------------------------------------
printf "*** Update script"
echo

printf "Update: $TXTGREEN yum update\n$TXTNORMAL"
printf "Update\n" > /var/log/update_script.log
sudo yum update -y >> /var/log/update_script.log 2>&1
echo

printf "Update script: $TXTGREEN /var/log/update_script.log\n$TXTNORMAL"
echo >> /var/log/update_script.log 
echo

printf "Upgrade: $TXTGREEN yum upgrade\n$TXTNORMAL"
printf "Upgrade\n" >> /var/log/update_script.log
sudo yum upgrade -y >> /var/log/update_script.log 2>&1
echo

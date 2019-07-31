#!/bin/sh

TXTNORMAL="\033[0m"
TXTBLUE="\033[1;34m"
TXTRED="\033[1;31m"
TXTGREEN="\033[1;32m"


# --------------------------------------------------------------------------------------------------------------
#    verifier si le fichier /etc/crontab a ete modifie.
# --------------------------------------------------------------------------------------------------------------

printf "*** Checking /var/log/crontab-checksum file for updates"
echo

MAIL_ADMIN="$USER@student.42.fr"

sudo touch /tmp/crontab-check
sudo touch /var/log/crontab-checksum;

if [ -f "/var/log/crontab-checksum" ]
then
	sudo md5sum /etc/crontab > /tmp/crontab-check;
	sudo diff -q /tmp/crontab-check /var/log/crontab-checksum;
	if [ $? -ne 0 ]
	then
		printf "Le fichier /etc/crontab a ete modifie" | mail -s "crontab" $MAIL_ADMIN;
		sudo md5sum /etc/crontab >> /var/log/crontab-checksum;
	fi
else
	sudo md5sum /etc/crontab > log /var/log/crontab-checksum;
fi



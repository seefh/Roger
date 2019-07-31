#!/bin/sh

TXTNORMAL="\033[0m"
TXTBLUE="\033[1;34m"
TXTRED="\033[1;31m"
TXTGREEN="\033[1;32m"


# sources :
#
# - https://www.microlinux.fr/apache-centos-7/#installation
# - https://www.microlinux.fr/apache-ssl-centos-7/
# - http://www.linux-france.org/prj/edu/archinet/systeme/ch24s03.html
#

echo

# --------------------------------------------------------------------------------------------------------------
#                                            WEB Server Installation
# --------------------------------------------------------------------------------------------------------------

echo
printf "*** Starting Web Service Installation\n"
echo

printf "Installation : $TXTGREEN  yum install httpd\n$TXTNORMAL"
 sudo yum install -y httpd
echo

printf "Activatiing httpd service: $TXTGREEN  systemctl enable httpd\n$TXTNORMAL"
 sudo systemctl enable httpd
echo

printf "Starting httpd service: $TXTGREEN  systemctl start httpd\n$TXTNORMAL"
 sudo systemctl start httpd
echo

printf "Installing Elinks (Text Mode Browser): $TXTGREEN  yum install elinks\n$TXTNORMAL"
 sudo yum install -y elinks 
echo


# --------------------------------------------------------------------------------------------------------------
#                                           WEB Server ssl Implementation
# --------------------------------------------------------------------------------------------------------------

# On notera l’apparition d’un fichier de configuration ssl.conf dans /etc/httpd/conf.d.
printf "HTTPS Installation : $TXTGREEN  yum install mod_ssl\n$TXTNORMAL"
 sudo yum install -y mod_ssl
echo

# Avant de continuer, effectuer une copie de sauvegarde du fichier de configuration par défaut. Configurer Apache et SSL
printf "HTTPS Configuration :\n"
# Si l’on part d’un répertoire /var/www/html vide, on peut récupérer un peu de contenu statique pour avoir quelque chose à nous mettre sous la dent.
cd /etc/httpd/conf.d
 sudo cp ssl.conf ssl.conf.orig
echo

# --------------------------------------------------------------------------------------------------------------
#                                           copy web www.xxx.fr html file and resources
# --------------------------------------------------------------------------------------------------------------

printf "*** Copying resource files\n"
echo
if [ ! -e /var/www/html ]
then
	cp -rf /rs1/html /var/www
else
	cp -rf /rs1/html/index.html /var/www/html
	if [ ! -e /var/www/html/src ]
	then
		cp -rf /rs1/html/src /var/www/html
	else
		cp -rf /rs1/html/src/*  /var/www/html/src
	fi
fi


# --------------------------------------------------------------------------------------------------------------
#                                           Auto signed Certificates
# --------------------------------------------------------------------------------------------------------------

printf "Please enter web netbios name : "
read NETBIOSSERVER
echo

printf "Please enter FQDN (Full Qualified Domain Name) server name : "
read FQDN
echo

SSLPATH=/etc/httpd/$NETBIOSSERVER"_ssl"
sudo mkdir $SSLPATH

SSLCSRFILE=$SSLPATH/$NETBIOSSERVER.csr
SSLKEYFILE=$SSLPATH/$NETBIOSSERVER.key
SSLCRTFILE=$SSLPATH/$NETBIOSSERVER.crt
CACRTFILE=$SSLPATH/ca.crt
CASRLFILE=$SSLPATH/ca.srl
CAKEYFILE=$SSLPATH/ca.key

echo $SSLPATH
echo $SSLCSRFILE
echo $CASRLFILE

printf "Private server key generation $TXTGREEN openssl genrsa 1024 > $SSLKEYFILE $TXTNORMAL"
 sudo openssl genrsa 1024 > $SSLKEYFILE
echo

printf "Certificate Request $TXTGREEN openssl req -new -key $SSLKEYFILE > $SSLCSRFILE $TXTNORMAL"
 sudo openssl req -new -key $SSLKEYFILE > $SSLCSRFILE
echo

printf "Certificate Authority Private key Creation $TXTGREEN openssl genrsa -des3 1024 > $CAKEYFILE $TXTNORMAL"
 sudo openssl genrsa -des3 1024 > $CAKEYFILE
echo

printf "x509 Certificate Creation $TXTGREEN openssl req -new -x509 -days 365 -key $CAKEYFILE > $CACRTFILE $TXTNORMAL"
 sudo openssl req -new -x509 -days 365 -key $CAKEYFILE > $CACRTFILE
echo

printf "CA Certificate signature :\n $TXTGREEN openssl x509 -req -in $SSLCSRFILE -out $SSLCRTFILE -CA $CACRTFILE -CAkey $CAKEYFILE -CAcreateserial -CAserial $CASRLFILE $TXTNORMAL"
 sudo openssl x509 -req -in $SSLCSRFILE -out $SSLCRTFILE -CA $CACRTFILE -CAkey $CAKEYFILE -CAcreateserial -CAserial $CASRLFILE
echo


# --------------------------------------------------------------------------------------------------------------
#                                           /etc/httpd/conf.d/ssl.conf configuration
# --------------------------------------------------------------------------------------------------------------

SSLCONFFILE=/etc/httpd/conf.d/ssl.conf
echo $SSLCONFFILE

 sudo sed -i -e "s/^[#\t ]*SSLCertificateFile[\t ]*.*\$/SSLCertificateFile \/etc\/httpd\/$NETBIOSSERVER\_ssl\/$NETBIOSSERVER.crt/" $SSLCONFFILE 

 sudo sed -i -e "s/^[#\t ]*SSLCertificateKeyFile[\t ]*.*\$/SSLCertificateKeyFile \/etc\/httpd\/$NETBIOSSERVER\_ssl\/$NETBIOSSERVER.key/" $SSLCONFFILE

 sudo sed -i -e "s/<VirtualHost _default_:443>/<VirtualHost *:443>/" $SSLCONFFILE

 sudo sed -i -e "s/^[#\t ]*ServerName www.example.com:443[\t ]*.*\$/ServerName $FQDN:443/" $SSLCONFFILE


# --------------------------------------------------------------------------------------------------------------
#                                           restart HTTPD
# --------------------------------------------------------------------------------------------------------------

printf "Restarting httpd :\n"
 sudo systemctl restart httpd
echo

printf "*** copy certificate to the gateway ? (y/n) : "
read answer
if [ $answer = "y" ]
then
	printf "Please enter gateway's ip address or hostname : "
	read GTW_ADDRESS
	printf "Please enter $GTW_ADDRESS's login : "
	read GTW_LOGIN
	echo

	sudo scp $CACRTFILE $GTW_LOGIN@$GTW_ADDRESS:
fi

echo
printf "\nDone...\nPress any key to continue"
read anyKey

#!/bin/sh

TXTNORMAL="\033[0m"
TXTBLUE="\033[1;34m"
TXTRED="\033[1;31m"
TXTGREEN="\033[1;32m"

IPCONFIG_FILE="/rs1/scripts/ipConf.sh"
SSHDCONFIG_FILE="/rs1/scripts/sshdConf.sh"
WEBSSLCONFIG_FILE="/rs1/scripts/webSslConf.sh"
SCHEDULECONFIG_FILE="/rs1/scripts/scheduleConf.sh"
IPTABLESCONFIG_FILE="/rs1/scripts/iptablesConf.sh"
FAIL2BANCONFIG_FILE="/rs1/scripts/fail2banConf.sh"

ENABLED_PORT=0
CONTINUE=true

while ($CONTINUE)
do
    clear

    echo
    echo
    printf $TXTNORMAL"\n------------------------------------------------------------"
    printf $TXTNORMAL"\n            Roger Skyline 1 - Server Configuration          "
    printf $TXTNORMAL"\n------------------------------------------------------------"
    printf "\nPlease select an option\n"
    printf "\t    $TXTGREEN  1$TXTNORMAL : Automatic configuration - Recommended\n"
    printf "\t    $TXTGREEN  2$TXTNORMAL : Manual configuration (Advanced user)\n"
    echo
    printf "\t type$TXTGREEN 0$TXTNORMAL to exit configuration scripts\n"
    echo
    printf $TXTNORMAL"------------------------------------------------------------"
    printf "\nYour choice:  $TXTGREEN"
    read CHOICE
    printf $TXTNORMAL
    echo


    if [ $CHOICE -lt 0 ] || [ $CHOICE -gt 2 ] # error
    then
        printf "\nPlease enter a value between 0 and 2";

    elif [ $CHOICE -eq 0 ] || [ $CHOICE -eq 2 ] # manual
    then
        CONTINUE=false; 


    elif [ $CHOICE -eq 1 ] # Automatic
    then
        printf "\nRun Network Configuration ? (y/n) : "
        read answer
        if [ $answer = "y" ]
        then
            sh $IPCONFIG_FILE
        fi

        printf "\nRun SSHD Configuration ? (y/n) : "
        read answer
        if [ $answer = "y" ]
        then
            printf "Please enter port number to enable: "
            read ENABLED_PORT
            sh $SSHDCONFIG_FILE $ENABLED_PORT
        fi

        printf "\nRun Web and SSL Configuration ? (y/n) : "
        read answer
        if [ $answer = "y" ]
        then
            sh $WEBSSLCONFIG_FILE
        fi

        printf "\nRun scripts schedule Configuration ? (y/n) : "
        read answer
        if [ $answer = "y" ]
        then
             sh $SCHEDULECONFIG_FILE
        fi

        printf "\nRun Fail2ban Configuration - Iptables Configuration ? (y/n) : "
        read answer
        if [ $answer = "y" ]
        then
            if  [ $ENABLED_PORT -eq 0 ]
            then
                printf "Please enter port number to enable: "
                read ENABLED_PORT
            fi
            sh $FAIL2BANCONFIG_FILE $ENABLED_PORT
            sh $IPTABLESCONFIG_FILE $ENABLED_PORT
        fi
    fi
done

if [ $CHOICE -eq 2 ] # manual
then
    CONTINUE=true
fi

while ($CONTINUE)
do
    
    clear

    echo
    printf $TXTNORMAL"\n------------------------------------------------------------"
    printf $TXTNORMAL"\n            Roger Skyline 1 - Server Configuration          "
    printf $TXTNORMAL"\n------------------------------------------------------------"
    printf "\nPlease select an option to configure\n"
    printf "\t    $TXTGREEN  1$TXTNORMAL Network\n"
    printf "\t    $TXTGREEN  2$TXTNORMAL SSHD\n"
    printf "\t    $TXTGREEN  3$TXTNORMAL Web and SSL\n"
    printf "\t    $TXTGREEN  4$TXTNORMAL Schedule Crontab\n"
    printf "\t    $TXTGREEN  5$TXTNORMAL Fail2ban - iptables rules\n"
    echo
    printf "\t type$TXTGREEN 0$TXTNORMAL to exit configuration scripts\n"
    echo

    printf $TXTNORMAL"------------------------------------------------------------"
    printf "\nYour choice:  $TXTGREEN"
    read CHOICE
    printf $TXTNORMAL #"------------------------------------------------------------"
    echo
    echo
    
    if [ $CHOICE -eq 0 ]
    then
        CONTINUE=false
    elif [ $CHOICE -eq 1 ]
    then
        sh $IPCONFIG_FILE
    elif [ $CHOICE -eq 2 ]
    then
        if  [ $ENABLED_PORT -eq 0 ]
        then
            printf "Please enter port number to enable: "
            read ENABLED_PORT
        fi
        sh $SSHDCONFIG_FILE $ENABLED_PORT
    elif [ $CHOICE -eq 3 ]
    then
        sh $WEBSSLCONFIG_FILE
    elif [ $CHOICE -eq 4 ]
    then
        sh $SCHEDULECONFIG_FILE
    elif [ $CHOICE -eq 5 ]
    then
        if  [ $ENABLED_PORT -eq 0 ]
        then
            printf "Please enter port number to enable: "
            read ENABLED_PORT
        fi
        sh $FAIL2BANCONFIG_FILE $ENABLED_PORT
        sh $IPTABLESCONFIG_FILE $ENABLED_PORT
    else
        printf "\nPlease enter a value between 0 and 5";
    fi

    printf $TXTNORMAL
    echo
done

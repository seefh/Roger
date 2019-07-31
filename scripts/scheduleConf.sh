#!/bin/sh

# --------------------------------------------------------------------------------------------------------------
#   schedule script
# --------------------------------------------------------------------------------------------------------------
#echo

printf "*** schedule scripts"
echo

sudo yum install -y postfix
sudo yum install -y mailx

# directoy and schedule files creation
sudo -k 
sudo -u $USER -v  # set user's crontab
    (crontab -l; echo "@reboot" /rs1/schedule/updateConf.sh) | crontab -
    (crontab -l; echo "0 4 * * *" /rs1/schedule/updateConf.sh) | crontab -
    (crontab -l; echo "0 0 * * *" /rs1/schedule/checkSumConf.sh) | crontab -

#    if ! crontab -l | grep -q -m 1 '@reboot /rs1/schedule/updateConf.sh'
#    then
#        (crontab -l 2>/dev/null || true; echo "@reboot" /rs1/schedule/updateConf.sh) | crontab -
#        (crontab -l 2>/dev/null || true; echo "0 4 * * *" /rs1/schedule/updateConf.sh) | crontab -
#    fi

#    if ! crontab -l | grep -q -m 1 '0 0 \* \* \* /rs1/schedule/checkSumConf.sh'
#        (crontab -l 2>/dev/null || true; echo "0 0 * * *" /rs1/schedule/checkSumConf.sh) | crontab -
#    fi
sudo -k 

printf "scheduled scripits :\n\t/rs1/schedule/updateConf.sh : (rebo10.11.200.33ot, 04:00 once a week)
                            \n\t/rs1/schedule/checkSumConf.sh : (00:00 am)"

echo
printf "\nDone...\nPress any key to continue"
read anyKey


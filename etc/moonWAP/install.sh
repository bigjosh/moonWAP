
#do initial update
/etc/moonWAP/updateMoon.sh

#set us up to autorun every minute
echo "* * * * * /etc/moonWAP/updatemoon.sh" >>newchrontab.txt
crontab -e

#!/bin/sh

# Setup moonWAP in this router
# Assumes that the /etc directory from the dirtibution has been copied to /etc on target
# Should be run after nodogsplash is installed 

curpath=$(readlink -f "$0")
curdir=$(dirname "$curpath")

if [ "$curdir" != "/etc/moonWAP" ]; then
    echo "ERROR: This tree must be installed under /etc."
fi


# Make our scritps executible 
chmod +x $(dirname $0)/updateMoon.sh
chmod +x $(dirname $0)/updateMoonToNow.sh

#do initial update
/etc/moonWAP/updateMoon.sh

#set us up to autorun every minute

# write out current crontab
# TODO: Don't everwrite existing crontab contents
tmpfile=$(mktemp)
# Update the moon once per hour
echo "00 * * * 1-7 /etc/moonWAP/updateMoonToNow.sh" >> $tmpfile
#install new cron file
crontab $tmpfile
rm $tmpfile

# cron not enabled by default
/etc/init.d/cron start
/etc/init.d/cron enable
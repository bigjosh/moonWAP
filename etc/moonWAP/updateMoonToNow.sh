#!/bin/sh

# update to current real-time moonphase
# calls updateMoon.sh in same directory
#  Creates /etc/nodogsplash/htdocs/status.html

now=$(date "+%Y-%m-%d %H:%M:%S")
$(dirname $0)/updateMoon.sh "$now" >/etc/nodogsplash/htdocs/status.html

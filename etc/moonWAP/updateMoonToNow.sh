#!/bin/sh

# update to current real-time moonphase
# calls updateMoon.sh in same directory
#  Creates /etc/nodogsplash/htdocs/status.html

# save output to an info page
infopage="/etc/nodogsplash/htdocs/pages/mooncalc.html"

# prophlactically make the directory
mkdir $(dirname $infopage)

now=$(date "+%Y-%m-%d %H:%M:%S")

# save the output to the info page
echo "<H2>Details of most recent moon phase calculation</h2><pre>" > $infopage
$(dirname $0)/updateMoon.sh "$now" >> $infopage
echo "</pre>" >> $infopage


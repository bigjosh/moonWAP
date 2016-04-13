#!/bin/sh


# update to a new moonpase
# pass in the time to update in the format "YYYY-MM-DD hh:mm:ss" (or just "YYYY-MM-DD") (returned by date %s)
# requires splash.template file to be in the same directory

when=`date -d "$1" "+%Y-%m-%d %H:%M:%S"`
echo "Calcuilating moon phase for $when"

# Start with the time of a recent known new moon (got from http://astro.ukho.gov.uk/moonwatch/ )
newmoon="2016-03-09 01:24"

newmoonstr=$( date -d "$newmoon" "+%Y-%m-%d %H:%M:%S" )

echo "Recent new moon was at $newmoonstr"

# current length of lunar month in seconds (painfully from https://www.wolframalpha.com/input/?i=lunar+month+in+seconds )
seclunarMonthLen=2551442

echo "Current lunar cycle lenth is $seclunarMonthLen seconds (~$(( seclunarMonthLen / ( 24 * 60 * 60 ) )) days)"

# convert new moon time to seconds 
secnewmoon=$(date -d "$newmoon" +%s)

# convert the requested time to seconds
sectimenow=$(date -d "$1" +%s)

# calculate seconds since the new moon

secsinceNew=$((  sectimenow - secnewmoon  ))
daysinceNew=$(( secsinceNew / ( 60 * 60 * 24 ) ))

echo "It has been $secsinceNew seconds (~$daysinceNew dayss) since recent new moon"

# Compute current phase (0=New, 0.5 * lunarMonth=Full)
secinPhase=$(( secsinceNew % seclunarMonthLen ))
dayinPhase=$(( secinPhase / ( 60 * 60 * 24 ) ))

echo "We are $secinPhase seconds (~$dayinPhase days) into the current lunar cycle"

# ~30 days in a lunar month. This is a hack, but there are no decimals in BASH so be gentle.
moonDay=$(( secinPhase / ( 24 * 60 * 60 ) ))

echo "Curently day $moonDay of 30 in lunar month"

if [ $moonDay -le 1 ]   || [ $moonDay -ge  29 ]; then
    ssid="\xf0\x9f\x8c\x91"
    image="moon-0000.jpg"
    name="NEW MOON"
    qos="100%"
    power="15"
elif [ $moonDay -le 5 ]; then
    ssid="\xf0\x9f\x8c\x92"
    image="moon-0035.jpg"    
    name="WAXING CRESCENT"
    qos="75% AND WANING"
    power="13"
elif [ $moonDay -le 9 ]; then
    ssid="\xf0\x9f\x8c\x93"
    image="moon-0044.jpg"    
    name="FIRST QUARTER"
    qos="50% AND WANING"
    power="8"
elif [ $moonDay -le 13 ]; then
    ssid="\xf0\x9f\x8c\x94"
    image="moon-0060.jpg"    
    name="WAXING GIBBOUS"
    qos="25% AND WANING"
    power="3"
elif [ $moonDay -le 16 ]; then
    ssid="\xf0\x9f\x8c\x95"
    image="moon-0076.jpg"    
    name="FULL MOON"
    qos="0%"
    power="0"
elif [ $moonDay -le 20 ]; then
    ssid="\xf0\x9f\x8c\x96"
    image="moon-0120.jpg"
    name="WANING GIBBOUS"
    qos="25% AND WAXING"
    power="3"
elif [ $moonDay -le 24 ]; then
    ssid="\xf0\x9f\x8c\x97"
    image="moon-0135.jpg"    
    name="LAST QUARTER"
    qos="50% AND WAXING"
    power="8"
else
    ssid="\xf0\x9f\x8c\x98"
    image="moon-0147.jpg"
    name="WANING CRESCENT"
    qos="75% AND WAXING"
    power="12"
fi

echo -e "SSID = $ssid"    
echo "Name = $name" 
echo "Image = $image"
echo "QOS = $qos"
echo "Power= $power of 15"

## Set the TX powerupdate, which rises and falls over the cycle

iwconfig wlan0 txpower "$((power))dBm"

## Update the SSID. 

# Convert new ssid to unicode
newssid="$(echo -e $ssid)"
currentssid=$(uci get wireless.@wifi-iface[0].ssid)

# don't up/down the interface unless the ssid actually changed to avoid kicking people off
if [ "$newssid" != "$currentssid" ]; then
	uci set wireless.@wifi-iface[0].ssid="$newssid"
    uci set wireless.@wifi-iface[0].txpower="$((power))dBm"
	uci commit wireless
	/sbin/wifi down
	/sbin/wifi up
    echo "Wifi interface reset to enable new SSID"
    # seems like there must be a delay before changing txpower
    sleep 2
fi

## Set the TX powerupdate, which rises and falls over the cycle
# note that it seem that you must set txpower AFTER down/up

iwconfig wlan0 txpower "$((power))dBm"


## Now make the new splash page HTML using our template
#Find a better way someday since constantly overwriting the splash page will
#wear the flash memmory. Maybe serve from /tmp, or generate on the fly?

# Substutite the real-time values into the splash.html template

sed -e "s/~MP_IMAGE~/$image/g" \
    -e "s/~MP_PHASE~/$name/g" \
    -e "s/~MP_QOS~/$qos/g" \
	$(dirname $0)/splash.template >/etc/nodogsplash/htdocs/splash.html



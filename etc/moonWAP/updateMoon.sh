#!/bin/sh

# update to a new moonpase
# pass in the time to update in the format "YYYY-MM-DD hh:mm:ss" (or just "YYYY-MM-DD") (returned by date %s)

when=`date -d $1 +'%Y-%m-%d %H:%M:%S'`
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
    name="NEW MOON"
    qos="100%"
    power="15"
elif [ $moonDay -le 5 ]; then
    ssid="\xf0\x9f\x8c\x92"
    name="WAXING CRESCENT"
    qos="75% AND WANING"
    power="13"
elif [ $moonDay -le 9 ]; then
    ssid="\xf0\x9f\x8c\x93"
    name="FIRST QUARTER"
    qos="50% AND WANING"
    power="8"
elif [ $moonDay -le 13 ]; then
    ssid="\xf0\x9f\x8c\x94"
    name="WAXING GIBBOUS"
    qos="25% AND WANING"
    power="3"
elif [ $moonDay -le 16 ]; then
    ssid="\xf0\x9f\x8c\x95"
    name="FULL MOON"
    qos="0%"
    power="0"
elif [ $moonDay -le 20 ]; then
    ssid="\xf0\x9f\x8c\x96"
    name="WANING GIBBOUS"
    qos="25% AND WAXING"
    power="3"
elif [ $moonDay -le 24 ]; then
    ssid="\xf0\x9f\x8c\x97"
    name="LAST QUARTER"
    qos="50% AND WAXING"
    power="8"
else
    ssid="\xf0\x9f\x8c\x98"
    name="WANING CRESCENT"
    qos="75% AND WAXING"
    power="12"
fi


echo -e "SSID = $ssid"    
echo "Name = $name" 
echo "QOS = $qos"
echo "Power= $power of 15"

return

## Update the SSID. 

# Convert the phase into on of the 
ssidStep

# This nasty mess computes the UNICODE chars for the moon phases. Each 4 bytes is one char (total of 8) and there are 9 of them (we only use the 1st 8)
moonString="\xF0\x9F\x8C\x91\xF0\x9F\x8C\x92\xF0\x9F\x8C\x93\xF0\x9F\x8C\x94\xF0\x9F\x8C\x95\xF0\x9F\x8C\x96\xF0\x9F\x8C\x97\xF0\x9F\x8C\x98"
moonChar=`echo $moonString | cut -b $(( ( (moonStep / 2 ) * 16) + 1 ))-$(( ( (moonStep / 2) * 16 ) + 16 ))`

# There are only 8 steps, so we only need to change on even stpes
# it is good to not change redundantly becuase we will boot any connected stations 

if [[ $(( ( $moonStep / 2 ) * 2 )) -eq $moonStep ]]; 
then
	# The echo -e decodes the hex string into an actual unicode char
	uci set wireless.@wifi-iface[0].ssid="$(echo -e $moonChar)"
	uci commit wireless
	/sbin/wifi down
	/sbin/wifi up
fi

## Set the TX powerupdate, which rises and falls over the cycle

if [[ $moonStep -le 8 ]]; then moonPower=$(( ( $moonStep * 2 ) ))
else moonPower=$((  ( ( 16 - $moonStep ) * 2 ) )) 
fi

iwconfig  wlan0 txpower "$moonPower"dbm


## Now make the new splash page HTML using our template
#Find a better way someday since constantly overwriting the splash page will
#wear the flash memmory. Maybe serve from /tmp, or generate on the fly?

# There are 16 steps and 54 images...
moonImage=$(( ( moonStep * 54 ) / 16 ))

# Calculate the signal strenght with rises for the first half of cycle then falls for the rest

if [[ $moonStep -le 8 ]]; then moonPercent=$(( ( $moonStep * 100 ) / 8 ))
else moonPercent=$(( ( ( 16 - $moonStep ) * 100 ) / 8 ))
fi

if [[ $moonStep -eq 0 ]]; then moonDirection="NEW"
elif [[ $moonStep -lt 8 ]]; then moonDirection="WAXING"
elif [[ $moonStep -eq 8 ]]; then moonDirection="FULL"
else  moonDirection="WANING"
fi

# Substutite the real-time values into the splash.html template

sed -e "s/~MP_IMAGE~/$moonImage/g" \
    -e "s/~MP_PERCENT~/$moonPercent/g" \
    -e "s/~MP_DIRECTION~/$moonDirection/g" \
	/etc/moonWAP/splash.template >/etc/nodogsplash/htdocs/splash.html

cat /etc/nodogsplash/htdocs/splash.html

echo moonStep=$moonStep
echo moonPower=$moonPower
echo moonChar=$moonChar

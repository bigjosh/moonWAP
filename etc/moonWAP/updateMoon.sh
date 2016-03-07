#!/bin/sh

# UpdatedCalled automatically to update the moonphase in various places

# calculate the current phase

# Full cycle every 16 minutes

moonStep=$(( ( $(date +%s) /  60  ) % 16  ))

# moonStep is now 0-15


## Update the SSID. 

# There are only 8 steps, so we only need to change on even stpes
# it is good to not change redundantly becuase we will boot any connected stations 

if [[ $(( ( $moonStep / 2 ) * 2 )) -eq $moonStep ]]; 
then

	# This nasty mess computes the UNICODE chars for the moon phases. Each 4 bytes is one char (total of 8) and there are 9 of them (we only use the 1st 8)
	moonString="\xF0\x9F\x8C\x91\xF0\x9F\x8C\x92\xF0\x9F\x8C\x93\xF0\x9F\x8C\x94\xF0\x9F\x8C\x95\xF0\x9F\x8C\x96\xF0\x9F\x8C\x97\xF0\x9F\x8C\x98"
	moonChar=`echo $moonString | cut -b $(( ( (moonStep / 2 ) * 16) + 1 ))-$(( ( (moonStep / 2) * 16 ) + 16 ))`
	
	uci set wireless.@wifi-iface[0].ssid="$(echo -e $moonChar)"
	uci commit wireless
	/sbin/wifi down
	/sbin/wifi up

fi

## Set the TX powerupdate, which rises and falls over the cycle

if [[ $moonStep -le 8 ]]; then moonPower=$(( ( $moonStep * 2 ) + 1 ))
else moonPower=$((  ( ( 15 - $moonStep ) * 2 ) + 1 )) 
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


moonPercent=$(( ( moonStep * 100 ) / 15 ))


if [[ $moonPercent -eq 0 ]]; then moonDirection="NEW"
elif [[ $moonPercent -lt 50 ]]; then moonDirection="WAXING"
elif [[ $moonPercent -eq 50 ]]; then moonDirection="FULL"
elif [[ $moonPercent -lt 100 ]]; then moonDirection="WANING"
else  moonDirection="Full"
fi

echo $moonDirection

sed -e "s/~MP_IMAGE~/$moonImage/g" \
    -e "s/~MP_PERCENT~/$moonPercent/g" \
    -e "s/~MP_DIRECTION~/$moonDirection/g" \
	/etc/moonWAP/splash.template >/etc/nodogsplash/htdocs/splash.html

cat /etc/nodogsplash/htdocs/splash.html

echo moonStep=$moonStep
echo moonPower=$moonPower
echo moonChar=$moonChar

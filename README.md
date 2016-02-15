# moonWAP
Setup instructions for a moon-phase-driven captive portal

Project created by Tega Brain...

http://tegabrain.com/

## Assumes

1. You have this router with factory installed standard OpenWRT image... 

  http://amzn.to/1ThS6xZ

2. The router is connected to the internet via the WAN port. 
3. You have a laptop with SSH on it that can connect to the router over Wifi. 

## Setup

1. Press and hold the reset button for 8 seconds to reboot the router to factory default state
2. Wait for the AP to come back up and connect to it over Wifi (default password is "goodlife")
3. Navigate to 192.168.8.1
4. Set new password
5. Wait for the AP to come back up and connect to it with the new password
6. SSH to 192.168.8.1 and log in with the new password
7. Enter these commands...  

  ```
opkg update
opkg install nodogsplash
/etc/init.d/nodogsplash enable
```
  ...to install the nodogsplash package and enable it to run automatically on boot
  
7. Enter the commands...

   ```
opkg install wget
wget -O /etc/nodogsplash/htdocs/splash.html --no-check-certificate https://raw.githubusercontent.com/bigjosh/moonWAP/master/htdocs/splash.html
```

  ...to download the HTML for the new splash page into the `nodogsplash` content directory
  
8. Enter the commands...

   ```
opkg install unzip
wget --no-check-certificate "https://github.com/bigjosh/moonWAP/releases/download/1.0/images.zip" 
unzip images.zip -d /etc/nodogsplash/htdocs/
```

 ...to download the moonphase GIF images as a zip file and then decompress them into the `nodogsplash` content directory
 
9.  Enter the commands...  

   ```
uci set wireless.@wifi-iface[0].ssid="$(echo -ne 'Moonphase \xf0\x9f\x8c\x99 WAP')"
uci set wireless.@wifi-iface[0].encryption=none
uci commit
```

  ...to set the new SSID and clear the Wifi access password
 
9. Enter `reboot` to reboot router and start nodogsplash with (hopefully) the new moonphase splash page!

## Change SSID

To change the SSID, connect to the router over Wifi and navigate to the setup pages at...

http://192.168.8.1

...and go to `Advanced Settings` and set...

Network->wifi->settings->General Setup->ESSID to the new SSID (with emoji!) 

...and then hit the "Save and Apply" button

## TODO

* Figure out a way to modulate the AP signal strength or bandwith based on moonphase
* Install [Weaved](http://weaved.com/) or some other system so the box can be maintained and updated remotely

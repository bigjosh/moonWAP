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

1. Press and hold the reset button for 8 seconds to reboot the router to factory default state.
2. Wait for the AP to come back up and connect to it.
3. Navigate to 192.168.8.1
4. Set new password
5. Wait for the AP to come back up and connect to it with the new password
6. SSH to 192.168.8.1 and log in with the new password
7. Enter these commands...  

  ```
opkg update
opkg install nodogsplash
./init.d/nodogsplash enable
```
  ...to install the nodogsplash package and enable it to run automatically on boot
  
7. Enter the command...

  `wget -P /etc/nodogsplash/htdocs http://github/`

  ...to download the HTML for the new splash page into the `nodogsplash` content directory.
  
8. Enter the commands...

   ```
opkg install unzip
wget "http://tycho.usno.navy.mil/gif/Moon.zip" 
unzip Moon.zip -d /etc/nodogsplash/htdocs/images
```

 ...to download the moonphase GIF images as a zip file and then decompress them into the `nodosplash` content directory. 
9. Enter `reboot` to reboot router and start nodogsplash

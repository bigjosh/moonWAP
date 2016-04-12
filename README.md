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
  ...to install the nodogsplash package and enable it to run automatically on boot. 
  
7. Copy the contents of `/etc` of this repo to the `/etc` directory on the device. I use SCP. 

8. Run the install script...

  ```
cd /etc/moonWap
chmod +x install.sh
./install.sh
```
  ...to install the `moonWAP` configuration.
  
## Enable Weaved for remote SSH access (optional)
1. Get and install the `Weaved` tarball...

  ```
   wget -O git://github.com/weaved/installer/raw/master/binaries/weaved-OpenWRT-9331-0.94.tar`
   tar -xvf weaved-OpenWRT-9331-0.94.tar
   cd weaved
   ./install.sh
   rm /etc/init.d/weavedWEB
  ```

  Note that we are disabling the Weaved WEB proxy since we only care about SSH access.
  
2. Log into the Weaved website and wait for this new machine to show up under services. 

## TODO

1. Right now nodogsplash does not do anything to DNS requests, so the access point *must* have an internet connection or else the initial probe will fail and the user will not see the login screen. Might be nice to catch these DNS requests and serve them locally. 
2. Might be nice to animate the moon and signal strength localy in javascript.

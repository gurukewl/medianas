#!/bin/bash
# Need to disable power button in xfce with: DOESNT WORK -> BUG in lUbuntu! 
# /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml value=0 
# /etc/systemd/logind.conf : HandlePowerKey=ignore

echo "Power button $1 seconds pressed"
if [ "$1" -lt "1" ]; then
echo "Short Press"
#Short Button Code
#Short Press
#Shutdown
poweroff
#Short Press END
elif [ "$1" -gt "9" ]; then
   # make blue LED BLINK and Reset Config - Default
      
   echo "Reset to Default Config"
   if [ -e /opt/medianas/factory/medianas_complete.zip ]; then
	   echo timer > /sys/class/leds/led1/trigger;
	   echo 10 > /sys/class/leds/led1/delay_on;
	   echo 40 > /sys/class/leds/led1/delay_off;
	   unzip -o /opt/medianas/factory/medianas_complete.zip -d /opt/medianas/cache/factory
	   cp -af /opt/medianas/cache/factory/CONFIG_SYSTEM/. /etc/
	   cp -af /opt/medianas/cache/factory/CONFIG_USER/. /home/odroid/.config/
	   cp -af /opt/medianas/cache/factory/opt/. /opt/
	   cp -af /opt/medianas/cache/factory/medianas/. /var/www/medianas/
	   echo "Factory Setting Successful"
	   reboot
   fi
else
echo "Long Press"
#Long Button Code
#Long Press

#Long Press END
fi

exit 0

#!/bin/bash
# start_accesspoint_onboot.sh

# Check for existing connection AND (new) cable disconnected on eth0
# Could also check for Opstate of eth0 (/sys/class/net/eth0/operstate)
# Slow routers seem to make problems without carrier check
if [ "$(cat /sys/class/net/eth0/carrier)" -lt "1" -a "$(LANG=C && /sbin/ip addr show eth0 | grep 'inet ' | wc -l)" -lt "1" -a "$(LANG=C && /sbin/ip addr show wlan0 | grep 'ether' | wc -l)" -gt "0" -a "$(LANG=C && /sbin/ip addr show wlan0 | grep 'inet ' | grep -v '169.254' | wc -l)" -lt "1" ]; then
	echo "No network connection..." 
else
	exit 0
fi

# Check for Parameter auto_accesspoint_mode in options
if [ "$(grep 'auto_accesspoint_mode=1' /opt/medianas/options.conf | wc -l)" -lt "1" ]; then
	echo "No Auto-Accesspoint-Mode activated"
	exit 0
fi

echo "Starting Accesspoint Mode..."
/var/www/medianas/application/plugins/accesspoint/scripts/install_accesspoint.sh /var/www/medianas/application/plugins/accesspoint/scripts/ 1

exit 0
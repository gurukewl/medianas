#!/bin/bash

#$1 is parameter for ssid
#$2 is parameter for passphrase

# Make sure previous script is loaded to prevent connection abort
sleep 5
eth_connected=$(LANG=C && /sbin/ip addr show eth0 | grep -o 'inet [0-9.]\+' | grep -o '[0-9.]\+')

hostapd_running=$(ps -Al | grep hostapd | wc -l)
if [ "$hostapd_running" -gt "0" ]; then
	/etc/init.d/hostapd stop 2>&1 > /dev/null
	# Disable Accesspoint
	echo "Disable Accesspoint"
	/var/www/medianas/application/plugins/accesspoint/scripts/uninstall_accesspoint.sh 1
	sleep 3
fi

ifdown wlan0 2>&1 > /dev/null
killall -q wpa_supplicant && sleep 3

wpa_supplicant -B w -D wext -i wlan0 -c /opt/medianas/wpa_supplicant.conf 2>&1 > /dev/null;
wpa_cli -iwlan0 add_network
wpa_cli -iwlan0 set_network 0 key_mgmt WPA-PSK
wpa_cli -iwlan0 set_network 0 mode 0
eval "wpa_cli -iwlan0 set_network 0 psk '\"$2\"'"
eval "wpa_cli -iwlan0 set_network 0 ssid '\"$1\"'"
wpa_cli -iwlan0 enable_network 0
wpa_cli -iwlan0 save_config
killall -q wpa_supplicant && sleep 3

# Enable Interface Wlan0
sed -i 's/#pre-up wpa_supplicant/pre-up wpa_supplicant/;s/#allow-hotplug wlan0/allow-hotplug wlan0/;s/#auto wlan0/auto wlan0/;s/#iface wlan0 inet dhcp/iface wlan0 inet dhcp/;s/#post-down killall/post-down killall/' /etc/network/interfaces

# Launch Wlan0 and check for valid DHCPOffer!
checkwifi=$(LANG=C && ifup wlan0 2>&1 | grep "No DHCPOFFERS received" | wc -l)
sleep 3

# Check Wlan connection problem: sometimes IP still on accesspoint | grep -v '192.168.189.1 '
if [ "$checkwifi" -gt "0" -o "$(LANG=C && /sbin/ip addr show wlan0 | grep 'inet ' | grep -v '169.254' | wc -l)" -lt "1" ]; then
	echo "<b>No IP-Address could be received - WiFi NOT working correctly. Please check Network-ID and Passphrase!</b>"
	sed -i 's/^pre-up wpa_supplicant/#pre-up wpa_supplicant/;s/^allow-hotplug wlan0/#allow-hotplug wlan0/;s/^auto wlan0/#auto wlan0/;s/^iface wlan0 inet dhcp/#iface wlan0 inet dhcp/;s/^post-down killall/#post-down killall/' /etc/network/interfaces
	ifdown wlan0 2>&1 > /dev/null
	killall wpa_supplicant && sleep 3
	wpa_supplicant -B w -D wext -i wlan0 -c /opt/medianas/wpa_supplicant.conf 2>&1 > /dev/null
	sleep 1
	# Remove Network that does not work
	wpa_cli -iwlan0 remove_network 0
	wpa_cli -iwlan0 save_config
	killall wpa_supplicant && sleep 3
	wpa_supplicant -B w -D wext -i wlan0 -c /opt/medianas/wpa_supplicant.conf 2>&1 > /dev/null 
	sleep 1
	if [ "$hostapd_running" -gt "0" -o "$eth_connected" == "" ]; then
		/var/www/medianas/application/plugins/accesspoint/scripts/install_accesspoint.sh /var/www/medianas/application/plugins/accesspoint/scripts/ 1
	fi
else
    # enable Autoreconnect WiFi
    echo "Enable Autoreconnect WiFi..."    
    autoreconnect_wifi=$(cat /opt/medianas/options.conf | grep autoreconnect_wifi | wc -l)    
	if [ "1" -gt "$autoreconnect_wifi" ]; then
	    echo "autoreconnect_wifi=1" >> /opt/medianas/options.conf
	else
	    sed -i 's/autoreconnect_wifi.*/autoreconnect_wifi=1/' /opt/medianas/options.conf
	fi
fi


echo "Finished <b><a href='/plugins/medianas_settings/controller/Wlan.php'>Please Click here Reload Page!</a></b>"

exit 0
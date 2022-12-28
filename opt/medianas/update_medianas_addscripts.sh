#!/bin/sh
#Upsampling Squeezelite
#(echo "y") | apt-get install libsoxr0

#Remove error logging to ubuntu
rm /etc/init/whoopsie.conf

#Remove Cron spamming syslog
rm /etc/rsyslog.d/50-default.conf
crontab -u odroid -l > /opt/medianas/cache/cronodroid
sed -i 's/start_audioplayer.sh$/start_audioplayer.sh > \/dev\/null 2>\&1/' /opt/medianas/cache/cronodroid
crontab -u odroid /opt/medianas/cache/cronodroid
rm /opt/medianas/cache/cronodroid

if [ -e /opt/medianas/factory/medianas_complete.zip ]; then
    echo "Factory Settings available"
else
	mkdir /opt/medianas/factory
	wget http://shop.medianas.com/media/downloadable/currentversion/medianas_complete.zip -O /opt/medianas/factory/medianas_complete.zip	
	echo "Added Factory Settings"
fi

#Add medianas Powerbutton to StartUp Only on ODROID U3!
HW_U3=$(cat /proc/cpuinfo | grep Hardware | grep -i "ODROID-U2/U3" | wc -l)
if [ "$HW_U3" -gt "0" ]; then
	powerbutton=$(cat /etc/rc.local | grep pwrbutton | wc -l)
	if [ "$powerbutton" -lt "1" ]; then 
		sed -i 's/^exit 0/\/opt\/medianas\/pwrbutton 2>\&1 > \/dev\/null \&\n\nexit 0/' /etc/rc.local
	fi
	
	#Update Bootoptions for setting resolution from http://forum.odroid.com/viewtopic.php?f=52&t=2947
	if [ -e /media/boot/boot-auto_edid.scr ]; then
		echo "Boot Options for HDMI existing"
	else	
		wget http://builder.mdrjr.net/tools/boot.scr_ubuntu.tar -O /opt/medianas/cache/boot_scr.tar
		tar -xf /opt/medianas/cache/boot_scr.tar -C /opt/medianas/cache
		rm -Rf /opt/medianas/cache/x
		cp /opt/medianas/cache/x2u2/boot-* /media/boot
		rm -Rf /opt/medianas/cache/x2u2
		cp -f /media/boot/boot.scr /media/boot/boot-auto_edid.scr
	fi
	# Fix IPv6 deaktivieren - Problem: reloadin apache after this fix may crash apache process
	IPV6DISABLED=$(grep -i "Listen 0.0.0.0:80" /etc/apache2/ports.conf | wc -l)
	if [ "$IPV6DISABLED" -lt "1" ]; then 
		echo "Disable IPv6 for Webinterface"		
		sudo sed -i 's/Listen 80/Listen 0.0.0.0:80/' /etc/apache2/ports.conf		
	fi	
	
	NFSINSTALLED=$(dpkg -s nfs-common | grep "Status: install ok" | wc -l)	
	if [ "$NFSINSTALLED" -lt "1" ]; then
		apt-get update
		echo "Y" | apt-get install nfs-common --yes
	fi	
fi

# XU4: check Mac-Adress and remove udev rule with Mac
HW_XU3=$(cat /proc/cpuinfo | grep Hardware | grep -i "ODROID-XU3" | wc -l)
if [ "$HW_XU3" -gt "0" ]; then	
	echo "Remove MAC-Address from UDEV-Rules"
	# cat /etc/udev/rules.d/70-persistent-net.rules remove my Device MAC and eth1 if existing
	sed -i 's/.*00:1e:06:31:06:13.*//' /etc/udev/rules.d/70-persistent-net.rules
	sed -i 's/.*eth1.*//' /etc/udev/rules.d/70-persistent-net.rules
	
	# Fix for wrong FSTAB
	sed -i "s/1##USERMOUNT/1\n\n##USERMOUNT/" /etc/fstab
	
	# Fix IPv6 deaktivieren - Problem: reloadin apache after this fix may crash apache process
	IPV6DISABLED=$(grep -i "Listen 0.0.0.0:80" /etc/apache2/ports.conf | wc -l)
	if [ "$IPV6DISABLED" -lt "1" ]; then 
		echo "Disable IPv6 for Webinterface"		
		sudo sed -i 's/Listen 80/Listen 0.0.0.0:80/' /etc/apache2/ports.conf
	fi
	# Fix for usbmount ntfs/ntfs-3g (otherwise it will not mount correctly)
	apt-get update
	apt-get install at -y
	# Apply Patch for usbmount if not yet patched
	if [ "$(grep -i "medianas" /usr/share/usbmount/usbmount | wc -l)" -lt "1" ]; then 
		sed -i "s~mount \"-t\$fstype\" \"\${options:+-o\$options}\" \"\$DEVNAME\" \"\$mountpoint\"~echo mount \"-t\$fstype\" \"\${options:\+-o\$options}\" \"\$DEVNAME\" \"\$mountpoint\" >/tmp/usbmount_medianas.sh\n                at -f /tmp/usbmount_medianas.sh now~" /usr/share/usbmount/usbmount
	fi
	# Patch wrong patch...
	sed -i "s/echo echo/echo/;s/echo echo/echo/;s/echo echo/echo/;s/echo echo/echo/;s@at -f /tmp/usbmount_medianas.sh now >/tmp/usbmount_medianas.sh@@" /usr/share/usbmount/usbmount
fi

#Disable IPv6 - not working correct yet
#ip -6 neigh flush dev eth0
#ip -6 neigh flush dev wlan0
#echo "net.ipv6.conf.all.disable_ipv6 = 1" > /etc/sysctl.d/01-disable-ipv6.conf

#Check if Install was OK (filesize = 0 problem) otherwise try again...
if [ -s /opt/medianas/start_xbmc.sh ]; then
	echo "OK"
else
	echo "FILESIZE WRONG - Retry Installation"
	sleep 2
	if [ -e /var/www/medianas/application/config/plugins.xml ]; then 
		unzip -o /opt/medianas/cache/webinterface.zip -d /var/www -x \*plugins.xml
	else
		unzip -o /opt/medianas/cache/webinterface.zip -d /var/www
	fi
	
	echo "Install Scripts"
	unzip -o /opt/medianas/cache/scripts.zip -d /
fi

#Fix for rc.local file to make Mounting more robust
sed -i 's/done;\/bin\/mount -a/done;set +e;\/bin\/mount -a;set -e;/' /etc/rc.local

HW_RASPBERRY=$(cat /proc/cpuinfo | grep Hardware | grep -i "BCM2708\|BCM2709\|BCM2837\|BCM2835\|BCM2836" | wc -l)
if [ "$HW_RASPBERRY" -gt "0" ]; then
	#Fix for wrong hostname in Image 2.31
	HOSTNAME=$(cat /etc/hostname)
	if [ ! "$HOSTNAME" = "" ]; then 		
		sudo sed -i "s/raspberrypi/$HOSTNAME/;s/medianas/$HOSTNAME/" /etc/hosts
	fi
	
	#Timeout fix on Start / Stop (90sec wait)
	sudo sed -i "s/#DefaultTimeoutStartSec=.*/DefaultTimeoutStartSec=10s/;s/#DefaultTimeoutStopSec=.*/DefaultTimeoutStopSec=10s/" /etc/systemd/system.conf
	
	#sudo sed -i 's@/var/lib/mpd:/bin/false@/var/lib/mpd:/bin/bash@' /etc/passwd
	sudo usermod -aG audio mpd
	# Fix Permissions for Radio Folder (justboom info in forum)
	sudo chown -R mpd:audio /var/lib/mpd/music/RADIO
	sudo sed -i 's/odroid/pi/' /etc/usbmount/usbmount.conf
	#Fix for rc.local file	
	sed -i 's/let \"COUNTER++\"/COUNTER=\$\(\(COUNTER+1\)\)/;s/\;mount/\;\/bin\/mount/' /etc/rc.local
	
	#Fix for missing SYSTEM_USER in audioplayer.conf and wrong audioplayer.conf.sav on image creation
	if [ $(grep -i "SYSTEM_USER" /opt/medianas/audioplayer.conf.sav | wc -l) -lt "1" ]; then
		echo "SYSTEM_USER=pi" >> /opt/medianas/audioplayer.conf.sav
		sed -i 's/SQUEEZELITE_PARAMETER.*/SQUEEZELITE_PARAMETER=-o default:CARD=ALSA -a 120::16:/' /opt/medianas/audioplayer.conf.sav
		sed -i 's/SHAIRPORT_PARAMETER.*/SHAIRPORT_PARAMETER=-d default:CARD=ALSA/' /opt/medianas/audioplayer.conf.sav
	fi
	
	EXPECTINSTALLED=$(dpkg -s expect | grep "Status: install ok" | wc -l)
	if [ "$EXPECTINSTALLED" -lt "1" ]; then
		apt-get update
		echo "Y" | apt-get install ntfs-3g lsb-release expect -y
	fi
	
	#Remove "-a 120::16:" from squeezelite_parameter due to fixed sample rate
	sed -i 's/\-a 120::16:/\-a 120:::/' /opt/medianas/audioplayer.conf
	#Copy Squeezeplug custom.css and Header Files if Existing
	if [ -e "/var/www/medianas/application/plugins/squeezeplug/view/header_custom.php" ]; then
	    # Update Plugin squeezeplug
		/opt/medianas/install_plugin.sh http://shop.medianas.com/media/downloadable/beta/squeezeplug.tar
	    echo "Copy custom header files"
	    cp -f /var/www/medianas/application/plugins/squeezeplug/view/header_custom.php /var/www/medianas/application/view/
	    cp -f /var/www/medianas/application/plugins/squeezeplug/scripts/custom.css /var/www/medianas/public/
	    mkdir /var/www/medianas/public/addons/squeezeplug
	    cp -f /var/www/medianas/application/plugins/squeezeplug/scripts/images/* /var/www/medianas/public/addons/squeezeplug/
	    
	    # FIX ERROR remove double Entry in Crontab
	    crontab -u pi -l | /usr/bin/uniq > /opt/medianas/cache/cronmedianas
		crontab -u pi /opt/medianas/cache/cronmedianas
	    rm /opt/medianas/cache/cronmedianas
	fi
	
	#get Version (beta/currentversion)
	ISBETA=$(grep -i "beta" /var/www/medianas/application/config/version.txt | wc -l)
	if [ "$ISBETA" -lt "1" ]; then
	    VERSION="currentversion"
	else
		VERSION="beta"
	fi
	
	if [ -e "/var/www/medianas/application/plugins/allo/view/header_custom.php" ]; then
	    # Update Plugin Header		
	    echo "Copy custom header files Allo"
	    cp -f /var/www/medianas/application/plugins/allo/view/header_custom.php /var/www/medianas/application/view/
	    cp -f /var/www/medianas/application/plugins/allo/scripts/custom.css /var/www/medianas/public/
	fi
	if [ -e "/var/www/medianas/application/plugins/hifiberry/view/header_custom.php" ]; then
	    # Workaround for OLDER hifiberry Images - get current Pluginfiles to overwrite CSS	    
	    /opt/medianas/install_plugin.sh https://shop.medianas.com/media/downloadable/$VERSION/hifiberry.tar
	    
	    # Update Plugin Header		
	    echo "Copy custom header files hifiberry"	    
	    cp -f /var/www/medianas/application/plugins/hifiberry/view/header_custom.php /var/www/medianas/application/view/
	    cp -f /var/www/medianas/application/plugins/hifiberry/scripts/custom.css /var/www/medianas/public/
	fi
	if [ -e "/var/www/medianas/application/plugins/iqaudio/view/header_custom.php" ]; then
	    # Workaround for OLDER hifiberry Images - get current Pluginfiles to overwrite CSS	    
	    /opt/medianas/install_plugin.sh https://shop.medianas.com/media/downloadable/$VERSION/iqaudio.tar
	    
	    # Update Plugin Header		
	    echo "Copy custom header files iqaudio"
	    cp -f /var/www/medianas/application/plugins/iqaudio/view/header_custom.php /var/www/medianas/application/view/
	    cp -f /var/www/medianas/application/plugins/iqaudio/scripts/custom.css /var/www/medianas/public/
	fi
	if [ -e "/var/www/medianas/application/plugins/audiophonics/view/header_custom.php" ]; then
	    # Update Plugin Header		
	    echo "Copy custom header files audiophonics"
	    cp -f /var/www/medianas/application/plugins/audiophonics/view/header_custom.php /var/www/medianas/application/view/
	    cp -f /var/www/medianas/application/plugins/audiophonics/scripts/custom.css /var/www/medianas/public/
	fi	
	if [ -e "/var/www/medianas/application/plugins/justboom/view/header_custom.php" ]; then
	    # Update Plugin Header		
	    echo "Copy custom header files justboom"
	    cp -f /var/www/medianas/application/plugins/justboom/view/header_custom.php /var/www/medianas/application/view/
	    cp -f /var/www/medianas/application/plugins/justboom/scripts/custom.css /var/www/medianas/public/
	fi	
	
	if [ "$(grep -i "start_audioplayer" /etc/rc.local | wc -l)" -lt "1" ]; then
		# Add Start Audioplayer to boot (not wait for crontab)
		sudo sed -i "s/^exit 0/#medianas Start Audioplayer\nsudo -u pi -H -s \/opt\/medianas\/start_audioplayer.sh > \/dev\/null 2>\&1 \&\n\nexit 0/" /etc/rc.local
	fi
	
	# USBMOUNT Charset Umlaute Fix Fat32
	if [ "$(grep -i "iocharset=iso8859-1" /etc/usbmount/usbmount.conf | wc -l)" -lt "1" ]; then
		sudo sed -i "s/fstype=vfat,gid=users,uid=pi/fstype=vfat,gid=users,uid=pi,iocharset=iso8859-1/" /etc/usbmount/usbmount.conf
	fi
	
	# Fix wrong YMPD Parameter webport
	sed -i 's/YMPD_PARAMETER=8081/YMPD_PARAMETER=--webport 8081/' /opt/medianas/audioplayer.conf
	
	# Jessie Fix USBMOUNT NTFS ONLY ON JESSIE!
	ISJESSIE=$(lsb_release -r | grep '8.0' | wc -l)	
	if [ "$ISJESSIE" -gt "0" -a -e /etc/systemd/system ]; then
		if [ ! -e /etc/systemd/system/usbmount@.service ]; then
			echo "Fix USB-Mount on Debian Jessie"
			echo "[Unit]\nBindTo=%i.device\nAfter=%i.device\n\n[Service]\nType=oneshot\nTimeoutStartSec=0\nEnvironment=DEVNAME=%I\nExecStart=/usr/share/usbmount/usbmount add\nRemainAfterExit=yes" > /etc/systemd/system/usbmount@.service
			echo "# Rules for USBmount -*- conf -*-\nKERNEL==\"sd*\", DRIVERS==\"sbp2\",         ACTION==\"add\",  PROGRAM=\"/bin/systemd-escape -p --template=usbmount@.service \$env{DEVNAME}\", ENV{SYSTEMD_WANTS}+=\"%c\"\nKERNEL==\"sd*\", SUBSYSTEMS==\"usb\",       ACTION==\"add\",  PROGRAM=\"/bin/systemd-escape -p --template=usbmount@.service \$env{DEVNAME}\", ENV{SYSTEMD_WANTS}+=\"%c\"\nKERNEL==\"ub*\", SUBSYSTEMS==\"usb\",       ACTION==\"add\",  PROGRAM=\"/bin/systemd-escape -p --template=usbmount@.service \$env{DEVNAME}\", ENV{SYSTEMD_WANTS}+=\"%c\"\nKERNEL==\"sd*\",                          ACTION==\"remove\",       RUN+=\"/usr/share/usbmount/usbmount remove\"\nKERNEL==\"ub*\",                          ACTION==\"remove\",       RUN+=\"/usr/share/usbmount/usbmount remove\"" > /etc/udev/rules.d/usbmount.rules
			rm /lib/udev/rules.d/usbmount.rules
		fi		
		# ifplugd fix for missing eth0
		sudo sed -i 's/^INTERFACES=""/INTERFACES="eth0"/' /etc/default/ifplugd
		
		# Update Kodi Settings for Webserver on Port 80 to remote Control
		if [ -e /home/pi/.kodi/userdata/guisettings.xml ]; then
		   echo "Update Kodi: Activate Webserver for Remote Control"
		   sed -i 's@<webserver default="true">false</webserver>@<webserver>true</webserver>@' /home/pi/.kodi/userdata/guisettings.xml
		fi		
	fi
	
	RELEASE=$(lsb_release -a 2>/dev/null | grep Codename | sed "s/Codename:\t//")
	if [ "$RELEASE" = "stretch" -o "$RELEASE" = "buster" ]; then		
		if [ ! -e /etc/systemd/system/apache2.service ]; then
			cp /lib/systemd/system/apache2.service /etc/systemd/system/
			echo "Apply Fix for private /tmp folder in Apache Service"
			sed -i 's@PrivateTmp=true@PrivateTmp=false@' /etc/systemd/system/apache2.service
		fi
		sed -i 's@DefaultTimeoutStartSec=10@DefaultTimeoutStartSec=20@' /etc/systemd/system.conf
	fi
	
	# Fix for moving Repository mode from testing to stable 
	if [ "$RELEASE" = "buster" ]; then
		apt-get --allow-releaseinfo-change update -y
	fi
	
	# Fix for NOT JESSIE and deleted usbmount rules
	if [ "$ISJESSIE" -lt "1" -a ! "$RELEASE" = "stretch" -a ! "$RELEASE" = "buster" -a ! -e /lib/udev/rules.d/usbmount.rules ]; then
		echo "Remove Fix for USB-Mount on NON-Jessie"
		echo "KERNEL==\"sd*\", DRIVERS==\"sbp2\",		ACTION==\"add\",	RUN+=\"/usr/share/usbmount/usbmount add\"\nKERNEL==\"sd*\", SUBSYSTEMS==\"usb\",	ACTION==\"add\",	RUN+=\"/usr/share/usbmount/usbmount add\"\nKERNEL==\"ub*\", SUBSYSTEMS==\"usb\",	ACTION==\"add\",	RUN+=\"/usr/share/usbmount/usbmount add\"\nKERNEL==\"sd*\",				ACTION==\"remove\",	RUN+=\"/usr/share/usbmount/usbmount remove\"\nKERNEL==\"ub*\",				ACTION==\"remove\",	RUN+=\"/usr/share/usbmount/usbmount remove\"" > /lib/udev/rules.d/usbmount.rules
		rm /etc/systemd/system/usbmount@.service
		rm /etc/udev/rules.d/usbmount.rules		
	fi
	
	EXFATINSTALLED=$(dpkg -s exfat-fuse | grep "Status: install ok" | wc -l)	
	if [ "$EXFATINSTALLED" -lt "1" ]; then
		apt-get update
		echo "Y" | apt-get install exfat-fuse exfat-utils --yes
		# fix USB-Mount filesystem Options
		EXFATUSBMOUNT=$(grep -i "exfat" /etc/usbmount/usbmount.conf | wc -l)
		if [ "$EXFATUSBMOUNT" -lt "1" ]; then
			sed -i 's/hfsplus/hfsplus exfat/' /etc/usbmount/usbmount.conf
		fi
	fi
	
	#Add Further Languages here
	if [ -e /etc/locale.gen ]; then
		if [ "5" -gt "$(grep -e "^de_DE\|^fr_FR\|^it_IT\|^en_GB\|^ru_RU" /etc/locale.gen | wc -l)" ]; then
			sudo sed -i 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/;s/# it_IT.UTF-8 UTF-8/it_IT.UTF-8 UTF-8/;s/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/;s/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/;s/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen
  			# FOR TESTSERVER DEMO LANGUAGES (activate all): sudo sed -i 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/;s/# it_IT.UTF-8 UTF-8/it_IT.UTF-8 UTF-8/;s/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/;s/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/;s/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/;s/# hu_HU.UTF-8 UTF-8/hu_HU.UTF-8 UTF-8/;s/# es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen
  			sudo locale-gen
  			echo "Updated Locales"
  		fi
  	fi
  	
  	if [ -e /etc/pulse/daemon.conf -a "$(grep -i '^default-fragments = 5' /etc/pulse/daemon.conf | wc -l)" -lt "1" ]; then
       echo "default-fragments = 5\ndefault-fragment-size-msec = 2\n" >> /etc/pulse/daemon.conf
    fi
    
    # Fix for unlimited Network Timeout on Boot (prevents booting)
    if [ -e /lib/systemd/system/networking.service.d/network-pre.conf -a "$(grep TimeoutStartSec /lib/systemd/system/networking.service.d/network-pre.conf | wc -l)" -lt "1" ]; then
    	echo "\n[Service]\nTimeoutStartSec=45\n" >> /lib/systemd/system/networking.service.d/network-pre.conf
    fi
    
    # Start Accesspoint on Boot only for RPI
    if [ "$(grep -i "start_accesspoint_onboot.sh" /etc/rc.local | wc -l)" -lt "1" ]; then
    	sudo sed -i "s@^exit 0@#Start Accesspoint on Boot if no network connection available\n/var/www/medianas/application/plugins/accesspoint/scripts/start_accesspoint_onboot.sh\nexit 0@" /etc/rc.local
    fi
    
    # If no hostapd Running also disable dnsmasq - bugfix for running dmsmasq on some installations
    if [ "$(ps -Al | grep hostapd | wc -l)" -lt "1" -a "$(ps -Al | grep dnsmasq | wc -l)" -gt "0" ]; then
    	sudo update-rc.d -f dnsmasq disable
    	sudo /etc/init.d/dnsmasq stop
    	echo "Disabled DHCP Server DNSMASQ - Service should only run in Accesspoint Mode."
    fi
fi

#htaccess Password Protection Overwrite Backup
if [ -e "/var/www/medianas/public/.htaccess_add" ]; then
	cat /var/www/medianas/public/.htaccess_add | cat - /var/www/medianas/public/.htaccess > /var/www/medianas/public/.htaccess.tmp && mv /var/www/medianas/public/.htaccess.tmp /var/www/medianas/public/.htaccess
fi

showHelpOnSidebar=$(grep -a "showHelpOnSidebar" /opt/medianas/options.conf | wc -l)
if [ "$showHelpOnSidebar" -lt "1" ]; then
    echo "showHelpOnSidebar=1" >> /opt/medianas/options.conf
    echo "Added Help on Sidebar"
fi

# Delete News Sidebar -> force Reload News
if [ -e /tmp/0.html ]; then
	rm /tmp/0.html
fi

# Custom Allo Sparky usbmount for user "vana"
USERNAME=$(grep -aP "^[ \t]*SYSTEM_USER" /opt/medianas/audioplayer.conf | sed -n -e "s/^[ \t]*[A-Za-z_0-9\.]*=//p")
if [ "$USERNAME" = "vana" ]; then
	sudo sed -i "s/odroid/vana/" /etc/usbmount/usbmount.conf
fi

if [ ! -e /opt/medianas/custom_autostart.sh ]; then
	echo '#!/bin/bash\n#Custom Autostart File\n' > /opt/medianas/custom_autostart.sh
	chmod 777 /opt/medianas/custom_autostart.sh
fi
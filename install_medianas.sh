#!/bin/bash
echo "#### mediaNAS-Installer for x86-x64 devices ####"
echo "This script installs scripts to /opt/medianas and the webinterface to /var/www/medianas"
echo " - On first start it will do an update/upgrade and expand filesystem and get Max2Play files - then it automatically rebootes"
echo " - On second start it installs all the fancy stuff and brings the webinterface to life"
echo "Edit Parameters on top of script to change the default behavior of this script!"
echo ""
echo "RUN with 'sudo install_medianas.sh 2>&1 | tee install_medianas.log' to save Install-Logfile and see output on console!"
echo ""

# # expand Filesystem during install
# EXPAND_FILESYSTEM="N"

# # set to Y if you want default password "medianas"
# CHANGE_PASSWORD="N" 

# leave empty to keep current hostname
CHANGE_HOSTNAME="" 
PROJECT="mediaNAS" 

CWD=$(pwd)

if [ "$(whoami)" != "root" ]; then
	echo "Run this script with sudo OR as root! Otherwise it won't install correctly!"
	exit 1
fi

LINUX=$(lsb_release -a 2>/dev/null | grep Distributor | sed "s/Distributor ID:\t//")
RELEASE=$(lsb_release -a 2>/dev/null | grep Codename | sed "s/Codename:\t//")

echo "Linux is $LINUX"
echo "Release is $RELEASE"

sudo apt-get update
echo "Y" | sudo apt-get upgrade	
pushd $CWD
sudo cp -r medianas/opt/* /opt
chmod -R 777 /opt/medianas/
# chmod 666 /etc/fstab
# echo -e "\n##USERMOUNT" >> /etc/fstab
# cp /etc/fstab /etc/fstab.sav
# chmod 666 /etc/fstab.sav

# Make sure eth0 is named correctly	
# sudo echo 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="*", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="eth*", NAME="eth0"' >> /etc/udev/rules.d/70-persistent-net.rules
sudo echo "Y" | apt-get install apache2 php php-json php-xml -y
sudo a2enmod rewrite
rm /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default
cp medianas/CONFIG_SYSTEM/apache2/sites-enabled/medianas.conf /etc/apache2/sites-enabled/
sed -i 's/LogLevel warn/LogLevel error/' /etc/apache2/apache2.conf
cp -r medianas/medianas/ /var/www/medianas 
sudo /etc/init.d/apache2 restart
sudo echo "Y" | apt-get install samba samba-common samba-common-bin mc ntfs-3g cifs-utils nfs-common git libconfig-dev smbclient

sudo apt-get install debconf-utils
# echo "Generate Locales for predefined languages..."
# sed -i 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/;s/# it_IT.UTF-8 UTF-8/it_IT.UTF-8 UTF-8/;s/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/;s/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/;s/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
export LANG=en_GB.UTF-8
dpkg-reconfigure -f noninteractive locales
echo "Asia/Kolkata" > /etc/timezone
ln -fs /usr/share/zoneinfo/`cat /etc/timezone` /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

sudo apt-get install ifplugd
sudo echo "Y" | apt-get install nmap
# sudo echo "Y" | apt-get remove xscreensaver

sudo echo "Y" | apt-get install usbmount
cp -f medianas/CONFIG_SYSTEM/usbmount/usbmount.conf /etc/usbmount/usbmount.conf

pushd $CWD
#fix exzessives Logging in syslog & co (cron)
cp -f medianas/CONFIG_SYSTEM/rsyslog.conf /etc/rsyslog.conf

#Copy Config Files 
echo "1.0" > /var/www/medianas/application/config/version.txt

#Remove Bash history & Clean up the system
apt-get --yes autoremove
apt-get --yes autoclean
apt-get --yes clean
rm /root/.bash_history
cd /
history -c
	
#Disable IPv6 for Apache
sed -i 's/Listen 80/Listen 0.0.0.0:80/' /etc/apache2/ports.conf

pushd $CWD
#Sudoers
cp -f medianas/CONFIG_SYSTEM/sudoers.d/medianas /etc/sudoers.d/
#Network
cp -f medianas/CONFIG_SYSTEM/network/* /etc/network/
chmod 666 /etc/network/*
#Samba
cp -f medianas/CONFIG_SYSTEM/samba/smb.conf /etc/samba/
#Udev Rules
cp -f medianas/CONFIG_SYSTEM/udev/rules.d/* /etc/udev/rules.d/

#Add Net-Availability Check for Mountpoints to /etc/rc.local and make it more robust with "set +e"
sudo sed -i "s/^exit 0/#Network Check for Mountpoints\nCOUNTER=0;while \[ -z \"\$\(\/sbin\/ip addr show eth0 \| grep -i 'inet '\)\" -a -z \"\$\(\/sbin\/ip addr show wlan0 \| grep -i 'inet '\)\" -a \"\$COUNTER\" -lt \"5\" \]; do echo \"Waiting for network\";COUNTER=\$\(\(COUNTER+1\)\);sleep 3;done;set +e;\/bin\/mount -a;set -e;\n\nexit 0/" /etc/rc.local

# #Change Password to default
# if [ "$CHANGE_PASSWORD" = "Y" ]; then 
# 	echo -e "medianas\nmedianas\n" | passwd
# fi
# if [ "$CHANGE_HOSTNAME" = "" ]; then
# 	cat /etc/hostname > /opt/medianas/playername.txt
# 	cat /etc/hostname > /opt/medianas/playername.txt.sav
# else
# 	echo "$CHANGE_HOSTNAME" > /etc/hostname
# 	# edit hosts file
# 	sudo sed -i "s/raspberrypi/$CHANGE_HOSTNAME/;s/odroid/$CHANGE_HOSTNAME/" /etc/hosts
# fi
# chmod 666 /etc/hostname

chmod 777 /opt/medianas/wpa_supplicant.conf

echo "To Install Autoconfig run: "
echo "sed -i \"s@^#Max2Play\\\$@#Max2Play\nif [ -e /boot/medianas.conf ]; then /opt/medianas/autoconfig.sh; fi\n@\" /etc/rc.local" 

#Remove Install Files in local directory
# rm -R medianas
# rm -R medianas_complete.zip
# rm install_medianas.sh

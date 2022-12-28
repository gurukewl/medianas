#!/bin/sh
# Do this if possible as root!
# File is work in progress and not working (more as a reminder what to do...)
# Fix Internet connection

# Get medianas
wget shop.medianas.com/media/downloadable/currentversion/medianas_complete.zip
unzip medianas_complete.zip -d medianas

# Update Sources
sudo apt-get update

# Screensaver entfernen
sudo echo "Y" | apt-get remove xscreensaver

# Cronjob für Autostart der Player
#sudo echo "* * * * /opt/medianas/start_audioplayer.sh" >> cron

# Apache2 installieren und Config kopieren
sudo echo "Y" | apt-get install apache2 php5 php5-json
sudo a2enmod rewrite
rm /etc/apache2/sites-enabled/000-default.conf
cp medianas/CONFIG_SYSTEM/apache2/sites-enabled/medianas.conf /etc/apache2/sites-enabled/
cp -r medianas/medianas/ /var/www/medianas 
sudo /etc/init.d/apache2 reload

# Samba aufsetzen für IP-Namensauflösung unter Windows 
sudo echo "Y" | apt-get install samba samba-common

# XBMC über Konsole starten: SSH mit User Login
#  www-data: rechte anpassen für .ssh verzeichnis unter www
#  ssh-keygen -> key export nach linaro

# Shairport Installieren und alle Dienste dazu (ahci, etc.) https://github.com/abrasive/shairport (Doku)

# DAUERHAFT IN MODPROBE SPEICHERN: config für modprobe kopieren
modprobe -rv rtl8192cu;
 
# Sprache anpassen 
sudo apt-get install debconf-utils

# nmap installieren für erkennung weiterer Boxen auf port 5002
sudo echo "Y" | apt-get install nmap

# ifplugd installieren -> ETH0 wird nicht auf auto gesetzt in interfaces
sudo apt-get install ifplugd

# Idle Funktion für ext. Festplatte http://blog.sepa.spb.ru/2013/03/precompiled-hd-idle-armhf-deb-package.html 
# http://hd-idle.sourceforge.net/ -> deb Paket in medianas vorhanden
# -> autostart auf aktiv /etc/default/hd-idle und Kommentar letzte Zeile raus VORINSTALLIEREN!

# Alsaequal http://www.thedigitalmachine.net/alsaequal.html -> Alsaequal mit Paket Caps installieren
# vorher Symlink auf lib Verzeichnis alsa-lib und dann noch apt-get install libasound2-plugin-equal

# medianas Scripte und Dienste
sudo cp -r medianas/opt/ /opt

# Sudoers, Scripts & everything else
pushd medianas/CONFIG_SYSTEM
sudo cp -r . /etc/

# Make some Files Writable
# hostname, ...

#fstab erweitern um ##USERMOUNT

# Remove writeable on sudoers

#USBmount installieren
apt-get install usbmount



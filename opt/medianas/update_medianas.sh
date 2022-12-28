#!/bin/sh
#Update medianas Scripts and Webinterface
if [ "$1" = "beta" ];then
   VERSION=beta
else
   VERSION=currentversion
fi
   
echo "Get Data"
wget "https://shop.medianas.com/media/downloadable/$VERSION/webinterface.zip" -O /opt/medianas/cache/webinterface.zip
wget "https://shop.medianas.com/media/downloadable/$VERSION/scripts.zip" -O /opt/medianas/cache/scripts.zip

echo "Install Webinterface"
if [ -e /var/www/medianas/application/config/plugins.xml ]; then 
	unzip -o /opt/medianas/cache/webinterface.zip -d /var/www -x \*plugins.xml
else
	unzip -o /opt/medianas/cache/webinterface.zip -d /var/www
fi

echo "Install Scripts"
unzip -o /opt/medianas/cache/scripts.zip -d /

# Fix für usbmount Geschwindigkeit
sed -i 's/^MOUNTOPTIONS="sync,noexec,nodev,noatime,nodiratime"/MOUNTOPTIONS="noexec,nodev,noatime,nodiratime"/' /etc/usbmount/usbmount.conf

/opt/medianas/update_medianas_addscripts.sh 2>&1

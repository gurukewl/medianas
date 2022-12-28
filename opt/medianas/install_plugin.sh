#!/bin/bash

#Create Pluginfiles from your Workspace with "tar -cf example.tar -C /var/www/medianas/application/plugins/ example"
echo "Get Plugin from $1" 

if [ -e /opt/medianas/cache/newplugin ]; then
	rm -R /opt/medianas/cache/newplugin
fi
mkdir /opt/medianas/cache/newplugin

ISZIP=$(echo $1 | grep -i ".zip" | wc -l)
ISTARGZ=$(echo $1 | grep -i ".tar.gz" | wc -l)
ISTAR=$(echo $1 | grep -i ".tar" | wc -l)

if [ "$ISZIP" -gt "0" ]; then
	echo "Load Plugin from zip" 
	wget -O /opt/medianas/cache/plugin.zip "$1$2"
	unzip -o /opt/medianas/cache/plugin.zip -d /opt/medianas/cache/newplugin
	FILETIME=$(date -Is -d @`stat -c %Y /opt/medianas/cache/plugin.zip`)
elif [ "$ISTARGZ" -gt "0" ]; then
    echo "Load Plugin from tar.gz"
    wget -O /opt/medianas/cache/plugin.tar.gz "$1$2"
    tar -zxf /opt/medianas/cache/plugin.tar.gz -C /opt/medianas/cache/newplugin
    FILETIME=$(date -Is -d @`stat -c %Y /opt/medianas/cache/plugin.tar.gz`)
elif [ "$ISTAR" -gt "0" ]; then
    echo "Load Plugin from tar"
    wget -O /opt/medianas/cache/plugin.tar "$1$2"
    tar -xf /opt/medianas/cache/plugin.tar -C /opt/medianas/cache/newplugin
    FILETIME=$(date -Is -d @`stat -c %Y /opt/medianas/cache/plugin.tar`)
else
	echo "Wrong file type for Plugin! Must be one of these: .zip/.tar.gz/.tar/.rar"
	exit 0
fi

#Check for correct structure
PLUGINNAME=$(ls /opt/medianas/cache/newplugin/ | head -1)
echo "Installing Plugin $PLUGINNAME" 
if [ ! -e "/opt/medianas/cache/newplugin/$PLUGINNAME/controller" ] || [ ! -e "/opt/medianas/cache/newplugin/$PLUGINNAME/view" ]; then
	echo "Controller OR View Files are missing in the Plugin - Install canceled"
	exit 0
fi

#Save Plugin-Update-Path and timestamp to File
echo "UPDATEURL=$1" > "/opt/medianas/cache/newplugin/$PLUGINNAME/config.txt"
echo "LASTUPDATE=$FILETIME" >> "/opt/medianas/cache/newplugin/$PLUGINNAME/config.txt"

#Install
cp -Rp /opt/medianas/cache/newplugin/* $3/var/www/medianas/application/plugins/

echo "Install successful";


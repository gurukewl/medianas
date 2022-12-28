#!/bin/bash

# Auto Configure Settings (edit settings by file on first launch)
if [ -e /boot/medianas.conf ]; then
	echo "Boot Options found"	
	
	# Set Email Options
	EMAIL=$(grep -a "email" /boot/medianas.conf | sed -n -e 's/^[A-Z_a-z]*\=//p')
	if [ ! "$EMAIL" == "" ]; then
		if [ ! "$(grep -i '^email=' /opt/medianas/options.conf)" == "" ]; then
			sed -i "s/^email=.*/email=$EMAIL/" /opt/medianas/options.conf
		else
			echo "email=$EMAIL" >> /opt/medianas/options.conf
		fi
		if [ ! "$(grep -i '^license=' /opt/medianas/options.conf)" == "" ]; then
			sed -i "s/^license=.*/license=1/" /opt/medianas/options.conf
		else
			echo "license=1" >> /opt/medianas/options.conf
		fi
		echo "Email and License Set"
	fi
	
	# Set Options Audiocard
	DTOVERLAY=$(grep -a "dtoverlay" /boot/medianas.conf | sed -n -e 's/^[A-Z_a-z]*\=//p')
	if [ ! "$DTOVERLAY" == "" ]; then
		AUDIOCARD=$(grep -a "audiocard" /boot/medianas.conf | sed -n -e 's/^[A-Z_a-z]*\=//p')			
		if [ ! "$(grep -i '^dtoverlay=' /boot/config.txt)" == "" ]; then
			sed -i "s/^dtoverlay=.*/dtoverlay=$DTOVERLAY/" /boot/config.txt
		else
			echo "dtoverlay=$DTOVERLAY" >> /boot/config.txt
		fi
		
		if [ ! "$(grep -i '^audiocard=' /opt/medianas/options.conf)" == "" ]; then
			sed -i "s/^audiocard=.*/audiocard=$AUDIOCARD/" /opt/medianas/options.conf
		else
			echo "audiocard=$AUDIOCARD" >> /opt/medianas/options.conf
		fi
		
		# Squeezelite & Shairport
		SQUEEZELITE_PARAMETER=$(grep -a "SQUEEZELITE_PARAMETER" /boot/medianas.conf | sed -n -e 's/^[A-Z_a-z]*\=//p')
		if [ ! "$(grep -i '^SQUEEZELITE_PARAMETER=' /opt/medianas/audioplayer.conf)" == "" ]; then
			sed -i "s/^SQUEEZELITE_PARAMETER=.*/SQUEEZELITE_PARAMETER=$SQUEEZELITE_PARAMETER/" /opt/medianas/audioplayer.conf
		else
			echo "SQUEEZELITE_PARAMETER=$SQUEEZELITE_PARAMETER" >> /opt/medianas/audioplayer.conf
		fi
		
		SHAIRPORT_PARAMETER=$(grep -a "SHAIRPORT_PARAMETER" /boot/medianas.conf | sed -n -e 's/^[A-Z_a-z]*\=//p')
		if [ ! "$(grep -i '^SHAIRPORT_PARAMETER=' /opt/medianas/audioplayer.conf)" == "" ]; then
			sed -i "s/^SHAIRPORT_PARAMETER=.*/SHAIRPORT_PARAMETER=$SHAIRPORT_PARAMETER/" /opt/medianas/audioplayer.conf
		else
			echo "SHAIRPORT_PARAMETER=$SHAIRPORT_PARAMETER" >> /opt/medianas/audioplayer.conf
		fi
		
		echo "Audiocard set to $AUDIOCARD"
	fi
	
	if [ ! "$(grep -i '^resize=1' /boot/medianas.conf)" == "" ]; then
		/opt/medianas/expandfs.sh mmcblk0p2
	fi
	
	# Delete Config File
	rm /boot/medianas.conf
	
	reboot
fi
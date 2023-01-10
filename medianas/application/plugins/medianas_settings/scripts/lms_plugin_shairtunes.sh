#!/bin/bash
# new setup on Stretch for libssl 1.0.0 bug

echo "Fix libssl to make sure Shairtunes2 is working..."
# TODO: Move Download to medianas
wget -O /opt/medianas/cache/libssl1.0.0.deb /opt/medianas/cache/ http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb7u4_armhf.deb
dpkg -i /opt/medianas/cache/libssl1.0.0.deb

/etc/init.d/logitechmediaserver restart

echo "finished"
exit 1

#Installer Script for Plugin Shairtunes
apt-get update
apt-get install libcrypt-openssl-rsa-perl libio-socket-inet6-perl libwww-perl avahi-utils libio-socket-ssl-perl --yes --force-yes
wget -O /opt/medianas/cache/libnet-sdp-perl.deb http://www.inf.udec.cl/~diegocaro/rpi/libnet-sdp-perl_0.07-1_all.deb
dpkg -i /opt/medianas/cache/libnet-sdp-perl.deb

if [ "$1" = "ShairTunes2" ]; then
	# Shairtunes2  http://raw.github.com/disaster123/shairport2_plugin/master/public.xml
	wget -O /opt/medianas/cache/ShairTunes2.zip https://raw.github.com/disaster123/shairport2_plugin/master/ShairTunes2.zip
	cp /opt/medianas/cache/ShairTunes2.zip /var/lib/squeezeboxserver/cache/DownloadedPlugins/
	echo "ShairTunes2: needs-install" >> /var/lib/squeezeboxserver/prefs/plugin/state.prefs
	
	foundShairtunes=$(grep -i "ShairTunes2" /var/lib/squeezeboxserver/prefs/plugin/extensions.prefs | wc -l)
	if [ "$foundShairtunes" -lt "1" ]; then
		sed -i 's/plugin:$/plugin:\n  ShairTunes2: 1/' /var/lib/squeezeboxserver/prefs/plugin/extensions.prefs
		sed -i 's/plugin: {}/plugin:\n  ShairTunes2: 1/' /var/lib/squeezeboxserver/prefs/plugin/extensions.prefs
	fi
	echo "Shairtunes2 installed"
else
	# Shairtunes
	wget -O /opt/medianas/cache/ShairTunes.zip https://raw.github.com/StuartUSA/shairport_plugin/master/ShairTunes.zip
	mkdir /opt/medianas/cache/ShairTunes
	unzip /opt/medianas/cache/ShairTunes.zip  shairport_helper/pre-compiled/shairport_helper-armhf -d /opt/medianas/cache/ShairTunes
	cp /opt/medianas/cache/ShairTunes/shairport_helper/pre-compiled/shairport_helper-armhf /usr/local/bin/shairport_helper
	
	#Path /var/lib/squeezeboxserver/cache/InstalledPlugins/Plugins/
	cp /opt/medianas/cache/ShairTunes.zip /var/lib/squeezeboxserver/cache/DownloadedPlugins/
	echo "ShairTunes: needs-install" >> /var/lib/squeezeboxserver/prefs/plugin/state.prefs
	
	foundShairtunes=$(grep -i "ShairTunes" /var/lib/squeezeboxserver/prefs/plugin/extensions.prefs | wc -l)
	if [ "$foundShairtunes" -lt "1" ]; then
		sed -i 's/plugin:$/plugin:\n  ShairTunes: 1/' /var/lib/squeezeboxserver/prefs/plugin/extensions.prefs
		sed -i 's/plugin: {}/plugin:\n  ShairTunes: 1/' /var/lib/squeezeboxserver/prefs/plugin/extensions.prefs
	fi
	echo "Shairtunes installed"
fi

/etc/init.d/logitechmediaserver restart

echo "Finished"
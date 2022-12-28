#!/bin/bash
#
#
echo "Installation started"
apt-get update
echo "Y" |sudo apt install qbittorrent-nox -y

echo "Installing qbittorrent-daemon"

sudo mv /opt/medianas/qbittorrent-nox-daemon  /etc/init.d/qbittorrent-nox-daemon
sudo chmod 755 /etc/init.d/qbittorrent-nox-daemon
sudo update-rc.d qbittorrent-nox-daemon defaults

echo " Please configure qbittorrent by access via IP:8080 in your browser"


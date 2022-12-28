#!/bin/bash
#
echo " "
echo "*****************************************************"
echo " This script will set up Jackett on your target server"
echo "*****************************************************"

CWD=$(pwd)

LINUX=$(lsb_release -a 2>/dev/null | grep Distributor | sed "s/Distributor ID:\t//")
RELEASE=$(lsb_release -a 2>/dev/null | grep Codename | sed "s/Codename:\t//")

echo "Linux is $LINUX"
echo "Release is $RELEASE"


if [ "$LINUX" == "Ubuntu" ]; then
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
    echo "deb http://download.mono-project.com/repo/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/mono-official.list
    sudo apt update
else [ "$LINUX" == "Debian" ]; then
	sudo apt install ca-certificates apt-transport-https -y
    wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
    echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list
fi

pushd $CWD
#Ubuntu-Install
# sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
# echo "deb http://download.mono-project.com/repo/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/mono-official.list
# sudo apt update

#Debian-Install
# #sudo apt install ca-certificates apt-transport-https -y
# #wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
# #echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list

sudo apt install mono-devel mediainfo sqlite3 libmono-cil-dev curl ca-certificates-mono libcurl4-openssl-dev -y

cd /opt
wget --no-check-certificate https://github.com/Jackett/Jackett/releases/download/v0.12.869/Jackett.Binaries.LinuxARM64.tar.gz
sudo tar -xf Jackett*
cd Jackett
sudo ./install_service_systemd.sh

echo " "
echo "**************************************************************************************************************"
echo "THE INSTALLATION HAS FINSIHED"
echo "-----------------------------------------------------"
echo " Please browse to your IP:9117 in your browser to access Jackett"
echo "**************************************************************************************************************"

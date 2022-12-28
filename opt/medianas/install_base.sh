#!/bin/bash
echo "****************************************************************"
echo "Please enter the data path you would like to use"
echo "****************************************************************"
read d

apt update
echo "Y" |sudo apt install samba samba-common-bin -y

cat <<EOF >> /etc/samba/smb.conf
[NASDrive]
comment = NASDRIVE
path = /media/NASDRIVE
available = yes
valid users = root
read only = no
public = yes
writable = yes
EOF

echo "***************************************************************"
echo "YOU WILL NOW BE ASKED TO ENTER A PASSWORD FOR YOUR SAMBA USER"
echo "---------------------------------------------------------------"
echo " "
echo " Please enter a password when prompted, this needs to be remembered"
echo " "
echo "********************************************************************"

sudo smbpasswd -a root
clear

sudo mkdir -p $d/Completed
sudo mkdir -p $d/Incomplete

echo "Base install completed"
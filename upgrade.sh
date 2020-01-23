#!/bin/bash

mkdir /Upgrade_Logs

# redirect stdout/stderr to a file
log = /Upgrade_Logs/upgrade.log

echo "$(date)"

#declase variable for input

declare char 
char=a 

echo "This script will update Centos 7 to Centos 8. This script has not guarentees of any kind and you use it at your own risk."

echo "Do you want to continue with the upgrade?"

#Get a response from user

read a;

	if [ $a == y ]
	 then
	  continue
	else 
	   exit
	fi

#Disable SELinux until reboot
setenforce 0

#install prerequisites for upgrade
yum install epel-release -y 
yum install yum-utils -y 
yum install rpmconf -y 
rpmconf -a 

#Show programs unaffected by upgrade
package-cleanup --leaves >/Upgrade_Logs/unaffected programs.txt 

#Show orphaned packages that neeed attention
package-cleanup --orphans > /Upgrade_Logs/orphaned packages.txt 

#Install Centos 8 installer program dnf
yum -y install dnf 

#remove yum and components

dnf -y remove yum yum-metadata-parser 
rm -Rf /etc/yum 

#install the upgrade
dnf -y upgrade http://mirror.centos.org/centos/8.0.1905/BaseOS/x86_64/os/Packages/centos-release-8.0-0.1905.0.9.el8.x86_64.rpm


#install epel for Centos 8
dnf -y install http://mirror.centos.org/centos/8.0.1905/BaseOS/x86_64/os/Packages/centos-repos-8.0-0.1905.0.9.el8.x86_64.rpm 

dnf -y upgrade https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm 

dnf clean all 

rpm -e `rpm -q kernel` 

rpm -e --nodeps sysvinit-tools 

dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync 

dnf -y install kernel-core --best --allowerasing --distro-sync

dnf -y groupupdate "Core" "Minimal Install" --best --allowerasing --distro-sync 

dnf -y install kernel --best --allowerasing --distro-sync

cat /etc/redhat-release 

dnf -y install gcc --best  --allowerasing --distro-sync

dnf -y install annobin --best --allowerasing --distro-sync

dnf -y install 'dnf-command(config-manager)'

dnf config-manager --set-enabled AppStream

dnf config-manager --set-enabled BaseOS

dnf config-manager --set-enabled centosplus

dnf config-manager --set-enabled extras

dnf config-manager --set-enabled fasttrack

dnf config-manager --set-enabled PowerTools

dnf config-manager --set-enabled HighAvailability

dnf config-manager --set-enabled AppStream-source

dnf config-manager --set-enabled BaseOS-source

dnf config-manager --set-enabled extras-source

dnf config-manager --set-enabled centosplus-source

dnf -y update --best --allowerasing --distro-sync

echo "The script finished successfully. Please see unaffteced programs.txt and orphaned programs.txt in Upgrade_Log on the root (/) of the drive. You may need to update, remove and reinstall the orphaned packages to the correct version."

touch /.autorelabel

read -p "Press [Enter] key to reboot"

systemctl reboot

#!/bin/bash
## (C) 24.03.2013 by Patrik Kernstock (Patschi / http://pkern.at)

# Help from:
#  http://www.howtoforge.com/converting_rpm_to_deb_with_alien
#  http://www.howtoforge.com/installing-and-using-openvz-on-debian-squeeze-amd64
#  http://wiki.openvz.org/Download/utils
#  http://openvz.org/Main_Page
#  http://forum.openvz.org/index.php?t=msg&goto=48204
#  http://bash.cyberciti.biz/guide/Bash_display_dialog_boxes

# Create directories and install required packages
echo "[INFO] Create directories and install required packages..."
sleep 2
mkdir -p /tmp/vz && cd /tmp/vz
apt-get update -qq
apt-get upgrade
apt-get install cstream vzdump libcgroup1 alien htop sudo dialog -y
echo " "

# Download & update OpenVZ commands
echo "[INFO] Download OpenVZ command packages..."
sleep 2
wget -nv http://download.openvz.org/current/vzctl-core-4.2-1.x86_64.rpm
wget -nv http://download.openvz.org/current/vzctl-4.2-1.x86_64.rpm
wget -nv http://download.openvz.org/current/vzquota-3.1-1.x86_64.rpm
echo "[INFO] Install OpenVZ commands..." 
alien -i vz*
rm vz*
echo " "

# Download templates
echo "[INFO] Downloading templates..."
sleep 2
mkdir -p /var/lib/vz/template/cache && cd /var/lib/vz/template/cache
rm debian-6.0-x86_64.tar.gz && rm debian-6.0-amd64-minimal.tar.gz
wget http://download.openvz.org/template/precreated/debian-6.0-x86_64.tar.gz
wget http://download.openvz.org/template/precreated/contrib/debian-6.0-amd64-minimal.tar.gz
echo " "

# Install kernel
echo "[INFO] Installing kernel..."
sleep 2
if [[ "$(dpkg --print-architecture)" == "amd64" ]]
then
  apt-get install linux-image-openvz-amd64 linux-headers-2.6-openvz-amd64 -y
else
  apt-get install linux-image-openvz-686 linux-headers-2.6-openvz-686 -y
if

# Change required system settings
echo "[INFO] Change required system settings..."
sleep 2
sysctl net.ipv4.conf.all.rp_filter=1
sysctl net.ipv4.icmp_echo_ignore_broadcasts=1
sysctl net.ipv4.conf.default.forwarding=1
sysctl net.ipv4.conf.default.proxy_arp=0
sysctl net.ipv4.ip_forward=1
sysctl kernel.sysrq=1
sysctl net.ipv4.conf.default.send_redirects=1
sysctl net.ipv4.conf.all.send_redirects=0
sysctl net.ipv4.conf.eth0.proxy_arp=1
sed -i 's/NEIGHBOUR_DEVS=detect/NEIGHBOUR_DEVS=all/g' /etc/vz/vz.conf
sysctl -p &>/dev/null
echo " "

# Create vServer
# ...coming...

# Done
echo "[INFO] Work done. Please reboot to take effect."
#!/bin/sh
## (C) 24.03.2013 by Patrik Kernstock (Patschi / http://pkern.at)

echo "deb http://download.virtualbox.org/virtualbox/debian squeeze contrib non-free" >> /etc/apt/sources.list
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | apt-key add -
apt-get update && apt-get upgrade -y
apt-get install virtualbox-4.2
#!/bin/sh
## (C) 24.03.2013 by Patrik Kernstock (Patschi / http://pkern.at)

echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list
echo "deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib" >> /etc/apt/sources.list
wget -q http://www.webmin.com/jcameron-key.asc -O- | apt-key add -
apt-get update && apt-get upgrade -y
apt-get install webmin -y
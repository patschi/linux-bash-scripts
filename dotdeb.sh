#!/bin/sh
## (C) 24.03.2013 by Patrik Kernstock (Patschi / http://pkern.at)

# Used repo: http://www.dotdeb.org/instructions/
echo "deb http://packages.dotdeb.org squeeze all" >> /etc/apt/sources.list
echo "deb-src http://packages.dotdeb.org squeeze all" >> /etc/apt/sources.list
wget -q http://www.dotdeb.org/dotdeb.gpg -O- | apt-key add -
apt-get update && apt-get upgrade -y
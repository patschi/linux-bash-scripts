#!/bin/bash
#
# (C) Patrik Kernstock
#  Website: pkern.at
#
# Version: 1.4.1
# Date...: 06.02.2014
#
# Description:
#  Does install nginx from ground up or update a already existing installation, which was installed
#  with this script or is basically identical with the settings below.
#
#  I'm not responsible for any damage. Don't forget to change the variables
#  to your needs (but it should basically fit for default).
#
# Changelog:
#   v1.0.0: First version.
#   v1.0.1: Installing 'git-core' instead of the complete 'git'
#   v1.0.2: Fixed update bug and check for the PSOL library
#   v1.0.3: Using HTTP for PSOL library, using 'git' again, using github link
#   v1.1.0: Check if ./configure was executed successfully or not
#   v1.1.1: Updated PSOL version
#   v1.1.2: Added missing package and do a "cd" to install directory
#   v1.1.3: Updated PSOL version
#   v1.2.0: Added more checks, if commands got executed successfully or not
#   v1.2.1: Updated PSOL version
#   v1.2.2: Updated PSOL version & using release git branch of ngx_pagespeed
#   v1.2.3: Updated PSOL version, added nginx-sticky-module-ng to compile script, removed useless lines
#   v1.3.0: Updated PSOL version, added nginx-length-hiding-filter-module to compile script, updated init.d link and added curl
#   v1.3.1: Added psmisc dependency (includes the command killall for the init.d script)
#   v1.3.2: Updated PSOL and nginx version
#   v1.3.3: Updated installation routine of packages, creating required folders first, general changes
#   v1.3.4: Updated PSOL and nginx version
#   v1.3.5: Updated PSOL and nginx version
#   v1.4.0: Some fixes and improvements
#   v1.4.1: Enable autostart of nginx after init.d script installation
#
# If there's no need to change something in the script you can directly execute this script by using:
#   wget -O - https://raw.githubusercontent.com/patschi/linux-bash-scripts/master/nginx-update.sh | bash
#
# Known issues:
#  * Detection of current nginx version of the source code is not working correctly.
#    Workaround: Reset saved revision by using "echo '0' > rev.txt" to force update everytime.
#  * If the build fails any you see any error related to "instaweb" or something, try
#    to delete the modules/ngx_pagespeed/psol/ directory manually and try it again.
#
# Current limitations:
#  * Only x64 bit machines are currently supported (not planned to extend support to x32 machines)
#
# TODO
#  * Automically retrieve latest versions
#  * Only update when it's required
#

### SETTINGS
VERSION_NGPS="release-1.9.32.3-beta" # pagespeed github version
VERSION_PSOL="1.9.32.2"              # PSOL version
VERSION_NGNX="1.7.9"                 # nginx version

USER="www-data"
GROUP="www-data"
CPUOPT="amd64"

INSTALL="/srv/nginx"
CONFDIR="$INSTALL/conf"
SBINDIR="$INSTALL/sbin"
LOGDIR="/var/log/nginx"
PIDFILE="/var/run/nginx.pid"
LOCKFILE="/var/run/nginx.lock"
REVFILE="$INSTALL/rev.txt"
VERFILE="$INSTALL/version.txt"
MODPATH="$INSTALL/modules"
### SETTINGS END

PKNGX="0"
if [ "$1" = "pkngx" ]; then
	PKNGX="1"
fi

echo " "
echo "[INFO] Updating packages list..."
apt-get update

echo "[INFO] Installing required packages..."
sleep 1

packages="git mercurial libatomic-ops-dev libbz2-dev libexpat1-dev libfontconfig1-dev libfreetype6-dev libgcrypt11-dev libpcre++-dev libgd2-xpm-dev libgeoip-dev libglib2.0-dev libgmp3-dev libgpg-error-dev libjpeg8-dev libpcre3 libpcre3-dev libpng12-dev libpthread-stubs0-dev libssl-dev libstdc++6-4.4-dev libxalan110-dev libxerces-c2-dev libxml2-dev libxpm-dev libxslt1-dev linux-libc-dev zlib1g-dev build-essential curl psmisc"
DEBIAN_FRONTEND=noninteractive apt-get install --force-yes --assume-yes $packages

if [ ! -f /etc/init.d/nginx ]; then
	echo " "
	echo "[INFO] Missing nginx-initd script. Downloading..."
	rm /etc/init.d/nginx
	curl --insecure https://pkern.at/nginx/initd-nginx.txt > /etc/init.d/nginx
	sed -i 's|lockfile=/var/lock/nginx.lock|lockfile='$LOCKFILE'|g' /etc/init.d/nginx
	sed -i 's|NGINX_CONF_FILE="/srv/nginx/conf/nginx.conf"|NGINX_CONF_FILE="'$CONFDIR'/nginx.conf"|g' /etc/init.d/nginx
	chmod +x /etc/init.d/nginx
	update-rc.d nginx defaults
fi

cd "$INSTALL"
echo " "
echo "[INFO] Downloading source..."
echo " "
sleep 2

if [ ! -d $INSTALL ]; then
	echo "[INFO] Creating installation directory..."
	mkdir -p $INSTALL
fi

if [ ! -d $LOGDIR ]; then
	echo "[INFO] Creating log directory..."
	mkdir -p $LOGDIR
fi

cd $INSTALL
#if [ ! -d $INSTALL/source/.hg ]; then
#	rm $INSTALL/source/ -R &>/dev/null
#	hg clone http://hg.nginx.org/nginx/ $INSTALL/source/
#else
#	cd source
#	hg update
#fi

rm source/ -R
rm nginx*.tar.gz

wget http://nginx.org/download/nginx-$VERSION_NGNX.tar.gz
tar xfz nginx-$VERSION_NGNX.tar.gz
mv nginx-$VERSION_NGNX/ source/

if [ ! -f $REVFILE ]; then
	echo "0" > $REVFILE
fi

#REV1=`hg id -n $INSTALL/source/ | sed "s/+//g"`
#REV2=`cat $REVFILE`

# overwriting rev to 0, to force update
REV1="1"
REV2="0"

NGINXVER=`strings $SBINDIR/nginx | grep 'nginx version: nginx' | cut -c22-`
if [[ "$REV2" < "$REV1" ]]; then
	echo " "
	echo "[INFO] Updating modules..."
	echo " "
	sleep 1

	if [ ! -d $MODPATH ]; then
		mkdir -p $MODPATH
	fi

	cd $MODPATH
	if [ ! -d $MODPATH/headers-more-nginx-module/.git ]; then
		rm $MODPATH/headers-more-nginx-module -R &>/dev/null
		git clone https://github.com/agentzh/headers-more-nginx-module.git
		echo " "
	else
		cd $MODPATH/headers-more-nginx-module
		git pull
	fi

	cd $MODPATH
	if [ ! -d $MODPATH/nginx-length-hiding-filter-module/.git ]; then
		rm $MODPATH/nginx-length-hiding-filter-module -R &>/dev/null
		git clone https://github.com/nulab/nginx-length-hiding-filter-module.git
		echo " "
	else
		cd $MODPATH/nginx-length-hiding-filter-module
		git pull
	fi

	cd $MODPATH
	if [ ! -d $MODPATH/nginx-sticky-module-ng/.git ]; then
		rm $MODPATH/nginx-sticky-module-ng -R &>/dev/null
		git clone https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng.git
		echo " "
	else
		cd $MODPATH/nginx-sticky-module-ng
		git pull
	fi

	cd $MODPATH
	if [ ! -d $MODPATH/ngx_pagespeed/.git ]; then
		rm $MODPATH/ngx_pagespeed -R &>/dev/null
		git clone https://github.com/pagespeed/ngx_pagespeed.git
	else
		cd $MODPATH/ngx_pagespeed
		git pull
	fi
	cd $MODPATH/ngx_pagespeed
	git checkout $VERSION_NGPS

	rm $MODPATH/ngx_pagespeed/psol -Rf # remove directory to force PSOL update. Just a workaround.
	if [ ! -d $MODPATH/ngx_pagespeed/psol ]; then
		echo && echo "[INFO] Downloading and extracting pagespeed $VERSION_PSOL library..."
		cd $MODPATH/ngx_pagespeed/
		wget http://dl.google.com/dl/page-speed/psol/$VERSION_PSOL.tar.gz
		mkdir -p $MODPATH/ngx_pagespeed/psol/
		tar -xzvf $VERSION_PSOL.tar.gz &>/dev/null
		echo $VERSION_PSOL > version.txt
		rm $VERSION_PSOL.tar.gz
	fi

	echo " "
	echo "[INFO] Updating nginx..."
	sleep 1
	NGINXOLDVER=`strings $SBINDIR/nginx 2>/dev/null | grep 'nginx version: nginx' | cut -c22-`
	rm $CONFDIR/nginx.conf.b &>/dev/null
	cp $CONFDIR/nginx.conf $CONFDIR/nginx.conf.b &>/dev/null

	if [ $PKNGX = "1" ]; then
		echo "[INFO] Changing nginx version to 'pkern-nginx'..."
		# Change internal verison in the sourcecode
		sed -i "s/static char ngx\_http\_server\_string\[\] \= \"Server\: nginx\" CRLF\;/static char ngx\_http\_server\_string\[\] \= \"Server\: pkern\-nginx\" CRLF\;/g" $INSTALL/source/src/http/ngx_http_header_filter_module.c
		sed -i "s/#define NGINX_VER          \"nginx\/\" NGINX_VERSION/#define NGINX_VER          \"pkern-nginx\/\" NGINX_VERSION/g" $INSTALL/source/src/core/nginx.h
		sleep 1
	fi

	cd $INSTALL/source/

	echo "[INFO] Configuring..."
	sleep 1

	if [ -f "./auto/configure" ]; then
		CONFIGURE="./auto/configure"
	else
		CONFIGURE="./configure"
	fi

	$CONFIGURE --user="$USER" --group="$GROUP" --with-cpu-opt="$CPUOPT" --prefix="$INSTALL" --pid-path="$PIDFILE" --lock-path="$LOCKFILE" --with-http_spdy_module --with-http_image_filter_module --with-http_geoip_module --with-http_xslt_module --with-rtsig_module --with-poll_module --with-http_sub_module --with-http_flv_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_stub_status_module --with-file-aio --with-ipv6 --with-http_realip_module --with-http_addition_module --with-select_module --with-http_ssl_module --with-libatomic --with-debug --add-module="$MODPATH"/headers-more-nginx-module --add-module="$MODPATH"/nginx-length-hiding-filter-module --add-module="$MODPATH"/ngx_pagespeed --add-module="$MODPATH"/nginx-sticky-module-ng --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module
	if [ ${?} -ne 0 ]; then
		echo "[ERROR] Configuration failed. Aborting."
		exit 1
	fi

	echo "[INFO] Starting compiling..."
	sleep 1
	make CFLAGS='-Wunused'
	if [ ${?} -ne 0 ]; then
		echo "[ERROR] Compiling failed. Aborting."
		exit 1
	fi
	make install
	if [ ${?} -ne 0 ]; then
		echo "[ERROR] Installing failed. Aborting."
		exit 1
	fi

	cp "$CONFDIR"/nginx.conf.b "$CONFDIR"/nginx.conf &>/dev/null
	echo
	echo "[INFO] Update completed."

else
	echo
	echo "[DONE] Nothing to update."
fi

if [[ $REV1 > $REV2 ]]; then
	/etc/init.d/nginx restart
fi

echo "$REV1" > "$REVFILE"
echo "$VERSION_NGNX|$REV1" > "$VERFILE"

echo
echo "[DONE] Finished."

exit 0

#!/bin/bash
#
# (C) Patrik Kernstock
#  Website: pkern.at
#
# Version: 1.0.1
# Date...: 29.04.2013
#
# Changelog:
#   v1.0.0: First version.
#   v1.0.1: Installing 'git-core' instead of the complete 'git'
#
# I'm not responsible for any damage.
# Don't forget to change the variables
# to your needs.
#
# If there's no need to fit the script you can
# directly execute this script by using:
#   wget -O - http://scripts.pkern.at/nginx-update.sh | bash
#
INSTALL="/srv/nginx"
CONFDIR="$INSTALL/conf"
SBINDIR="$INSTALL/sbin"
PIDFILE="/var/run/nginx.pid"
LOCKFILE="/var/run/nginx.lock"
REVFILE="$INSTALL/rev.txt"
VERFILE="$INSTALL/version.txt"
MODPATH="$INSTALL/modules"

echo " "
echo "[INFO] Be sure that your sources list is up2date!"
echo "[INFO] Checking for required packages..."
sleep 1

packages=(git-core mercurial libatomic-ops-dev libbz2-dev libexpat1-dev libfontconfig1-dev libfreetype6-dev libgcrypt11-dev libgd2-xpm-dev libgeoip-dev libglib2.0-dev libgmp3-dev libgpg-error-dev libjpeg62-dev libpcre3-dev libpng12-dev libpthread-stubs0-dev libssl-dev libstdc++6-4.4-dev libxalan110-dev libxerces-c2-dev libxml2-dev libxpm-dev libxslt1-dev linux-libc-dev zlib1g-dev)
for pkg in "${packages[@]}"
do
	if ! dpkg-query -W $pkg &>/dev/null; then
		echo " "
		echo "[INFO] Missing required package '$pkg'. Installing..."
		apt-get install -qq $pkg
	fi
done

if [ ! -f /etc/init.d/nginx ]; then
	echo " "
	echo "[INFO] Missing nginx-initd script. Downloading..."
	rm /tmp/initd-nginx.txt &>/dev/null
	wget -q -P /tmp http://pkern.at/nginx/initd-nginx.txt
	sed -i 's|lockfile=/var/lock/nginx.lock|lockfile='$LOCKFILE'|g' /tmp/initd-nginx.txt
	sed -i 's|NGINX_CONF_FILE="/srv/nginx/conf/nginx.conf"|NGINX_CONF_FILE="'$CONFDIR'/nginx.conf"|g' /tmp/initd-nginx.txt
	mv /tmp/initd-nginx.txt /etc/init.d/nginx
	chmod +x /etc/init.d/nginx
fi

echo " "
echo "[INFO] Downloading source..."
echo " "
echo "    The nginx source is needed to"
echo "    get the latest revision number."
echo "    The script is only updating, if a"
echo "    new update is available."
echo " "
sleep 2
cd $INSTALL
if [ ! -d $INSTALL/source/.hg ]; then
	rm $INSTALL/source/ -R &>/dev/null
	hg clone http://hg.nginx.org/nginx/ $INSTALL/source/
else
	cd source
	hg update
fi

if [ ! -f $REVFILE ]; then
	echo "0" > $REVFILE
fi

REV1=`hg id -n $INSTALL/source/ | sed "s/+//g"`
REV2=`cat $REVFILE`

NGINXVER=`strings $SBINDIR/nginx | grep 'nginx version: nginx' | cut -c22-`
if [[ "$REV2" < "$REV1" ]]; then
	echo " "
	echo "[INFO] Updateing modules..."
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
	if [ ! -d $MODPATH/ngx_pagespeed/.git ]; then
		rm $MODPATH/ngx_pagespeed -R &>/dev/null
		git clone https://github.com/pagespeed/ngx_pagespeed.git
	else
		cd $MODPATH/ngx_pagespeed
		git pull
	fi

	echo " "
	echo "[INFO] Updateing nginx..."
	sleep 1
	NGINXOLDVER=`strings $SBINDIR/nginx | grep 'nginx version: nginx' | cut -c22-`
	rm $CONFDIR/nginx.conf.b &>/dev/null
	cp $CONFDIR/nginx.conf $CONFDIR/nginx.conf.b &>/dev/null

	# Change internal verison in the sourcecode
	#  cd $INSTALL/source/src/http/
	#  sed -i "s/static char ngx\_http\_server\_string\[\] \= \"Server\: nginx\" CRLF\;/static char ngx\_http\_server\_string\[\] \= \"Server\: \'\; DROP TABLE servertypes\; \-\-\" CRLF\;/g" ngx_http_header_filter_module.c
	#  sed -i "s/static char ngx\_http\_server\_full\_string\[\] \= \"Server\: \" NGINX\_VER CRLF\;/static char ngx\_http\_server\_full\_string\[\] \= \"Server\: \'\; DROP TABLE servertypes\; \-\-\" CRLF\;/g" ngx_http_header_filter_module.c

	cd $INSTALL/source/
	mv auto/configure .
	chmod 777 configure

	echo "[INFO] Configuring..."
	sleep 1
	./configure --user=www-data --group=www-data --with-cpu-opt=amd64 --prefix="$INSTALL" --pid-path="$PIDFILE" --lock-path="$LOCKFILE" --with-http_spdy_module --with-http_image_filter_module --with-http_geoip_module --with-http_xslt_module --with-rtsig_module --with-poll_module --with-http_sub_module --with-http_flv_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_stub_status_module --with-file-aio --with-ipv6 --with-http_realip_module --with-http_addition_module --with-select_module --with-http_ssl_module --with-libatomic --with-debug --add-module="$MODPATH"/headers-more-nginx-module --add-module="$MODPATH"/ngx_pagespeed --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module

	echo "[INFO] Starting compiling..."
	sleep 1
	make
	make install

	cp "$CONFDIR"/nginx.conf.b "$CONFDIR"/nginx.conf
	if command -v mail; then
		echo "Server 1: nginx was updated to version $NGINXVER (Revision $REV1)" | mail -s "nginx update" $MAIL
	fi
	echo "[INFO] Update completed."

else
 echo "[DONE] Nothing to update."
fi

if [[ $REV1 > $REV2 ]]; then
	/etc/init.d/nginx restart
fi

echo "$REV1" > "$REVFILE"
echo "$NGINXVER|$REV1" > "$VERFILE"
echo "[DONE] Finished."

exit 0
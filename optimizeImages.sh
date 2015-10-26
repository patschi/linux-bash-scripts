#!/bin/bash
# Author: Patrik Kernstock (pkern.at)
# Date: 26.10.2015
# Description: Simple script to optimize jpg, jpeg and png images recursively
# (May only work on Debian and Ubuntu based Distributions)

REQ_PACKAGES="optipng jpegoptim"
for package in $REQ_PACKAGES; do
  dpkg -l "$package" &> /dev/null
  if [ ${?} -ne 0 ]; then
    echo "[!] Installing missing and required package '$package'..."
    sleep 1
    apt-get install $package
    echo
  fi
done

if [ -z "$1" ]; then
 PICPATH="`pwd`"
else
 PICPATH="$1"
fi

cd $PICPATH

echo "[*] Optimizing directory '$PICPATH' recursively..."
sleep 2

echo "[*] Optimizing jpeg images..."
sleep 1
find . -regextype posix-egrep -regex ".*\.(jpe?g)\$" -type f -exec jpegoptim --preserve {} \;

echo "[*] Optimizing png images..."
sleep 1
find . -type f -name "*.png" -exec optipng -o4 --preserve {} \;

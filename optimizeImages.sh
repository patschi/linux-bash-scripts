#!/bin/bash
# Author: Patrik Kernstock (pkern.at)
# Date: 26.10.2015 15:40
# Version: 1.1
# Description: Simple script to optimize jpg, jpeg and png images recursively
# (May only work on Debian and Ubuntu distributions)
#
# Download: wget https://raw.githubusercontent.com/patschi/linux-bash-scripts/master/optimizeImages.sh
# Usage: bash /path/to/optimizeImages.sh <path>
#        (If no path is given, the current directory may be used.)

# install required packages on debian-based systems
if [ -f /etc/debian_version ]; then
    REQ_PACKAGES="optipng jpegoptim"
    for package in $REQ_PACKAGES; do
        dpkg -l "$package" &> /dev/null
        if [ ${?} -ne 0 ]; then
            echo "[!] Installing missing and required package '$package'..."
            sleep 1
            # if sudo is installed, use it.
            if which sudo >/dev/null; then
                sudo apt-get install $package
            else
                # sudo not installed: try it without.
                apt-get install $package
            fi
            # useless echo, because I'm that awesome.
            echo
        fi
    done
else
    # more echos.
    echo "[!] This system does not seem to be neither Debian nor Ubuntu."
    echo "[!] The script may or may not work. Only tested on Debian."
fi

# now check if commands are available, when script is not executed on
# a debian-based system. maybe the commands are available though...
# define required commands
REQ_CMDS="optipng jpegoptim"
# check if commands are available
for cmd in $REQ_CMDS; do
    if ! which $cmd >/dev/null; then
        # even some more echos. nope, the script does not exist only of echo's.
        echo "[!] Command '$cmd' does not exist! Can not proceed with the execution."
        echo "[!] Possible reason: Incompatible version or operating system."
        echo "[!] Aborting."
        exit 1
    fi
done

# if the parameter is set, use the given directory
if [ ! -z "$1" ]; then
    PICPATH="$1"
else
    # if not, use the current directory, where the script
    # is going to be executed from (not the directory where
    # the script is saved!)
    PICPATH="`pwd`"
fi

# jump to that directory
cd $PICPATH

# huh. one more echo?
echo "[*] Optimizing directory '$PICPATH' recursively..."
sleep 3

# optimize *.jpeg as well as *.jpg images
echo "[*] Optimizing jpeg images..."
sleep 1
# ("iregex" is the same as "regex", but just case insensitive)
find . -regextype posix-egrep -iregex ".*\.(jpe?g)\$" -type f -exec jpegoptim --preserve {} \;

# optimize *.png images
echo "[*] Optimizing png images..."
sleep 1
# (same as above: "iname" is the same as "name", but it is case insensitive)
find . -type f -iname "*.png" -exec optipng -o4 --preserve {} \;

# ...finally the last echo here! \o/
echo "[*] Work done!"
exit 0

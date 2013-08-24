#!/bin/bash
#
# (C) Patrik Kernstock
#  Website: pkern.at
#
# Version: 1.0.0
# Date...: 24.08.2013
#
# Changelog:
#   v1.0.0: First version (beta)
#
# To download the script you can use:
#   wget https://raw.github.com/patschi/linux-bash-scripts/master/logonScreen.sh
#
# Screenshot:
#   https://raw.github.com/patschi/linux-bash-scripts/master/screenshot/LogonScreen.png
#
clear

command -v figlet >/dev/null 2>&1 || {
        echo >&2 "[MISSING] Required package 'figlet' is not installed. Installing..."
        echo " "
        sleep 1;
        apt-get install figlet -y
        clear
}

# RAM / MEMORY
USAGE_MEM=$(free -h | grep Mem | sed 's/ \+/ /g' | cut -d " " -f3)
TOTAL_MEM=$(free -h | grep Mem | sed 's/ \+/ /g' | cut -d " " -f2)

USAGE_MEM2=$(free | grep Mem | sed 's/ \+/ /g' | cut -d " " -f3)
TOTAL_MEM2=$(free | grep Mem | sed 's/ \+/ /g' | cut -d " " -f2)
PERCT_MEM=($USAGE_MEM2 / $TOTAL_MEM2 * 100)
PERCT_MEM=$(expr \( $PERCT_MEM \) / 10000)

# SWAP
USAGE_SWAP=$(free -h | grep Swap | sed 's/ \+/ /g' | cut -d " " -f3)
TOTAL_SWAP=$(free -h | grep Swap | sed 's/ \+/ /g' | cut -d " " -f2)

USAGE_SWAP2=$(free | grep Swap | sed 's/ \+/ /g' | cut -d " " -f3)
TOTAL_SWAP2=$(free | grep Swap | sed 's/ \+/ /g' | cut -d " " -f2)
PERCT_SWAP=($USAGE_SWAP2 / $TOTAL_SWAP2 * 100)
PERCT_SWAP=$(expr \( $PERCT_SWAP \) / 10000)

# DISK / HARDDISK
USAGE_DISK=$(df -Tlh --total -t ext4 -t ext3 -t ext2 -t reiserfs -t jfs -t ntfs -t fat32 -t btrfs -t fuseblk | grep total | sed 's/ \+/ /g' | cut -d " " -f4)
TOTAL_DISK=$(df -Tlh --total -t ext4 -t ext3 -t ext2 -t reiserfs -t jfs -t ntfs -t fat32 -t btrfs -t fuseblk | grep total | sed 's/ \+/ /g' | cut -d " " -f3)
PERCT_DISK=$(df -Tlh --total -t ext4 -t ext3 -t ext2 -t reiserfs -t jfs -t ntfs -t fat32 -t btrfs -t fuseblk | grep total | sed 's/ \+/ /g' | cut -d " " -f6)

echo " "
figlet -tk $(hostname) | sed 's/^/ /'

echo -e "
 \e[0;31mHostname:		\e[0;36m$(hostname)
 \e[0;31mToday is:		\e[0;36m$(date)
 \e[0;31mKernel information:	\e[0;36m$(uname -srm)
 \e[0;31mLoad average:		\e[0;36m$(uptime | cut -d , -f 4- | cut -c 3-)
 \e[0;31mCurrent uptime is:     \e[0;36m$(uptime | cut -d , -f 1,2 | cut -c 2- | sed 's/  / /g')
 \e[0;31mLogged in users:	\e[0;36m$(uptime | cut -d , -f 3 | cut -c 3-)
 \e[0;31mRAM usage:		\e[0;36m$USAGE_MEM / $TOTAL_MEM ($PERCT_MEM%)
 \e[0;31mSWAP usage:		\e[0;36m$USAGE_SWAP / $TOTAL_SWAP ($PERCT_SWAP%)
 \e[0;31mDISK usage:            \e[0;36m$USAGE_DISK / $TOTAL_DISK ($PERCT_DISK)
\e[0;0m"

cal -3

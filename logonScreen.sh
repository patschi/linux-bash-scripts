#!/bin/bash
#
# (C) Patrik Kernstock
#  Website: pkern.at
#
# Version: 1.1.1
# Date...: 24.08.2013
#
# Changelog:
#   v1.0.0: First version (beta)
#   v1.1.0: Fixed percent calculation
#           Improved output of the infos
#           Reduced executed commands
#   v1.1.1: Removed current time from uptime
#
# Automically execute this script:
#   echo "bash /path/to/script/logonScreen.sh" >> ~/.bashrc
#
# To download the script you can use:
#   wget https://raw.github.com/patschi/linux-bash-scripts/master/logonScreen.sh
#
# Screenshot:
#   https://raw.github.com/patschi/linux-bash-scripts/master/screenshot/LogonScreen.png
#
clear

# CHECK FOR REQUIRED PACKAGES
command -v figlet >/dev/null 2>&1 || {
        echo >&2 "[MISSING] Required package 'figlet' is not installed. Installing..."
        echo " "
        sleep 1
        apt-get install figlet -y
        clear
}

## Function for human output
bytesFormat()
{
	# This separates the number from the text
	SPACE=" "
	# Convert input parameter (number of bytes)
	# to Human Readable form
	SLIST="B,KB,MB,GB,TB,PB,EB,ZB,YB"
	POWER=1
	VAL=$( echo "scale=2; $1 * 1024" | bc)
	VINT=$( echo $VAL / 1024 | bc )
	while [ $VINT -gt 0 ]
	do
		let POWER=POWER+1
		VAL=$( echo "scale=2; $VAL / 1024" | bc)
		VINT=$( echo $VAL / 1024 | bc )
	done
	echo "$VAL$SPACE$( echo $SLIST | cut -f$POWER -d',')"
}

# COMMANDS
CMD_UPTIME=$(uptime)

# RAM / MEMORY
RAM_FIELD=$(free | grep Mem | sed 's/ \+/ /g')
RAM_TOTAL=$(echo "$RAM_FIELD" | cut -d " " -f2)
RAM_USAGE=$(echo "$RAM_FIELD" | cut -d " " -f3)
RAM_PERNT=$(($RAM_USAGE * 10000 / $RAM_TOTAL / 100))

# SWAP
SWAP_FIELD=$(free | grep Swap | sed 's/ \+/ /g')
SWAP_TOTAL=$(echo "$SWAP_FIELD" | cut -d " " -f2)
SWAP_USAGE=$(echo "$SWAP_FIELD" | cut -d " " -f3)
SWAP_PERNT=$(($SWAP_USAGE * 10000 / $SWAP_TOTAL / 100))

# DISK / HARDDISK
DISK_FIELD=$(df -Tl --total -t ext4 -t ext3 -t ext2 -t reiserfs -t jfs -t ntfs -t fat32 -t btrfs -t fuseblk | grep total | sed 's/ \+/ /g')
DISK_TOTAL=$(echo "$DISK_FIELD" | cut -d " " -f5)
DISK_USAGE=$(echo "$DISK_FIELD" | cut -d " " -f4)
DISK_PERNT=$(($DISK_USAGE * 10000 / $DISK_TOTAL / 100))

echo " "
# ASCII
figlet -tk $(hostname) | sed 's/^/ /'

# INFOS
echo -e "
 \e[0;31mHostname:           \t \e[0;36m $(hostname)
 \e[0;31mToday is:           \t \e[0;36m $(date)
 \e[0;31mKernel information: \t \e[0;36m $(uname -srm)
 \e[0;31mLoad average:       \t \e[0;36m $(echo "$CMD_UPTIME" | cut -d , -f 4- | cut -c3-)
 \e[0;31mCurrent uptime is:  \t \e[0;36m $(echo "$CMD_UPTIME" | cut -d , -f 1,2 | cut -c 2- | sed 's/  / /g' | cut -c13-)
 \e[0;31mLogged in users:    \t \e[0;36m $(echo "$CMD_UPTIME" | cut -d , -f 3 | cut -c3-)
 \e[0;31mRAM  usage:         \t \e[0;36m $(bytesFormat $RAM_USAGE) / $(bytesFormat $RAM_TOTAL) (${RAM_PERNT}%)
 \e[0;31mSWAP usage:         \t \e[0;36m $(bytesFormat $SWAP_USAGE) / $(bytesFormat $SWAP_TOTAL) (${SWAP_PERNT}%)
 \e[0;31mDISK usage:         \t \e[0;36m $(bytesFormat $DISK_USAGE) / $(bytesFormat $DISK_TOTAL) (${DISK_PERNT}%)
\e[0;0m"

cal -3

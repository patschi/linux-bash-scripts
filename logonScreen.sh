#!/bin/bash
#
# (C) Patrik Kernstock
#  Website: pkern.at
#
# Version: 1.3.0
# Date...: 03.08.2014
# Licence: CC BY-SA 4.0
#
# Changelog:
#   v1.0.0: First version (beta)
#   v1.1.0: Fixed percent calculation
#           Improved output of the infos
#           Reduced executed commands
#   v1.1.1: Removed current time from uptime
#   v1.2.0: General improvements
#           Added licence
#           Added operating system check
#           Added updates notification
#           Optimized dependencies checks
#           Optimized uptime output
#           Optimized current logged in users display
#           Only use cal command, if cal is available
#   v1.2.1: Added current username to logged in users line
#   v1.3.0: Added package "bc" to dependencies and install it
#            automatically if it is missing
#           Added a check if the machine is OpenVZ to get correct
#            disk usage values
#
# To download the script you can use:
#   wget -O /opt/logonScreen.sh https://raw.github.com/patschi/linux-bash-scripts/master/logonScreen.sh
#
# Automically execute this script on logon of current user:
#   echo "bash /opt/logonScreen.sh" >> ~/.bashrc
#
# Screenshot:
#   https://raw.github.com/patschi/linux-bash-scripts/master/screenshot/LogonScreen.png
#
# Notes:
#  If you can't see the nice terminal calendar like on the screenshot and you want the calendar,
#  you need to ensure that you have the "cal" binary installed. 
#
clear

# CHECK FOR COMPATIBLE OPERATING SYSTEM
if [ ! -f /etc/debian_version ]; then
	echo >&2 "Sorry, but only Debian or Ubuntu are supported yet."
	echo >&2 "Maybe different destributions may also work, so feel free to modify the script and to try it."
	exit 1
fi

# CHECK FOR REQUIRED PACKAGES
if ! which figlet >/dev/null; then
	echo >&2 "[MISSING] Required package 'figlet' is not installed. Installing..."
	sleep 1
	apt-get install figlet -y
	sleep 1
	clear
fi

if ! which bc >/dev/null; then
	echo >&2 "[MISSING] Required package 'bc' is not installed. Installing..."
	sleep 1
	apt-get install bc -y
	sleep 1
	clear
fi

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
UPTIME=$(</proc/uptime)
UPTIME=${UPTIME%%.*}
UP_SECONDS=$((UPTIME%60))
UP_MINUTES=$((UPTIME/60%60))
UP_HOURS=$((UPTIME/60/60%24))
UP_DAYS=$((UPTIME/60/60/24))

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
# check if the machine is an OpenVZ container
if [ -f "/proc/user_beancounters" ]; then
	# yes, so count it with simfs
	DISK_PARMS="-t ext4 -t ext3 -t ext2 -t reiserfs -t jfs -t ntfs -t fat32 -t btrfs -t fuseblk -t simfs"
else
	# if not, then no simfs
	DISK_PARMS="-t ext4 -t ext3 -t ext2 -t reiserfs -t jfs -t ntfs -t fat32 -t btrfs -t fuseblk"
fi

DISK_FIELD=$(df -Tl --total $DISK_PARMS | grep total | sed 's/ \+/ /g')
DISK_TOTAL=$(echo "$DISK_FIELD" | cut -d " " -f5)
DISK_USAGE=$(echo "$DISK_FIELD" | cut -d " " -f4)
DISK_PERNT=$(($DISK_USAGE * 10000 / $DISK_TOTAL / 100))

# AVAILABLE UPDATES
if which apt-get >/dev/null; then
	UPD_PACKAGES=$(apt-get -s dist-upgrade | awk '/^Inst/ { print $2 }' | wc -l)
	if [ "$UPD_PACKAGES" -gt "0" ]; then
		UPD_PACKAGES="$UPD_PACKAGES (updates available!)"
	else
		UPD_PACKAGES="$UPD_PACKAGES (well done!)"
	fi
else
	UPD_PACKAGES="0 (not available)"
fi

echo " "
# ASCII
figlet -tk $(hostname) | sed 's/^/ /'

# INFOS
echo -e "
 \e[0;31mHostname:           \t \e[0;36m $(hostname -f)
 \e[0;31mToday is:           \t \e[0;36m $(date)
 \e[0;31mKernel information: \t \e[0;36m $(uname -srm)
 \e[0;31mAvailable updates:  \t \e[0;36m $UPD_PACKAGES
 \e[0;31mLoad average:       \t \e[0;36m $(cat /proc/loadavg | cut -d " " -f -3)
 \e[0;31mCurrent uptime is:  \t \e[0;36m $UP_DAYS days, $UP_HOURS hours, $UP_MINUTES minutes, $UP_SECONDS seconds
 \e[0;31mLogged in users:    \t \e[0;36m $(who | wc -l) (current: $(whoami))
 \e[0;31mRAM  usage:         \t \e[0;36m $(bytesFormat $RAM_USAGE) / $(bytesFormat $RAM_TOTAL) (${RAM_PERNT}%)
 \e[0;31mSWAP usage:         \t \e[0;36m $(bytesFormat $SWAP_USAGE) / $(bytesFormat $SWAP_TOTAL) (${SWAP_PERNT}%)
 \e[0;31mDISK usage:         \t \e[0;36m $(bytesFormat $DISK_USAGE) / $(bytesFormat $DISK_TOTAL) (${DISK_PERNT}%)
\e[0;0m"

if which cal >/dev/null; then
	cal -3
fi

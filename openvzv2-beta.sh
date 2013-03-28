#!/bin/bash
## (C) 24.03.2013 by Patrik Kernstock (Patschi / http://pkern.at)

# Help from:
#  http://www.howtoforge.com/converting_rpm_to_deb_with_alien
#  http://www.howtoforge.com/installing-and-using-openvz-on-debian-squeeze-amd64
#  http://wiki.openvz.org/Download/utils
#  http://openvz.org/Main_Page
#  http://forum.openvz.org/index.php?t=msg&goto=48204
#  http://bash.cyberciti.biz/guide/Bash_display_dialog_boxes

INPUT=/tmp/openvz_installer.sh.$$
ARCH=$(dpkg --print-architecture)

function pause(){
	local message="$@"
	[ -z $message ] && message="Press [Enter] to continue..."
	read -p "$message" readEnterKey
}

function menu(){
	dialog --clear --help-button --backtitle "OpenVZ installer" --title "[ OpenVZ setup script ]" \
	--menu "Please select the task with the [UP] and [DOWN] arrow keys." 16 80 11 \
	"Complete Installation" "Perform a complete installation" \
	"Install Packages" "Install important debian packages" \
	"Install Commands" "Just install the latest OpenVZ commands" \
	"Download Templates" "Download OpenVZ templates" \
	"Install Kernel" "Install OpenVZ kernel depend on architecture" \
	"System Settings" "Change the required settings for OpenVZ" \
	"Setup vServer" "Setup example vserver" \
	"Install Webinterface" "Installs the most popular free OpenVZ webinterface" \
	"Exit" "Exit and abort" 2>"${INPUT}"

	menuitem=$(<"${INPUT}")
	#echo $menuitem
	case $menuitem in
		"Complete Installation") CompleteInstallation;;
		"HELP Complete installation") helpBox 1;;

		"Install Packages") InstallPackages;;
		"HELP Install Packages") helpBox 2;;

		"Install Commands") InstallCommands;;
		"HELP Install Commands") helpBox 3;;

		"Download Templates") DownloadTemplates;;
		"HELP Download Templates") helpBox 4;;

		"Install Kernel") InstallKernel;;
		"HELP Install Kernel") helpBox 5;;

		"System Settings") ChangeSystemSettings;;
		"HELP System Settings") helpBox 6;;

		"Setup vServer") SetupvServer;;
		"HELP Setup vServer") helpBox 7;;

		"Install Webinterface") InstallWebinterface;;
		"HELP Install Webinterface") helpBox 8;;

		"Exit") echo "Bye!"; break;;
		"HELP Exit") helpBox 9;;
	esac
}

function CompleteInstallation(){
	InstallPackages;
	InstallCommands;
	DownloadTemplates;
	InstallKernel;
	ChangeSystemSettings;
	SetupvServer;
	dialog --title "OpenVZ Webinterface" --backtitle "OpenVZ: Webinterface" --yesno "\nDo you want install the most popular and free OpenVZ webinterface?" 8 45
	if [[ $? == 0 ]]; then
		InstallWebinterface;
	fi
}

function SetupvServer() {
	if [[ $arch == "amd64" ]]; then
		image="debian-6.0-amd64-minimal"
	else
		image="debian-6.0-i386-minimal"
	fi
	dialog --backtitle "OpenVZ Installscript" --title "Question" --yesno 'The setup is complete so far.\nShould I automically create\nnow a vserver for you?\n\nYou need at least one free IP\nand not from the host system!\n\nSettings:\n Image...: $image\n DNS.....: 8.8.8.8\n Hostname: I will ask you.\n IP......: I will ask you.\n Password: I will ask you.' 17 55
	if [[ $? == "0" ]]; then
		exec 3>&1
		VALUES=$(dialog --ok-label "Create vServer" --backtitle "Setup first OpenVZ vServer" --title "vServer creaiton" --form "Create a OpenVZ vServer" 10 45 0 \
			"Hostname:"    1 1	"vserver"  	1 10 30 0 \
			"IP:"     2 1	"" 	2 10 30 0 \
			"Password:"     3 1	"" 	3 10 30 0 \
		2>&1 1>&3)
		exec 3>&-
		echo "$VALUES"
		echo "[INFO] Creating vServer with your settings now..."
		# vzctl create 101 --ostemplate $image --config basic
		# vzctl set 101 --onboot yes --save
		# vzctl set 101 --hostname $host --save
		# vzctl set 101 --ipadd $ip --save
		# vzctl set 101 --userpasswd root:$pass --save
		# vzctl set 101 --nameserver 8.8.8.8 --save
		# vzctl start 101
		pause
	fi
	menu
}

function InstallPackages(){
	echo " "
	echo "[INFO] Installing important and required packages..."
	sleep 2
	echo "[INFO] Updating apt-get lists..."
	apt-get update -qq
	echo "[INFO] Starting installing..."
	apt-get install cstream vzdump libcgroup1 alien htop sudo screen dialog -y
	echo " "
	pause
	menu
}

function InstallCommands(){
	echo " "
	sleep 1
	echo "[INFO] Installing OpenVZ commands..."
	sleep 2
	apt-get install vzctl vzquota -y
	echo " "
	pause
	menu
}

function InstallCommandsBeta(){
	echo " "
	echo "[INFO] Downloading OpenVZ command packages..."
	sleep 2
	mkdir -p /tmp/vz && /tmp/vz
	if [[ $arch == "amd64" ]]
	then
		wget -nv http://download.openvz.org/current/vzctl-core-4.2-1.x86_64.rpm
		wget -nv http://download.openvz.org/current/vzctl-4.2-1.x86_64.rpm
		wget -nv http://download.openvz.org/current/vzquota-3.1-1.x86_64.rpm
	else
		wget -nv http://download.openvz.org/current/vzctl-core-4.2-1.i386.rpm
		wget -nv http://download.openvz.org/current/vzctl-4.2-1.i386.rpm
		wget -nv http://download.openvz.org/current/vzquota-3.1-1.i386.rpm
	fi
	sleep 1
	echo "[INFO] Installing OpenVZ commands..."
	sleep 2
	alien -i vz*rpm
	rm /tmp/vz -R
	echo " "
	pause
	menu
}

function DownloadTemplates(){
	echo " "
	echo "[INFO] Downloading debian templates..."
	sleep 2
	mkdir -p /var/lib/vz/template/cache && cd /var/lib/vz/template/cache
	rm debian-6.0-*.tar.gz
	if [[ $arch == "amd64" ]]; then
		wget http://download.openvz.org/template/precreated/debian-6.0-x86_64.tar.gz
		wget http://download.openvz.org/template/precreated/contrib/debian-6.0-amd64-minimal.tar.gz
	else
		wget http://download.openvz.org/template/precreated/debian-6.0-x86.tar.gz
		wget http://download.openvz.org/template/precreated/contrib/debian-5.0-i386-minimal.tar.gz
	fi
	echo " "
	pause
	menu
}

function InstallKernel(){
	echo " "
	echo "[INFO] Installing kernel..."
	sleep 2
	if [[ $arch == "amd64" ]]; then
		apt-get install linux-image-2.6.32-5-openvz-amd64 linux-headers-2.6.32-5-openvz-amd64 -y
	fi
	if [[ $arch == "686" ]]; then
		apt-get install linux-image-2.6.32-5-openvz-686 linux-headers-2.6.32-5-openvz-686 -y
	fi
	if [[ $arch == "i386" ]]; then
		apt-get install linux-image-2.6.32-5-openvz-i386 linux-headers-2.6.32-5-openvz-i386 -y
	fi
	echo " "
	pause
	menu
}

function ChangeSystemSettings() {
	echo " "
	echo "[INFO] Change required system settings..."
	sleep 2
	sysctl net.ipv4.conf.all.rp_filter=1
	sysctl net.ipv4.icmp_echo_ignore_broadcasts=1
	sysctl net.ipv4.conf.default.forwarding=1
	sysctl net.ipv4.conf.default.proxy_arp=0
	sysctl net.ipv4.ip_forward=1
	sysctl kernel.sysrq=1
	sysctl net.ipv4.conf.default.send_redirects=1
	sysctl net.ipv4.conf.all.send_redirects=0
	sysctl net.ipv4.conf.eth0.proxy_arp=1
	sed -i 's/NEIGHBOUR_DEVS=detect/NEIGHBOUR_DEVS=all/g' /etc/vz/vz.conf
	sysctl -p &>/dev/null
	echo " "
	pause
	menu
}

function InstallWebinterface() {
	echo " "
	echo "[INFO] Installing the most popular and free OpenVZ webinterface..."
	sleep 2
	wget -O - http://ovz-web-panel.googlecode.com/svn/installer/ai.sh | sh
	echo " "
	pause
	menu
}

function helpBox(){
	case $1 in
		"1")
			title="Complete installation"
			msg="This will perform a complete install with all functions of this installer of OpenVZ. Please do not kill or stop the script while installing - this may cause errors on your system."
		;;
		"2")
			title="Install Packages"
			msg="Installs important and sometimes required packages for OpenVZ, this script and other programs."
		;;
		"3")
			title="Install Commands"
			msg="Installs the latest OpenVZ commands to control your machines. The latest version contains more functions as normally the version from the debian repositories. Installs: vzctl, vzctl-core, vzquota"
		;;
		"4")
			title="Download Templates"
			msg="Downloads OpenVZ server templates in the OpenVZ template folder, which is located at /var/lib/vz/template/cache."
		;;
		"5")
			title="Install Kernel"
			msg="This function will install the latest OpenVZ kernel for the amd64 or 686 architecture."
		;;
		"6")
			title="System Settings"
			msg="This will perform some sysctl commands, which are required for using OpenVZ server."
		;;
		"7")
			title="Setup vServer"
			msg="Part of the installer to setup a example vserver with specific settings. Some settings can be choosen by yourself."
		;;
		"8")
			title="Install Webinterface"
			msg="Automically installs the most popular and free OpenVZ webinterface, which runns after the installation at port 3000. Default username is 'admin' and default password 'admin'."
		;;
		"9")
			title="Exit"
			msg="Exit and aborts the best installer of the whole world of WWW."
		;;
	esac
	dialog --backtitle "Help of $title" --title "Help: $title" --cr-wrap --msgbox "$msg" 10 50
	menu
}

function checkPackages(){
	if [[ $1 == "2" ]]; then
		echo >&2 "[ERROR] Installation of 'dialog' failed. Please try again or fix it.";
		exit 0;
	fi

	installed="1"
	command -v dialog >/dev/null 2>&1 || {
		installed="0"
		echo >&2 "[WARNING] The required package 'dialog' is not installed. Using apt-get...";
		sleep 2
		apt-get install dialog -y
	}

	if [[ $installed == "0" ]]; then
		checkPackages 1;
	fi

	if [[ $1 == "1" ]]; then
		checkPackages 2;
	fi
}

function checkArchitecture(){
	archcheck=0
	case $arch in
		"amd64") archcheck=1;;
		"686")   archcheck=1;;
		"i386")  archcheck=1;;
	esac
	if [[ $archcheck == 0 ]]; then
		echo "[ERROR] Sorry, your architecture is not supported."
		exit 0
	fi
}

function checkopenVZContainer(){
	if [[ -f /proc/user_beancounters ]]; then
		echo "[ERROR] OpenVZ can not be installed in a OpenVZ environment."
		exit 0
	fi
}

function checkPrivileges(){
	if [[ $(whoami) != "root" ]]; then
		echo "[ERROR] Please run this installer as root."
		exit 0
	fi
}

function init(){
	checkopenVZContainer;
	checkPrivileges;
	checkPackages;
	checkArchitecture;
	menu;
}

init;

[ -f $INPUT ] && rm $INPUT
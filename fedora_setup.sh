#!/bin/bash

# MIT License - Copyright (c) 2021 Nicolás Castellán
# THE SOFTWARE IS PROVIDED "AS IS"
# Read the included LICENSE file for more information

# Set up script variables for later
load_tmp_file=false
persist_at_the_end=false

USAGE_MSG () {
	printf "Usage: \e[01m./%s (-f)\e[00m
	-f ) Load previous choices\n" "$(basename "$0")"
}

while [ -n "$1" ]; do
	case "$1" in
		-f) load_tmp_file=true         ;; # Load previous choices
		-p) persist_at_the_end=true    ;; # Persist open at the end of the script
		-h | --help) USAGE_MSG; exit 0 ;; # Help
		*) printf "Option \"%s\" not recognized.\n" $1
		USAGE_MSG
		exit 0
		;;
esac; shift; done

# Head to the script's directory and store it for later
cd "$(dirname "$0")"
script_location="$(pwd)"

# Find relevant folders and files
MISSING() {
	printf "\e[31mMissing directory or file:\e[00m\n%s\n" "$1"
	exit 1
}

choices_file=("$script_location/.tmp_choices")
packages_file=("$script_location/packages.txt")
scripts_folder=("$script_location/scripts")
postinstall_folder=("$script_location/post-install.d")
[ -f "$packages_file"      ] || MISSING "$packages_file"
[ -d "$scripts_folder"     ] || MISSING "$scripts_folder"
[ -d "$postinstall_folder" ] || MISSING "$postinstall_folder"

unset USAGE_MSG MISSING

# Prepare module variables
GNOME_APPEARANCE=false
GNOME_SETTINGS=false
GNOME_EXTENSIONS=false
BUILD_MC_SERVER=false
INSTALL_DUC=false

# Function to draw a line across the width of the console.
Separate () {
	if [ ! -z $1 ]; then tput setaf $1; fi
	printf "\n\n%`tput cols`s\n" |tr " " "="
	tput sgr0
}

# Aquire root privileges now
sudo echo >/dev/null || exit 1

printf "Welcome to \e[01mFedora Setup\e[00m version %s!\n" $(git describe --tags --abbrev=0)
printf "Follow the instructions and you should be up and running soon\n";
printf "THE SOFTWARE IS PROVIDED \"AS IS\", read the license for more information\n\n"

#region Prompting the user for their choices
if ! $load_tmp_file; then
	# We're about to make a new choices file
	[ -f "$choices_file" ] && rm "$choices_file"

	# List of packages to install (then set up)
	printf "Confirm packages to install:\n"

	# Go through a list of packages asking the user to choose which ones to
	# install.
	IFSB="$IFS"
	IFS="$(echo -en "\n\b")"
	for i in $(cat "$packages_file"); do
		read -r -p "Confirm: `tput setaf 3``printf %s $i | cut -d ' ' -f 1 | tr '_' ' '``tput sgr0` (Y/n) "
		[[ ${REPLY,,} == "y" ]] || [ -z $REPLY ] && \
		TO_DNF+=("$(printf %s "$i" | cut -d ' ' -f 2-)")
	done
	IFS="$IFSB"
	unset IFSB

	# Append "essential" packages
	TO_DNF+=("ufw" "xclip")

	# Store all selected packages
	echo "TO_DNF - ${TO_DNF[@]}" >> "$choices_file"
	Separate 4

	printf "Choose some extra scripts to run:\n"
	# Check if a script is present before prompting
	prompt_user () {
		unset Confirmed
		if [ -f "$scripts_folder/$1" ]; then
			read -rp "Do you want to $2 (Y/n) "
			if [[ ${REPLY,,} == "y" ]] || [ -z $REPLY ]; then
				Confirmed=true
			else Confimed=false; fi
		else Confimed=false; fi
	}

	# Start prompting the user
	prompt_user "gnome_appearance.sh" "configure the appearance of gnome"
	GNOME_APPEARANCE=$Confirmed
	test $GNOME_APPEARANCE && Modules+=("GNOME_APPEARANCE")

	prompt_user "gnome_settings.sh" "modify some of gnome's configurations"
	GNOME_SETTINGS=$Confirmed
	test $GNOME_SETTINGS && Modules+=("GNOME_SETTINGS")

	prompt_user "gnome_extensions.sh" "install some gnome extensions"
	GNOME_EXTENSIONS=$Confirmed
	test $GNOME_EXTENSIONS && Modules+=("GNOME_EXTENSIONS")

	if [[ ${TO_DNF[@]} == *"java"* ]]; then
		prompt_user "mc_server_builder.sh" "build a minecraft server"
		BUILD_MC_SERVER=$Confirmed
		test $BUILD_MC_SERVER && Modules+=("BUILD_MC_SERVER")
	fi

	prompt_user "duc_noip_install.sh" "install No-Ip's DUC"
	INSTALL_DUC=$Confirmed
	test $INSTALL_DUC && Modules+=("INSTALL_DUC")

	prompt_user "systemdboot_switch.sh" "switch to systemd-boot"
	SYSTEMDBOOT_SWITCH=$Confirmed
	test $SYSTEMDBOOT_SWITCH && Modules+=("SYSTEMDBOOT_SWITCH")

	echo "MODULES - ${Modules[@]}" >> "$choices_file"
	Separate 4
fi
#endregion

#region Loading choices from file
if $load_tmp_file; then
	# Error if there aren't previous choices
	if [ -f "$choices_file" ]; then
		printf "\e[01mLoading previous choices\e[00m\n"
	else
		printf "\e[31mERROR: No previous choices file.\e[00m\n"
		exit 1
	fi

	# Load dnf packages
	TO_DNF=$(cat "$choices_file" | grep "TO_DNF")
	TO_DNF=${TO_DNF/"TO_DNF - "/""}

	# Load module scripts to run
	Modules=$(cat "$choices_file" | grep "MODULES")
	Modules=${Modules/"MODULES - "/""}
	[[ "$Modules" == *"GNOME_APPEARANCE"*   ]] && GNOME_APPEARANCE=true
	[[ "$Modules" == *"GNOME_SETTINGS"*     ]] && GNOME_SETTINGS=true
	[[ "$Modules" == *"GNOME_EXTENSIONS"*   ]] && GNOME_EXTENSIONS=true
	[[ "$Modules" == *"BUILD_MC_SERVER"*    ]] && BUILD_MC_SERVER=true
	[[ "$Modules" == *"INSTALL_DUC"*        ]] && INSTALL_DUC=true
	[[ "$Modules" == *"SYSTEMDBOOT_SWITCH"* ]] && SYSTEMDBOOT_SWITCH=yes

	Separate 4
fi
#endregion

# The script starts working now

# Set BIOS time to UTC
sudo timedatectl set-local-rtc 0

# Ensure these hidden folders are present and have the right permissions
# Normal folders
for i in mydock icons themes; do
	[ ! -d ~/.$i ] && [ -d ~/$i ] && mv ~/$i ~/.$i
	[ ! -d ~/.$i ] && mkdir ~/.$i
	chmod 755 ~/.$i
done

# Secret folders
for i in ssh safe; do
	[ ! -d ~/.$i ] && [ -d ~/$i ] && mv ~/$i ~/.$i
	[ ! -d ~/.$i ] && mkdir ~/.$i
	chmod 700 ~/.$i
done

# Backup the following files if present
for i in .bashrc .clang-format .zshrc .vimrc; do
	[ ! -f ~/$i-og ] && [ -f ~/$i ] && cp ~/$i ~/$i-og
	# "-og" stands for original
done

# Create an "empty file" template
[ -f ~/Templates/Empty ] || touch ~/Templates/Empty

# Test for an internet connection and exit if none is found.
ping -c 1 google.com &>/dev/null
if [ ! $? -eq 0 ]; then
	printf "\e[31mERROR: No internet\e[00m\n" >&2 /dev/null
	exit 1
fi

# Configure dnf now, before we start using it
sudo mv /etc/dnf/dnf.conf /etc/dnf/dnf.conf-og
DNF_CONF="[main]
gpgcheck=1
installonly_limit=3
clean_requirements_on_remove=True
best=False
skip_if_unavailable=True
fastestmirror=True
max_parallel_downloads=20
defaultyes=True
minrate=384k
installonly_limit=3"
printf "%s\n" "$DNF_CONF" | sudo tee /etc/dnf/dnf.conf >/dev/null
unset DNF_CONF

# Stop GNOME's packagekit to avoid problems while the package manager is being used.
sudo systemctl stop packagekit

# Set up extra sources now
REPOS_ADDED=0
RPMFUSION_NONFREE_QUEUED=false
RPMFUSION_FREE_QUEUED=false
for i in ${TO_DNF[@]}; do
case $i in
	code)
	REPOS_ADDED=1
	printf "Preparing \e[01mVisual Studio Code\e[00m source...\n"
	sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
	printf "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\n" | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
	;;

	brave-browser)
	REPOS_ADDED=1
	printf "Preparing \e[01mBrave Browser\e[00m source...\n"
	sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
	printf "[brave-browser-rpm-release.s3.brave.com_x86_64_]\nname=Brave Browser\nbaseurl=https://brave-browser-rpm-release.s3.brave.com/x86_64/\nenabled=1\ngpgkey=https://brave-browser-rpm-release.s3.brave.com/brave-core.asc\ngpgcheck=1\n" | sudo tee /etc/yum.repos.d/brave-browser.repo >/dev/null
	;;

	# TODO: Find a way to avoid hard-coding RPM-Fusion
	obs-studio|VirtualBox|vlc)
	if ! $RPMFUSION_FREE_QUEUED; then
		REPOS_ADDED=1
		TO_RPMFUSION+=("https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm")
		RPMFUSION_FREE_QUEUED=true
	fi
	;;

	discord|steam)
	if ! $RPMFUSION_NONFREE_QUEUED; then
		REPOS_ADDED=1
		TO_RPMFUSION+=("https://mirrors.rpmfusion.org/free/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm")
		RPMFUSION_NONFREE_QUEUED=true
	fi
	;;
esac
done

if [[ "${TO_RPMFUSION[@]}" ]]; then
	printf "Preparing \e[01mRPM Fusion\e[00m source...\n"
	sudo dnf install -y ${TO_RPMFUSION[@]} >/dev/null
fi

test $REPOS_ADDED -ne 0 && Separate 4
unset REPOS_ADDED RPMFUSION_FREE_QUEUED RPMFUSION_NONFREE_QUEUED TO_RPMFUSION

printf "Updating repositories...\n"
sudo dnf check-update --refresh # Exit code will be 100 if upgrades are available

# If upgrades are available, offer the user a chance to install them now.
if [ $? -eq 100 ]; then
	printf "Upgrades are available, do you want to update now? (\e[35mY\e[00m)\n"
	printf "Or do you want to skip and proceed to install your packages? (\e[35mN\e[00m)\n"
	read -rp "You answer (default is Y): "
	if [[ ${REPLY,,} = "y" ]] || [ -z $REPLY ]; then
		printf "Upgrading...\n"
		sudo dnf upgrade -y
	fi
fi

Separate 4

# Install user-selected packages now:
printf "Installing user-selected packages...\n"
sudo dnf install ${TO_DNF[@]} ${APPEND_DNF[@]}

# Source the post-installation scripts for the packages we've installed
if [ $? -eq 0 ]; then
	for i in $(ls "$postinstall_folder" | grep \.sh$); do
		[[ "${TO_DNF[@]}" == *"${i/".sh"/""}"* ]] && \
			source "$postinstall_folder/$i"
	done
fi

# Run modules
if [[ "$GNOME_APPEARANCE" == true   ]]; then
	Separate 4; printf "Running \e[01mGNOME Appearance\e[00m module...\n"
	"$scripts_folder/gnome_appearance.sh"
fi
if [[ "$GNOME_SETTINGS" == true     ]]; then
	Separate 4; printf "Running \e[01mGNOME Settings\e[00m module...\n"
	"$scripts_folder/gnome_settings.sh"
fi
if [[ "$GNOME_EXTENSIONS" == true   ]]; then
	Separate 4; printf "Running \e[01mGNOME Extensions\e[00m module...\n"
	"$scripts_folder/gnome_extensions.sh"
fi
if [[ "$BUILD_MC_SERVER" == true    ]]; then
	Separate 4; printf "Running \e[01mBuild Minecraft server\e[00m module...\n"
	"$scripts_folder/mc_server_builder.sh"
fi
if [[ "$INSTALL_DUC" == true        ]]; then
	Separate 4; printf "Running \e[01mInstall No-Ip's DUC\e[00m module...\n"
	"$scripts_folder/duc_noip_install.sh" -e
fi
if [[ "$SYSTEMDBOOT_SWITCH" == true ]]; then
	Separate 4; printf "Running \e[01mSwitch to systemd-boot module\e[00m...\n"
	"$scripts_folder/systemdboot_switch.sh"
fi

# Restart gnome's package kit after we've finished using the package manager
sudo systemctl restart packagekit
Separate 4

# Clean up after we're done
[ -f "$choices_file" ] && rm "$choices_file"

if $persist_at_the_end; then
	read -p "Press any key to finish. " -n 1
fi

printf "\e[01;32mFinished!\e[00m your system has been set up.\n"
exit 0
# Thanks for downloading, and enjoy!

#!/bin/bash

# MIT License - Copyright (c) 2021-2022 Nicolás Castellán <cnicolas.developer@gmail.com>
# SPDX License identifier: MIT
# THE SOFTWARE IS PROVIDED "AS IS"
# Read the included LICENSE file for more information

# Set up script variables for later
load_choices_file=no
persist_at_the_end=no
run_as_root=no

USAGE_MSG () {
	printf "Usage: \e[01m./%s (-f)\e[00m
	-f ) Load previous choices
	-s ) Run as root (not recommended)\n" "$(basename "$0")"
}

while [ -n "$1" ]; do
	case "$1" in
		-f) load_choices_file=yes      ;; # Load previous choices
		-p) persist_at_the_end=yes     ;; # Persist open at the end of the script
		-s) run_as_root=yes            ;; # Don't stop if run as sudo
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

# Prepare and test filepaths in variables
choices_file="$script_location/.tmp_choices"

packages_file="$script_location/packages.txt"
remove_file="$script_location/remove.txt"

scripts_folder="$script_location/scripts"
postinstall_folder="$script_location/post-install.d"
sources_folder="$script_location/sources.d"

[ -f "$packages_file"      ] || MISSING "$packages_file"
[ -f "$remove_file"        ] || MISSING "$remove_file"
[ -d "$scripts_folder"     ] || MISSING "$scripts_folder"
[ -d "$postinstall_folder" ] || MISSING "$postinstall_folder"
[ -d "$sources_folder"     ] || MISSING "$sources_folder"

unset USAGE_MSG MISSING

# Function to draw a line across the width of the console.
Separate () {
	printf "\n\n\e[34m%`tput cols`s\e[00m\n" | tr ' ' '='
}

# The script should not be run as root
if [ "$(id -u)" == 0 -a "$run_as_root" = "no" ]; then
	printf "\e[31mThe script should not be run as root, as some things might break\e[00m
Instead, run it as your user and let the script ask for root privileges
To force the script to run as root, use the -s flag\n" >&2
	exit 1
fi

# Aquire root privileges now
sudo echo >/dev/null || exit 1

# Give the welcome message and license disclaimer
commit="$(git log -1 --format='%h' 2>/dev/null)"
version="$(git describe --tags --abbrev=0 2>/dev/null)"
[ -n "$version" ] && \
	version=" version $version"
[ -z "$version" -a -n "$commit" ] && \
	version=" at commit $commit"

printf "Welcome to \e[36;01mFedora Setup\e[00m%s!
Follow the instructions and you should be up and running soon
THE SOFTWARE IS PROVIDED \"AS IS\", read the license for more information\n\n" "$version"
unset version commit

#region Prompting the user for their choices
if [ "$load_choices_file" = "no" ]; then
	# We're about to make a new choices file
	[ -f "$choices_file" ] && rm "$choices_file"

	# Configure IFS and umask
	IFSB="$IFS"
	IFS="$(echo -en "\n\b")"
	MASK=$(umask)
	umask 077

	# The loops are optimized by writing each line to a file in memory
	MEMFILE=/tmp/$$-line

	# Go through a list of packages asking the user to choose wich ones to remove.
	printf "Confirm packages to remove:\n"
	for i in $(cat "$remove_file"); do
		echo "$i" > $MEMFILE && chmod u-w $MEMFILE

		read -rp "$(printf "Confirm: \e[31m%s\e[00m (y/N) " "$(cut -d' ' -f1 $MEMFILE | tr '_' ' ')" )"
		[ "${REPLY,,}" == "y" ] && \
			TO_REMOVE+=($(cut -d' ' -f2- $MEMFILE))

		chmod u+w $MEMFILE
	done
	TO_REMOVE=($(echo "${TO_REMOVE[@]}" | tr ' ' '\n' | sort -u))
	echo "TO_REMOVE - ${TO_REMOVE[@]}" >> "$choices_file"

	# Go through a list of packages asking the user to choose which ones to install.
	printf "Confirm packages to install:\n"

	# Process the packages file and prompt the user
	for i in $(cat "$packages_file"); do
		echo "$i" > $MEMFILE && chmod u-w $MEMFILE

		# Detect category and user choice to skip or not skip
		if [ -n "$(awk '$0 ~ /^\S/' $MEMFILE)" ]; then
			read -rp "$(printf "Do you want to install \e[01;33m%s\e[00m software? (%s) (Y/n) > " "$(awk '{print $1}' $MEMFILE | tr '_' ' ')" "$(cut -d' ' -f2- $MEMFILE)")"
			[ "${REPLY,,}" == 'y' -o -z "$REPLY" ] && SKIP_CATEGORY=no || SKIP_CATEGORY=yes
		fi
		# Process apps in a category
		if [ -n "$(awk '$0 ~ /\t/' $MEMFILE)" -a "$SKIP_CATEGORY" = 'no' ]; then
			read -rp "$(printf "  Confirm: \e[33m%s\e[00m (Y/n) " "$(awk '{print $1}' $MEMFILE | tr '_' ' ')")"
			[ "${REPLY,,}" == 'y' -o -z "$REPLY" ] && \
				TO_DNF+=($(cut -d' ' -f2- $MEMFILE))
		fi

		chmod u+w $MEMFILE
	done

	# Append essential packages, sort, and write
	TO_DNF+=("xclip" "rpmconf" "pxz")
	TO_DNF=($(echo "${TO_DNF[@]}" | tr ' ' '\n' | sort -u))
	echo "TO_DNF - ${TO_DNF[@]}" >> "$choices_file"

	# Delete MEMFILE, and return IFS and umask to normal
	rm $MEMFILE
	IFS="$IFSB"
	umask $MASK
	unset IFSB MASK MEMFILE

	Separate

	# Load extra scripts to run
	printf "Choose some extra scripts to run:\n"
	for i in $(ls "$scripts_folder" | grep \.sh$); do
		read -rp "$(printf "Do you want to run the \e[01m%s\e[00m extra script? (Y/n) " "${i/".sh"/""}")"
		[ "${REPLY,,}" = "y" -o -z "$REPLY" ] && \
			SCRIPTS+=("$i")
	done

	# Store selected scripts
	echo "SCRIPTS - ${SCRIPTS[@]}" >> "$choices_file"
	Separate
fi
#endregion

#region Loading choices from file
if [ "$load_choices_file" = "yes" ]; then
	# Error if there aren't previous choices
	if [ -f "$choices_file" ]; then
		printf "\e[01mLoading previous choices\e[00m\n"
	else
		printf "\e[31mERROR: No previous choices file.\e[00m\n"
		exit 1
	fi

	# Load packages to remove
	TO_REMOVE=$(cat "$choices_file" | grep "TO_REMOVE")
	TO_REMOVE=${TO_REMOVE/"TO_REMOVE - "/""}

	# Load dnf packages
	TO_DNF=$(cat "$choices_file" | grep "TO_DNF")
	TO_DNF=${TO_DNF/"TO_DNF - "/""}

	# Load extra scripts to run
	SCRIPTS=$(cat "$choices_file" | grep "SCRIPTS")
	SCRIPTS=${SCRIPTS/"SCRIPTS - "/""}

	Separate
fi
#endregion

# The script starts working now

# Set BIOS time to UTC
sudo timedatectl set-local-rtc 0

# Create themes, icons, and desktop folders
mkdir -p ~/.local/share/{themes,icons}

# Create secret folders
mkdir -p ~/{.ssh,.safe} -m 700

# Backup the following files if present
for i in .bashrc .clang-format .zshrc .vimrc .config/{nvim/init.vim,htop/htoprc} ; do
	[ ! -f ~/$i-og -a -f ~/$i ] && cp ~/{$i,$i-og}
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
[ ! -f /etc/dnf/dnf.conf-og ] && sudo cp /etc/dnf/dnf.conf /etc/dnf/dnf.conf-og
sudo cp "$script_location/samples/dnf.conf" /etc/dnf/dnf.conf

# Stop packagekit to avoid problems while the package manager is being used.
sudo systemctl stop packagekit

# Source all the files containing extra sources now.
for i in $(ls "$sources_folder" | grep \.txt$); do
	if [[ "${TO_DNF[@]}" == *"${i/".txt"/""}"* ]];then
		source "$sources_folder/$i"
		if ! [[ "${REPOS_CONFIGURED[@]}" =~ "$URL" ]]; then
			# Configure the repository
			if [[ "$URL" =~ "rpmfusion" ]]; then
				TO_RPMFUSION+=("$URL")
			else
				printf "Preparing \e[01m%s\e[00m source...\n" "$NAME"
				sudo rpm --import "$KEY"
				printf "$CONF\n" | sudo tee "/etc/yum.repos.d/$CONF_FILE" >/dev/null
			fi

			# List it as already configured
			REPOS_CONFIGURED+=("$URL")
		fi
	fi
done

# RPM Fusion repositories have to be installed using dnf. We cannot just use
# rpm --import and write the repository file. Instead, we queue the
# repositories for installation in the previous loop, and install them now.
if [[ "${TO_RPMFUSION[@]}" ]]; then
	printf "Preparing \e[01mRPM Fusion\e[00m source...\n"
	sudo dnf install -y ${TO_RPMFUSION[@]} >/dev/null
fi

[[ "${REPOS_CONFIGURED[@]}" ]] && Separate
unset REPOS_CONFIGURED URL KEY NAME CONF CONF_FILE

printf "Updating repository metadata...\n"
sudo dnf makecache --refresh

if [ -n "$TO_REMOVE" ]; then
	Separate
	printf "Removing user-selected packages...\n"
	sudo dnf remove ${TO_REMOVE[@]}
fi

# If upgrades are available, offer the user a chance to install them now.
if sudo dnf -q check-update; [ $? -eq 100 ]; then
	Separate
	printf "Upgrades are available, do you want to update now? (\e[35mY\e[00m)\n"
	printf "Or do you want to skip and proceed to install your packages? (\e[35mN\e[00m)\n"
	read -rp "You answer (default is Y): "
	if [[ ${REPLY,,} = "y" ]] || [ -z $REPLY ]; then
		printf "Upgrading...\n"
		sudo dnf upgrade -y
	fi
fi

Separate

# Install user-selected packages now:
printf "Installing user-selected packages...\n"
sudo dnf install ${TO_DNF[@]}

# Source the post-installation scripts for the packages we've installed
if [ $? -eq 0 ]; then
	for i in $(ls "$postinstall_folder" | grep \.sh$); do
		[[ "${TO_DNF[@]}" == *"${i/".sh"/""}"* ]] && \
			source "$postinstall_folder/$i"
	done
fi

# Run extra scripts
for i in ${SCRIPTS[@]}; do
	Separate
	printf "Running \e[01m%s\e[00m extra script...\n" "${i/".sh"/""}"
	"$scripts_folder/$i"
done

# Restart package kit after we've finished using the package manager
sudo systemctl restart packagekit
Separate

# Wait for child processes and clean up
wait
[ -f "$choices_file" ] && rm "$choices_file"

if [ "$persist_at_the_end" = "yes" ]; then
	read -p "Press any key to finish. " -n 1
fi

printf "\e[01;32mFinished!\e[00m your system has been set up.\n"
exit 0
# Thanks for downloading, and enjoy!

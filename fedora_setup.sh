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

unset USAGE_MSG

# Head to the script's directory and store it for later
cd "$(dirname "$0")"
script_location="$(pwd)"
choices_file=("$script_location/.tmp_choices")
packages_file=("$script_location/packages.txt")
modules_folder=("$script_location/modules")

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
sudo echo >/dev/null

printf "Welcome to \e[01mFedora Setup\e[00m version %s!\n" $(git describe --tags --abbrev=0)
printf "Follow the instructions and you should be up and running soon\n";
printf "THE SOFTWARE IS PROVIDED \"AS IS\", read the license for more information\n\n"

#region Prompting the user for their choices
if ! $load_tmp_file: then
	# Go through a list of packages asking the user to choose which ones to
	# install.
	Confirm_from_list () {
		unset Confirmed
		for i in ${To_Confirm[@]}; do
			read -r -p "Confirm `tput setaf 3`\"$i\"`tput sgr0` (Y/n) " -t 10
			O=$?

			# User presses ENTER -> YES
			# Times out          -> NO
			if [ $O -eq 0 ] && [ -z $REPLY ]; then REPLY=("y"); fi
			if [ $O -gt 128 ]; then echo; REPLY=("n"); fi

			# Append confirmed items to the list.
			if [[ ${REPLY,,} == "y" ]]; then
				Confimed+=("$i")
			fi
		done
	}

	# We're about to make a new choices file
	[ -f "$choices_file" ] && rm "$choices_file"

	# List of packages to install (then set up)
	printf "Confirm packages to install:\n"

	# Load packages from packages.txt
	for i in $(cat "$packages_file"); do To_Confirm+=("$i"); done
	Confirm_from_list
	TO_DNF=(${Confirmed[@]})

	# Append "essential" packages
	To_DNF+=("neofetch" "vim" "ufw" "xclip")

	# Store all selected packages
	printf "TO_DNF - %s\n" "${TO_DNF[@]}" >> "$choices_file"
	Separate 4

	# Pre-installation instructions for the packages:
	# If pre-installation instructions could add further packages they should be
	# executed now. This way, we only need to run the package manager once.
	for i in ${TO_DNF[@]}; do
	case $i in
		code)
		printf "I noticed you're installing \e[36mvscode\e[00m...\n"

		 LIST=("nodejs")                                                   # NodeJS
		LIST+=("@c-development" "clang" "cmake")                           # C/C++
		LIST+=("java-latest-openjdk-devel" "@eclipse")                     # Java
		LIST+=("dotnet-sdk-5.0" "dotnet-sdk-3.1" "aspnetcore-runtime-3.1") # .NET

		for i in ${LIST[@]}; do
			read -rp "Do you want to install `tput setaf 3`$i`tput sgr0` too? (Y/n) "
			if [[ ${REPLY,,} == "y" ]] || [ -z $REPLY ]; then
				APPEND_DNF+=("$i")
			fi
		done
		unset LIST
		;;

		zsh)
		APPEND_DNF+=("zsh-syntax-highlighting" "zsh-autosuggestions" "python3-pip" "util-linux-user")
		;;

		"@development-tools")
		APPEND_DNF+=("git-lfs")
		;;
	esac
	done
	printf "APPEND_DNF - %s\n" "${APPEND_DNF[@]}" >> "$choices_file"

	Separate 4

	printf "Choose some extra scripts to run:\n"
	# Check if a script is present before prompting
	prompt_user () {
		unset Confirmed
		if [ -f "$modules_folder/$1" ]; then
			read -rp "Do you want to $2 (Y/n) "
			if [[ ${REPLY,,} = "y" ]] || [[ -z $REPLY ]]; then
				Confirmed=true
			else Confimed=false; fi
		else Confimed=false; fi
	}

	# Start prompting the user
	prompt_user "gnome_appearance.sh" "configure the appearance of gnome"
	GNOME_APPEARANCE=$Confimed
	test $GNOME_APPEARANCE && Modules+=("GNOME_APPEARANCE")

	prompt_user "gnome_settings.sh" "modify some of gnome's configurations"
	GNOME_SETTINGS=$Confimed
	test $GNOME_SETTINGS && Modules+=("GNOME_SETTINGS")

	prompt_user "gnome_extensions.sh" "install some gnome extensions"
	GNOME_EXTENSIONS=$Confimed
	test $GNOME_EXTENSIONS && Modules+=("GNOME_EXTENSIONS")

	if [[ ${TO_DNF[@]} == *"java"* ]]; then
		prompt_user "mc_server_builder.sh" "build a minecraft server"
		BUILD_MC_SERVER=$Confimed
		test $BUILD_MC_SERVER && Modules+=("BUILD_MC_SERVER")
	fi

	prompt_user "duc_noip_install.sh" "install No-Ip's DUC"
	INSTALL_DUC=$Confimed
	test $INSTALL_DUC && Modules+=("INSTALL_DUC")

	printf "MODULES - %s\n" "${Modules[@]}" >> "$choices_file"
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

	APPEND_DNF=$(cat "$choices_file" | grep "APPEND_DNF")
	APPEND_DNF=${APPEND_DNF/"APPEND_DNF - "/""}

	# Load module scripts to run
	Modules=(cat "$choices_file" | grep "MODULES")
	Modules=${Modules/"MODULES - "/""}
	[[ "$Modules" == *"GNOME_APPEARANCE"* ]] && GNOME_APPEARANCE=true
	[[ "$Modules" == *"GNOME_SETTINGS"* ]] && GNOME_SETTINGS=true
	[[ "$Modules" == *"GNOME_EXTENSIONS"* ]] && GNOME_EXTENSIONS=true
	[[ "$Modules" == *"BUILD_MC_SERVER"* ]] && BUILD_MC_SERVER=true
	[[ "$Modules" == *"INSTALL_DUC"* ]] && INSTALL_DUC=true

	Separate 4
fi
#endregion

# The script starts working now

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
	[ ! -f ~/$i-og ] && cp ~/$i ~/$i-og
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
minrate=384k"
printf "%s\n" "$DNF_CONF" | sudo tee /etc/dnf/dnf.conf >/dev/null
unset DNF_CONF

# Stop GNOME's packagekit to avoid problems while the package manager is being used.
sudo systemctl stop packagekit

# Set up extra sources now
RPM_FUSION_INSTALLED=false
for i in ${TO_DNF[@]}; do
case $i in
	code)
	printf "Preparing \e[01mVisual Studio Code\e[00m source...\n"
	sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
	printf "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\n" | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
	;;

	brave-browser)
	printf "Preparing \e[01mBrave Browser\e[00m source...\n"
	sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
	printf "[brave-browser-rpm-release.s3.brave.com_x86_64_]\nname=Brave Browser\nbaseurl=https://brave-browser-rpm-release.s3.brave.com/x86_64/\nenabled=1\ngpgkey=https://brave-browser-rpm-release.s3.brave.com/brave-core.asc\ngpgcheck=1\n" | sudo tee /etc/yum.repos.d/brave-browser.repo
	;;

	# TODO: Find a way to avoid hard-coding RPM-Fusion
	discord|obs-studio|steam|vrtualbox|vlc)
	if ! $RPM_FUSION_INSTALLED; then
		printf "Preparing \e[01mRPM Fusion\e[00m source...\n"
		sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm >/dev/null
		RPM_FUSION_INSTALLED=true
	fi
	;;
esac
done
unset RPM_FUSION_INSTALLED

printf "Updating repositories...\n"
sudo dnf check-update --refresh # Exit code will be 100 if upgrades are available

# If upgrades are available, offer the user a chance to install them now.
if [ $? -eq 100 ]; then
	printf "Upgrades are available, do you want to update now? (\e[35mY\e[00m)\n"
	printf "Or do you want to skip and proceed to install your packages? (\e[35mN\e[00m)\n"
	read -rp "You answer (default is Y): "
	if [[ ${REPLY,,} = "y" ]] || [ -z $REPLY ]; then
		printf "Upgrading...\n"
		sudo dnf upgrade
	fi
fi

Separate 4

# Install user-selected packages now:
printf "Installing user-selected packages...\n"
sudo dnf install ${TO_DNF[@]} ${APPEND_DNF[@]}

# After successfully installing the packages, if further configuration is required
# it should be executed now.
if [ $? -eq 0 ]
for i in ${TO_DNF[@]} ${APPEND_DNF[@]}; do
case $i in
	code)
	# Instructions for this package are very extensive, so they're in another file
	source "$script_location/vscode.sh"
	;;

	lm_sensors)
	Separate 4
	printf "Configure \"lm_sensors\":\n"
	sleep 1.5 # Time for the user to read
	sudo sensors-detect
	;;

	vim)
	cat "$script_location/samples/vimrc" | sudo tee /root/.vimrc /root/.vimrc-og | tee ~/.vimrc ~/.vimrc-og >/dev/null
	;;

	"@development-tools")
	git lfs install &>/dev/null
	;;

	tlp)
	Separate 4
	printf "Successfully installed \e[36mtlp\e[00m, configuring..."

	# Conditionally execute all the steps to configure tlp.
	sudo mv /etc/tlp.conf /etc/tlp.conf-og && \
	cat "$script_location/samples/tlp.conf" | sudo tee /etc/tlp.conf >/dev/null && \
	sudo systemctl enable tlp && \
	sudo systemctl restart tlp

	printf "%s\e[00m\n" $([ $? -eq 0 ] && printf "\e[32mSuccess" || printf "\e[31mFail")

	read -rp "Do you want to suspend the OS when you close the lid? (laptops only) (Y/n) "
	[[ ${REPLY,,} == "y" ]] && sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=suspend/' /etc/systemd/logind.conf
	;;

	zsh)
	Separate 4
	printf "Successfully installed \e[36mzsh\e[00m, configuring...\n"

	# Create .zshrc files
	     [ ! -f ~/.zshrc ]     && cat "$script_location/samples/zshrc" | tee ~/.zshrc ~/.zshrc-og >/dev/null
	sudo [ ! -f /root/.zshrc ] && cat "$script_location/samples/zshrc" | sudo tee /root/.zshrc /root/.zshrc-og >/dev/null

	# Prepare powerline shell
	sudo pip3 install powerline-shell &>/dev/null

	if [ $? -eq 0 ]; then
		sed -i "s/# user_powerline/use_powerline/" ~/.zshrc
		sudo sed -i "s/# user_powerline/use_powerline/" /root/.zshrc

		mkdir -p ~/.config/powerline-shell
		sudo mkdir -p /root/.config/powerline-shell

		#region file
		FILE='{
	"segments": [
		"virtual_env",
		"username",
		"hostname",
		"ssh",
		"cwd",
		"git",
		"hg",
		"jobs",
		"root"
	],
	"cwd": {
		"max_depth": 3
	}
}'
		#endregion
		printf "%s\n" "$FILE" | sudo tee /root/.config/powerline-shell/config.json | tee ~/.config/powerline-shell/config.json >/dev/null
		unset FILE
	fi

	# Ensure zsh aliases file exists
	     [ -f ~/.zsh_aliases ] || printf "# zsh aliases file\n" | tee ~/.zsh_aliases     >/dev/null
	sudo [ -f ~/.zsh_aliases ] || printf "# zsh aliases file\n" | tee /root/.zsh_aliases >/dev/null

	read -rp "Do you want to make `tput setaf 6`zsh`tput sgr0` your default shell? (Y/n) "
	if [[ ${REPLY,,} == "y" ]] || [ -z $REPLY ]; then
		chsh -s $(which zsh)
		sudo chsh -s $(which zsh)
	fi
	;;
esac
done
fi

# Restart gnome's package kit after we've finished using the package manager
sudo systemctl restart packagekit

# Run modules
if [ $GNOME_APPEARANCE ]; then
	"$modules_folder/gnome_appearance.sh"
fi
if [ $GNOME_SETTINGS   ]; then
	"$modules_folder/gnome_settings.sh"
fi
if [ $GNOME_EXTENSIONS ]; then
	"$modules_folder/gnome_extensions.sh"
fi
if [ $BUILD_MC_SERVER  ]; then
	"$modules_folder/mc_server_builder.sh"
fi
if [ $INSTALL_DUC      ]; then
	"$modules_folder/duc_noip_install.sh" -e
fi

# Clean up after we're done
[ -f "$choices_file" ] && rm "$choices_file"

if $persist_at_the_end; then
	read -p "Press any key to finish. " -n 1
fi

exit 0
# Thanks for downloading, and enjoy!

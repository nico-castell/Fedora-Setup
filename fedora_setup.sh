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
	TO_DNF+=("neofetch" "vim" "ufw" "xclip")

	# Store all selected packages
	printf "TO_DNF - %s\n" "${TO_DNF[@]}" >> "$choices_file"
	Separate 4

	# Pre-installation instructions for the packages:
	# If pre-installation instructions could add further packages they should be
	# executed now. This way, we only need to run the package manager once.
	APPENDED=0
	for i in ${TO_DNF[@]}; do
	case $i in
		code)
		APPENDED=1
		printf "I noticed you're installing \e[36mVisual Studio Code\e[00m...\n"

		 LIST=("nodejs")                                                   # NodeJS
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
	esac
	done
	printf "APPEND_DNF - %s\n" "${APPEND_DNF[@]}" >> "$choices_file"

	test $APPENDED -ne 0 && Separate 4
	unset APPENDED

	printf "Choose some extra scripts to run:\n"
	# Check if a script is present before prompting
	prompt_user () {
		unset Confirmed
		if [ -f "$modules_folder/$1" ]; then
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
	Modules=($(cat "$choices_file" | grep "MODULES"))
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
minrate=384k"
printf "%s\n" "$DNF_CONF" | sudo tee /etc/dnf/dnf.conf >/dev/null
unset DNF_CONF

# Stop GNOME's packagekit to avoid problems while the package manager is being used.
sudo systemctl stop packagekit

# Set up extra sources now
REPOS_ADDED=0
RPM_FUSION_INSTALLED=false
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
	discord|obs-studio|steam|vrtualbox|vlc)
	if ! $RPM_FUSION_INSTALLED; then
		REPOS_ADDED=1
		printf "Preparing \e[01mRPM Fusion\e[00m source...\n"
		sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm >/dev/null
		RPM_FUSION_INSTALLED=true
	fi
	;;
esac
done
test $REPOS_ADDED -ne 0 && Separate 4
unset REPOS_ADDED RPM_FUSION_INSTALLED

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

# After successfully installing the packages, if further configuration is required
# it should be executed now.
if [ $? -eq 0 ]; then
for i in ${TO_DNF[@]} ${APPEND_DNF[@]}; do
case $i in
	code)
	# Instructions for this package are very extensive, so they're in another file
	source "$script_location/vscode.sh"
	;;

	lm_sensors) # Tell the user to configure the sensors
	Separate 4
	printf "Successfully installed \e[36mlm_sensors\e[00m, configuring...\n"
	sleep 1.5 # Time for the user to read
	sudo sensors-detect
	;;

	vim) # Install .vimrc
	cat "$script_location/samples/vimrc" | sudo tee /root/.vimrc /root/.vimrc-og | tee ~/.vimrc ~/.vimrc-og >/dev/null
	;;

	flatpak) # Add flathub repository and delete fedora's repos.
	if sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >/dev/null; then
		sudo flatpak remote-delete fedora >/dev/null
		sudo flatpak remote-delete fedora-testing >/dev/null
	fi
	;;

	tlp) # Copy the configuration file
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

	git) # Configure git
	Separate 4
	printf "Successfully installed \e[36mGit\e[00m, configuring...\n"

	# User configurations
	read -p "What's your commit name? " USERNAME
	git config --global user.name "$USERNAME"
	read -p "What's your commit email? " EMAIL
	git config --global user.email "$EMAIL"
	read -p "What do you want to call the default branch? " BRANCH
	[ ! -z $BRANCH ] && git config --global init.defaultBranch "$BRANCH"
	unset USERNAME EMAIL BRANCH

	# Choose a commit editor
	printf "Please, select a default editor for commit messages:\n"
	which code  >/dev/null && GIT_EDITORS+=("vscode")
	which vim   >/dev/null && GIT_EDITORS+=("vim")
	which namo  >/dev/null && GIT_EDITORS+=("nano")
	which gedit >/dev/null && GIT_EDITORS+=("gedit")
	select GIT_EDITOR in ${GIT_EDITORS[@]}; do
	case $GIT_EDITOR in
		vscode) git config --global core.editor "code --wait"         ;;
		vim)    git config --global core.editor "vim"                 ;;
		nano)   git config --global core.editor "nano"                ;;
		gedit)  git config --global core.editor "gedit -s"            ;;
		*) printf "Option %s not recognized.\n" $GIT_EDITOR; continue ;;
	esac; break; done
	unset GIT_EDITOR GIT_EDITORS

	# If vscode was installed, configure it as a git mergetool and difftool
	if which code >/dev/null; then
		printf "Setting \e[36mVisual Studio Code\e[00m as a Git merge and diff tool...\n"
		git config --global merge.tool vscode
		git config --global mergetool.vscode.cmd 'code --wait $MERGED'
		git config --global diff.tool vscode
		git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'
	fi

	# Configure git
	printf "Configuring pull behaviour...\n"
	git config --global pull.ff only
	printf "Setting up some aliases...\n"
	git config --global alias.mrc '!git merge $1 && git commit -m "$2" --allow-empty && :'
	git config --global alias.flog "log --all --graph --oneline --format=format:'%C(bold yellow)%h%C(r) %an➜ %C(bold)%s%C(r) %C(auto)%d%C(r)\'"
	git config --global alias.sflog "log --all --graph --oneline --format=format:'%C(bold yellow)%h%C(r) §%C(bold green)%G?%C(r) %an➜ %C(bold)%s%C(r) %C(auto)%d%C(r)'"
	git config --global alias.slog 'log --show-signature -1'
	git config --global alias.mkst 'stash push -u'
	git config --global alias.popst 'stash pop "stash@{0}" -q'
	git config --global alias.unstage 'reset -q HEAD -- .'
	;;

	zsh) # Copy .zshrc and offer to switch default shell
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

# Run modules
if [[ "$GNOME_APPEARANCE" == true   ]]; then
	Separate 4; printf "Running \e[01mGNOME Appearance\e[00m module...\n"
	"$modules_folder/gnome_appearance.sh"
fi
if [[ "$GNOME_SETTINGS" == true     ]]; then
	Separate 4; printf "Running \e[01mGNOME Settings\e[00m module...\n"
	"$modules_folder/gnome_settings.sh"
fi
if [[ "$GNOME_EXTENSIONS" == true   ]]; then
	Separate 4; printf "Running \e[01mGNOME Extensions\e[00m module...\n"
	"$modules_folder/gnome_extensions.sh"
fi
if [[ "$BUILD_MC_SERVER" == true    ]]; then
	Separate 4; printf "Running \e[01mBuild Minecraft server\e[00m module...\n"
	"$modules_folder/mc_server_builder.sh"
fi
if [[ "$INSTALL_DUC" == true        ]]; then
	Separate 4; printf "Running \e[01mInstall No-Ip's DUC\e[00m module...\n"
	"$modules_folder/duc_noip_install.sh" -e
fi
if [[ "$SYSTEMDBOOT_SWITCH" == true ]]; then
	Separate 4; printf "Running \e[01mSwitch to systemd-boot module\e[00m...\n"
	"$modules_folder/systemdboot_switch.sh"
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

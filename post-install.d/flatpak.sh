# bash script to be sourced from fedora_setup.sh

sudo echo >/dev/null
(
	# Add flathub repository and delete fedora's repos
	if
	sudo flatpak --system remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >/dev/null && \
		sudo flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >/dev/null
	then
		sudo flatpak remote-delete fedora >/dev/null
		sudo flatpak remote-delete fedora-testing >/dev/null
	fi
) &

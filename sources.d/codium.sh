# bash script to be sourced from fedora_setup.sh

# Check if it is already configured
if ! [[ "${REPOS_CONFIGURED[@]}" =~ "https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/" ]]; then
	printf "Preparing \e[01mVS Codium\e[00m source...\n"

	# Configure the repository
	sudo rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
	printf "[code]\nname=Visual Studio Code\nbaseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\n" | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null

	# List is as already configured
	REPOS_CONFIGURED+=("https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/")
fi

# bash script to be sourced from fedora_setup.sh

# Check if it is already configured
if ! [[ "${REPOS_CONFIGURED[@]}" =~ "https://brave-browser-rpm-release.s3.brave.com/x86_64/" ]]; then
	printf "Preparing \e[01mBrave Browser\e[00m source...\n"

	# Configure the repository
	sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
	printf "[code]\nname=Visual Studio Code\nbaseurl=https://brave-browser-rpm-release.s3.brave.com/x86_64/\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\n" | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null

	# List is as already configured
	REPOS_CONFIGURED+=("https://brave-browser-rpm-release.s3.brave.com/x86_64/")
fi

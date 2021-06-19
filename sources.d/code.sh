# bash script to be sourced from fedora_setup.sh

# Check if it is already configured
if ! [[ "${REPOS_CONFIGURED[@]}" =~ "https://packages.microsoft.com/yumrepos/vscode" ]]; then
	printf "Preparing \e[01mVisual Studio Code\e[00m source...\n"

	# Configure the repository
	sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
	printf "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\n" | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null

	# List is as already configured
	REPOS_CONFIGURED+=("https://packages.microsoft.com/yumrepos/vscode")
fi

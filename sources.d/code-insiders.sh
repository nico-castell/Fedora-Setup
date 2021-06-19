# bash script to be sourced from fedora_setup.sh

URL="https://packages.microsoft.com/yumrepos/vscode"
KEY="https://packages.microsoft.com/keys/microsoft.asc"

# Check if it is already configured
if ! [[ "${REPOS_CONFIGURED[@]}" =~ "$URL" ]]; then
	printf "Preparing \e[01mVisual Studio Code\e[00m source...\n"

	# Configure the repository
	sudo rpm --import "$KEY"
	printf "[code]\nname=Visual Studio Code\nbaseurl=%s\nenabled=1\ngpgcheck=1\ngpgkey=%s\n" "$URL" "$KEY" | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null

	# List is as already configured
	REPOS_CONFIGURED+=("$URL")
fi

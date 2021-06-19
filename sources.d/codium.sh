# bash script to be sourced from fedora_setup.sh

URL="https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/"
KEY="https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg"

# Check if it is already configured
if ! [[ "${REPOS_CONFIGURED[@]}" =~ "$URL" ]]; then
	printf "Preparing \e[01mVS Codium\e[00m source...\n"

	# Configure the repository
	sudo rpm --import "$KEY"
	printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=VS Codium\nbaseurl=%s\nenabled=1\ngpgcheck=1\ngpgcheck=1\ngpgkey=%s\n" "$URL" "$KEY" | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null

	# List is as already configured
	REPOS_CONFIGURED+=("$URL")
fi

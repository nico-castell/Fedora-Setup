# bash script to be sourced from fedora_setup.sh

URL="https://brave-browser-rpm-release.s3.brave.com/x86_64/"
KEY="https://brave-browser-rpm-release.s3.brave.com/brave-core.asc"

# Check if it is already configured
if ! [[ "${REPOS_CONFIGURED[@]}" =~ "$URL" ]]; then
	printf "Preparing \e[01mBrave Browser\e[00m source...\n"

	# Configure the repository
	sudo rpm --import "$KEY"
	printf "[brave-browser-rpm-release.s3.brave.com_x86_64_]\nname=Brave Browser\nbaseurl=%s\nenabled=1\ngpgkey=%s\ngpgcheck=1\n" "$URL" "$KEY" | sudo tee /etc/yum.repos.d/brave.repo >/dev/null

	# List is as already configured
	REPOS_CONFIGURED+=("$URL")
fi

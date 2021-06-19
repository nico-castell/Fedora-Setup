# bash script to be sourced from fedora_setup.sh

URL="https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"

# Check if it is already configured
if ! [[ "${REPOS_CONFIGURED[@]}" =~ "$URL" ]]; then
	# Queue the repository
	TO_RPMFUSION+=("$URL")

	# List is as already configured
	REPOS_CONFIGURED+=("$URL")
fi

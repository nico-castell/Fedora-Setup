# bash script to be sourced from fedora_setup.sh

# Check if it is already configured
if ! [[ "${REPOS_CONFIGURED[@]}" =~ "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" ]]; then
	# Queue the repository
	TO_RPMFUSION+=("https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm")

	# List is as already configured
	REPOS_CONFIGURED+=("https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm")
fi

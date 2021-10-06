# bash script to be sourced from fedora_setup.sh

Separate 4
printf "Successfully installed \e[36mKernel development\e[00m, configuring...\n"
read -rep "Do you want to configure your system for developing the linux kernel? (y/N) "
if [ ${REPLY,,} == "y" ]; then

	# Add a group with special permissions
	# TODO

	# Create the directory structure and clone the stable branch of the kernel from kernel.org.
	printf "Creating the directory structure to develop the linux kernel...\n"
	mkdir -p ~/kernel/{built,configs}
	pushd . >/dev/null
	cd ~/kernel

	# Offer not to clone the kernel as it can take quite a long time
	read -rep "$(printf "Do you want to clone the linux kernel now? (Can take a \e[01mvery\e[00m long time) (y/N) ")"
	if [ ${REPLY,,} == "y" ]; then
		read -rep "Type in the kernel version (vX.X.X) to shallow clone: "
		if [ -n $REPLY ]; then
			# Make a shallow clone of a specific tag in the repository
			git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git 'linux-stable' -b $REPLY --depth=0
		fi
	fi

	# Create a script to help in kernel development, and put it in the $PATH.
	# TODO

fi
unset REPLY

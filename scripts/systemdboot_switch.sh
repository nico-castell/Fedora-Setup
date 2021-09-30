#!/bin/bash

###############################################################
# WARNING: THIS SCRIPT COULD BREAK YOUR BOOT - USE WITH CAUTION
###############################################################

# This way of switching is based on an article at:
#   https://kowalski7cc.xyz/blog/systemd-boot-fedora-32

# Switching to systemd-boot required removing grub.
printf "\e[33mSwitching to systemd-boot requires removing grub.\e[00m
A new EFI boot entry will be created and your boot partition will be mounted at \e[01m/efi\e[00m.
It's not recommendable to use systemd-boot if your boot partition is small (I recommend 512 MiB).

WARNING: Do not use this script if you use separate partitions for /boot and /boot/efi.\n\n"

PROCEED=false
read -rp "Now that you understand the risk, do you still want to switch? (y/N) "
[[ ${REPLY,,} == "y" ]] && PROCEED=true

# Switch to systemd-boot
if $PROCEED; then
	printf "Switching now. \e[01;31mDO NOT REBOOT OR CANCEL\e[00m...\n"

	# Need sudo privileges
	sudo echo >/dev/null

	# systemd-boot is not for Legacy boot. So we can't switch if the system doesn't use UEFI.
	if [ ! -d /sys/firmware/efi ]; then
		printf "YOUR SYSTEM DOESN'T USE EFI BOOT, cannot switch to systemd-boot.\n" >&2
		exit 2
	fi

	# Find some necessary packages
	if ! which blkid sed awk cut cat sudo grep kernel-install &>/dev/null; then
		printf "Missing required packages\n"
		exit 3
	fi

	# Prepare directory and make a backup of the /etc/fstab
	sudo mkdir /efi
	sudo cp /etc/fstab /etc/fstab-og

	# Get the UUID of the EFI partition
	for i in $(sudo blkid | grep EFI); do
		[[ "$i" == UUID* ]] && ID="$i"
	done
	ID=${ID//\"/}

	# Get the current mountpoint of the boot partition
	MOUNT=$(cat /etc/fstab | grep "$ID" | awk '{print $2}')

	# Move the partition to /efi only if it's not already there
	if ! [[ "$MOUNT" == '/efi' ]]; then
		printf "Moving boot partition, \e[01;31mDO NOT REBOOT OR CANCEL\e[00m...\n"
		PART=${MOUNT//\//\\/}                   # eg /boot/efi -> \/boot\/efi
		sudo sed -i "s/$PART/\/efi/" /etc/fstab # Edit fstab

		if [ $? -eq 0 ]; then
			sudo umount $MOUNT
			sudo mount /efi
		fi
	fi

	# Make directory for systemd-boot
	sudo mkdir /efi/$(cat /etc/machine-id); O=$?

	# Remove grub, grubby and shim
	printf "Removing grub, \e[01;31mDO NOT REBOOT OR CANCEL\e[00m...\n"
	[ $O -eq 0 ] && sudo rm /etc/dnf/protected.d/{grub*,shim*} && \
	sudo dnf remove -y grubby grub2* shim* memtest86* &>/dev/null && \
	sudo rm -rf /boot/grub2 && sudo rm -rf /boot/loader
	unset O

	# Install systemd-boot
	printf "Installing systemd-boot, \e[01;31mDO NOT REBOOT OR CANCEL\e[00m...\n"
	cut -d' ' -f2- /proc/cmdline | sudo tee /etc/kernel/cmdline >/dev/null
	sudo bootctl install 2>&1 | grep entry

	# Reinstall kernel
	printf "Reinstalling kernel, \e[01;31mDO NOT REBOOT OR CANCEL\e[00m...\n"
	sudo kernel-install add $(uname -r) /lib/modules/$(uname -r)/vmlinuz

	# Give notice the process is finished
	[ $? -eq 0 ] && printf "\e[01;32mSuccess!\e[00m it is now safe to reboot.\n"

else
	exit 1
fi

exit 0

# Exit codes:
# 0 - All good
# 1 - User canceled the switch
# 2 - System uses Legacy boot
# 3 - Missing package/s

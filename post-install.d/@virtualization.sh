# bash script to be sourced from fedora_setup.sh

STATE=ok

# Prepare config for user administration
sudo sed -i 's/^#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/g' /etc/libvirt/libvirtd.conf || STATE=bad

# Prepare the user for virtualization
sudo usermod -aG libvirt $USER       &>/dev/null || STATE=bad
sudo systemctl enable --now libvirtd &>/dev/null || STATE=bad

[ "$STATE" = "bad" ] && printf "ERROR preparing virtualization\n" >&2
unset STATE

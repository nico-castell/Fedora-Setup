# bash script to be sourced from fedora_setup.sh

# Prepare config for user administration
sudo sed -i 's/^#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/g' /etc/libvirt/libvirtd.conf

# Prepare the user for virtualization
sudo usermod -aG libvirt,qemu $USER
sudo systemctl enable --now libvirtd

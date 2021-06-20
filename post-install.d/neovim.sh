# bash script to be sourced from fedora_setup.sh

# Install a neovim init file
Separate 4
printf "Successfully installed \e[36mNeovim\e[00m, configuring...\n"

# Create config directories and name the file
LOCATION='.config/nvim'
mkdir -p "$HOME/$LOCATION"
sudo mkdir -p "/root/$LOCATION"
LOCATION="$LOCATION/init.vim"

cat "$script_location/samples/nvim.vim"                  | \
	sudo tee "/root/$LOCATION" "/root/$LOCATION-og"       | \
	tee "$HOME/$LOCATION" "$HOME/$LOCATION-og" >/dev/null

read -rp "$(printf "Do you want to make \e[01mneovim\e[00m the default \e[35m\$EDITOR\e[00m? (Y/n) ")" SWP

# Swap default editor
if [ "${SWP,,}" = "y" -o -z "$SWP" ]; then
	printf "Making \e[01mneovim\e[00m the new default editor...\n"
	sudo dnf remove nano-default-editor vim-default-editor -y --allowerasing >/dev/null

# .sh file
printf "# Ensure nvim is set as EDITOR if it isn't already set

if [ -z \"\$EDITOR\" ]; then
	export EDITOR=\"%s\"
fi\n" $(which nvim) | sudo tee /etc/profile.d/nvim-default-editor.sh >/dev/null

# .csh file
printf "# Ensure nvim is set as EDITOR if it isn't already set

if ( ! (\$?EDITOR) ) then
	setenv EDITOR \"%s\"
fi\n" $(which nvim) | sudo tee /etc/profile.d/nvim-default-editor.csh >/dev/null

fi

unset SWP LOCATION

# bash script to be sourced from fedora_setup.sh

# Copy .zshrc and offer to change default shell
Separate 4
printf "Successfully installed \e[36mzsh\e[00m, configuring...\n"

# Create .zshrc files
     [ ! -f ~/.zshrc ]     && cat "$script_location/samples/zshrc" | tee ~/.zshrc ~/.zshrc-og >/dev/null
sudo [ ! -f /root/.zshrc ] && cat "$script_location/samples/zshrc" | sudo tee /root/.zshrc /root/.zshrc-og >/dev/null

# Prepare powerline shell
sudo pip3 install powerline-shell &>/dev/null

if [ $? -eq 0 ]; then
	sed -i "s/# user_powerline/use_powerline/" ~/.zshrc
	sudo sed -i "s/# user_powerline/use_powerline/" /root/.zshrc

	mkdir -p ~/.config/powerline-shell
	sudo mkdir -p /root/.config/powerline-shell

	#region file
	FILE='{
"segments": [
	"virtual_env",
	"username",
	"hostname",
	"ssh",
	"cwd",
	"git",
	"hg",
	"jobs",
	"root"
	],
	"cwd": {
		"max_depth": 3
	}
}'
	#endregion
	printf "%s\n" "$FILE" | sudo tee /root/.config/powerline-shell/config.json | tee ~/.config/powerline-shell/config.json >/dev/null
	unset FILE
fi

# Ensure zsh aliases file exists
     [ -f ~/.zsh_aliases ] || printf "# zsh aliases file\n" |      tee ~/.zsh_aliases     >/dev/null
sudo [ -f ~/.zsh_aliases ] || printf "# zsh aliases file\n" | sudo tee /root/.zsh_aliases >/dev/null

read -rp "Do you want to make `tput setaf 6`Z-Shell`tput sgr0` your default shell? (Y/n) "
if [[ ${REPLY,,} == "y" ]] || [ -z $REPLY ]; then
	chsh -s $(which zsh)
	sudo chsh -s $(which zsh)
fi

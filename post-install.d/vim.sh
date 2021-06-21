# bash script to be sourced from fedora_setup.sh

# Install .vimrc
Separate 4
printf "Successfully installed \e[36mVim\e[00m, configuring...\n"
cat "$script_location/samples/vimrc"     | \
	sudo tee /root/.vimrc /root/.vimrc-og | \
	tee ~/.vimrc ~/.vimrc-og >/dev/null

read -rp "$(printf "Do you want to make \e[01mVim\e[00m the default \e[35m\$EDITOR\e[00m? (Y/n) ")" SWP
read -rp "$(printf "Do you want to use \e[01mpowerline\e[00m in vim? (Y/n) ")" PWL

# Swap default editor
if [ "${SWP,,}" = "y" -o -z "$SWP" ]; then
	swap_editor() {
		printf "Making \e[01mVim\e[00m the new default editor...\n"
		sudo dnf swap nano-default-editor vim-default-editor -y --allowerasing &>/dev/null
	}
	swap_editor &
fi

# Install powerline for vim
if [ "${PWL,,}" = "y" -o -z "$PWL" ]; then
	prepare_powerline() {
		printf "Installing \e[01mpowerline\e[00m for Vim...\n"
		sudo pip3 install powerline-status &>/dev/null && \
			printf "
if &term !=? 'linux'
	\" Disable dynamic statusline
	augroup statusline
		au!
	augroup end
	\" Powerline
	set rtp+=%s
	set laststatus=2
	set showtabline=1
	set noshowmode
	set t_Co=256
endif\n" "$(pip3 show powerline-status 2>/dev/null | grep Location | cut -d ' ' -f 2-)/powerline/bindings/vim" | \
	tee -a ~/.vimrc | sudo tee -a /root/.vimrc >/dev/null
	}
	prepare_powerline &
fi

# If neovim was also installed, write some code so the user can check the
# editor they're running
which nvim &>/dev/null && printf "
\" Simple check to see if you're in nvim or vim
function! Checkeditor()
	if has('nvim') | echo 'nvim' | else | echo 'vim' | endif
endfunction
command! Checkeditor call Checkeditor()\n" | \
	sudo tee -a "/root/.vimrc"              | \
	tee -a "$HOME/.vimrc" >/dev/null

# Wait for subprocesses to be over, and unset vars and functions to avoid contamination
wait
unset SWP PWL swap_editor prepare_powerline

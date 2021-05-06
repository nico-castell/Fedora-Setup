# Script to set up vscode

# WARNING: This script must be executed by running:
#    source "$script_location/vscode.sh"
# from fedora_setup.sh because it depends on variables declared in
# fedora_setup.sh

Separate 4
printf "Successfully installed \e[36mVisual Studio Code\e[00m, configuring...\n"
printf "Choose some developer tools to prepare:\n"

[[ ${TO_DNF[@]} == *"@development-tools"* ]] && LIST+=("Git with vscode")
[[ ${APPEND_DNF[@]} == *"nodejs"* ]]         && LIST+=("VS Code Extension development")

# Do not attempt to configure if no packages were installed
# (Safeguard in case someone tries to run this file without sourcing it properly)
if [ -n ${TO_DNF[@]} ] && [ -n ${APPEND_DNF[@]} ]; then
select c in "${LIST[@]}" exit; do
case $c in
	"Git with vscode")
	# Configure user to make commits.
	echo "Configure git:"
	read -p "What's your GitHub username? " USERNAME
	git config --global user.name "$USERNAME"
	read -p "What's your GitHub email? " EMAIL
	git config --global user.email "$EMAIL"

	read -p "What do you want to call the default branch? " DEF_BRANCH
	if [ ! -z $DEF_BRANCH ]; then
		git config --global init.defaultBranch "$DEF_BRANCH"
	fi
	unset USERNAME EMAIL DEF_BRANCH

	# Integrate vscode in some common Git operations.
	printf "Please, select a default editor for commit messages:\n"
	GIT_EDITORS+=("vscode")
	GIT_EDITORS+=("vim")
	GIT_EDITORS+=("nano")
	GIT_EDITORS+=("gedit")
	select GIT_EDITOR in ${GIT_EDITORS[@]}; do
	case $GIT_EDITOR in
		vim)    git config --global core.editor vim            ;;
		vscode) git config --global core.editor 'code --wait'  ;;
		nano)   git config --global core.editor nano           ;;
		gedit)  git config --global core.editor 'gedit -s'     ;;
		*) echo "Option $GIT_EDITOR not recognized."; continue ;;
	esac; break; done
	unset GIT_EDITOR GIT_EDITORS

	printf "Setting \e[01mVS Code\e[00m as the default merge tool...\n"
	git config --global merge.tool vscode
	git config --global mergetool.vscode.cmd 'code --wait $MERGED'
	git config --global diff.tool vscode
	git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'

	echo "Configuring pull behaviour..."
	git config --global pull.ff only

	# Set up aliases
	printf "Setting up some Git aliases...\n"
	git config --global alias.mrc '!git merge $1 && git commit -m "$2" --allow-empty && :'
	git config --global alias.flog "log --all --graph --oneline --format=format:'%C(bold yellow)%h%C(r) %an➜ %C(bold)%s%C(r) %C(auto)%d%C(r)\'"
	git config --global alias.sflog "log --all --graph --oneline --format=format:'%C(bold yellow)%h%C(r) §%C(bold green)%G?%C(r) %an➜ %C(bold)%s%C(r) %C(auto)%d%C(r)'"
	git config --global alias.slog 'log --show-signature -1'
	git config --global alias.mkst 'stash push -u'
	git config --global alias.popst 'stash pop "stash@{0}" -q'
	git config --global alias.unstage 'reset -q HEAD -- .'

	echo
	;;

	"VS Code Extension development")
	printf "Installing: \e[01myo generator-code vsce\e[00m...\n"
	Animate & PID=$!
	sudo npm install -g yo generator-code vsce >/dev/null
	kill $PID
	echo
	;;

	exit) break ;;
	*) echo "Option $c not recognized." ;;
esac
done
fi

unset LIST

# Script to set up vscode

# WARNING: This script must be executed by running:
#    source "$script_location/vscode.sh"
# from fedora_setup.sh because it depends on variables declared in
# fedora_setup.sh

[[ ${APPEND_DNF[@]} == *"nodejs"* ]] && LIST+=("VS Code Extension development")

# Do not run if the package is not being sourced
if [[ "$0" == *"vscode.sh" ]] && [ ! -z "$LIST" ]; then
Separate 4
printf "Successfully installed \e[36mVisual Studio Code\e[00m, configuring...\n"
printf "Choose some developer tools to prepare:\n"

select c in "${LIST[@]}" exit; do
case $c in
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

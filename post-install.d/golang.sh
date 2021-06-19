# bash script to be sourced from fedora_setup.sh

# Add Golang configs every user's profile
[ ! -f /etc/profile.d/golang.sh ] && \
	printf "# Configure Golang

[ -d /usr/local/go/bin ] && \\
	export PATH=\"/usr/local/go/bin:\$PATH\"

GOPATH=\"\$HOME/.local/golang\"

export GOPATH\n" | sudo tee /etc/profile.d/golang.sh >/dev/null

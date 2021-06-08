# bash script to be sourced from fedora_setup.sh

# Modify $GOPATH for the Z-Shell
mkdir -p ~/.zshrc.d && \
	printf "
# Configure Golang
# Find folder in case of custom installation
[ -d /usr/local/go/bin ] && \
	PATH=\"/usr/local/go/bin:\$PATH\"

# \$GOPATH and built binaries
export GOPATH=\"\$HOME/.local/golang\"
export PATH=\"\$GOPATH/bin:\$PATH\"\n" | tee -a ~/.zshrc.d/golang.sh >/dev/null

# Modifiy $GOPATH for the Bourne Again shell
mkdir -p ~/.bashrc.d && \
	printf "
# Configure Golang
# Find foler in case of custom installation
[ -d /usr/local/go/bin ] && \
	PATH=\"/usr/local/go/bin:\$PATH\"

# \$GOPATH and built binaries
export GOPATH=\"\$HOME/.local/golang\"
export PATH=\"\$GOPATH/bin:\$PATH\"\n" | tee ~/.bashrc.d/golang.sh >/dev/null

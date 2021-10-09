# Change log

All significant changes to **Fedora Setup** will be documented here.

- [Unreleased](#unreleased)
	- [Added](#added)
	- [Changed](#changed)
	- [Fixed](#fixed)
- [Released](#released)
	- [Version 2.2.0 - *2021-10-06*](#version-220---2021-10-06)
	- [Version 2.1.0 - *2021-07-15*](#version-210---2021-07-15)
	- [Version 2.0.0 - *2021-06-19*](#version-200---2021-06-19)
	- [Version 1.6.0 - *2021-06-11*](#version-160---2021-06-11)
	- [Version 1.5.0 - *2021-06-05*](#version-150---2021-06-05)
	- [Version 1.4.0 - *2021-06-02*](#version-140---2021-06-02)
	- [Version 1.3.0 - *2021-05-26*](#version-130---2021-05-26)
	- [Version 1.2.1 - *2021-05-18*](#version-121---2021-05-18)
	- [Version 1.2.0 - *2021-05-18*](#version-120---2021-05-18)

## Unreleased
### Added
- [.zshrc](samples/zshrc):
	- Added support for displaying tags in the git prompt.
- [packages.txt](packages.txt):
	- Added an option to install kernel development tools.
	- Added the Archive manager (file-roller).
- [kernel-devel.sh](post-install.d/kernel-devel.sh):
	- This script performs a few steps to get you running on kernel development.
- [kdev.sh](samples/kdev.sh):
	- This script has a few bash functions to help users when managing kernel config files.
### Changed
- [.bashrc](samples/bashrc):
	- Updated this file's git prompt, `ls` aliases and added `xterm-kitty` as a color terminal.
### Fixed
- [zsh.sh](post-install.d/zsh.sh):
	- The script now configures the chosen shell prompt for root too.
- [golang.sh](post-install.d/golang.sh):
	- The script now announces itself before asking questions (to avoid confusion).
- [kernel-devel.sh](post-install.d/kernel-devel.sh):
	- The script makes sure the directory `~/.local/bin` exists before writing a file in it.
- [@virtualization.sh](post-install.d/@virtualization.sh):
	- The file no longer puts the user in the *qemu* group as it's not necessary.

## Released
### Version [2.2.0](https://github.com/nico-castell/Fedora-Setup/releases/tag/2.2.0) - *2021-10-06*
This version comes after 27 commits and a **very** long time. However, it comes with **many**
improvements across the entire project. Some of the more important are:
- The main script now handles being run as root, previously there was no defined behaviour for this.
- The addition of the `remove.txt` file, allowing the user to remove potentially unwanted software.
- The use of `/etc/zshenv` to configure the **$PATH** for all users.
- Addition of Virtualization packages to `packages.txt` and a post-install script to allow the user
	to use virtual machines in a type 1 hypervisor, the previous options were type 2.
#### Added
- [fedora_setup.sh](fedora_setup.sh):
	- The script now stops if you run it as root, you should run it as your user. You can use the `-s`
		flag to override and run it as root, which is not tested, so it may cause problems.
	- The package `pxz` is now listed as essential and always installed.
	- Added a list of possible packages to remove, this helps clean some of the "bloat" Fedora that
		comes presintalled.
- [remove.txt](remove.txt):
	- This new file contains a list of preinstalled packages a user may want to remove.
- [packages.txt](packages.txt):
	- Some virtualization packages such as `@virtualization` and `bridge-utils` are now listed.
	- The Krita drawing software was added.
	- The chromium browser is now in the list.
	- Some fun terminal commands are now in the list (figlet, cowsay, fortune, etc)
- [@virtualization.sh](post-install.d/@virtualization.sh):
	- This file was added to configure virtualization for the user.
- [duc_noip_install.sh](scripts/duc_noip_install.sh):
	- Now, if you pass the `-s` flag to the script, it will set up a systemd service and a systemd
		timer so it runs every time you boot the computer.
	- If you run the script as root, the "supporting" files such as No-IP's icon and the desktop entry
		will be placed in `/usr/local` instead of `~/.local`.
	- The script now shows the status of the installation as *Success* or *Failed* when it finishes.
	- The script now writes an installation log to `/usr/local/src` to help system admins delete the
		program if they no longer need it.
- [mc_server_builder.sh](scripts/mc_server_builder.sh):
	- The `compress.sh` script written by this script now shows a progress percentage while creating
		backups of the server.
#### Changed
- [gnome_settings.sh](scripts/gnome_settings.sh):
	- The file now configures `gedit` in a lot more depth.
	- Changed zoom level for Nautilus's icon view.
	- The terminal and top bar configurations that were in
		[gnome_appearance.sh](scripts/gnome_appearance.sh) are now in this file.
- [gnome_appearance.sh](scripts/gnome_appearance.sh):
	- This file now has support for tarballs using different compression methods, such as `*.tar.xz`.
	- This script no longer configures the appearance of the gnome terminal or the top bar.
- [tlp.sh](post-install.d/tlp.sh):
	- The script now offers many more configuration choices for handling the lid switch.
	- The script now restarts the *systemd-logind* service after writing to the config file.
- [zsh.sh](post-install.d/zsh.sh):
	- The script now writes to `/etc/zshenv` code to add `~/.local/bin` to the $PATH for all users.
	- The script no longer uses `chsh` to change the user's default shell. It now uses `usermod`.
- [.zshrc](post-install.d/zshrc):
	- The file has a decorative header now
	- The file no longer modifies the $PATH. As that is now handled by `/etc/zshenv`.
- [fedora_setup.sh](fedora_setup.sh):
	- Use `cat <<EOF` instead of `printf "[..]" | tee"` to write to `dnf.conf`.
	- The script now sorts its package lists and removes duplicates before doing any operations.
- [systemdboot_switch.sh](scripts/systemdboot_switch.sh):
	- There were a few performance improvents in this script.
	- There's now a warning about using the script if you use separate partitions for /boot and
		/boot/efi.
#### Fixed
- [.zshrc](samples/zshrc):
	- The file no longer causes the Z-Shell to start showing an error code of 1.
- [init.vim](samples/nvim.vim):
	- Fixed error when interactively replacing text.
- [.vimrc](samples/vimrc):
	- Fixed error when interactively replacing text.
#### Removed
- [.zshrc](samples/zshrc):
	- The file no longer reads `~/.zsh_aliases`.
- [packages.txt](packages.txt):
	- Packages `python3-pip` and `util-linux-user` are no longer listed as part of **Z-Shell**.
#### Deprecated
- [mc_server_builder.sh](scripts/mc_server_builder.sh):
	- This script will be removed and replaced by an entirely separate repository, the project will
		aim to create the server as a systemd service that is easy to manage while providing better
		security.

### Version [2.1.0](https://github.com/nico-castell/Fedora-Setup/releases/tag/2.1.0) - *2021-07-15*
This update came after 29 commits, many more than usual, it focused mainly on the Vim editor, but there were many more changes:
- The configuration of **Vim** was heavily improved (specially the statusline) and **Neovim** was added with a similar config.
- The [mc_server_builder.sh](scripts/mc_server_builder.sh) script was reworked to be more stable (and updated to 1.17.1).
- There are two new flags available for the [back_me_up.sh](back_me_up.sh) script: `-r` and `-s`.
- The [sources.d](sources.d) folder was simplified by letting the main script handle setting up the sources, while the files in the folder just give it variables.
#### Added
- [fedora_setup.sh](fedora_setup.sh):
  - Added package [`rpmconf`](https://src.fedoraproject.org/rpms/rpmconf) to the list of *"essentials"*. It helps you manage configuration files after updating packages.
- [back_me_up.sh](back_me_up.sh):
  - Added `-r` flag, which tells the script to replace the latest backup.
  - Added `-s` flag, which tells the script to backup the `~/.safe` and `~/.ssh` folders.
- [golang.sh](post-install.d/golang.sh):
  - Added the choice to install development tools for Visual Studio Code.
- [packages.txt](packages.txt):
  - Added [Neovim](https://neovim.io/) package.
- [.zshrc](samples/zshrc):
  - Added `lz` and `llz` aliases to easily see SELinux tags when listing files.
- [nvim.vim](samples/nvim.vim):
  - Added a config file for neovim with many of the features of the current [.vimrc](samples/vimrc).
- [neovim.sh](post-install.d/neovim.sh):
  - Added file to let user configure **Neovim** after installing it.
  - Can write a special function to the config file to check which editor you're running when you also install **Vim**.
- [.vimrc](samples/vimrc):
  - A dynamic statusline for non-powerline vim editors. It changes based on wether the user is an active or inactive split.
  - Set a scroll-offset of 5 lines to keep your sight further from the edges of the screen.
  - Integrate with the system clipboard.
- [vim.sh](post-install.d/vim.sh):
  - Can write a special function to the config file to check which editor you're running when you also install **Neovim**.
- [git.sh](post-install.d/git.sh):
  - The new alias `eflog` will show a log of commits with commiter emails.
  - Now it can more deeply integrate editors such as **Vim** and **Neovim** with Git.
#### Changed
- [fedora_setup.sh](fedora_setup.sh):
  - Changed how extra sources are processed, making it a lot simpler to keep adding sources.
- [sources.d](sources.d):
  - Files are no longer "small" shellscripts, but *.txt* files that [fedora_setup.sh](fedora_setup.sh) sources to get the variables it has to process.
  - [fedora_setup.sh](fedora_setup.sh) will handle the configuration of each source, while the files in this folder just give it the required information.
- [mc_server_builder.sh](scripts/mc_server_builder.sh):
	- The script was heavily modified to make it more stable.
	- It no longer sets up the firewall by default.
	- Option `-mc` is now `-v` (for *visible*).
	- You now use the `-f` flag to tell the script to configure the firewall.
	- It no longer needs user assistance to delete firewall rules.
	- The download link is now at the top of the script for it to be easy to update.
	- There's a list of possible exit codes and their meanings.
- [.zshrc](samples/zshrc):
  - Use `awk` commands instead of combining `grep`, `rev` and `cut` for the git prompt. (Less subprocesses)
- [.vimrc](samples/vimrc):
  - Put backup, undo, and swap files in `~/.cache/vim`, and set their permissions so other users cannot read them.
  - Changed textwidth for *plain text* and *markdown* to 100 characters
  - Reconfigured some of the coloring to be more consistent on terminal and gui.
- [vim.sh](post-install.d/vim.sh):
  - Reworded some prompts to avoid confusion with neovim.
#### Fixed
- [mc_server_builder.sh](scripts/mc_server_builder.sh):
	- The animation does no longer lingers in your shell if you interrupt the script (*^C*).

### Version [2.0.0](https://github.com/nico-castell/Fedora-Setup/releases/tag/2.0.0) - *2021-06-19*
This version, while it doesn't bring much new, reworked an important step of the main script, the installation of **dnf repositories**, to be much more expandable than before, without requiring to edit the main script to modify the step. However, some small features were added, such as:
- New packages in the installation list.
- Line highlighting in Vim
- A post-install script to set up the GNOME Sdk
#### Added
- [sources.d](sources.d):
  - This folder will contain sources to be added before installing packages.
- [gnome-builder.sh](post-install.d/gnome-builder.sh):
  - Added the file, it gives the user a choice to install the **GNOME SDK** when **flatpak** was also installed.
- [packages.txt](packages.txt):
  - Added [Kitty Terminal](https://sw.kovidgoyal.net/kitty/), [Alacritty](https://github.com/alacritty/alacritty), and [Visual Studio Code Insiders](https://code.visualstudio.com/insiders/) packages.
- [.zshrc](samples/zshrc):
  - Added support for Kitty terminal.
- [.vimrc](samples/vimrc):
  - Added line highlighting.
#### Changed
- [fedora_setup.sh](fedora_setup.sh):
  - Changed methodology for adding repositories. Now the [sources.d](sources.d) folder contains the sources in files named according to the package that needs the source.
- [.zshrc](samples/zshrc):
  - The **vscode prompt** can now be chosen by assigning the value `vscode` to the `prompt_style` variable.
  - Made **vscode prompt** trigger when `$VSCODE_GIT_IPC_HANDLE` is set, instead of `"$VSCODE_TERM" == "yes"`. This means the user won't have to manually set the variable from the vscode settings.
  - The **user environment** section now edits the `$PATH` more carefully.
- [golang.sh](post-install.d/golang.sh):
  - Changed how we manipulate the `$PATH` environment variable.
#### Fixed
- [vim.sh](post-install.d/vim.sh):
  - Fixed root user not getting powerline when the user installs it.
- [.zshrc](samples/zshrc):
  - Fixed prompt starting with error code 1 when `~/.zsh_aliases` is missing.
- [fedora_setup.sh](fedora_setup.sh):
  - Fixed a typo in RPM Fusion nonfree
  - No longer reading an unused variable when installing user-selected packages.

### Version [1.6.0](https://github.com/nico-castell/Fedora-Setup/releases/tag/1.6.0) - *2021-06-11*
This version is made up of a few improvements, a rewritten script, and fixes. The most significant additions are:
- Added **Eclipse IDE** and **VS Codium** packages.
- Added **Golang** with a post-installation script to set up the `$GOPATH` to the `~/.local/golang` path.
- Improved and faster **git info in the prompt**.
- Rewriting of the **duc_noip_install.sh** script.
#### Added
- [packages.txt](packages.txt):
  - Added [**Eclipse IDE**](https://www.eclipse.org/downloads/) and [**VS Codium**](https://vscodium.com/).
  - Added support for [**Golang**](https://golang.org/), this required some modifications to the **Z-Shell** setup.
- [fedora_setup.sh](fedora_setup.sh):
  - Added **VS Codium** source.
- [.zshrc](samples/zshrc):
  - Added info about staged and untracked files in the git prompt.
  - Aliases and configs are now sourced from files under the `~/.zshrc.d` folder, as well as from a `~/.zsh_aliases` file.
- [.bashrc](samples/bashrc):
  - The improved git info for the prompt was brought to this file too.
- [back_me_up.sh](back_me_up.sh):
  - The scripts now also looks to back up the following folders and files: `~/.zshrc.d`, `~/.bashrc.d` and `~/.bash_aliases`.
#### Changed
- [duc_noip_install.sh](scripts/duc_noip_install.sh):
  - Rewrote the script to be much more reliable and simple to edit.
- [fedora_setup.sh](fedora_setup.sh):
  - Extra scripts are now executed through loops, this is much more expandable (and reliable) than the previous system.
  - Changed `true` and `false` for `yes` and `no` for compatibility with `test` command.
  - Renamed `load_tmp_file` variable to `load_choices_file` to avoid confusion.
- [vim.sh](post-install.d/vim.sh):
  - Switch from user installation of powerline-status to system installation.
- [zsh.sh](post-install.d/zsh.sh):
  - Switch from user installation of powerline-shell to system installation.
- [.zshrc](sapmles/zshrc):
  - Improved performance and eliminated edge cases for the git info.
- [packages.txt](packages.txt):
  - Separated **CMake** from **C/C++ development**.
#### Fixed
- [vim.sh](post-install.d/vim.sh):
  - Excessive arguments error.
- [zsh.sh](post-install.d/zsh.sh):
  - Missing space when prompting the user.
- [git.sh](post-install.d/git.sh):
  - Fixed faulty config for the vim editor.
- [fedora_setup.sh](fedora_setup.sh):
  - Fixed error in **RPM Fusion** setup.
  - Fixed errors when in the welcome message when running from a shallow git clone or the .git folder is missing.
#### Deprecated
- [.zshrc](samples/zshrc):
  - This file will continue sourcing the `~/.zsh_aliases` file, but it will be fully replaced by `~/.zshrc.d` in an upcoming release. Because of this, the `~/.zsh_aliases` file will no longer be automatically created.

### Version [1.5.0](https://github.com/nico-castell/Fedora-Setup/releases/tag/1.5.0) - *2021-06-05*
This is another minor version, the main update is the introduction of *powerline* for **Vim**, but there are other updates to the git setup and zsh prompts.
#### Added
- [.zshrc](samples/zshrc):
  - The ubuntu style prompt now has path shortening when deep in a directory structure.
  - Ubuntu and fedora style prompts now show a gear (`⚙`) when there are suspended jobs.
  - There is a new prompt style designed for Visual Studio Code, it's a very simple, modern looking prompt that remains easy to render by vscode's GPU accelerated prompt.
- [vim.sh](post-install.d/vim.sh):
  - Added a choice to install powerline-status plugin for vim.
- [git.sh](post-install.d/git.sh):
  - Added alias `now-ignored` to find files that should be untracked after updating `.gitignore`.
#### Changed
- [.zshrc](samples/zshrc):
  - The kali style prompt has new softer edges: `╭──` instead of `┌──`.
- [zsh.sh](post-install.d/zsh.sh):
  - Now the script will not attempt to install powerline automatically, instead, it will ask the user if they want to install it.
- [git.sh](post-install.d/git.sh):
  - Changed the order of operations.
  - Alias `unstage` now takes paths as arguments.

### Version [1.4.0](https://github.com/nico-castell/Fedora-Setup/releases/tag/1.4.0) - *2021-06-02*
It's a small release, the main additions are the prompt styles for **zsh** and styling for **vim**.
#### Added
- [.zshrc](samples/zshrc):
  - User can now choose a style by setting the `prompt_style` variable.
  - Now the paths `~/.locan/bin` and `~/bin` are added to the \$PATH.
- [zsh.sh](post-install.d/zsh.sh):
  - The user is now offered a choice between multiple prompt styles to use.
- [.vimrc](samples/vimrc):
  - The file now adds some light styling to the vim editor.
#### Changed
- [duc_noip_install.sh](scripts/duc_noip_install.sh):
  - Changed installation location.
#### Fixed
- [fedora_setup.sh](fedora_setup.sh):
  - Fixed $SYSTEMDBOOT_SWITCH not being loaded from the choices file.
- [.vimrc](samples/vimrc):
  - Fixed the statusline showing current line instead of total lines after the `/`.
- [back_me_up.sh](back_me_up.sh):
  - Fixed trying to keep less than one backup, set the minimum to 1.

### Version [1.3.0](https://github.com/nico-castell/Fedora-Setup/releases/tag/1.3.0) - *2021-05-26*
The main change is the rewriting of the [back_me_up.sh](back_me_up.sh) script. However, there were other changes, new features, and a few fixes.
#### Added
- [fedora_setup.sh](fedora_setup.sh):
  - dnf.conf now has `installonly_limit=3`.
- [git.sh](post-install.d/git.sh):
  - Now you can configure `gpg` to sign your commits.
- [packages.txt](packages.txt):
  - Added more packages
- [vim.sh](post-install.d/vim.sh):
  - Now the script prints to the console and can ask the user to change the default `$EDITOR`.
#### Changed
- [back_me_up.sh](back_me_up.sh):
  - Rewrote the script, now it's much simpler to read, and has the capacity to keep a certain number of backups, deleting the oldest ones as you make new ones.
  - Some edge cases where removed from it's main loop because they weren't really helpful
- [fedora_setup.sh](fedora_setup.sh):
  - `neofetch` and `vim` are no longer "essential" packages.
- [packages.txt](packages.txt):
  - Neofetch and Vim were added to the list
#### Fixed
- [nodejs.sh](post-install.d/nodejs.sh):
  - Fix noisy output when `code` isn't found.
- [zsh.sh](post-install.d/zsh.sh):
  - Fixed typo that would enable powerline-shell after successful installation.

### Version [1.2.1](https://github.com/nico-castell/Fedora-Setup/tree/1.2.1) - *2021-05-18*
#### Added
- [gnome_settings.sh](modules/gnome_settings.sh):
  - Added checks to see if the application to configure is installed.

### Version [1.2.0](https://github.com/nico-castell/Fedora-Setup/releases/tag/1.2.0) - *2021-05-18*
This is a cumulative release of many minor changes and fixes, along with one big change. The main change is the creation of the [post-install.d](post-install.d) directory, which separates the package setup phase from the main script, and simplifies development.
#### Added
- [post-install.d](post-install.d):
  - Created this directory to put all post-installation instructions in this folder. This is to avoid unnecessary complexity in [fedora_setup.sh](fedora_setup.sh).
- [fedora_setup.sh](fedora_setup.sh):
  - Added a check to find if required folders and/or files are missing.
#### Removed
- [fedora_setup.sh](fedora_setup.sh):
  - To avoid complexity, the post-instalation instructions were removed from this script, instead opting to source them from the new directory [post-install.d](post-install.d).
#### Changed
- [fedora_setup.sh](fedora_setup.sh):
  - Now RPM-Fusion Free and Non-Free are queued separately and installed once, this means the script won't install two sources without needing one of them.
- [packages.txt](packages.txt):
  - Organized packages by category.
- [.zshrc](samples/zshrc):
  - The prompt was made much more similar to Fedora's default prompt.
  - Many minor modifications were made
- [.bashrc](samples/bashrc):
  - The file was heavily modified to be similar to Fedora's default .bashrc with a few improvements.
#### Fixed
- [fedora_setup.sh](fedora_setup.sh):
  - Fixed error when writing to choices file, which would cause problems when reading from it.
  - Fixed script not exiting when failing to get sudo privileges.
- [git.sh](post-install.d/git.sh):
  - Fixed typo `namo` instead of `nano`.
- [tlp.sh](post-install.d/tlp.sh):
  - Fixed missing new-line.

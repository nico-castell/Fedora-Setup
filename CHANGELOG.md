# Change log

All significant changes to **Fedora Setup** will be documented here.

- [Released](#released)
	- [Version 2.5.0 - *2022-10-09*](#version-250---2022-10-09)
	- [Version 2.4.0 - *2021-11-21*](#version-240---2021-11-21)
	- [Version 2.3.0 - *2021-10-17*](#version-230---2021-10-17)
	- [Version 2.2.1 - *2021-10-08*](#version-221---2021-10-08)
	- [Version 2.2.0 - *2021-10-06*](#version-220---2021-10-06)
	- [Version 2.1.0 - *2021-07-15*](#version-210---2021-07-15)
	- [Version 2.0.0 - *2021-06-19*](#version-200---2021-06-19)
	- [Version 1.6.0 - *2021-06-11*](#version-160---2021-06-11)
	- [Version 1.5.0 - *2021-06-05*](#version-150---2021-06-05)
	- [Version 1.4.0 - *2021-06-02*](#version-140---2021-06-02)

## Released
### Version [2.5.0](https://github.com/nico-castell/Fedora-Setup/releases/tag/2.5.0) - *2022-10-09*
This is the longest I've ever taken to release a version. Highlights of this version include:
- gdm settings through [gnome_settings.sh](scripts/gnome_settings.sh).
- A few more packages to install
- Removed the clunky keybindings from [gnome_settings.sh](scripts/gnome_settings.sh).
#### Added
- [fedora_setup.sh](fedora_setup.sh):
	- Given that now some post-install.d processes use child subshells to run things in the
		background, a `wait` command was implemented in the final clean-up step so the user doesn't
		close the shell while some things are still running.
- [dnf.conf](dnf.samples/dnf.conf):
	- This file's contents were previously held in the *fedora_setup.sh* script, but are now held in
		this sample file to simplify code maintainability.
- [gnome_settings.sh](scripts/gnome_settings.sh):
	- The script now configures the new GNOME Text Editor.
	- The script can now configure gdm via the */etc/dconf/db/gdm.d/10-settins.ini* file.
- [packages.txt](packages.txt):
	- Added RPM Packaging in the development category.
	- Added Transmission and Fragments in the Network category.
	- Added GNOME Web (epiphany) in the Network category.
	- Added Evolution in the Office category.
	- Added GNOME Console in the Utilities category.
- [remove.txt](remove.txt):
	- Added GNOME_Help to the list.
#### Changed
- [fedora_setup.sh](fedora_setup.sh):
	- There were many "behind the scenes" performance optimizations. Including the optimization of
		the `Separate` function, the parallelization of some tasks and simplfying some commands.
	- The contents of dnf.conf are now held in a sample file, instead of in the script.
- [post-install.d](post-install.d):
	- Many of the files now use child subshells `( .. ) &` to speed up the setup by running some
		things in the background.
- [packages.txt](packages.txt):
	- **Development Tools** no longer lists git and git-lfs for installation, as now they have their
		own entry in the list.
	- **GNOME Builder** no longers installs gnome-software-devel.
	- **Kernel development** no longer lists rpm-build as RPM Packaging is now its own entry in the
		list.
- [sources.d](sources.d):
	- Some of the .repo files generated from the info in this folder will now use `$basearch` in dnf
		to show the architecture being used.
- [git.sh](post-intall.d/git.sh):
	- The alias `slog` now does not specify the number of commits to show, now the user can specify
		how many commits they want to show.
	- The `now-ignored` alias was renamed to `list-ignored` because the keyword list better explains
	  what the alias does.
	- The placeholders for all `log --format` aliases were updated to use *%C(auto)* instead of
		*%C(r)*.
	- The alias `list-ignored` now uses the option `-o` because of an update to git.
- [.zshrc](samples/zshrc):
	- Changed the way coloring works for all the ls aliases. `ls` itselft is now aliased to `ls -BhF
	  --group-directories-first`, *raw* ls can still be used in the shell by typing `\ls`.
- [zsh.sh](post-install.d/zsh.sh):
	- The script now makes a copy of *.zshrc* in */etc/skel/.zshrc*.
	- The script now configures useradd to use zsh as the default shell when the user changes their
		default shell to zsh.
- [init.vim](samples/nvim.vim):
	- The filetype *gitcommit* was added to an autocommand group to display colorcolumns at columns
	  50 and 70 to help keep git commit messages at a reasonable length.
	- The color of the mode in the statusline was changed to blue.
	- Allow neovim to use the guicursor.
- [.vimrc](samples/vimrc):
	- The filetype *gitcommit* was added to an autocommand group to display colorcolumns at columns
	  50 and 70 to help keep git commit messages at a reasonable length.
	- The color of the mode in the statusline was changed to blue.
- [packages.txt](packages.txt):
	- Removed Git from the Development category since it comes preinstalled.
	- Meson and Ninja Build now come together.
- [back_me_up.sh](back_me_up.sh):
	- The script was updated to be able to handle drives in */run/media/user* as well as in */media*.
	- The script now syncs the drive to make unmounting it after using the script faster.
- [mc_server_builder.sh](scripts/mc_server_builder.sh):
	- The version was updated to 1.19.2.
#### Fixed
- [fedora_setup.sh](fedora_setup.sh):
	- The script now doesn't miss the *install upgrades* step because of extra steps between checking
		for upgrades and prompting the user to install them.
- [zsh.sh](post-install.d):
	- Use the script to fix the way */etc/zprofile* handles */etc/profile.d*.
- [flatpak.sh](flatpak.sh):
	- The user remote installation was fixed, it used sudo to install flathub for the user which
	  resulted in root getting a user remote, instead of the current user.
- [gnome_settings.sh](scripts/gnome_settings.sh):
	- Removed the keybindings configurations as they were rather clunky.
	- GNOME Terminal is no longer configured twice.
#### Removed
- **ufw.sh**:
	- The script was removed because it wasn't used.
- [git.sh](post-intall.d/git.sh):
	- The alias `mrc` was removed because it is only useful in very rare situations.

### Version [2.4.0](https://github.com/nico-castell/Fedora-Setup/releases/tag/2.4.0) - *2021-11-21*
This release comes after 28 commits, and it is as extensive as it seems. These were the points of
focus for this version:
- Fixing bugs,
- improving (slightly) code maintainabilty,
- correcting outdated comments, and most notably:
- **categorizing the dnf packages** so the user can now choose to skip an entire software category
	when selecting packages to install, and
- **taking into account the grub config** when swithching to systemdboot.
#### Added
- [systemdboot_switch.sh](scripts/systemdboot_switch.sh):
	- The file can now process the grub config at `/etc/default/grub` and use some of it for
		systemd-boot.
	- The file now checks the partition table to see if there are multiple partition mounpoints under
		`/boot`, such as `/boot` and `/boot/efi`. If there are, the script will exit before making a
		mess.
- [init.vim](samples/nvim.vim):
	- The file type *limits* was added to use tabs with a length of 8.
- [.vimrc](samples/vimrc):
	- The file type *limits* was added to use tabs with a length of 8.
- [remove.txt](remove.txt):
	- Added *Document Scanner* to the list.
- [back_me_up.sh](back_me_up.sh):
	- Added a notification to signal when the backup is finished.
	- It now backs up the `~/.gitconfig` file.
#### Changed
- [fedora_setup.sh](fedora_setup.sh):
	- The way the *packages.txt* file is processed has changed, the user can now skip certain
		categories of software.
	- The loops that process *remove.txt* and *packages.txt* were optimized using a file in memory
		(in `/tmp`) and this file is protected using umask and chmod during operation.
- [packages.txt](packages.txt):
	- The format of the file was changed:
		1. Lines that are not indented represent categories
		2. Indented lines represent apps
		3. Indented lines belong to the category above them
		4. Indented lines must use a hard tab for indentation
- [.zshrc](samples/zshrc):
	- The code for the git prompt was changed to be much faster by using zsh's *vcs_info*. This means
		less functionality, but much less code to run every time the prompt needs to be renderes.
	- The shell can now detect when it is running inside GNOME Builder, and use the vscode prompt.
	- The `la` alias now groups folders first.
	- Made many other tweaks to improve code maintainability and speed.
- [.bashrc](samples/bashrc):
	- The `la` alias now groups folders first.
#### Fixed
- [flatpak.sh](post-install.d/flatpak.sh):
	- The file now sets up the flathub remote for both system and user, this fixes errors when
	  installing the GNOME Builder SDK.
- [kdev.sh](samples/kdev.sh):
	- Stop assuming the user's *cwd* when using `kdev config`.
	- Fixed `kdev config` failing to find the config type currently in use.
	- Kdev clean (on level 4) now also removes directories.
- [init.vim](samples/nvim.vim):
	- Fixed local settings that lingered when changing filetype from markdown, text, or limits to
	  anything else.
- [.vimrc](samples/vimrc):
	- Fixed local settings that lingered when changing filetype from markdown, text, or limits to
	  anything else.

### Version [2.3.0](https://github.com/nico-castell/Fedora-Setup/releases/tag/2.3.0) - *2021-10-17*
This is a small release made in parity with the
[PopOS Setup](https://github.com/nico-castell/PopOS-Setup) project to syncronize changes to this
date.
#### Changed
- [fedora_setup.sh](fedora_setup.sh):
	- The `dnf.conf` file written by this script is now configured to avoid installing weak
		dependencies.
- [gnome_apperance.sh](scripts/gnome_appearance.sh):
	- The script now installs the themes and icons in `~/.local/share` instead of `~/.themes` or
		`~/.icons`.
- [systemdboot_switch.sh](scripts/systemdboot_switch.sh):
	- Tweaked the file to give a little more info to the user and be more maintainable.
- [kdev.sh](samples/kdev.sh):
	- The script's *config* function was updated to avoid modifying the Makefile as that could
		trigger unnecessary complete recompiles of the kernel.
- [.zshrc](samples/zshrc):
	- Tweaked the final character of the vscode prompt.
#### Fixed
- [fedora_setup.sh](fedora_setup.sh):
	- Fixed essential packages being forgotten after loading choices from the temporary file.
	- Fixed an unnecessary call to the *Separate* function.
- [.zshrc](samples/zshrc):
	- The git prompt now doesn't dissapear if you're not in the root folder of a repository.
- [.bashrc](samples/bashrc):
	- The git prompt now doesn't dissapear if you're not in the root folder of a repository.

### Version [2.2.1](https://github.com/nico-castell/Fedora-Setup/releases/tag/2.2.1) - *2021-10-08*
This is a small release, it is meant to complete version 2.2.0. These features were planned for it
but I wanted to make a release even if it wasn't 101% ready. The main changes are:
- Added kernel development tools to the list of programs to install.
- Caught up the *.bashrc* with the *.zshrc*.
- Fixed a few errors.
#### Added
- [.zshrc](samples/zshrc):
	- Added support for displaying tags in the git prompt.
- [packages.txt](packages.txt):
	- Added an option to install kernel development tools.
	- Added the Archive manager (file-roller).
- [kernel-devel.sh](post-install.d/kernel-devel.sh):
	- This script performs a few steps to get you running on kernel development.
- [kdev.sh](samples/kdev.sh):
	- This script has a few bash functions to help users when managing kernel config files.
#### Changed
- [.bashrc](samples/bashrc):
	- Updated this file's git prompt, `ls` aliases and added `xterm-kitty` as a color terminal.
#### Fixed
- [zsh.sh](post-install.d/zsh.sh):
	- The script now configures the chosen shell prompt for root too.
- [golang.sh](post-install.d/golang.sh):
	- The script now announces itself before asking questions (to avoid confusion).
- [kernel-devel.sh](post-install.d/kernel-devel.sh):
	- The script makes sure the directory `~/.local/bin` exists before writing a file in it.
- [@virtualization.sh](post-install.d/@virtualization.sh):
	- The file no longer puts the user in the *qemu* group as it's not necessary.

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

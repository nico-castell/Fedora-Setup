# Change log

All significant changes to **Fedora Setup** will be documented here.

- [Unreleased](#unreleased)
  - [Changed](#changed)
  - [Fixed](#fixed)
- [Released](#released)
  - [Version 1.6.0 - *2021-06-11*](#version-160---2021-06-11)
  - [Version 1.5.0 - *2021-06-05*](#version-150---2021-06-05)
  - [Version 1.4.0 - *2021-06-02*](#version-140---2021-06-02)
  - [Version 1.3.0 - *2021-05-26*](#version-130---2021-05-26)
  - [Version 1.2.1 - *2021-05-18*](#version-121---2021-05-18)
  - [Version 1.2.0 - *2021-05-18*](#version-120---2021-05-18)
  - [Version 1.1.0 - *2021-05-12*](#version-110---2021-05-12)
  - [Version 1.0.0 - *2021-05-06*](#version-100---2021-05-06)
- [Pre releases](#pre-releases)
  - [Version 0.0.2 - *2021-05-04*](#version-002---2021-05-04)
  - [Version 0.0.1 - *2021-05-03*](#version-001---2021-05-03)

## Unreleased
### Changed
- [.zshrc](samples/zshrc):
  - The **vscode prompt** can now be chosen by assigning the value `vscode` to the `prompt_style` variable.
  - Made **vscode prompt** trigger when `$VSCODE_GIT_IPC_HANDLE` is set, instead of `"$VSCODE_TERM" == "yes"`. This means the user won't have to manually set the variable from the vscode settings.
### Fixed
- [.zshrc](samples/zshrc):
  - Fixed prompt starting with error code 1 when `~/.zsh_aliases` is missing.

## Released
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

### Version [1.1.0](https://github.com/nico-castell/Fedora-Setup/releases/tag/1.1.0) - *2021-05-12*
The variable APPEND_DNF was removed, along with **vscode.sh**. The instructions of vscode.sh were added to [fedora_setup.sh](fedora_setup.sh). Also, a few packages were added to [packages.txt](packages.txt).
#### Added
- [fedora_setup.sh](fedora_setup.sh):
  - The script now sets the BIOS time to UTC.
  - The script now configures [Flathub](https://flathub.org/home) as a flatpak remote, then removes Fedora's remotes.
  - Git configuration and vscode extension development are now part of this file
- [geary-autostart.desktop](deskcuts/geary-autostart.desktop):
  - Added deskcut to autostart geary service when logging in.
- [packages.txt](packages.txt):
  - Added `gnome-extensions-app` to be installed along with `gnome-tweaks`.
  - .NET 5.0 and 3.1 are now listed in this file
#### Fixed
- [packages.txt](packages.txt):
  - Added missing depedencies of VirtualBox.
#### Removed
- [fedora_setup.sh](fedora_setup.sh):
  - Removed `APPEND_DNF` as it is no longer useful
- **vscode.sh**:
  - The file was removed because it was no longer useful.

### Version [1.0.0](https://github.com/nico-castell/Fedora-Setup/releases/tag/1.0.0) - *2021-05-06*
This version introduces mainly a new way to load packages from [packages.txt](packages.txt), and a module to switch to systemd-boot. But the majority of the work was debugging.
#### Added
- [systemdboot_switch.sh](modules/systemdboot_switch.sh):
  - This new module can switch Fedora's bootloader from **grub** to **systemd-boot**.
- [fedora_setup.sh](fedora_setup.sh):
  - Introduced a new way of loading and selecting packages. The user can now see the name of the app eg **Z-Shell**, confirm the package, and load multiple packages, eg **zsh zsh-autosuggestions \+**.
  - The script now announces that it has finished.
- [packages.txt](packages.txt):
  - Some new packages were added, such as **C/C++**, **GNOME Boxes**, and more.
#### Changed
- [packages.txt](packages.txt):
  - Given the new way fedora_setup.sh loads packages, packages.txt was given a new structure to accomodate this by using spaces as delimiters between the name the user sees and the packages selected. Addinionally this means APPEND_DNF is not as useful now.
- [fedora_setup.sh](fedora_setup.sh):
  - When the user chooses to upgrade, `dnf` will assume yes, instead of prompting for confirmation, again.
  - PackageKit is now restarted *after* running the modules.
- [vscode.sh](vscode.sh):
  - Updated git aliases `flog` and `sflog`.
- [gnome_extensions.sh](modules/gnome_extensions.sh):
  - xdg-open was silenced
- [gnome_settings.hs](modules/gnome_settings.sh):
  - `favorite-apps` config was deleted, and a few other settings were regrouped.
#### Removed
- [fedora_setup.sh](fedora_setup.sh):
  - Given the new way packages are loaded, the following were removed, in favor of loading them when the user selects their package (TO_DNF):
    - **C/C++** was removed from APPEND_DNF when choosing packages to append to Visual Studio Code.
    - **zsh** and **@development-tools** no longer contribute to APPEND_DNF.
#### Fixed
- **NOTE:** The project was tested on a VM to find and fix errors.
- [mc_server_builder.sh](modules/mc_server_builder.sh):
  - The location of the image file was fixed.
- [fedora_setup.sh](fedora_setup.sh):
  - The output was cleaned up.
  - Modules are now running properly.
  - Fixed backing up files such as *.bashrc*, *.clang-format*, *.zshrc*, *.vimrc*.
  - Fixed Brave Browser source config outputting the .repo file to the console.
  - Many syntax errors were fixed.
- [vscode.sh](vscode.sh):
  - Fixed how the script would offer configurations even if it wasn't sourced properly.

## Pre releases

### Version [0.0.2](https://github.com/nico-castell/Fedora-Setup/tree/0.0.2) - *2021-05-04*
#### Added
- [back_me_up.sh](back_me_up.sh):
  - Support for Fedora auto-mounting directory.
- [fedora_setup.sh](fedora_setup.sh):
  - Now the .zsh_aliases file for the root user will be created automatically.
#### Changed
- [.vimrc](samples/vimrc):
  - Configure statusline in just one line
  - Store backup, undo, and swap files in a centralized ~/.vimdata directory.
- [fedora_setup.sh](fedora_setup.sh):
  - New method to obtain the latest git tag.
  - Removed `mkdir` commands for vim setup, the .vimrc file can now do it itself.
  - Improved the configuration of the dnf.conf file.
#### Fixed
- [fedora_setup.sh](fedora_setup.sh):
  - Fixed a few typos.
  - Fixed wrongly named brave browser gpg key.
#### Removed
- [mc_server_builder.sh](modules/mc_server_builder.sh):
  - Removed `update-desktop-database` commands as these commands don't run on Wayland.

### Version [0.0.1](https://github.com/nico-castell/Fedora-Setup/tree/0.0.1) - *2021-05-03*
This project is a heavily reworked version of [Pop!_OS Setup](https://github.com/nico-castell/PopOS-Setup), adapted to work in [Fedora](https://getfedora.org/en/workstation/download/).

# Change log

All significant changes to **Fedora Setup** will be documented here.

- [Unreleased](#unreleased)
  - [Added](#added)
  - [Fixed](#fixed)
- [Released](#released)
  - [Version 1.0.0 - *2021-05-06*](#version-100---2021-05-06)
- [Pre releases](#pre-releases)
  - [Version 0.0.2 - *2021-05-04*](#version-002---2021-05-04)
  - [Version 0.0.1 - *2021-05-03*](#version-001---2021-05-03)

## Unreleased
### Added
- [fedora_setup.sh](fedora_setup.sh):
  - The script now sets the BIOS time to UTC.
### Fixed
- [packages.txt](packages.txt):
  - Added missing depedencies of VirtualBox.

## Released

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

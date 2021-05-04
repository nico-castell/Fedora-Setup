# Change log

All significant changes to **Fedora Setup** will be documented here.

- [Unreleased](#unreleased)
  - [Added](#added)
  - [Changed](#changed)
  - [Fixed](#fixed)
  - [Removed](#removed)
- [Pre releases](#pre-releases)
  - [Version 0.0.1 - *2021-05-03*](#version-001---2021-05-03)

## Unreleased
### Added
- [back_me_up.sh](back_me_up.sh):
  - Support for Fedora auto-mounting directory.
- [fedora_setup.sh](fedora_setup.sh):
  - Now the .zsh_aliases file for the root user will be created automatically.
### Changed
- [.vimrc](samples/vimrc):
  - Configure statusline in just one line
  - Store backup, undo, and swap files in a centralized ~/.vimdata directory.
- [fedora_setup.sh](fedora_setup.sh):
  - New method to obtain the latest git tag.
  - Removed `mkdir` commands for vim setup, the .vimrc file can now do it itself.
  - Improved the configuration of the dnf.conf file.
### Fixed
- [fedora_setup.sh](fedora_setup.sh):
  - Fixed a few typos.
  - Fixed wrongly named brave browser gpg key.
### Removed
- [mc_server_builder.sh](modules/mc_server_builder.sh):
  - Removed `update-desktop-database` commands as these commands don't run on Wayland.

## Pre releases

### Version [0.0.1](https://github.com/nico-castell/Fedora-Setup/tree/0.0.1) - *2021-05-03*
This project is a heavily reworked version of [Pop!_OS Setup](https://github.com/nico-castell/PopOS-Setup), adapted to work in [Fedora](https://getfedora.org/en/workstation/download/).

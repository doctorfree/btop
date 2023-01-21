## Table of contents

1. [Overview](#overview)
1. [Installation](#installation)
    1. [Arch Linux based installation](#arch-linux-based-installation)
    1. [Debian based installation](#debian-based-installation)
    1. [RPM based installation](#rpm-based-installation)
    1. [Manual installation](#manual-installation)
1. [Configuration](#configuration)
1. [Usage](#usage)
1. [Removal](#removal)
1. [Changelog](#changelog)

## Overview

Btop version 1.2.13 release 1 adds support for Arch-like platforms (e.g. Manjaro Linux)

## Installation

Download the [latest Arch, Debian, or RPM package format release](https://github.com/doctorfree/btop/releases) for your platform. If your platform does not support Arch, Debian, or RPM format installs then download the compressed binary distribution archive for your platform and the `Install-bin.sh` script. On macOS use `brew install btop` and `brew link --overwrite btop` to install btop.

### Arch Linux based installation

Install the package on Arch Linux based systems by executing the command:

```shell
sudo pacman -U ./btop_1.2.13-1-x86_64.pkg.tar.zst
```

### Debian based installation

Install the package on Debian based systems by executing the commands:

```shell
sudo apt update -y
sudo apt install ./btop_1.2.13-1.amd64.deb
```

or, on a Raspberry Pi:

```shell
sudo apt update -y
sudo apt install ./btop_1.2.13-1.armhf.deb
```

### RPM based installation

Install the package on RPM based systems by executing the command
```shell
sudo dnf update -y
sudo dnf localinstall ./btop-1.2.13-1.x86_64.rpm
```

### Manual installation

On systems for which the Arch, Debian, or RPM packages will not suffice, install manually by downloading the `Install-bin.sh` script and either the gzip'd distribution archive or the zip'd distribution archive.  After downloading the installation script and distribution archive, as a user with sudo privilege execute the commands:

```shell
chmod 755 Install-bin.sh
sudo ./Install-bin.sh /path/to/btop_1.2.13-1.<arch>.tgz
or
sudo ./Install-bin.sh /path/to/btop_1.2.13-1.<arch>.zip
```

## Usage

Execute `man btop` to view the *btop* manual page. Explore the features and capabilities of *btop* by running it in interactive menu mode with the command:

```console
btop
```

## Removal

Removal of the package on Arch Linux based systems can be accomplished by issuing the command:

```shell
sudo pacman -Rs btop
```

Removal of the package on Debian based systems can be accomplished by issuing the command:

```shell
sudo apt remove btop
```

Removal of the package on RPM based systems can be accomplished by issuing the command:

```shell
sudo dnf remove btop
```

On systems for which the manual installation was performed using the `Install-bin.sh` script, remove Btop manually by downloading the `Uninstall-bin.sh` script and, as a user with sudo privilege, execute the commands:

```shell
chmod 755 Uninstall-bin.sh
sudo ./Uninstall-bin.sh
```

On macOS removal can be performed with `brew uninstall btop`

## Changelog

Version 1.2.13 release 1 adds support for:

* Arch-like platforms (e.g. Manjaro Linux)
* Fixes remote Arch package installations in `ascinit`
* Manual installation location moved from `/usr` to `/usr/local`
* Update `btop` to version 1.2.13

See [CHANGELOG.md](https://github.com/doctorfree/btop/blob/master/CHANGELOG.md) for a full list of changes in every Btop release

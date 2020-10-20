# Welcome to grizzarch

`grizzarch` is my personal arch distro, and an enternal WIP. 

If you're here, you're probably a friend (unless I decided to open-source this for some reason).

## Philosophy

The philosophy of my arch build is "default first". In most cases, I find that the defaults exist for a reason, so until/unless I have a specific need/desire for something that isn't provided with the default option, we go with what is standard. 

With an Arch distro, there isn't much that comes standard. There are a lot of components that come with `systemd`, however, and that's what I'm using for the majority of this build.

**NOTE:** CHANGE THE LUKS AND USER PASSWORD AFTER YOU'VE IMPORTED THE VHD. CONSIDER THE DEFAULT PASSWORDS TO BE INSECURE AFTER INITIAL INSTALL. 

[We'll come back to the passwords later on in the readme](#Important-notes-about-security)

## "Finished" elements

- [GRUB bootloader](https://wiki.archlinux.org/index.php/GRUB) using UEFI (with `--removable` so the `.ovf` out the other side is bootable)

- [LVM on LUKS encryption](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS)

- [systemd](https://wiki.archlinux.org/index.php/Systemd) (including [networkd](https://wiki.archlinux.org/index.php/Systemd-networkd) and [resolved](https://wiki.archlinux.org/index.php/Systemd-resolved))

- [i3](https://i3wm.org/) with custom i3status config

- [termite](https://wiki.archlinux.org/index.php/Termite) with custom config

- Default user config is copied to /etc/skel_grizzarch/ so new users inherit the starting customizations. The default /etc/skel/ is left intact.

## Future plans

- [Steam](https://wiki.archlinux.org/index.php/Steam) + [Proton](https://github.com/ValveSoftware/Proton/)
- [Android Studio](https://wiki.archlinux.org/index.php/Android#Android_Studio)
- plug-and-play `/home/$USER` directory on separate VHD
- [ARCHISO](https://wiki.archlinux.org/index.php/Archiso) image to be able to install this arch image to physical hardware from a flash drive
- Other cool projects, as I think of them :) 

# Decisions

- Decided against including XDG default folders. I'm pretty particular about how my home directory is organized, so defaults usually just annoy me.

## Build system

This project uses [Packer](https://www.packer.io/) to generate the images.

To initiate a build:

`packer build ./arch.json`

Packer does a lot of heavy-lifting for us. It creates a simple web server so we can `curl` scripts into the live environment easily. It orchestrates the entire process, from ARCHISO intial boot, to copying config files for more complex pieces of software like `i3wm` or `systemd`. 

However, in order to stay as portable as possible, all of the actual configuration work is done in old-fashioned conf files and bash scripts, so that with (theoretically) minimal effort, this arch build could also be done by running the existing scripts in order, without the need for `Packer`. I've documented a lot of the scripts, and have tried to make everything as "self-documented" as possible for the areas I couldn't be bothered to write about.

### http/

The `http/` directory holds all of the files that need to be downloaded to the machine using `curl`. This is mostly for files that are required in the live environment, but any file that needs to be added before `ssh` is set up should go here.

### ssh/

The `ssh/` directory is for files that will be added after `ssh` has been set up on the VM. This should be most of the software configuration, application installs, and user preference customizations that a user would normally do after the inital bootstrap of a new Arch install anyway.

### .gitignore

Check out the comments in my [.gitignore file](.gitignore) for some built-in quality-of-life directory exclusions that'll prevent accidental VHD commits.




## Important notes about security

**The default user, user password, and encryption password are in the variables section of the packer template json, called:**

`arch_user`

`arch_pass`

`encryption_pass`

Regardless of how you customize the passwords for the build, please change them after you've gotten settled in your grizzarch install.

[Unix SE question on changing LUKS authentication](https://unix.stackexchange.com/questions/252672/how-do-i-change-a-luks-password)

Use `passwd` to change the user password.

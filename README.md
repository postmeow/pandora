
An early boot initram Linux operating system.
Loads straight into /init file without going through an init system.
Bootstrapped with alpine-latest-stable.

As an initram is usually being used as an emergency console in other distributions,
Pandora aims to be a fully fledged environment. Most of the boot media is allocated
for kernel modules for broad hardware support. 

The initramfs is decompressed into RAM to tmpfs with a selection of packages.

Additional packages can be added to the bootstrap script that makes pandora.

User configuration, home directories or packages are mounted from persistent storage when available. 
The root filesystem however remains tmpfs and files are mounted on top. 

Optional storage is scanned and mounted to `/mnt/$DEV` and utilized if `pandora/.pandora-loader` is found.
```
/mnt/vda # mounted from /dev/vda
└── pandora
    ├── .pandora-loader # empty trigger file for pandora detection
    ├── etc
    │   └── ssh # is mounted to /etc/ssh when found or any other etc dir
    │       ├── moduli
    │       ├── ssh_config
    │       ├── ssh_config.d
    │       ├── ssh_host_key
    │       └── sshd_config
    ├── home 
    │   └── meow # is mounted to /home/meow when found or any other home dir
    │       └── project
    │           └── README.md
    ├── init # executable file run on boot based on shebang when found
    └── swap # swapfile enabled on boot when found
```
There are no daemons running from the initial init and should started manually or from
the persistent storage init file.

Pandora aims to be feature rich without complex abstractions seen in modern Linux for simplicty and performance.
It comes with no warranty and is an experimental testbed for a different approach.

The bootstrap consists of a few files that retrieves alpine packages, pandora specifics and creates the ISO

```
.
├── README.md
└── bootstrap
    ├── mkpandora.sh # main script. outputs cd.iso
    ├── pkg_install.sh # ./pkg_install.sh pkgname dest/ retrieves apk package from alpine latest and extracts to dest
    └── pkg_search.sh # ./pkg_search.sh pkgname searches for apk package by name frmo alpine latest and returns name
```

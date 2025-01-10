A Linux distribution.
Bootstrapped with alpine-latest-stable.

Boot ASAP in readonly RAM. 
Claim given resources such as optional local or remote storage. 
Spawn containers or virtual machine in RAM or persistent storage.
Aims to be zero config with simplicity in mind.

dev branch. commit progress here.

./mktest/init

main script. launches qemu instance with serial console and generates fresh pandora iso with mkiso.

./mkiso/init 

creates pandora iso and echos path to iso. prepares initram with mkinitram and rootfile system with mkrootfs.
a minimal kernel is copied that will only boot with qemu scsi, virtio and bochs-drm framebuffer support.
 
./mkrootfs/init $rootfsFilename

create rootfs sparse filesystem named rootfsFilename.
uses mkapkchroot to populate filesystem with a set of apk packages. 
includes apk (alpine linux package manager), debootstrap for creating Debian like chroots, qemu for launching virtual machines
and the dora userspace management script for interfacing with pandora.

./mkinitram $initramName

create minimal initram for early boot and echos path to archive. its important to keep the initram small as boot time increases by nature.
uses mkapkchroot to populate the file system with an init that switches root made by mkrootfs.

./mkapkchroot/init $chrootname "$apkPackage1 $apkPackage2"

creates a chrootable or swap root directory named $chrootname and installs given APK packages into chroot.

The boot process:

syslinux launches a stripped qemu kernel with scsi and virtio support with a minimal initram.
the initram has a /sbin/init shell script that mounts the rootfs on the iso.
the root is switched to the rootfs in readonly mode as its a sparse filesystem on the iso. the /proc, /dev are mounted with tmpfs and populated kernel mounts.
If existing local storage is encountered and detected as previously used pandora storage will be setup as used before.
If empty local storage is encountered it will be claimed.
Networking DHCP is started with sshd and a framebuffer, nothing else. At this point less than 30 Mb of RAM is claimed and ready for operation.

the dora tool supplied in the rootfs can be used for the actual operations after boot.

dora is the system management script in userspace for post boot operations. 

it should manage daemons such as sshd.
it should create chroots for various distributions.
it should link shared directories between chroots.
it should manage virtual machines supplied with chroots or existing distributions.
it should report common connectivity problems and hardware compatibility.
it should manage recurring scripts known as cronjobs.
it should manage logging known as syslog.

Goals:

- Do one thing and do it well.
- Keep it simple stupid.
- Near zero configuration.
- Long existence by low maintenance.
- Modern and legacy interfaces.


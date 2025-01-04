#!/bin/bash
RELEASE="pandora-$(date +%Y.%m)"
rm -r initbuild /tmp/apkworld /tmp/pkgdepends /tmp/pkgdepends2 APKINDEX APKINDEX.tar.gz
touch /tmp/apkworld /tmp/pkgdepends
mkdir -p initbuild/{bin,dev,etc,lib,lib64,mnt/root,proc,root,sbin,sys}
touch initbuild/dev/null

PKGS="""
coreutils
kmod
mount
busybox
bash
readline
musl
bash
readline
libncurses
libncursesw
musl-utils
binutils
htop
ncurses-terminfo
ncurses-terminfo-base
openssh-server
openssh-client
openssh-client-default
nano
e2fsprogs
git
openssh-keygen
xorriso
wget
brotli-libs
"""

for pkg in $PKGS;do
	./pkg_install.sh $pkg initbuild/
done
./pkg_install.sh ca-certificates initbundle/
./pkg_install.sh ca-certificates-bundle initbuild/
./pkg_install.sh brotli-libs initbuild

rm initbuild/.??*

echo "root:::0:::::" > initbuild/etc/shadow
echo "root:x:0:0:root:/root:/bin/bash" > initbuild/etc/passwd
echo "root:x:0:root" > initbuild/etc/group
echo 'nameserver 1.1.1.1' >  initbuild/etc/resolv.conf
echo 'nameserver 8.8.4.4' >> initbuild/etc/resolv.conf
echo "127.0.0.1 $RELEASE localhost" > initbuild/etc/hosts


echo 'export PS1="# "' > initbuild/root/.profile

echo """
-------------------------------------------
PANDORA ($RELEASE)           
Github: https://github.com/postmeow/pandora
-------------------------------------------


""" > initbuild/etc/issue
echo """#!/bin/bash
busybox hostname $RELEASE
export PATH="$PATH:/usr/bin:/bin:/usr/sbin:/sbin"
mount -t sysfs -o noexec,nosuid,nodev sysfs /sys
mount -t proc none /proc
mount -t sysfs none /sys


/bin/busybox mkdir -p /usr/bin \
        /usr/sbin \
        /proc \
        /sys \
        /dev \
        "$sysroot" \
        /media/cdrom \
        /media/usb \
        /tmp \
        /etc \
        /run/cryptsetup

/bin/busybox --install -s

mount -t devtmpfs -o exec,nosuid,mode=0755,size=2M devtmpfs /dev 2>/dev/null \
        ||  mount -t tmpfs -o exec,nosuid,mode=0755,size=2M tmpfs /dev
mkdir /dev/pts
mount -t devpts pts /dev/pts
chmod 1777 /tmp
modprobe usbcore e1000 

if [ -f /sys/devices/platform/QEMUVGID:00/modalias ];then
echo "Running inside QEMU. Loading modules"
find /lib/modules/ -type f -name  \*virtio\* -exec bash -c 'modprobe $(basename {} | cut -d'.' -f1)' \;
fi

#echo 'Loading modules...'
#find -name  \*.ko.gz -exec bash -c "modprobe $(basename {} | cut -d '.' -f1)" \;
#echo 'Modules loaded'
echo 'Starting DHCP client detached'
ifconfig eth0 up
udhcpc -i eth0 &
/init_automount.sh
while true;do
	/sbin/getty 38400 tty1
done
""" > initbuild/init

cp files/* initbuild/

chmod +x initbuild/init

rm -r build
mkdir -p build/boot/syslinux
mkdir -p /tmp/build-tmp

./pkg_install.sh linux-lts /tmp/build-tmp
./pkg_install.sh syslinux /tmp/build-tmp
mv /tmp/build-tmp/boot/* build/boot/
mv /tmp/build-tmp/lib/modules initbuild/lib/
mv /tmp/build-tmp/usr/share/syslinux/isohdpfx.bin build/boot/syslinux
mv /tmp/build-tmp/usr/share/syslinux/isolinux.bin build/boot/syslinux
mv /tmp/build-tmp/usr/share/syslinux/ldlinux.c32 build/boot/syslinux
mv /tmp/build-tmp/usr/share/syslinux/libcom32.c32 build/boot/syslinux
mv /tmp/build-tmp/usr/share/syslinux/libutil.c32 build/boot/syslinux
mv /tmp/build-tmp/usr/share/syslinux/mboot.c32 build/boot/syslinux

echo """
TIMEOUT 10
PROMPT 1
DEFAULT lts

LABEL lts
MENU LABEL Linux lts
KERNEL /boot/vmlinuz-lts
INITRD /boot/pandorafs
APPEND modules=loop,squashfs,sd-mod,usb-storage,virtio_net,virtio_pci,af_packet quiet
""" > build/boot/syslinux/syslinux.cfg

mkdir initbuild/install
cp pkg_*.sh initbuild/install
cp mkpandora.sh initbuild/install

cd initbuild
find . | cpio -H newc -o -R root:root | gzip -9 > ../pandorafs
cd ..
mv pandorafs build/boot/

xorriso -as mkisofs \
   -r -J --joliet-long \
   -o cd.iso \
   -partition_offset 16 \
   -c boot/syslinux/boot.cat \
   -b boot/syslinux/isolinux.bin \
   -no-emul-boot -boot-load-size 4 -boot-info-table \
   build/

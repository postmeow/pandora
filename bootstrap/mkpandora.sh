#!/bin/bash
source build_env.sh
rm -rf $TMP_INITBUILD $TMP_BOOTBUILD $TMP_KERNBUILD $TMP_PKG_BUILD/apkworld $TMP_PKG_BUILD/pkgdepends2 $TMP_PKG_BUILD/pkgdepends

mkdir -p $TMP_INITBUILD/{bin,dev,etc,lib,lib64,proc,root,sbin,sys,tmp}
touch $TMP_INITBUILD/dev/null


while IFS= read -r pkgline; do
	pkgname="$(echo $pkgline | cut -d' ' -f 2)"
	pkgsuite="$(echo $pkgline | cut -d' ' -f 1)"
	echo "Installing $pkgname from $pkgsuite"
	./pkg_install.sh $pkgname $pkgsuite $TMP_INITBUILD
done <<< $(cat files/apk_bootstrap)
rm $TMP_INITBUILD/.??*
chmod 4755 $TMP_INITBUILD/bin/su

cp $TMP_PKG_BUILD/apkworld $TMP_INITBUILD/etc/apk/world
cp -R files/etc/* $TMP_INITBUILD/etc/
cp -R files/sbin/* $TMP_INITBUILD/sbin/
cp -R files/usr/* $TMP_INITBUILD/usr/
cp -R files/bin/* $TMP_INITBUILD/bin/
echo """
#!/bin/busybox sh
/sbin/init
""" > $TMP_INITBUILD/init
chmod +x $TMP_INITBUILD/init


mkdir -p $TMP_BOOTBUILD/boot/syslinux
mkdir -p $TMP_KERNBUILD

./pkg_install.sh linux-lts main $TMP_KERNBUILD
./pkg_install.sh syslinux main $TMP_KERNBUILD

mv $TMP_KERNBUILD/boot/* $TMP_BOOTBUILD/boot/
cp files/boot/syslinux/* $TMP_BOOTBUILD/boot/syslinux

mv $TMP_KERNBUILD/lib/modules $TMP_INITBUILD/lib/
mv $TMP_KERNBUILD/usr/share/syslinux/isohdpfx.bin $TMP_BOOTBUILD/boot/syslinux
mv $TMP_KERNBUILD/usr/share/syslinux/isolinux.bin $TMP_BOOTBUILD/boot/syslinux
mv $TMP_KERNBUILD/usr/share/syslinux/ldlinux.c32 $TMP_BOOTBUILD/boot/syslinux
mv $TMP_KERNBUILD/usr/share/syslinux/libcom32.c32 $TMP_BOOTBUILD/boot/syslinux
mv $TMP_KERNBUILD/usr/share/syslinux/libutil.c32 $TMP_BOOTBUILD/boot/syslinux
mv $TMP_KERNBUILD/usr/share/syslinux/mboot.c32 $TMP_BOOTBUILD/boot/syslinux

rm -r $TMP_KERNBUILD

cp -R files/etc/* $TMP_INITBUILD/etc/
cat files/etc/issue | sed "s/_RELEASE_/$RELEASE/g" > $TMP_INITBUILD/etc/issue

cd $TMP_INITBUILD
find . | cpio -H newc -o -R root:root | gzip -9 > ../pandorafs
cd ..
mv pandorafs $TMP_BOOTBUILD/boot/

xorriso -as mkisofs \
   -r -J --joliet-long \
   -o cd.iso \
   -partition_offset 16 \
   -c boot/syslinux/boot.cat \
   -b boot/syslinux/isolinux.bin \
   -no-emul-boot -boot-load-size 4 -boot-info-table \
   $TMP_BOOTBUILD

rm -r $TMP_BOOTBUILD

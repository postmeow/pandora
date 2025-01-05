#!/bin/bash
source build_env.sh
mkdir -p $TMP_PKG_BUILD
# pkg_install pkg_name install_dest/
if [[ -z "$1" || -z "$2" ]]; then
	echo "./pkg_install.sh syntax: name dest"
exit 1
fi
PKG=$(./pkg_search.sh $1)
grep $1 $TMP_PKG_BUILD/apkworld > /dev/null
if [ $? -eq 0 ]; then
	exit 0
fi
URL="https://dl-cdn.alpinelinux.org/alpine/latest-stable/main/x86_64"
if [ ! -f $TMP_PKG_BUILD/$PKG ]; then
	wget $URL/$PKG -O $TMP_PKG_BUILD/$PKG
fi
tar xvzf $TMP_PKG_BUILD/$PKG -C $2 > /dev/null
echo $1 >> $TMP_PKG_BUILD/apkworld
grep 'depend = so:' $2/.PKGINFO >> $TMP_PKG_BUILD/pkgdepends
awk '{if (++dup[$0] == 1) print $0;}' $TMP_PKG_BUILD/pkgdepends > $TMP_PKG_BUILD/pkgdepends2
while IFS= read -r line; do
    	LIB=$(echo $line | cut -d':' -f2)
	PKG2=$(cat $TMP_PKG_BUILD/APKINDEX | grep -m 1 -B 15 p:so:$LIB | grep 'P:'| cut -d':' -f 2)
	if [[ -z "$PKG2" ]]; then
		PKG2=$(cat $TMP_PKG_BUILD/APKINDEX | grep -m 1 -B 15 :$LIB | grep 'P:' | cut -d':' -f2)
	fi
	if [[ -z "$PKG2" ]]; then
		echo "error for $line for $PKG2"
		exit 1
	fi
	grep $PKG2 $TMP_PKG_BUILD/apkworld > /dev/null
	if [ $? -eq 1 ]; then
		./pkg_install.sh $PKG2 $2
	fi
done <<< $(cat $TMP_PKG_BUILD/pkgdepends2)

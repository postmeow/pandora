#!/bin/bash
# pkg_install pkg_name install_dest/
if [[ -z "$1" || -z "$2" ]]; then
	echo "./pkg_install.sh syntax: name dest"
exit 1
fi
PKG=$(./pkg_search.sh $1)
grep $1 /tmp/apkworld > /dev/null
if [ $? -eq 0 ]; then
	exit 0
fi
URL="https://dl-cdn.alpinelinux.org/alpine/latest-stable/main/x86_64"
if [ ! -f /tmp/$PKG ]; then
	wget $URL/$PKG -O /tmp/$PKG
fi
tar xvzf /tmp/$PKG -C $2 > /dev/null
echo $1 >> /tmp/apkworld
grep 'depend = so:' $2/.PKGINFO >> /tmp/pkgdepends
awk '{if (++dup[$0] == 1) print $0;}' /tmp/pkgdepends > /tmp/pkgdepends2
while IFS= read -r line; do
    	LIB=$(echo $line | cut -d':' -f2)
	PKG2=$(cat APKINDEX | grep -m 1 -B 15 p:so:$LIB | grep 'P:'| cut -d':' -f 2)
	if [[ -z "$PKG2" ]]; then
		PKG2=$(cat APKINDEX | grep -m 1 -B 15 :$LIB | grep 'P:' | cut -d':' -f2)
	fi
	if [[ -z "$PKG2" ]]; then
		echo "error for $line for $PKG2"
		exit 1
	fi
	grep $PKG2 /tmp/apkworld > /dev/null
	if [ $? -eq 1 ]; then
		./pkg_install.sh $PKG2 $2
	fi
done <<< $(cat /tmp/pkgdepends2)

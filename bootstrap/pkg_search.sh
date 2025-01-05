#!/bin/sh
source ./build_env.sh
mkdir -p $TMP_PKG_BUILD
if [[ -z "$1" ]]; then
	exit 1
fi
if [ ! -f $TMP_PKG_BUILD/APKINDEX ]; then
	URL="https://dl-cdn.alpinelinux.org/alpine/latest-stable/main/x86_64"
	wget $URL/APKINDEX.tar.gz -O $TMP_PKG_BUILD/APKINDEX.tar.gz
	tar xvzf $TMP_PKG_BUILD/APKINDEX.tar.gz -C $TMP_PKG_BUILD/
fi
echo $(cat $TMP_PKG_BUILD/APKINDEX | grep -m 1 -A 1 "P:$1" | sed 's/P://' | sed 's/V://' | tr '\n' '-' | sed 's/.$//').apk

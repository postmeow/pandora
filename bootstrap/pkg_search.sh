#!/bin/sh
if [[ -z "$1" ]]; then
	exit 1
fi
if [ ! -f APKINDEX ]; then
URL="https://dl-cdn.alpinelinux.org/alpine/latest-stable/main/x86_64"
wget $URL/APKINDEX.tar.gz
tar xvzf APKINDEX.tar.gz
fi
echo $(cat APKINDEX | grep -m 1 -A 1 "P:$1" | sed 's/P://' | sed 's/V://' | tr '\n' '-' | sed 's/.$//').apk

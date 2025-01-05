#!/bin/sh
source ./build_env.sh
if [[ -z "$1" || -z "$2" ]]; then
	exit 1
fi
PKGNAME="$1"
SUITE="$2"
mkdir -p $TMP_PKG_BUILD/$SUITE
if [ ! -f $TMP_PKG_BUILD/$SUITE/APKINDEX ]; then
	URL="$(./pkg_url.sh $SUITE)"
	wget $URL/APKINDEX.tar.gz -O $TMP_PKG_BUILD/APKINDEX_$SUITE.tar.gz --quiet > /dev/null
	tar xvzf $TMP_PKG_BUILD/APKINDEX_$SUITE.tar.gz -C $TMP_PKG_BUILD/$SUITE/ > /dev/null
	if [ $? -ne 0 ]; then
		exit 1
	fi
fi
echo $(cat $TMP_PKG_BUILD/$SUITE/APKINDEX | grep -m 1 -A 1 "P:$1" | sed 's/P://' | sed 's/V://' | tr '\n' '-' | sed 's/.$//').apk

#!/bin/sh
source ./build_env.sh
ALPINE_SUITE="$1"
echo "$ALPINE_APK_URL"/"$ALPINE_SUITE"/"$BUILD_ARCH"

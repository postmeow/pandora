#!/bin/bash
RELEASE="pandora-$(date +%Y.%m)"
BUILD_ARCH="x86_64"
ALPINE_APK_URL="https://dl-cdn.alpinelinux.org/alpine/latest-stable"
TMP_INITBUILD="/tmp/initbuild/"
TMP_BOOTBUILD="/tmp/bootbuild/"
TMP_KERNBUILD="/tmp/kernbuild/"
TMP_PKG_BUILD="/tmp/packagebuild/"

#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
#
# Update UU Game Booster version and hashes in Makefile.
#
# Usage: bash update.sh
#
# This script queries the official API for the latest plugin version,
# downloads each architecture's tarball, computes SHA256 and MD5,
# and updates the Makefile accordingly.

set -x

CURDIR="$(cd "$(dirname "$0")"; pwd)"
MAKEFILE="$CURDIR/Makefile"

# Get latest version from API (JSON format)
VERSION="$(curl -fsSL "https://router.uu.163.com/api/plugin?type=openwrt-x86_64" | jq -r ".url" | grep -oP 'v\K\d+\.\d+\.\d+' | head -1)" || exit 1
[ -z "$VERSION" ] && exit 1

PKG_VERSION="$(awk -F "PKG_VERSION:=" '{print $2}' "$MAKEFILE" | xargs)"
[ "$PKG_VERSION" != "$VERSION" ] || { echo "Already up to date: $VERSION"; exit 0; }

echo "Updating from $PKG_VERSION to $VERSION..."

for ARCH in "aarch64" "arm" "mipsel" "x86_64"; do
    FILE_INFO="$(curl -fsSL "https://router.uu.163.com/api/plugin?type=openwrt-$ARCH")"
    FILE_MD5="$(echo "$FILE_INFO" | jq -r ".md5")"
    FILE_VER="$(echo "$FILE_INFO" | jq -r ".url" | grep -oP 'v\K\d+\.\d+\.\d+' | head -1)"

    if [ "$FILE_VER" != "$VERSION" ]; then
        echo "Version mismatch for $ARCH. Expected: $VERSION, got: $FILE_VER."
        exit 1
    fi

    # Download tarball to compute SHA256
    TMPFILE="$(mktemp)"
    curl -fsSL "http://uurouter.gdl.netease.com/uuplugin/openwrt-$ARCH/v$VERSION/uu.tar.gz" -o "$TMPFILE"

    ACTUAL_MD5="$(md5sum "$TMPFILE" | awk '{print $1}')"
    if [ "$ACTUAL_MD5" != "$FILE_MD5" ]; then
        echo "MD5 mismatch for $ARCH. Expected: $FILE_MD5, got: $ACTUAL_MD5."
        rm -f "$TMPFILE"
        exit 1
    fi

    FILE_HASH="$(sha256sum "$TMPFILE" | awk '{print $1}')"
    rm -f "$TMPFILE"

    echo "$ARCH: sha256=$FILE_HASH md5=$FILE_MD5"

    # Update PKG_HASH line for this arch
    HASH_LINE="$(($(sed -n -e "/(\$(ARCH),$ARCH)/=" "$MAKEFILE") + 1))"
    sed -i "${HASH_LINE}s/PKG_HASH:=.*/PKG_HASH:=$FILE_HASH/" "$MAKEFILE"

    # Update UU_MD5SUM line for this arch
    MD5_LINE=$((HASH_LINE + 1))
    sed -i "${MD5_LINE}s/UU_MD5SUM:=.*/UU_MD5SUM:=$FILE_MD5/" "$MAKEFILE"
done

# Update version
sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$VERSION/g" "$MAKEFILE"

echo "Makefile updated to version $VERSION"

#!/bin/bash

# 定义架构
ARCH=$(uname -m)
case $ARCH in
  arm*) UU_ARCH=arm ;;
  aarch64) UU_ARCH=aarch64 ;;
  mipsel) UU_ARCH=mipsel ;;
  x86_64) UU_ARCH=x86_64 ;;
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# 获取最新版本和MD5
latest_info=$(curl -L -s -k -H "Accept:text/plain" "http://router.uu.163.com/api/plugin?type=openwrt-x86_64")
PKG_SOURCE_URL=$(echo $latest_info | cut -d, -f1)
PKG_MD5SUM_X86=$(echo $latest_info | cut -d, -f2)
PKG_VERSION=$(echo $PKG_SOURCE_URL | awk -F/ '{print $(NF-1)}')
arm_info=$(curl -L -s -k -H "Accept:text/plain" "http://router.uu.163.com/api/plugin?type=openwrt-arm")
PKG_MD5SUM_ARM=$(echo $arm_info | cut -d, -f2)
aarch64_info=$(curl -L -s -k -H "Accept:text/plain" "http://router.uu.163.com/api/plugin?type=openwrt-aarch64")
PKG_MD5SUM_AARCH64=$(echo $aarch64_info | cut -d, -f2)
mipsel_info=$(curl -L -s -k -H "Accept:text/plain" "http://router.uu.163.com/api/plugin?type=openwrt-mipsel")
PKG_MD5SUM_MIPSEL=$(echo $mipsel_info | cut -d, -f2)

# 更新Makefile
MAKEFILE_PATH="Makefile"
sed -i "s/PLACEHOLDER_VERSION/${PKG_VERSION}/g" $MAKEFILE_PATH
sed -i "s/PLACEHOLDER_RELEASE/${PKG_VERSION}/g" $MAKEFILE_PATH
sed -i "s/PLACEHOLDER_MD5SUM_X86/${PKG_MD5SUM_X86}/g" $MAKEFILE_PATH
sed -i "s/PLACEHOLDER_MD5SUM_ARM/${PKG_MD5SUM_ARM}/g" $MAKEFILE_PATH
sed -i "s/PLACEHOLDER_MD5SUM_AARCH64/${PKG_MD5SUM_AARCH64}/g" $MAKEFILE_PATH
sed -i "s/PLACEHOLDER_MD5SUM_MIPSEL/${PKG_MD5SUM_MIPSEL}/g" $MAKEFILE_PATH
#sed -i "s|PKG_VERSION:=.*|PKG_VERSION:=$PKG_VERSION|g" $MAKEFILE_PATH
#sed -i "s|PKG_SOURCE_URL:=.*|PKG_SOURCE_URL:=$PKG_SOURCE_URL|g" $MAKEFILE_PATH
#sed -i "s|PKG_MD5SUM:=.*|PKG_MD5SUM:=$PKG_MD5SUM|g" $MAKEFILE_PATH
#sed -i "s|PKG_RELEASE:=.*|PKG_RELEASE:=$PKG_VERSION|g" $MAKEFILE_PATH

echo "Makefile updated with version $PKG_VERSION"

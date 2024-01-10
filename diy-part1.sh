#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

function git_sparse_clone() {
branch="$1" rurl="$2" localdir="$3" && shift 3
git clone -b $branch --depth=1 --filter=blob:none --sparse $rurl $localdir
cd $localdir
git sparse-checkout init --cone
git sparse-checkout set $@
mv -n $@ ../
cd ..
rm -rf $localdir
}

#sed -i 's/KERNEL_PATCHVER:=5.15/KERNEL_PATCHVER:=5.10/g' ./target/linux/x86/Makefile

# 添加ssrp
#echo 'src-git helloworld https://github.com/fw876/helloworld' >> feeds.conf.default
rm -rf package/helloworld
git clone -b main --depth=1 https://github.com/fw876/helloworld.git package/helloworld

# 替换argon
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# 替换serverchan
git clone -b openwrt-18.06 https://github.com/tty228/luci-app-wechatpush.git package/luci-app-serverchan

# 添加oaf
git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter

# 添加ddns-go
# git clone https://github.com/sirpdboy/luci-app-ddns-go.git package/ddns-go

# 添加lucky
git clone  https://github.com/gdy666/luci-app-lucky.git package/lucky

# 添加watchcat-plus
git clone https://github.com/gngpp/luci-app-watchcat-plus.git package/luci-app-watchcat-plus

# 添加ap-modem
# svn export https://github.com/linkease/openwrt-app-actions/trunk/applications/luci-app-ap-modem package/luci-app-ap-modem

# iStore
# svn export https://github.com/linkease/istore-ui/trunk/app-store-ui package/app-store-ui
# svn export https://github.com/linkease/istore/trunk/luci package/luci-app-store

# 在线用户
# svn export https://github.com/haiibo/packages/trunk/luci-app-onliner package/luci-app-onliner
git_sparse_clone main "https://github.com/haiibo/packages" "packages" luci-app-onliner
sed -i '$i uci set nlbwmon.@nlbwmon[0].refresh_interval=2s' package/lean/default-settings/files/zzz-default-settings
sed -i '$i uci commit nlbwmon' package/lean/default-settings/files/zzz-default-settings
chmod 755 package/luci-app-onliner/root/usr/share/onliner/setnlbw.sh

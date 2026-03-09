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

#sed -i 's/KERNEL_PATCHVER:=5.15/KERNEL_PATCHVER:=5.10/g' ./target/linux/x86/Makefile

# 添加ssrp
rm -rf package/helloworld
git clone -b master --depth=1 https://github.com/fw876/helloworld.git package/luci-app-ssr-plus

# 添加passwall2
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall2 package/luci-app-passwall2

# 替换argon
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# 替换serverchan
git clone -b openwrt-18.06 https://github.com/tty228/luci-app-wechatpush.git package/luci-app-serverchan

# 添加oaf
git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter

# 添加lucky
git clone https://github.com/gdy666/luci-app-lucky.git package/lucky

# iStore
#echo 'src-git istore https://github.com/linkease/istore;main' >> feeds.conf.default
git clone https://github.com/linkease/istore-ui
mv istore-ui/app-store-ui package
git clone https://github.com/linkease/istore
mv istore/luci/* package
rm -rf istore istore-ui

# 在线用户
git clone https://github.com/haiibo/packages
mv packages/luci-app-onliner package
rm -rf packages
sed -i '$i uci set nlbwmon.@nlbwmon[0].refresh_interval=2s' package/lean/default-settings/files/zzz-default-settings
sed -i '$i uci commit nlbwmon' package/lean/default-settings/files/zzz-default-settings
chmod 755 package/luci-app-onliner/root/usr/share/onliner/setnlbw.sh

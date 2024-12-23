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
#echo 'src-git helloworld https://github.com/fw876/helloworld' >> feeds.conf.default
#rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box}
rm -rf package/helloworld
#git clone https://github.com/sbwml/openwrt_helloworld package/helloworld
git clone -b master --depth=1 https://github.com/fw876/helloworld.git package/helloworld
#git clone -b main --depth=1 https://github.com/fw876/helloworld.git package/helloworld
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang
#sed -i '/define Package\/mosdns\/install/i GO_PKG_TARGET_VARS:=$(filter-out CGO_ENABLED=%,$(GO_PKG_TARGET_VARS)) CGO_ENABLED=1\n' package/helloworld/mosdns/Makefile

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
git clone https://github.com/gdy666/luci-app-lucky.git package/lucky

# 添加watchcat-plus
#git clone https://github.com/openwrt/packages
#mv packages/utils/watchcat package/utils
#rm -rf packages
#git clone https://github.com/gngpp/luci-app-watchcat-plus.git package/luci-app-watchcat-plus
git clone https://github.com/sirpdboy/sirpdboy-package
mv sirpdboy-package/watchcat package/utils
mv sirpdboy-package/luci-app-watchcat-plus package
rm -rf sirpdboy-package

# 添加ap-modem
# svn export https://github.com/linkease/openwrt-app-actions/trunk/applications/luci-app-ap-modem package/luci-app-ap-modem

# iStore
# svn export https://github.com/linkease/istore-ui/trunk/app-store-ui package/app-store-ui
# svn export https://github.com/linkease/istore/trunk/luci package/luci-app-store

# 在线用户
# svn export https://github.com/haiibo/packages/trunk/luci-app-onliner package/luci-app-onliner
git clone https://github.com/haiibo/packages
mv packages/luci-app-onliner package
rm -rf packages
sed -i '$i uci set nlbwmon.@nlbwmon[0].refresh_interval=2s' package/lean/default-settings/files/zzz-default-settings
sed -i '$i uci commit nlbwmon' package/lean/default-settings/files/zzz-default-settings
chmod 755 package/luci-app-onliner/root/usr/share/onliner/setnlbw.sh

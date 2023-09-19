#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# 清理旧包
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-argon-mod
rm -rf feeds/luci/applications/luci-app-serverchan

# 替换watchcat
rm -rf feeds/packages/utils/watchcat
svn co https://github.com/openwrt/packages/trunk/utils/watchcat feeds/packages/utils/watchcat

# 修改默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 添加自定义源
echo 'src/gz openwrt_kiddin9 https://dl.openwrt.ai/23.05/packages/x86_64' >> package/system/opkg/files/customfeeds.conf

# 修改网络设置
sed -i 's/192.168.1.1/192.168.123.1/g' package/base-files/files/bin/config_generate
sed -i "13i\\uci set network.wan.proto='pppoe'\nuci set network.wan.username='test'\nuci set network.wan.password='123456'\nuci set network.wan.ifname='eth0'\nuci set network.lan.ipaddr='192.168.123.1'\nuci set network.lan.proto='static'\nuci set network.lan.type='bridge'\nuci set network.lan.ifname='eth1 eth2 eth3'\nuci commit network\n" package/lean/default-settings/files/zzz-default-settings

# x86 型号只显示 CPU 型号
sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore

# 修改本地时间格式
sed -i 's/os.date()/os.date("%a %Y-%m-%d %H:%M:%S")/g' package/lean/autocore/files/*/index.htm

# 修改版本为编译日期
date_version=$(date +"%y.%m.%d")
orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
sed -i "s/${orig_version}/R${date_version} by Ellison/g" package/lean/default-settings/files/zzz-default-settings
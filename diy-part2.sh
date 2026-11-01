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

# ssrp
if [ "$ENABLE_SSRP" = "true" ]; then
    echo "CONFIG_PACKAGE_luci-app-ssr-plus=y" >> .config
    echo "CONFIG_PACKAGE_luci-i18n-ssr-plus-zh-cn=y" >> .config
fi

# passwall2
if [ "$ENABLE_PASSWALL2" = "true" ]; then
    echo "CONFIG_PACKAGE_luci-app-passwall2=y" >> .config
    echo "CONFIG_PACKAGE_luci-i18n-passwall2-zh-cn=y" >> .config
    echo "CONFIG_PACKAGE_luci-app-passwall2_Basic_Core_All=y" >> .config
    echo "CONFIG_PACKAGE_luci-app-passwall2_Iptables_Transparent_Proxy=y" >> .config
    echo "CONFIG_PACKAGE_luci-app-passwall2_INCLUDE_Haproxy=y" >> .config
    echo "CONFIG_PACKAGE_luci-app-passwall2_INCLUDE_Hysteria=y" >> .config
    echo "CONFIG_PACKAGE_hysteria=y" >> .config
fi

# iStore
if [ "$ENABLE_ISTORE" = "true" ]; then
    echo "CONFIG_PACKAGE_luci-app-store=y" >> .config
    echo "CONFIG_PACKAGE_luci-i18n-store-zh-cn=y" >> .config
fi

# uugamebooster
if [ "$ENABLE_UUGAMEBOOSTER" = "true" ]; then
    pushd $GITHUB_WORKSPACE/uugamebooster
    bash update_makefile.sh || echo "[uugamebooster] API unreachable, using hardcoded version in Makefile"
    popd
    rm -rf feeds/packages/net/uugamebooster
    cp -r $GITHUB_WORKSPACE/uugamebooster feeds/packages/net/uugamebooster
    echo "CONFIG_PACKAGE_luci-app-uugamebooster=y" >> .config
    echo "CONFIG_PACKAGE_luci-i18n-uugamebooster-zh-cn=y" >> .config
    echo "CONFIG_PACKAGE_uugamebooster=y" >> .config
fi

# bxplug
if [ "$ENABLE_BXPLUG" = "true" ]; then
    echo "CONFIG_PACKAGE_bxplug=y" >> .config
fi

# komari-agent
if [ "$ENABLE_KOMARI_AGENT" = "true" ]; then
    echo "CONFIG_PACKAGE_komari-agent=y" >> .config
    echo "CONFIG_PACKAGE_luci-app-komari-agent=y" >> .config
    echo "CONFIG_PACKAGE_luci-i18n-komari-agent-zh-cn=y" >> .config
fi

# 修改默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 添加自定义源
echo 'src/gz openwrt_kiddin9 https://dl.openwrt.ai/latest/packages/x86_64/kiddin9' >> package/system/opkg/files/customfeeds.conf

# 修改网络设置
sed -i 's/192.168.1.1/192.168.123.1/g' package/base-files/files/bin/config_generate
sed -i '/local ports device macaddr/a\
\t[ "$1" = "lan" ] && { ports="eth1 eth2 eth3"; device=""; }\n\t[ "$1" = "wan" ] && { device="eth0"; ports="eth0"; }' package/base-files/files/bin/config_generate
sed -i "13i\\uci set network.wan.proto='pppoe'\nuci set network.wan.username='test'\nuci set network.wan.password='123456'\nuci commit network\n" package/lean/default-settings/files/zzz-default-settings

# x86 型号只显示 CPU 型号
sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore

# 修改本地时间格式
sed -i 's/os.date()/os.date("%a %Y-%m-%d %H:%M:%S")/g' package/lean/autocore/files/*/index.htm

# 修改版本为编译日期
date_version=$(date +"%y.%m.%d")
orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
sed -i "s/${orig_version}/R${date_version} by Ellison/g" package/lean/default-settings/files/zzz-default-settings

# ---- xray-core 版本守卫 ----
# 上游 coolsnowwolf/packages 偶尔会把 PKG_VERSION 写成一个 Xray-core 仓库里
# 根本不存在的 tag（2026-10-30 的 26.10.29 就是：tag 只有 …v26.10.21 / v26.10.31），
# 导致 PKG_SOURCE_URL 返回 404，构建在 xray-core 上反复重试几十分钟后失败。
# 这里校验 tag 是否存在：缺失则改用"下一个真实存在的更高版本"，并重算 PKG_HASH。
# 注意不能往回退版本：补丁栈是按新版本 go.sum 刷新的，旧版本反而打不上。
XRAY_MK="feeds/packages/net/xray-core/Makefile"
if [ -f "$XRAY_MK" ]; then
    XRAY_VER="$(sed -n 's/^PKG_VERSION:=//p' "$XRAY_MK" | head -n 1 | tr -d '[:space:]')"
    if [ -n "$XRAY_VER" ] && [ -z "$(git ls-remote --tags --refs https://github.com/XTLS/Xray-core "refs/tags/v$XRAY_VER")" ]; then
        echo "[xray-core] v$XRAY_VER 在 XTLS/Xray-core 不存在，开始修正"
        XRAY_TAGS="$(git ls-remote --tags --refs https://github.com/XTLS/Xray-core 'refs/tags/v*' \
            | sed 's#.*refs/tags/v##' | grep -E '^[0-9]+(\.[0-9]+){2}$' | sort -V)"
        XRAY_FIX="$(printf '%s\n' "$XRAY_TAGS" | while read -r t; do
            [ "$t" = "$XRAY_VER" ] && continue
            if [ "$(printf '%s\n%s\n' "$XRAY_VER" "$t" | sort -V | tail -n 1)" = "$t" ]; then
                echo "$t"; break
            fi
        done)"
        [ -n "$XRAY_FIX" ] || XRAY_FIX="$(printf '%s\n' "$XRAY_TAGS" | tail -n 1)"
        if [ -n "$XRAY_FIX" ]; then
            XRAY_TMP="$(mktemp)"
            if curl -fsSL "https://codeload.github.com/XTLS/Xray-core/tar.gz/v$XRAY_FIX?" -o "$XRAY_TMP"; then
                XRAY_HASH="$(sha256sum "$XRAY_TMP" | awk '{print $1}')"
                sed -i "s/^PKG_VERSION:=.*/PKG_VERSION:=$XRAY_FIX/" "$XRAY_MK"
                sed -i "s/^PKG_HASH:=.*/PKG_HASH:=$XRAY_HASH/" "$XRAY_MK"
                echo "[xray-core] 已改用 v$XRAY_FIX (sha256=$XRAY_HASH)"
            else
                echo "[xray-core] 下载 v$XRAY_FIX 源码失败，保持原版本（构建可能因此失败）"
            fi
            rm -f "$XRAY_TMP"
        fi
    fi
fi

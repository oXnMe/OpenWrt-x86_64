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

# ssrp
if [ "$ENABLE_SSRP" = "true" ]; then
    git clone -b master --depth=1 https://github.com/fw876/helloworld.git package/luci-app-ssr-plus
fi

# passwall2
if [ "$ENABLE_PASSWALL2" = "true" ]; then
    git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall2 package/luci-app-passwall2
fi

# argon
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# serverchan
git clone https://github.com/tty228/luci-app-wechatpush.git package/luci-app-wechatpush

# openappfilter
git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter

# lucky
git clone https://github.com/gdy666/luci-app-lucky.git package/lucky

# iStore
if [ "$ENABLE_ISTORE" = "true" ]; then
    git clone https://github.com/linkease/istore
    mv istore/luci/* package
    rm -rf istore
fi

# 在线用户
git clone https://github.com/haiibo/packages
mv packages/luci-app-onliner package
rm -rf packages
sed -i '$i uci set nlbwmon.@nlbwmon[0].refresh_interval=2s' package/lean/default-settings/files/zzz-default-settings
sed -i '$i uci commit nlbwmon' package/lean/default-settings/files/zzz-default-settings
chmod 755 package/luci-app-onliner/root/usr/share/onliner/setnlbw.sh

# bxplug
if [ "$ENABLE_BXPLUG" = "true" ]; then
    BXPLUG_INFO=$(curl -s "https://api.github.com/repos/linkease/istore-repo/contents/bin/packages/x86_64/nas" | grep -o 'bxplug_[^"]*\.ipk' | head -n 1)

    if [ -n "$BXPLUG_INFO" ]; then
        mkdir -p package/bxplug
        curl -L -o "package/bxplug/$BXPLUG_INFO" "https://github.com/linkease/istore-repo/raw/refs/heads/main/bin/packages/x86_64/nas/$BXPLUG_INFO"

        cat << 'EOF' > package/bxplug/Makefile
include $(TOPDIR)/rules.mk

PKG_NAME:=bxplug
PKG_VERSION:=$(shell ls $(CURDIR) | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9]+)?' | head -n 1)
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/bxplug
  SECTION:=net
  CATEGORY:=Network
  TITLE:=iStore bxplug (Binary)
  DEPENDS:=+uci
endef

define Package/bxplug/description
  Precompiled bxplug package from istore-repo.
endef

define Build/Compile
endef

define Package/bxplug/install
	mkdir -p $(PKG_BUILD_DIR)/ipk_tmp
	tar -C $(PKG_BUILD_DIR)/ipk_tmp -xzf $(CURDIR)/bxplug_$(PKG_VERSION)_x86_64.ipk
	tar -C $(1) -xzf $(PKG_BUILD_DIR)/ipk_tmp/data.tar.gz
	rm -rf $(PKG_BUILD_DIR)/ipk_tmp
endef

$(eval $(call BuildPackage,bxplug))
EOF
    fi
fi

# komari-agent
if [ "$ENABLE_KOMARI_AGENT" = "true" ]; then
    git clone https://github.com/oXnMe/openwrt-komari-agent.git package/openwrt-komari-agent
fi
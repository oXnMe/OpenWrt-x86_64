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

        cat << 'STRIP_EOF' > package/bxplug/strip_ads.py
import os
import re
import sys


def strip_index_html(path):
    if not os.path.exists(path):
        return False
    with open(path, encoding="utf-8") as f:
        html = f.read()

    original = html

    marker = '<div class="cbi-map-descr">'
    start = html.find(marker)
    if start >= 0:
        depth = 0
        i = start
        tag_end = html.find(">", start)
        pos = tag_end + 1
        closed = -1
        while pos < len(html):
            nxt_open = html.find("<div", pos)
            nxt_close = html.find("</div>", pos)
            if nxt_close < 0:
                break
            if nxt_open >= 0 and nxt_open < nxt_close:
                depth += 1
                pos = nxt_open + 4
            else:
                if depth == 0:
                    closed = nxt_close + len("</div>")
                    break
                depth -= 1
                pos = nxt_close + 6
        if closed > 0:
            html = html[:start] + html[closed:]

    ready_pat = re.compile(r"\n[ \t]*\$\(document\)\.ready\(function \(\) \{.*?\n[ \t]*\}\);\n", re.S)
    html = ready_pat.sub("\n", html)

    html = html.replace("https://cloud.beeconx.com.cn/api/ocean/materialPlatform/materialFile/getCurrentPluginAdBannerImage", "")
    html = html.replace("<%:【淘宝店】%>", "")
    html = html.replace("<%:【官网】%>", "")

    if html != original:
        with open(path, "w", encoding="utf-8") as f:
            f.write(html)
        return True
    return False


def strip_bm_js(js_dir):
    if not os.path.isdir(js_dir):
        return False
    target = None
    for fn in sorted(os.listdir(js_dir)):
        if fn.startswith("index-") and fn.endswith(".js"):
            p = os.path.join(js_dir, fn)
            with open(p, encoding="utf-8") as f:
                if "additionBannerInfo" in f.read():
                    target = p
                    break
    if not target:
        return False

    with open(target, encoding="utf-8") as f:
        s = f.read()
    original = s

    s = s.replace(
        'S=async()=>{let p=await at(new Date);O.value=p.data}',
        'S=async()=>{}',
    )

    s = s.replace('Ue("【淘宝店】")', '""')
    s = s.replace('Ue("【官网】")', '""')

    start_marker = 'R("div",null,[c(o,{type:"primary",style:{"margin-right":"2rem"},href:a(O).additionBannerInfo.taobao'
    start = s.find(start_marker)
    if start >= 0:
        end_marker = ',R("div",null,[c(P,'
        end = s.find(end_marker, start)
        if end >= 0:
            s = s[:start] + s[end + 1:]

    if s != original:
        with open(target, "w", encoding="utf-8") as f:
            f.write(s)
        return True
    return False


def main():
    data_root = sys.argv[1] if len(sys.argv) > 1 else "."
    changed = []

    idx = os.path.join(data_root, "usr/lib/lua/luci/view/beeconmini/index.htm")
    if strip_index_html(idx):
        changed.append("index.htm")

    js_dir = os.path.join(data_root, "www/luci-static/resources/beeconmini")
    if strip_bm_js(js_dir):
        changed.append("bm JS (index-*.js)")

    if changed:
        print("strip_ads: 已清除广告 -> " + ", ".join(changed))
    else:
        print("strip_ads: 未发现广告内容 (无需修改)")


if __name__ == "__main__":
    main()
STRIP_EOF

        cat << 'EOF' > package/bxplug/Makefile
include $(TOPDIR)/rules.mk

PKG_NAME:=bxplug
PKG_VERSION:=$(shell ls $(CURDIR) | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9]+)?' | head -n 1)
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/bxplug
  SECTION:=net
  CATEGORY:=Network
  TITLE:=iStore bxplug (Binary, ads stripped)
  DEPENDS:=+uci
endef

define Package/bxplug/description
  Precompiled bxplug package from istore-repo, with promotional ads removed at build time.
endef

define Build/Compile
endef

define Package/bxplug/install
	mkdir -p $(PKG_BUILD_DIR)/ipk_tmp
	tar -C $(PKG_BUILD_DIR)/ipk_tmp -xzf $(CURDIR)/bxplug_$(PKG_VERSION)_x86_64.ipk
	tar -C $(1) -xzf $(PKG_BUILD_DIR)/ipk_tmp/data.tar.gz
	python3 $(CURDIR)/strip_ads.py $(1)
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
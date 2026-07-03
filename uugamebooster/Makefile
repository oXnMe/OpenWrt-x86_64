# SPDX-License-Identifier: GPL-3.0-only
#
# Based on official UU Game Booster install scripts for OpenWrt.
# The official install.sh installs uuplugin_monitor.sh to /usr/sbin/uu/
# which handles downloading, extracting, starting, and auto-updating
# the uuplugin binary at runtime.
#
# This Makefile pre-installs the backup tarball and monitor script so
# the plugin works offline on first boot, while still supporting
# automatic updates via the monitor.
#
# To get the latest version & hashes:
#   curl -L -s -k -H "Accept:text/plain" "http://router.uu.163.com/api/plugin?type=openwrt-x86_64"
# Returns: <url>,<md5>,<fallback_url>,
# Or use JSON API:
#   curl -L -s -k "https://router.uu.163.com/api/plugin?type=openwrt-x86_64" | jq
# Then run: bash update.sh

include $(TOPDIR)/rules.mk

PKG_NAME:=uugamebooster
PKG_VERSION:=14.0.6
PKG_RELEASE:=1

PKG_SOURCE:=uu.tar.gz
PKG_SOURCE_URL:=https://uurouter.gdl.netease.com/uuplugin/openwrt-$(ARCH)/v$(PKG_VERSION)

ifeq ($(ARCH),aarch64)
  PKG_HASH:=4fe6fcad525c525ad530af69f102d90c1189330e4e3c3183b577ddde27731e2a
  UU_MD5SUM:=1e854479747fbb37940cf14789d5ac5d
else ifeq ($(ARCH),arm)
  PKG_HASH:=e8693a284d0a9445e73f8d2e9c3d330364cc6371d63c19da03f8e8c47f076caf
  UU_MD5SUM:=2526a9c8255a35aadcfbbb2f3ee69716
else ifeq ($(ARCH),mipsel)
  PKG_HASH:=6fd2497bfdcf228de050119f7f593547a0da3eca9c50baa6bf8d5da6e366c575
  UU_MD5SUM:=fcec7b7fea410df7ad6555068cee34a5
else ifeq ($(ARCH),x86_64)
  PKG_HASH:=1becd5ef81d257b22002f208cd303b04e421c7da4231523b7d82da2c7193b57f
  UU_MD5SUM:=2d43d97b5e5300f5b3dfc4e33a29a23c
endif

PKG_LICENSE:=Proprietary

include $(INCLUDE_DIR)/package.mk

define Package/uugamebooster
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=@(aarch64||arm||mipsel||x86_64) +kmod-tun
  TITLE:=NetEase UU Game Booster
  URL:=https://uu.163.com
endef

define Package/uugamebooster/description
  NetEase's UU Game Booster Accelerates Triple-A Gameplay and Market.
endef

define Build/Compile
endef

define Package/uugamebooster/conffiles
/usr/sbin/uu/uu.tar.gz
/usr/sbin/uu/uu.tar.gz.md5
/usr/sbin/uu/uuplugin_monitor.config
endef

define Package/uugamebooster/install
	# Install monitor script (official uuplugin_monitor.sh)
	$(INSTALL_DIR) $(1)/usr/sbin/uu
	$(INSTALL_BIN) $(CURDIR)/files/uuplugin_monitor.sh $(1)/usr/sbin/uu/uuplugin_monitor.sh

	# Generate monitor config: router type and model (architecture)
	# The monitor reads this to determine download URLs and plugin paths
	echo "router=openwrt" > $(1)/usr/sbin/uu/uuplugin_monitor.config
	echo "model=$(ARCH)" >> $(1)/usr/sbin/uu/uuplugin_monitor.config

	# Install backup tarball and its md5 (used by monitor for offline first boot)
	# The monitor extracts this to /tmp/uu/ at runtime and auto-updates when newer versions are available
	$(INSTALL_DATA) $(DL_DIR)/$(PKG_SOURCE) $(1)/usr/sbin/uu/uu.tar.gz
	echo "$(UU_MD5SUM)" > $(1)/usr/sbin/uu/uu.tar.gz.md5

	# Install init script and UCI config
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) $(CURDIR)/files/uugamebooster.init $(1)/etc/init.d/uugamebooster
	$(INSTALL_CONF) $(CURDIR)/files/uugamebooster.config $(1)/etc/config/uugamebooster
endef

$(eval $(call BuildPackage,uugamebooster))

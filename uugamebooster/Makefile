# 定义常量和变量
PKG_NAME:=uugamebooster
PKG_VERSION:=PLACEHOLDER_VERSION
PKG_RELEASE:=PLACEHOLDER_RELEASE
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_DIR:=$(PKG_BUILD_DIR)/$(PKG_NAME)-$(UU_ARCH)-bin

# 包含标准规则
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk

define Package/uugamebooster
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=@(aarch64||arm||mipsel||x86_64) +kmod-tun
  TITLE:=NetEase UU Game Booster
  URL:=https://uu.163.com
endef

define Package/uugamebooster/description
  NetEase's UU Game Booster accelerates Triple-A gameplay and market.
endef

PKG_SOURCE:=$(PKG_NAME)-$(UU_ARCH)-$(PKG_VERSION).tar.gz

define Build/Prepare
	$(call Build/Prepare/Default)
	mkdir -p $(PKG_SOURCE_DIR)
	tar -zxvf $(DL_DIR)/$(PKG_SOURCE) -C $(PKG_SOURCE_DIR)
endef

define Build/Compile
	# 编译过程留空
endef

define Package/uugamebooster/install
	$(INSTALL_DIR) $(1)/usr/share/uugamebooster
	$(INSTALL_BIN) $(PKG_SOURCE_DIR)/uuplugin $(1)/usr/share/uugamebooster/uuplugin
	$(INSTALL_CONF) $(PKG_SOURCE_DIR)/uu.conf $(1)/usr/share/uugamebooster/uu.conf
endef

define Package/uugamebooster/conffiles
/root/.uuplugin_uuid
endef

$(eval $(call BuildPackage,uugamebooster))

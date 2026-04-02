include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-wireguard
PKG_VERSION:=1
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0
PKG_MAINTAINER:=Codex

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-wireguard
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Compatibility meta package for WireGuard UI
  PKGARCH:=all
  DEPENDS:=+luci-proto-wireguard
endef

define Package/luci-app-wireguard/description
  Transitional compatibility package that pulls in luci-proto-wireguard
  on OpenWrt 25.12 where the old luci-app-wireguard package is gone.
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-wireguard/install
	:
endef

$(eval $(call BuildPackage,luci-app-wireguard))

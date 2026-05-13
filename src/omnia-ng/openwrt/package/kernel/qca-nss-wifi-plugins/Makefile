include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-nss-wifi-plugins
PKG_VERSION:=1.0.r29
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/nss-plugins.git
PKG_SOURCE_VERSION:=win.nss.$(PKG_VERSION)
PKG_MIRROR_HASH:=e9fc55abbf69968dd62dca208026c220c030607a2e36f9a2c0a54d76c64c03c2
PKG_RELEASE:=1

PKG_BUILD_DEPENDS :=
MAKE_OPTS:=

include $(INCLUDE_DIR)/package.mk

define KernelPackage/qca-nss-wifi-plugins
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Devices
  TITLE:=NSS Plugin Module
  DEPENDS:=@TARGET_ipq95xx||TARGET_ipq54xx||TARGET_ipq53xx||TARGET_ipq52xx||TARGET_ipq96xx +kmod-qca-nss-ppe +kmod-qca-nss-ppe-vp +kmod-qca-nss-ppe-ds @!LINUX_3_18
  FILES:=$(PKG_BUILD_DIR)/qca-nss-wifi-plugins.ko
  AUTOLOAD:=$(call AutoLoad,53,qca-nss-wifi-plugins)
endef

define KernelPackage/qca-nss-wifi-plugins/Description
Kernel module for NSS-WiFi Plugins
endef


EXTRA_CFLAGS+= \
	-I$(STAGING_DIR)/usr/include/qca-nss-ppe \
	-I$(STAGING_DIR)/usr/include/qca-nss-ppe-ds \
	-I$(STAGING_DIR)/usr/include/qca-ssdk \
	-I$(STAGING_DIR)/usr/include/qca-ssdk/fal \
	-I$(STAGING_DIR)/usr/include/qca-ssdk/init \
	-I$(STAGING_DIR)/usr/include/qca-nss-ppe-vp

define Build/Compile
	$(KERNEL_MAKE) $(strip $(MAKE_OPTS)) \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		modules
endef

define Build/InstallDev/qca-nss-wifi-plugins
	$(INSTALL_DIR) $(1)/usr/include/qca-nss-wifi-plugins
endef

define Build/InstallDev
	$(call Build/InstallDev/qca-nss-wifi-plugins,$(1))
endef

$(eval $(call KernelPackage,qca-nss-wifi-plugins))


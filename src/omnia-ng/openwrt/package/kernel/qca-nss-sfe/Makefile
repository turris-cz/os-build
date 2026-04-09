include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-nss-sfe
PKG_RELEASE:=1
PKG_VERSION:=1.0.r26

PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/shortcut-fe.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=win.nss.$(PKG_VERSION)

PKG_BUILD_DEPENDS :=
MAKE_OPTS:=

include $(INCLUDE_DIR)/package.mk

ifeq ($(CONFIG_TARGET_ipq),y)
subtarget:=$(SUBTARGET)
else
subtarget:=$(CONFIG_TARGET_BOARD)
endif

define KernelPackage/qca-nss-sfe
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Devices
  TITLE:=Shortcut Forwarding Engine
  DEPENDS:=@TARGET_ipq95xx||TARGET_ipq53xx||TARGET_ipq54xx||TARGET_ipq96xx||TARGET_ipq52xx\
		+kmod-qca-ssdk +kmod-ppp +kmod-pppoe \
		+!(TARGET_ipq53xx_ipq53xx_32_QSDK_256||TARGET_ipq54xx_ipq54xx_32_QSDK_256):kmod-nat46
  FILES:=$(PKG_BUILD_DIR)/qca-nss-sfe.ko
  AUTOLOAD:=$(call AutoProbe,qca-nss-sfe)
endef

define KernelPackage/qca-nss-sfe/Description
Kernel module for Shortcut Forwarding Engine
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/qca-nss-sfe
	$(CP) $(PKG_BUILD_DIR)/exports/* $(1)/usr/include/qca-nss-sfe/
endef

EXTRA_CFLAGS+= \
	-I$(STAGING_DIR)/usr/include/qca-ssdk \
	-I$(STAGING_DIR)/usr/include/qca-ssdk/fal \
	-I$(STAGING_DIR)/usr/include/qca-ssdk/init \
	-I$(STAGING_DIR)/usr/include/nat46 \
	-I$(PKG_BUILD_DIR)/exports \


define Build/Compile
	$(KERNEL_MAKE) $(strip $(MAKE_OPTS)) \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		SFE_SUPPORT_IPV6=y
endef

$(eval $(call KernelPackage,qca-nss-sfe))

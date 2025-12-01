include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-nss-crypto
PKG_RELEASE:=1
PKG_VERSION:=1.0.r26

PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/nss-crypto.git
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

define KernelPackage/qca-nss-crypto
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Devices
  TITLE:=Qualcomm Crypto driver
  DEPENDS:=@TARGET_ipq95xx||TARGET_ipq53xx||TARGET_ipq54xx||TARGET_ipq96xx||TARGET_ipq52xx\
		+kmod-qca-ssdk +kmod-qca-nss-drv-lite
  FILES:=$(PKG_BUILD_DIR)/v2.0/src/qca-nss-crypto.ko
  AUTOLOAD:=$(call AutoLoad,42,qca-nss-crypto)
endef

define KernelPackage/qca-nss-crypto/Description
Kernel module for Qualcomm Crypto acceleration
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/qca-nss-crypto
	$(CP) $(PKG_BUILD_DIR)/v2.0/include/* $(1)/usr/include/qca-nss-crypto/
endef

EXTRA_CFLAGS+= \
	-I$(STAGING_DIR)/usr/include/qca-ssdk \
	-I$(STAGING_DIR)/usr/include/qca-ssdk/fal \
	-I$(STAGING_DIR)/usr/include/qca-ssdk/init \
	-I$(STAGING_DIR)/usr/include/qca-nss-drv \
	-I$(PKG_BUILD_DIR)/v2.0/include

define Build/Compile
	$(KERNEL_MAKE) $(strip $(MAKE_OPTS)) \
		M="$(PKG_BUILD_DIR)/v2.0/src" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		SoC="$(subtarget)" \
		modules
endef

$(eval $(call KernelPackage,qca-nss-crypto))

include $(TOPDIR)/rules.mk

PKG_NAME:=qca-ssdk
PKG_RELEASE:=1
PKG_VERSION:=1.0.r26

PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/qca-ssdk.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=win.nss.$(PKG_VERSION)
PKG_MIRROR_HASH:=fe24b2c2990c2131392345b89bcb4a998be2e4230431b7d026680fdc573e5c5f

PKG_FLAGS:=nonshared
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-lto

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/qca-ssdk
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Devices
  TITLE:=Qualcom SSDK switch driver
  DEPENDS:=@(TARGET_ipq95xx) +kmod-qca-nss-phy
  FILES:=$(PKG_BUILD_DIR)/mk/qca-ssdk.ko
  AUTOLOAD:=$(call AutoLoad,30,qca-ssdk)
endef

define KernelPackage/qca-ssdk/Description
  Driver for Qualcomm Atheros switches.
endef

GCC_VERSION=$(shell echo "$(CONFIG_GCC_VERSION)" | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')

LNX_CONFIG_OPTS = LNX_MAKEOPTS='$(KERNEL_MAKEOPTS)' MODULE_TYPE=KSLIB modules

MAKE_FLAGS+= \
	TARGET_NAME=$(CONFIG_TARGET_NAME) \
	TOOL_PATH=$(firstword $(TOOLCHAIN_BIN_DIRS)) \
	SYS_PATH=$(LINUX_DIR) \
	TOOLPREFIX=$(TARGET_CROSS) \
	KVER=$(LINUX_VERSION) \
	ARCH=$(LINUX_KARCH) \
	TARGET_SUFFIX=$(CONFIG_TARGET_SUFFIX) \
	GCC_VERSION=$(GCC_VERSION) \
	EXTRA_CFLAGS="-fno-stack-protector -I$(STAGING_DIR)/usr/include -I$(PKG_BUILD_DIR)/include/hsl/mht" \
	SoC=$(CONFIG_TARGET_SUBTARGET) \
	SHELL="$(BASH)" \
	PRJ_PATH="$(PKG_BUILD_DIR)" \
	MK_PATH="$(PKG_BUILD_DIR)/mk"

ifeq ($(CONFIG_TARGET_SUBTARGET), "ipq807x")
    MAKE_FLAGS+= CHIP_TYPE=HPPE
endif

ifeq ($(CONFIG_TARGET_SUBTARGET), "ipq60xx")
    MAKE_FLAGS+= CHIP_TYPE=CPPE
endif

ifeq ($(CONFIG_TARGET_BOARD), "ipq95xx")
    MAKE_FLAGS+= CHIP_TYPE=APPE MHT_ENABLE=enable SoC=ipq95xx
endif

define Build/Compile
	+$(MAKE) $(PKG_JOBS) $(MAKE_FLAGS) -C $(PKG_BUILD_DIR)/mk $(LNX_CONFIG_OPTS)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/qca-ssdk
	$(INSTALL_DIR) $(1)/usr/include/qca-ssdk/api
	$(INSTALL_DIR) $(1)/usr/include/qca-ssdk/ref
	$(INSTALL_DIR) $(1)/usr/include/qca-ssdk/fal
	$(INSTALL_DIR) $(1)/usr/include/qca-ssdk/sal
	$(INSTALL_DIR) $(1)/usr/include/qca-ssdk/init
	$(CP) -rf $(PKG_BUILD_DIR)/include/api/sw_ioctl.h $(1)/usr/include/qca-ssdk/api
	if [ -f $(PKG_BUILD_DIR)/include/ref/ref_vsi.h ]; then \
	$(CP) -rf $(PKG_BUILD_DIR)/include/ref/ref_vsi.h $(1)/usr/include/qca-ssdk/ref/; \
	fi
	if [ -f $(PKG_BUILD_DIR)/include/ref/ref_fdb.h ]; then \
	$(CP) -rf $(PKG_BUILD_DIR)/include/ref/ref_fdb.h $(1)/usr/include/qca-ssdk/ref/; \
	fi
	if [ -f $(PKG_BUILD_DIR)/include/ref/ref_port_ctrl.h ]; then \
	$(CP) -rf $(PKG_BUILD_DIR)/include/ref/ref_port_ctrl.h $(1)/usr/include/qca-ssdk/ref/; \
	fi
	if [ -f $(PKG_BUILD_DIR)/include/init/ssdk_init.h ]; then \
	$(CP) -rf $(PKG_BUILD_DIR)/include/init/ssdk_init.h $(1)/usr/include/qca-ssdk/init/; \
	fi
	if [ -f $(PKG_BUILD_DIR)/include/init/ssdk_netlink.h ]; then \
	$(CP) -rf $(PKG_BUILD_DIR)/include/init/ssdk_netlink.h $(1)/usr/include/qca-ssdk/init/; \
	fi
	$(CP) -rf $(PKG_BUILD_DIR)/include/fal $(1)/usr/include/qca-ssdk
	$(CP) -rf $(PKG_BUILD_DIR)/include/common/*.h $(1)/usr/include/qca-ssdk
	$(CP) -rf $(PKG_BUILD_DIR)/include/sal/os/linux/*.h $(1)/usr/include/qca-ssdk
	$(CP) -rf $(PKG_BUILD_DIR)/include/sal/os/*.h $(1)/usr/include/qca-ssdk
endef

$(eval $(call KernelPackage,qca-ssdk))

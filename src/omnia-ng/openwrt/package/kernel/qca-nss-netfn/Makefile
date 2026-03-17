include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-nss-netfn
PKG_RELEASE:=1
PKG_VERSION:=1.0.r29

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/nss-netfn.git
PKG_MIRROR_HASH:=431df63d0dea395e4f9d88938335b1b5d47c91da5a94f2ac7c40a62711de3955
PKG_SOURCE_VERSION:=win.nss.$(PKG_VERSION)

MAKE_OPTS:=
MAKE_OPTS+=NETFN_FLOWMGR_AE_PPE_ENABLE=y
MAKE_OPTS+=NETFN_FLOWMGR_AE_SFE_ENABLE=y

include $(INCLUDE_DIR)/package.mk

define KernelPackage/qca-nss-netfn-tcpst
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Support
  DEPENDS:=+kmod-qca-nss-ppe \
	  +kmod-qca-nss-ppe-vp \
	  +kmod-qca-nss-flowmgr
  TITLE:=NSS network function tcp speedtest offload
  FILES:=$(PKG_BUILD_DIR)/offload/tcpst/qca-nss-netfn-tcpst.ko
endef

ifneq ($(CONFIG_PACKAGE_kmod-qca-nss-netfn-tcpst),)
MAKE_OPTS+=tcpst=y
endif

define KernelPackage/qca-nss-netfn-tcpst/Description
NSS network function tcpst offload module.
endef

define KernelPackage/qca-nss-netfn-sk-offload
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Devices
  TITLE:=Kernel driver for network function netfn sk offload
  DEPENDS:=+kmod-qca-nss-ppe \
    +kmod-qca-nss-ppe-vp \
    +kmod-qca-nss-flowmgr
  FILES:=$(PKG_BUILD_DIR)/offload/sk_offload/qca-nss-netfn-sk-offload.ko
endef

ifneq ($(CONFIG_PACKAGE_kmod-qca-nss-netfn-sk-offload),)
MAKE_OPTS+=skoffload=y
endif

define KernelPackage/qca-nss-netfn-sk-offload/Description
Kernel modules for network function sk offload
endef

define KernelPackage/qca-nss-netfn-sk-offload/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) files/iperf3_load_balance.sh $(1)/usr/bin/
endef

define KernelPackage/qca-nss-flowmgr
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Devices
  TITLE:=Kernel driver for Network function manager
  DEPENDS:=@TARGET_ipq53xx||TARGET_ipq54xx||TARGET_ipq95xx \
	  +kmod-qca-nss-ppe \
	  +kmod-qca-nss-ppe-rule \
	  +kmod-qca-nss-sfe
  FILES:=$(PKG_BUILD_DIR)/mgr/flowmgr/qca-nss-flowmgr.ko
  AUTOLOAD:=$(call AutoLoad,50,qca-nss-flowmgr)
endef

ifneq ($(CONFIG_PACKAGE_kmod-qca-nss-flowmgr),)
 MAKE_OPTS+=flowmgr=y
endif

define KernelPackage/qca-nss-flowmgr/Description
	Networking module for network function flow manager.
endef

define Build/InstallDev/qca-nss-flowmgr
	$(INSTALL_DIR) $(1)/usr/include/qca-nss-netfn
	$(CP) $(PKG_BUILD_DIR)/exports/* $(1)/usr/include/qca-nss-netfn/
endef

MAKE_OPTS+=netlink=y

define Build/InstallDev
	$(call Build/InstallDev/qca-nss-flowmgr,$(1))
endef

EXTRA_CFLAGS+= \
	-I$(PKG_BUILD_DIR)/exports \
	-I$(PKG_BUILD_DIR)/offload/exports \
	-I$(STAGING_DIR)/usr/include/qca-nss-ppe \
	-I$(STAGING_DIR)/usr/include/qca-nss-sfe

define Build/Compile
	$(KERNEL_MAKE) $(strip $(MAKE_OPTS)) \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		ARCH="$(LINUX_KARCH)" \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		modules
endef

$(eval $(call KernelPackage,qca-nss-netfn-tcpst))
$(eval $(call KernelPackage,qca-nss-netfn-sk-offload))
$(eval $(call KernelPackage,qca-nss-flowmgr))

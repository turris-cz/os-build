include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qca-nss-ecm
PKG_RELEASE:=1
PKG_VERSION:=1.0.r29

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/oss/lklm/qca-nss-ecm.git
PKG_MIRROR_HASH:=68abd77147aac23d5b38c03239e1a91e1c3b9ef7aade4e66710b02d84e114a1b
PKG_SOURCE_VERSION:=win.nss.$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

ifeq ($(CONFIG_QCA_NSS_ECM_EXAMPLES_PCC),y)
       FILES_EXAMPLES=$(PKG_BUILD_DIR)/examples/ecm_pcc_test.ko
endif

ifeq ($(CONFIG_QCA_NSS_ECM_EXAMPLES_MARK),y)
       FILES_EXAMPLES+=$(PKG_BUILD_DIR)/examples/ecm_mark_test.ko
endif

ifeq ($(CONFIG_QCA_NSS_ECM_EXAMPLES_SDX),y)
	FILES_EXAMPLES=$(PKG_BUILD_DIR)/examples/ecm_sdx_pcc.ko
endif

define KernelPackage/qca-nss-ecm/Default
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Support
  DEPENDS:=+TARGET_ipq806x:kmod-qca-nss-drv \
	+TARGET_ipq_ipq806x:kmod-qca-nss-drv \
	+TARGET_ipq_ipq807x:kmod-qca-nss-drv \
	+TARGET_ipq_ipq807x_64:kmod-qca-nss-drv \
	+TARGET_ipq807x:kmod-qca-nss-drv \
	+TARGET_ipq_ipq60xx:kmod-qca-nss-drv \
	+TARGET_ipq_ipq60xx_64:kmod-qca-nss-drv \
	+TARGET_ipq60xx:kmod-qca-nss-drv \
	+TARGET_ipq_ipq50xx:kmod-qca-nss-drv \
	+TARGET_ipq_ipq50xx_64:kmod-qca-nss-drv \
	+TARGET_ipq50xx:kmod-qca-nss-drv \
	+!(TARGET_ipq53xx_ipq53xx_32_QSDK_256||TARGET_ipq54xx_ipq54xx_32_QSDK_256):iptables-mod-extra \
	+!(TARGET_ipq53xx_ipq53xx_32_QSDK_256||TARGET_ipq54xx_ipq54xx_32_QSDK_256):kmod-ipt-conntrack \
	+(TARGET_ipq53xx_ipq53xx_32_QSDK_256||TARGET_ipq54xx_ipq54xx_32_QSDK_256):kmod-nf-conntrack \
	+!(TARGET_ipq53xx_ipq53xx_32_QSDK_256||TARGET_ipq54xx_ipq54xx_32_QSDK_256):kmod-vxlan \
	+kmod-pppoe @!LINUX_3_18 +kmod-qca-nss-ppe-vp
  TITLE:=QCA NSS Enhanced Connection Manager (ECM)
  FILES:=$(PKG_BUILD_DIR)/*.ko $(FILES_EXAMPLES) $(PKG_BUILD_DIR)/examples/ecm_ae_select.ko
  KCONFIG:=CONFIG_BRIDGE_NETFILTER=y \
	CONFIG_NF_CONNTRACK_EVENTS=y \
	CONFIG_NF_CONNTRACK_CHAIN_EVENTS=y \
	CONFIG_NF_CONNTRACK_DSCPREMARK_EXT=y
  PROVIDES:=kmod-qca-nss-ecm
endef

define KernelPackage/qca-nss-ecm/Description/Default
This package contains the QCA NSS Enhanced Connection Manager
endef

define KernelPackage/qca-nss-ecm/Default/install
	$(INSTALL_DIR) $(1)/etc/firewall.d $(1)/etc/init.d $(1)/usr/bin $(1)/lib/netifd/offload $(1)/etc/config $(1)/etc/uci-defaults $(1)/etc/sysctl.d
	$(INSTALL_DATA) ./files/qca-nss-ecm.firewall $(1)/etc/firewall.d/qca-nss-ecm
	$(INSTALL_BIN) ./files/qca-nss-ecm.init $(1)/etc/init.d/qca-nss-ecm
	$(INSTALL_BIN) ./files/ecm_dump.sh $(1)/usr/bin/
	$(INSTALL_BIN) ./files/on-demand-down $(1)/lib/netifd/offload/on-demand-down
	$(INSTALL_DATA) ./files/qca-nss-ecm.uci $(1)/etc/config/ecm
	$(INSTALL_DATA) ./files/qca-nss-ecm.defaults $(1)/etc/uci-defaults/99-qca-nss-ecm
	$(INSTALL_BIN) ./files/qca-nss-ecm.sysctl $(1)/etc/sysctl.d/qca-nss-ecm.conf
ifeq ($(CONFIG_KERNEL_IPQ_MEM_PROFILE),256)
	echo 'net.netfilter.nf_conntrack_max=2048' >> $(1)/etc/sysctl.d/qca-nss-ecm.conf
else ifeq ($(CONFIG_LOWMEM_FLASH),y)
	echo 'net.netfilter.nf_conntrack_max=2048' >> $(1)/etc/sysctl.d/qca-nss-ecm.conf
else ifeq ($(CONFIG_KERNEL_IPQ_MEM_PROFILE),512)
	echo 'net.netfilter.nf_conntrack_max=8192' >> $(1)/etc/sysctl.d/qca-nss-ecm.conf
endif
endef

# Variant with additional features enabled for standard profile
define KernelPackage/qca-nss-ecm-standard
  $(call KernelPackage/qca-nss-ecm/Default)
  TITLE+= (with standard features)
  VARIANT:=standard
  DEPENDS+= \
	+TARGET_ipq95xx:kmod-qca-nss-sfe +TARGET_ipq95xx:kmod-qca-nss-ppe \
	+TARGET_ipq53xx:kmod-qca-nss-sfe +TARGET_ipq53xx:kmod-qca-nss-ppe \
	+TARGET_ipq54xx:kmod-qca-nss-sfe +TARGET_ipq54xx:kmod-qca-nss-ppe \
	+TARGET_ipq96xx:kmod-qca-nss-sfe +TARGET_ipq54xx:kmod-qca-nss-ppe \
	+TARGET_ipq52xx:kmod-qca-nss-sfe +TARGET_ipq52xx:kmod-qca-nss-ppe \
	+!(TARGET_ipq53xx_ipq53xx_32_QSDK_256||TARGET_ipq54xx_ipq54xx_32_QSDK_256)&&(TARGET_ipq53xx||TARGET_ipq54xx):kmod-bonding \
	+TARGET_ipq95xx:kmod-bonding
endef

define KernelPackage/qca-nss-ecm-standard/Description
  $(call KernelPackage/qca-nss-ecm/Description/Default)
endef

define KernelPackage/qca-nss-ecm-standard/install
$(call KernelPackage/qca-nss-ecm/Default/install, $(1))
endef

# Variant with additional features enabled for noload profile
define KernelPackage/qca-nss-ecm-noload
  $(call KernelPackage/qca-nss-ecm/Default)
  TITLE+= (with noload features)
  PROVIDES:=kmod-qca-nss-ecm
  VARIANT:=noload
  DEPENDS+=+kmod-l2tp +kmod-pppol2tp +kmod-pptp +TARGET_ipq95xx:kmod-qca-nss-sfe +TARGET_ipq95xx:kmod-qca-nss-ppe \
	   +TARGET_ipq96xx:kmod-qca-nss-sfe +TARGET_ipq96xx:kmod-qca-nss-ppe \
	   +TARGET_ipq52xx:kmod-qca-nss-sfe +TARGET_ipq52xx:kmod-qca-nss-ppe \
	   +TARGET_ipq53xx:kmod-qca-nss-sfe +TARGET_ipq53xx:kmod-qca-nss-ppe \
	   +TARGET_ipq54xx:kmod-qca-nss-sfe +TARGET_ipq54xx:kmod-qca-nss-ppe \
	   +kmod-bonding
endef

define KernelPackage/qca-nss-ecm-noload/Description
  $(call KernelPackage/qca-nss-ecm/Description/Default)
  When selected, this package installs the driver but does not load it at init.
endef

define KernelPackage/qca-nss-ecm-noload/install
$(call KernelPackage/qca-nss-ecm/Default/install, $(1))
	#
	# Remove the START line from the init script, so that the symlink
	# in the /etc/rc.d directory is not created.
	#
	sed -i '/START=/d' $(1)/etc/init.d/qca-nss-ecm
endef

define Build/InstallDev/qca-nss-ecm
	$(INSTALL_DIR) $(1)/usr/include/qca-nss-ecm
	$(CP) $(PKG_BUILD_DIR)/exports/* $(1)/usr/include/qca-nss-ecm/
endef

define Build/InstallDev
	$(call Build/InstallDev/qca-nss-ecm,$(1))
endef

EXTRA_CFLAGS+= \
	-I$(STAGING_DIR)/usr/include/qca-nss-drv

ifeq ($(CONFIG_KERNEL_KASAN), y)
EXTRA_CFLAGS+= -Wframe-larger-than=2500
endif

EXTRA_CFLAGS+= \
	-I$(STAGING_DIR)/usr/include \
	-I$(STAGING_DIR)/usr/include/qca-nss-sfe \
	-I$(STAGING_DIR)/usr/include/qca-nss-ppe

ifneq ($(CONFIG_KERNEL_IPQ_MEM_PROFILE),256)
ifneq ($(CONFIG_LOWMEM_FLASH),y)
EXTRA_CFLAGS+= -I$(STAGING_DIR)/usr/include/nat46
endif
endif

ifneq ($(CONFIG_PACKAGE_kmod-ath),)
ECM_MAKE_OPTS+=ECM_OPEN_PROFILE_ENABLE=y
endif

ifeq ($(CONFIG_TARGET_ipq53xx)$(CONFIG_TARGET_ipq95xx)$(CONFIG_TARGET_ipq54xx),y)
ifeq ($(CONFIG_TARGET_ipq53xx_ipq53xx_32_QSDK_256)$(CONFIG_TARGET_ipq54xx_ipq54xx_32_QSDK_256),)
ECM_MAKE_OPTS+=ECM_INTERFACE_BOND_ENABLE=y
endif
endif

ifneq ($(CONFIG_KERNEL_IPQ_MEM_PROFILE),256)
ifneq ($(CONFIG_LOWMEM_FLASH),y)
ifneq ($(CONFIG_XFRM),)
ECM_MAKE_OPTS+=ECM_XFRM_ENABLE=y
endif
ECM_MAKE_OPTS+=ECM_NON_PORTED_SUPPORT_ENABLE=y
endif
endif

ifneq ($(CONFIG_TARGET_ipq53xx)$(CONFIG_TARGET_ipq95xx)$(CONFIG_TARGET_ipq54xx),)
ECM_MAKE_OPTS+=ECM_INTERFACE_SKIP_ACCEL_ENABLE=n
ECM_MAKE_OPTS+=ECM_INTERFACE_DSA_ENABLE=y
endif

ifeq ($(CONFIG_KERNEL_IPQ_MEM_PROFILE),256)
ECM_MAKE_OPTS+=ECM_FRONT_END_CONN_LIMIT_ENABLE=y
ECM_MAKE_OPTS+=ECM_256M_PROFILE=y
else ifeq ($(CONFIG_LOWMEM_FLASH),y)
ECM_MAKE_OPTS+=ECM_FRONT_END_CONN_LIMIT_ENABLE=y
endif

ifneq ($(CONFIG_TARGET_ipq95xx),)
ECM_MAKE_OPTS+=ECM_FRONT_END_SFE_ENABLE=y
ECM_MAKE_OPTS+=ECM_FRONT_END_PPE_ENABLE=y
FILES_EXAMPLES+=$(PKG_BUILD_DIR)/examples/ecm_sfe_l2.ko
endif

ifneq ($(CONFIG_TARGET_ipq53xx),)
ECM_MAKE_OPTS+=ECM_FRONT_END_SFE_ENABLE=y
ECM_MAKE_OPTS+=ECM_FRONT_END_PPE_ENABLE=y
ECM_MAKE_OPTS+=ECM_MHT_ENABLE=y
FILES_EXAMPLES+=$(PKG_BUILD_DIR)/examples/ecm_sfe_l2.ko
endif

ifneq ($(CONFIG_TARGET_ipq54xx),)
ECM_MAKE_OPTS+=ECM_FRONT_END_SFE_ENABLE=y
ECM_MAKE_OPTS+=ECM_FRONT_END_PPE_ENABLE=y
ECM_MAKE_OPTS+=ECM_MHT_ENABLE=y
FILES_EXAMPLES+=$(PKG_BUILD_DIR)/examples/ecm_sfe_l2.ko
endif

ifneq ($(CONFIG_TARGET_ipq96xx),)
ECM_MAKE_OPTS+=ECM_FRONT_END_SFE_ENABLE=y
ECM_MAKE_OPTS+=ECM_FRONT_END_PPE_ENABLE=y
ECM_MAKE_OPTS+=ECM_MHT_ENABLE=y
FILES_EXAMPLES+=$(PKG_BUILD_DIR)/examples/ecm_sfe_l2.ko
endif

ifneq ($(CONFIG_TARGET_ipq52xx),)
ECM_MAKE_OPTS+=ECM_FRONT_END_SFE_ENABLE=y
ECM_MAKE_OPTS+=ECM_FRONT_END_PPE_ENABLE=y
ECM_MAKE_OPTS+=ECM_MHT_ENABLE=y
FILES_EXAMPLES+=$(PKG_BUILD_DIR)/examples/ecm_sfe_l2.ko
endif

ifneq ($(findstring 6.1, $(LINUX_VERSION)),)
ECM_MAKE_OPTS+=ECM_CLASSIFIER_WIFI_ENABLE=y
endif

ifneq ($(findstring 6.6, $(LINUX_VERSION)),)
ECM_MAKE_OPTS+=ECM_CLASSIFIER_WIFI_ENABLE=y
endif

ifneq ($(CONFIG_PACKAGE_kmod-ath),)
ECM_MAKE_OPTS+=ECM_CLASSIFIER_WIFI_ENABLE=y
endif

ifneq ($(CONFIG_PACKAGE_kmod-qca-nss-ppe-qdisc),)
ECM_MAKE_OPTS+=ECM_FRONT_END_PPE_QOS_ENABLE=y
endif

ifeq ($(CONFIG_TARGET_ipq53xx)$(CONFIG_TARGET_ipq95xx)$(CONFIG_TARGET_ipq54xx), y)
ifneq ($(CONFIG_KERNEL_IPQ_MEM_PROFILE),256)
ECM_MAKE_OPTS+=ECM_INTERFACE_L2TPV3_ENABLE=y
endif
endif

ifeq ($(CONFIG_TARGET_ipq53xx)$(CONFIG_TARGET_ipq95xx)$(CONFIG_TARGET_ipq54xx), y)
ECM_MAKE_OPTS+=ECM_FRONT_END_BRIDGE_ISOLATION_ENABLE=y
endif

# Disable ECM IPv6 support when global IPv6 support is disabled.
ifneq ($(CONFIG_IPV6),)
ECM_MAKE_OPTS+=ECM_IPV6_ENABLE=y
endif

# Disable ECM Bridge VLAN Filtering support when global kernel config is disabled
ifneq ($(CONFIG_BRIDGE_VLAN_FILTERING),)
ECM_MAKE_OPTS+=ECM_BRIDGE_VLAN_FILTERING_ENABLE=y
endif

# Keeping default as ipq806x for branches that does not have subtarget framework
ifeq ($(CONFIG_TARGET_ipq),y)
subtarget:=$(SUBTARGET)
else
subtarget:=$(CONFIG_TARGET_BOARD)
endif

# Enable NSS frontend for all the platforms except ipq40xx, ipq95xx, ipq52xx, ipq53xx and ipq54xx
ifeq ($(CONFIG_TARGET_ipq_ipq40xx)$(CONFIG_TARGET_ipq40xx)$(CONFIG_TARGET_ipq95xx)$(CONFIG_TARGET_ipq53xx)$(CONFIG_TARGET_ipq54xx)$(CONFIG_TARGET_ipq96xx)$(CONFIG_TARGET_ipq52xx),)
ECM_MAKE_OPTS+=ECM_FRONT_END_NSS_ENABLE=y
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/qca-nss-ecm
	$(CP) $(PKG_BUILD_DIR)/exports/* $(1)/usr/include/qca-nss-ecm
endef

define Build/Compile
	$(KERNEL_MAKE) $(strip $(ECM_MAKE_OPTS)) \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" SoC="$(subtarget)" \
		EXAMPLES_BUILD_PCC="$(CONFIG_QCA_NSS_ECM_EXAMPLES_PCC)" \
		EXAMPLES_BUILD_MARK="$(CONFIG_QCA_NSS_ECM_EXAMPLES_MARK)" \
		EXAMPLES_BUILD_OVS="$(CONFIG_QCA_NSS_ECM_OVS)" \
		BUILD_ECM_WIFI_PLUGIN="$(CONFIG_QCA_NSS_ECM_WIFI_PLUGIN)" \
		EXAMPLES_BUILD_SDX="$(CONFIG_QCA_NSS_ECM_EXAMPLES_SDX)" \
		modules
endef

$(eval $(call KernelPackage,qca-nss-ecm-noload))
$(eval $(call KernelPackage,qca-nss-ecm-standard))

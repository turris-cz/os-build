include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=telemetry-agent
PKG_VERSION:=1.1.r29
PKG_RELEASE:=1
PKG_SOURCE_URL:=https://git.codelinaro.org/clo/qsdk/wifi/qca-telemetry-agent-oss.git
PKG_SOURCE_PROTO:=git
PKG_MIRROR_HASH:=ceb4912c93b6f76317f0c2749c30cae51b3465d23f42a021da6f9c3922fe0d9b
PKG_SOURCE_VERSION:=win_wlan_host.$(PKG_VERSION)
PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define KernelPackage/$(PKG_NAME)
  TITLE:=Telemetry Agent
  DEPENDS:=+kmod-ath12k
  FILES:=$(PKG_BUILD_DIR)/telemetry_agent.ko
endef

define KernelPackage/$(PKG_NAME)/description
	This package contains telemetry agent support for open source profile.
endef

MAKE_OPTS:= -C "$(PKG_BUILD_DIR)" \
	CROSS_COMPILE="$(KERNEL_CROSS)" \
	ARCH="$(LINUX_KARCH)" \
	EXTRA_CFLAGS="-Wall -Werror -Wno-unused-variable" \
	KERNEL_PATH="${LINUX_DIR}" \
	BUILD_PROFILE="Open" \
	PWD="$(PKG_BUILD_DIR)"
define Build/InstallDev
        $(CP) $(PKG_BUILD_DIR)/inc/telemetry_agent_app_if.h $(STAGING_DIR)/usr/include
endef

define Build/Compile
	$(KERNEL_MAKE) $(MAKE_OPTS) all
endef

$(eval $(call KernelPackage,$(PKG_NAME)))

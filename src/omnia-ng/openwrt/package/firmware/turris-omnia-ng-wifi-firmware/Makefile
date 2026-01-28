#
# Copyright (C) 2025 CZ.NIC z.s.p.o. (http://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=turris-omnia-ng-wifi-firmware
PKG_RELEASE:=3

include $(INCLUDE_DIR)/package.mk

define Package/turris-omnia-ng-wifi-firmware
  TITLE:=Turris Omnia NG Wi-Fi firmware (ath11k + ath12k)
  SECTION:=firmware
  CATEGORY:=Firmware
  DEPENDS:=+wireless-regdb
endef

define Build/Compile
endef

define Package/turris-omnia-ng-wifi-firmware/install
	$(INSTALL_DIR) $(1)/lib/firmware/IPQ9574/
	$(INSTALL_DATA) \
		./files/IPQ9574-github/m3_fw.* ./files/IPQ9574-github/q6_fw.* \
		$(1)/lib/firmware/IPQ9574/
	$(INSTALL_DIR) $(1)/lib/firmware/ath11k/IPQ9574/hw1.0/
	$(INSTALL_DATA) \
		./files/IPQ9574-codelinaro/board-2.bin \
		./files/caldata.bin \
		$(1)/lib/firmware/ath11k/IPQ9574/hw1.0/
	$(INSTALL_DIR) $(1)/lib/firmware/ath12k/QCN92XX/hw1.0/
	$(INSTALL_DATA) \
		./files/qcn9224/amss.bin \
		./files/qcn9224/amss_dualmac.bin \
		./files/qcn9224/board-2.bin \
		./files/qcn9224/m3.bin \
		./files/qcn9224/qdss_trace_config.bin \
		./files/qcn9224/regdb.bin \
		$(1)/lib/firmware/ath12k/QCN92XX/hw1.0/
	$(INSTALL_DATA) ./files/qcn9224/rxgainlutSKY_6G.bin \
		$(1)/lib/firmware/ath12k/QCN92XX/hw1.0/rxgainlut.bin
endef

$(eval $(call BuildPackage,turris-omnia-ng-wifi-firmware))

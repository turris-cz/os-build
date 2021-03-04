include(utils.m4)dnl
_FEATURE_GUARD_

-- 3G
Install("br2684ctl", "comgt", "uqmi", { priority = 40 })
Install("ppp-mod-pppoe", "pptpd", { priority = 40 })
Install("usb-modeswitch", { priority = 40 })

-- Kernel
forInstall(kmod,nf-nathelper-extra,usb-net-rndis,usb-net-qmi-wwan,usb-serial-option,usb-serial-qualcomm)

-- Luci
Install("luci-proto-3g", "luci-proto-qmi", { priority = 40 })

_END_FEATURE_GUARD_

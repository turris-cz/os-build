include(utils.m4)dnl
_FEATURE_GUARD_

-- Kernel
Install("kmod-usb-printer", { priority = 40 })

-- Luci
Install("luci-app-p910nd", { priority = 40 })

_END_FEATURE_GUARD_

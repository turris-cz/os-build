include(utils.m4)dnl Include utility macros
include(luci-utils.m4)dnl
_FEATURE_GUARD_

-- Kernel
Install("kmod-usb-printer", { priority = 40 })

-- Luci
luci_app("p910nd")

_END_FEATURE_GUARD_

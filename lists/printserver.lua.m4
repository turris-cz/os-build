include(utils.m4)dnl Include utility macros
_FEATURE_GUARD_

-- Kernel
Install("kmod-usb2", "kmod-usb-printer", { priority = 40 })

-- Luci
Install("luci-app-p910nd", { priority = 40 })
_LUCI_I18N_(p910nd)

_END_FEATURE_GUARD_

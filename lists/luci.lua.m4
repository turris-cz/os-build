include(utils.m4)dnl Include utility macros
_FEATURE_GUARD_

Install("luci", "luci-lighttpd", { priority = 40 })
forInstall(luci,base,proto-ipv6,proto-ppp,app-commands)
_LUCI_I18N_(base, commands)

_END_FEATURE_GUARD_

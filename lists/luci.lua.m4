-- Luci
Install("luci", "luci-lighttpd", { priority = 40 })
forInstall(luci,base,proto-ipv6,proto-ppp,app-commands)
_LUCI_I18N_(base, commands)


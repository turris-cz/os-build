include(utils.m4)dnl Include utility macros
include(luci-utils.m4)dnl
_FEATURE_GUARD_

Install("luci", "luci-base", "luci-lighttpd", { priority = 40 })
if for_l10n then
	Install("luci-i18n-base-en", { optional = true })
	for_l10n("luci-i18n-base-")
end

luci_app("commands")
luci_proto("ipv6", "ppp")

_END_FEATURE_GUARD_

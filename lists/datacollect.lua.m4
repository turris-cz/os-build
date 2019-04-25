include(utils.m4)dnl Include utility macros
_FEATURE_GUARD_

Install("foris-data_collect-plugin", { priority = 40 })
Install("server-uplink", { priority = 40 })
if for_l10n then
	for_l10n("foris-data_collect-plugin-l10n-")
end

Install("sentinel-dynfw-client", { priority = 40 })

_END_FEATURE_GUARD_

include(utils.m4)dnl Include utility macros
_FEATURE_GUARD_

foris_plugins = {
	"data_collect",
	"diagnostics",
	"netmetr",
	"openvpn",
	"pakon",
	"ssbackups",
	"storage",
	"subordinates",
}


Install("foris", "foris-diagnostics-plugin", "foris-storage-plugin", "lighttpd-https-cert", { priority = 40 })

if for_l10n then
	for_l10n("foris-l10n-")
	for_l10n('pkglists-l10n-')
	for plugin in pairs(foris_plugins) do
		if installed[plugin] then
			for_l10n("foris-" .. plugin .. "-plugin-l10n-")
		end
	end
end

_END_FEATURE_GUARD_

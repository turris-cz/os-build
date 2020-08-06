include(utils.m4)dnl
_FEATURE_GUARD_

local foris_plugins = {
	"data_collect",
	"diagnostics",
	"netmetr",
	"openvpn",
	"pakon",
	"plugins-distutils",
	"ssbackups",
	"storage",
	"subordinates",
}

local reforis_plugins = {
	"data-collection",
	"diagnostics",
	"netboot",
	"netmetr",
	"openvpn",
	"remote-access",
	"remote-devices",
	"remote-wifi-settings",
	"snapshots",
}

-- Conditional install requests for language packages
if for_l10n and features.request_condition then
	for _, lang in pairs(l10n or {}) do
		for _, plugin in pairs(foris_plugins) do
			local fplugin = "foris-" .. plugin .. "-plugin"
			Install(fplugin .. "-l10n-" .. lang, {
				priority = 10,
				optional = true,
				condition = fplugin
			})
		end
		for _, plugin in pairs(reforis_plugins) do
			local refplugin = "reforis-" .. plugin .. "-plugin"
			Install(refplugin .. "-l10n-" .. lang, {
				priority = 10,
				optional = true,
				condition = refplugin
			})
		end
	end
end

----------------------------------------------------------------------------------

Install("foris", { priority = 40 })
Install("foris-diagnostics-plugin", "foris-storage-plugin", { priority = 40 })

Install("reforis", { priority = 40 })
Install("reforis-diagnostics-plugin", { priority = 40 })
Install("reforis-snapshots-plugin", { priority = 40 })

if for_l10n then
	for_l10n("foris-l10n-")
	for_l10n("reforis-l10n-")
	for_l10n('pkglists-l10n-')
end

Install("lighttpd-https-cert", { priority = 40 })

_END_FEATURE_GUARD_

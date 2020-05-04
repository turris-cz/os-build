include(utils.m4)dnl
_FEATURE_GUARD_

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
		for _, plugin in pairs(reforis_plugins) do
			local refplugin = "reforis-" .. plugin .. "-plugin"
			Install(refplugin .. "-l10n-" .. lang, {
				priority = 40,
				optional = true,
				condition = refplugin
			})
		end
	end
end

----------------------------------------------------------------------------------

Install("reforis", { priority = 40 })
Install("reforis-diagnostics-plugin", { priority = 40 })
Install("reforis-snapshots-plugin", { priority = 40 })

if for_l10n then
	for_l10n("reforis-l10n-")
	for_l10n('pkglists-l10n-')
end

Install("lighttpd-https-cert", { priority = 40 })

_END_FEATURE_GUARD_

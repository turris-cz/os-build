include(utils.m4)dnl
_FEATURE_GUARD_

local reforis_plugins = {
	["data-collection"] = "sentinel-proxy",
	["haas"] = "haas-proxy",
	["diagnostics"] = "turris-diagnostics",
	["netboot"] = "turris-netboot-tools",
	["netmetr"] = "netmetr",
	["openvpn"] = "openvpn",
	["remote-access"] = false,
	["remote-devices"] = false,
	["remote-wifi-settings"] = false,
	["snapshots"] = "schnapps",
}

----------------------------------------------------------------------------------

Install("reforis", "reforis-storage-plugin", { priority = 40 })

for plugin, condition in pairs(reforis_plugins) do
	local refplugin = "reforis-" .. plugin .. "-plugin"
	if condition ~= false then
		Install(refplugin, { priority = 40, condition = condition or nil })
	end
	for _, lang in pairs(l10n or {}) do
		Install(refplugin .. "-l10n-" .. lang, {
			priority = 10,
			optional = true,
			condition = refplugin
		})
	end
end

if for_l10n then
	for_l10n("reforis-l10n-")
	for_l10n('pkglists-l10n-')
end

Install("lighttpd-https-cert", { priority = 40 })

_END_FEATURE_GUARD_

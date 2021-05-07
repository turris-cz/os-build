include(utils.m4)dnl
_FEATURE_GUARD_

local foris_plugins = {
	["diagnostics"] = "turris-diagnostics",
	["netmetr"] = "netmetr",
	["openvpn"] = "openvpn",
	["pakon"] = "pakon",
	["storage"] = false,
	["subordinates"] = "turris-netboot-tools",
}

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

Install("foris", "foris-storage-plugin", { priority = 40 })
Install("reforis", "reforis-storage-plugin", { priority = 40 })

for plugin, condition in pairs(foris_plugins) do
	local fplugin = "foris-" .. plugin .. "-plugin"
	if condition ~= false then
		Install(fplugin, { priority = 40, condition = condition })
	end
	for _, lang in pairs(l10n or {}) do
		Install(fplugin .. "-l10n-" .. lang, {
			priority = 10,
			optional = true,
			condition = fplugin
		})
	end
end

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
	for_l10n("foris-l10n-")
	for_l10n("reforis-l10n-")
	for_l10n('pkglists-l10n-')
end

Install("lighttpd-https-cert", { priority = 40 })

-- Workaround how to install foris-controller-nextcloud-module
-- because there is no nextcloud-plugin
Install("foris-controller-nextcloud-module", { condition = {"nextcloud", "foris-controller-storage-module"} })

_END_FEATURE_GUARD_

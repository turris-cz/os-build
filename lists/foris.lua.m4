include(utils.m4)dnl Include utility macros
_FEATURE_GUARD_

Install("foris", "foris-diagnostics-plugin", "foris-storage-plugin", "lighttpd-https-cert", { priority = 40 })


--[[
All foris plugins
Generated using:
 curl https://repo.turris.cz/hbd/omnia/packages/turrispackages/Packages | sed -n 's/^Package: foris-\([^-]\+\)-plugin.*/\1/p' | sort | uniq | sed 's/^/"/;s/$/",/'
]]
local foris_plugins = {
	"data_collect",
	"diagnostics",
	"netmetr",
	"openvpn",
	"pakon",
	"ssbackups",
	"storage",
	"subordinates",
}

if for_l10n then
	for_l10n("foris-l10n-")
	for_l10n('pkglists-l10n-')
	for _, plugin in pairs(foris_plugins) do
		if installed["foris-" .. plugin .. "-plugin"] then
			for_l10n("foris-" .. plugin .. "-plugin-l10n-")
		end
	end
end

_END_FEATURE_GUARD_

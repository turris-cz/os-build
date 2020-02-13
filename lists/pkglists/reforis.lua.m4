include(utils.m4)dnl
_FEATURE_GUARD_

Install("reforis", { priority = 40 })
Install("reforis-diagnostics-plugin", { priority = 40 })
Install("reforis-snapshots-plugin", { priority = 40 })

if for_l10n then
	for_l10n("reforis-l10n-")
end


-- Install reforis plugins if foris ones are installed
if features.request_condition then
	local mapping = {
		["diagnostics"] = "diagnostics",
		["openvpn"] = "openvpn",
		["remote-access"] = "subordinates",
		["remote-devices"] = "subordinates",
	}
	for reforis, foris in pairs(mapping) do
		Install("reforis-" .. reforis .. "-plugin", {
			priority = 40,
			condition = "foris-" .. foris .. "-plugin"
		})
	end
end


_END_FEATURE_GUARD_

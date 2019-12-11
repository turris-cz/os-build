include(utils.m4)dnl
include(foris-utils.m4)dnl
_FEATURE_GUARD_

Install("reforis", { priority = 40 })
if for_l10n then
	for_l10n("reforis-l10n-")
end

reforis_plugin("diagnostics", "openvpn")

_END_FEATURE_GUARD_

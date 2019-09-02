include(utils.m4)dnl
include(foris-utils.m4)dnl
_FEATURE_GUARD_

Install("foris", { priority = 40 })
if for_l10n then
	for_l10n("foris-l10n-")
	for_l10n('pkglists-l10n-')
end

foris_plugin("diagnostics", "storage")

Install("lighttpd-https-cert", { priority = 40 })

_END_FEATURE_GUARD_

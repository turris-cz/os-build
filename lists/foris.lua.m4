include(utils.m4)dnl Include utility macros
_FEATURE_GUARD_

Install("foris", "foris-diagnostics-plugin", "foris-storage-plugin", "lighttpd-https-cert", { priority = 40 })
if for_l10n then
	for_l10n("foris-l10n-")
	for_l10n("foris-diagnostics-plugin-l10n-")
	for_l10n("foris-storage-plugin-l10n-")
	for_l10n('pkglists-l10n-')
end

_END_FEATURE_GUARD_

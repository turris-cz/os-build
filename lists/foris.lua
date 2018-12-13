_FEATURE_GUARD_

Install("foris", "foris-diagnostics-plugin", "turris-webapps", "lighttpd-https-cert", { priority = 40 })
Install('userlists', { priority = 40 })
if for_l10n then
	for_l10n("foris-l10n-")
	for_l10n("foris-diagnostics-plugin-l10n-")
	for_l10n('userlists-l10n-')
end

_END_FEATURE_GUARD_

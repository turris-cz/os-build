include(utils.m4)dnl Include utility macros
_FEATURE_GUARD_

forInstall(luci-app,ahcp,firewall,minidlna,mjpg-streamer,statistics,tinyproxy,transmission,upnp)
forInstall(luci-proto,openconnect,relay,vpnc)
Install("luci-theme-bootstrap", { priority = 40 })
if board == "omnia" or board == "turris1x" then
	Install('luci-app-rainbow', { priority = 40 })
end

_LUCI_I18N_(ahcp, firewall, minidlna, statistics, tinyproxy, transmission, upnp)

_END_FEATURE_GUARD_

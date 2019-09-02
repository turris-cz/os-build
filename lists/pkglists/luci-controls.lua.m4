include(utils.m4)dnl
include(luci-utils.m4)dnl
_FEATURE_GUARD_

luci_app("ahcp", "adblock", "bcp38", "firewall", "minidlna", "mjpg-streamer", "sqm", "statistics", "tinyproxy", "transmission", "upnp")
if board == "omnia" or board == "turris1x" then
	luci_app('rainbow')
end
luci_proto("openconnect", "relay", "vpnc")

_END_FEATURE_GUARD_

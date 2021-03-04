include(utils.m4)dnl
_FEATURE_GUARD_

if board == "omnia" or board == "turris1x" then
	Install("luci-app-rainbow", { priority = 40 })
end

-- Additional protocols
forInstall(luci-app,ahcp,bcp38)
Install("luci-proto-relay", { priority = 40 })


if options and options.adblock then
	Install("luci-app-adblock", { priority = 40 })
end

if options and options.sqm then
	Install("luci-app-sqm", { priority = 40 })
end

if options and options.tinyproxy then
	Install("luci-app-tinyproxy", { priority = 40 })
end

if options and options.upnp then
	Install("luci-app-upnp", { priority = 40 })
end

if options and options.printserver then
	Install("kmod-usb-printer", { priority = 40 })
	Install("luci-app-p910nd", { priority = 40 })
end

if options and options.statistics then
	Install("luci-app-statistics", { priority = 40 })
end

if options and options.wireguard then
        Install("luci-app-wireguard", { priority = 40 })
end

_END_FEATURE_GUARD_

include(utils.m4)dnl
_FEATURE_GUARD_

local apps = {
	"ahcp",
	"adblock",
	"bcp38",
	"firewall",
	"minidlna",
	"mjpg-streamer",
	"sqm",
	"statistics",
	"tinyproxy",
	"transmission",
	"upnp"
}

local proto = {
	"openconnect",
	"relay",
	"vpnc"
}


for _, app in pairs(apps) do
	Install("luci-app-" .. app, { priority = 40 })
end

if board == "omnia" or board == "turris1x" then
	Install('luci-app-rainbow', { priority = 40 })
end

for _, proto in pairs(proto) do
	Install("luci-proto-" .. proto, { priority = 40 })
end

_END_FEATURE_GUARD_

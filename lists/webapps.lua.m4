include(utils.m4)dnl
_FEATURE_GUARD_

local webapps = {
	["luci"] = "luci-base",
	["netdata"] = "netdata",
	["nextcloud"] = "nextcloud",
	["transmission"] = "transmission",
	["tvheadend"] = "tvheadend",
}

Install("turris-webapps", { priority = 40 })

for webapp, condition in pairs(webapps) do
	Install("turris-webapps-" .. webapp, {
		condition = condition or nil,
		priority = 40
	})
end

_END_FEATURE_GUARD_

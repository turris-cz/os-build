include(utils.m4)dnl
_FEATURE_GUARD_

local webapps = {
	["netdata"] = "netdata",
	["transmission"] = "transmission",
	["tvheadend"] = "tvheadend",
	["nextcloud"] = "nextcloud",
}

Install("turris-webapps", { priority = 40 })

for webapp, condition in pairs(webapps) do
	Install("turris-webapps-" .. webapp, {
		condition = condition or nil,
		priority = 40
	})
end

_END_FEATURE_GUARD_

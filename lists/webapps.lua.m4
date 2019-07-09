include(utils.m4)dnl Include utility macros
_FEATURE_GUARD_

-- List of all available webapps packages integrations
webapps = {
	"foris",
	"reforis",
	"luci",
	"transmission",
	"nextcloud",
	"tvheadend",
	"mozilla-iot-gateway",
}


Install("turris-webapps", { priority = 40 })

for app in pairs(webapps) do
	if installed[app] then
		Install(app .. "-webapps", { priority = 20, optional = true })
	end
end

_END_FEATURE_GUARD_

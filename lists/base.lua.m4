include(utils.m4)dnl
include(repository.m4)dnl

list_script('base-min.lua')

_FEATURE_GUARD_

list_script('luci.lua')
list_script('foris.lua')
list_script('terminal-apps.lua')
list_script('webapps.lua')


-- Install various timezone information so local time would work
zoneinfo = {"core", "atlantic", "asia", "africa", "australia-nz", "europe", "northamerica", "india", "pacific", "poles", "simple", "southamerica"}
for _, zone in pairs(zoneinfo) do
	Install("zoneinfo-" .. zone, { priority = 40 })
end

-- IPv6
Install("ds-lite", "6in4", "6rd", "6to4", { priority = 40 })

_END_FEATURE_GUARD_

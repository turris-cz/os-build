include(utils.m4)dnl
_FEATURE_GUARD_

-- No more Foris and LuCI
Uninstall("foris", "luci", "luci-base", { priority = 45 })

-- Extra security
Install('common_passwords', { priority = 45 })

options = {
    "dynfw" = true,
    "haas" = true,
    "survey" = true,
    "nikola" = true,
    "minipot" = true,
}
Export("options")
Script("../pkglists/datacollection.lua")

_END_FEATURE_GUARD_

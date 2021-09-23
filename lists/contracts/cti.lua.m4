include(utils.m4)dnl
_FEATURE_GUARD_

-- Enforce contract
Install("omnia-cti-support", { priority = 60 })

-- Extra security
Install('common_passwords')

-- Data collection
Install('sentinel-i_agree_with_eula')

options = {
    ["dynfw"] = true,
    ["haas"] = true,
    ["survey"] = true,
    ["nikola"] = true,
    ["minipot"] = true,
}
Export("options")
Script("../pkglists/datacollect.lua")
Unexport("options")

_END_FEATURE_GUARD_

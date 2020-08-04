include(utils.m4)dnl
_FEATURE_GUARD_

-- No more Foris and LuCI and data collect UI
Uninstall("foris", "luci", "luci-base", { priority = 45 })
Uninstall("reforis-data-collection-plugin", { priority = 45 })

-- Alternative versions of packages
Install("shield-support", "reforis-shield", { priority = 45 })

-- Extra usability packages
Install("ip_autoselector", "firewall-redirect-192_168_1_1", { priority = 45 })

-- Extra security
Install('common_passwords', { priority = 45 })

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

-- Extra software
Script("../pkglists/netmetr.lua")
Script("../pkglists/openvpn.lua")

_END_FEATURE_GUARD_

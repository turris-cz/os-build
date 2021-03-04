include(utils.m4)dnl
_FEATURE_GUARD_

-- No more Foris and LuCI and data collect UI
Uninstall("foris", "luci", "luci-base", "turris-webapps", { priority = 45 })

-- Alternative versions of packages
Install("shield-support", { priority = 45 })

-- Extra usability packages
Install("ip_autoselector", "firewall-redirect-192-168-1-1", { priority = 45 })

-- Extra security
Install('common_passwords', { priority = 45 })
Install('sentinel-i_agree_with_eula', { priority = 45 })

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
options = {
    ["netmetr"] = true,
    ["dev-detect"] = true,
}
Export("options")
Script("../pkglists/net_monitoring.lua")
Unexport("options")
Script("../pkglists/openvpn.lua")

_END_FEATURE_GUARD_

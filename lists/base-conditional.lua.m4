-- Packages extensions and integrations with other with indirect dependencies
include(utils.m4)dnl

_FEATURE_GUARD_

-- Install replacement link for python when python-base is not installed and python3-base is
Install("python3-python", { condition = {Not("python-base"), "python3-base"}, priority = 40 })

-- Reload of OpenVPN on network restart to ensure fast reconnect
Install("openvpn-hotplug", { priority = 30, condition = "openvpn" })


_END_FEATURE_GUARD_

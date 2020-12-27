-- Packages extensions and integrations with other with indirect dependencies
include(utils.m4)dnl

_FEATURE_GUARD_

-- Reload of OpenVPN on network restart to ensure fast reconnect
Install("openvpn-hotplug", { priority = 30, condition = "openvpn" })


_END_FEATURE_GUARD_

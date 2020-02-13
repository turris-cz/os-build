include(utils.m4)dnl
_FEATURE_GUARD_

Install("foris-openvpn-plugin", { priority = 40 })
Install("openvpn-openssl", "openvpn-hotplug", "dhparam", { priority = 40 })

_END_FEATURE_GUARD_

include(utils.m4)dnl
_FEATURE_GUARD_

-- OpenVPN itself
Install("openvpn-crypto", { priority = 40 })

-- CA management for OpenVPN server
Install("turris-cagen", "dhparam", { priority = 40 })

_END_FEATURE_GUARD_

include(utils.m4)dnl Include utility macros
include(foris-utils.m4)dnl
_FEATURE_GUARD_

foris_plugin("openvpn")
Install("openvpn-openssl", "dhparam", { priority = 40 })

_END_FEATURE_GUARD_

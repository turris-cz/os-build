include(utils.m4)dnl
_FEATURE_GUARD_

Install("turris-netboot-tools", { priority = 40 })

Install("foris-subordinates-plugin", { priority = 40 })

Install("reforis-remote-access-plugin", { priority = 40 })
Install("reforis-remote-devices-plugin", "reforis-remote-wifi-settings-plugin", { priority = 40 })

_END_FEATURE_GUARD_

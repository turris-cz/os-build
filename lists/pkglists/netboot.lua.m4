include(utils.m4)dnl
_FEATURE_GUARD_

Install("foris-subordinates-plugin", { priority = 40 })
Install("reforis-remote-access-plugin", "reforis-remote-devices-plugin", { priority = 40 })

_END_FEATURE_GUARD_

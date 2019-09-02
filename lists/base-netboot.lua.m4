include(utils.m4)dnl
include(repository.m4)dnl

list_script('base-min.lua')

_FEATURE_GUARD_

Install("turris-netboot-data", { priority = 40 })
Install("foris-controller", { priority = 40 })

_END_FEATURE_GUARD_

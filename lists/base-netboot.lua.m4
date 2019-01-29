include(utils.m4)dnl Include utility macros
include(repository.m4)dnl Include Repository command
Script(repo_base_uri .. "/lists/base-min.lua")

_FEATURE_GUARD_

Install("turris-netboot-data", { priority = 40 })

_END_FEATURE_GUARD_

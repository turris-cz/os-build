include(utils.m4)dnl
_FEATURE_GUARD_

-- Extra security
Install('common_passwords')

-- Force-include data collect
Script("../pkglists/datacollect.lua")

_END_FEATURE_GUARD_

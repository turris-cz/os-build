include(base-min.lua.m4)

_FEATURE_GUARD_

include(luci.lua.m4)
include(foris.lua)
include(terminal-apps.lua)

_END_FEATURE_GUARD_

--[[
We are migrating from uClibc to musl, so reinstall everything depending on libc.
]]
if installed['turris-version'] and version_match(installed['turris-version'].version, '<4.0') then
	Package("libc", { abi_change_deep = true })
	Package('updater-ng', { deps = { 'libgcc' } })
end

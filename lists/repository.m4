dnl This is magic generating Repository command
dnl We expect this to be include in base.lua just after utils.m4
divert(-1)

# This is definition of subrepositories
pushdef(`SUBDIRS',`subdirs = {"base", "core" esyscmd(`awk "/^src-git/{printf \", \\\"%s\\\"\", \$'`2}" feeds.conf')}')

divert(0)dnl
local board
if model:match("[Mm][Oo][Xx]") then
	board = "mox"
elseif model:match("[Oo]mnia") then
	board = "omnia"
elseif model:match("^[Tt]urris$") then
	board = "turris"
else
	DIE("Unsupported Turris model: " .. tostring(model))
end

dnl
dnl Basic turris repository
Repository("turris", "https://repo.turris.cz/" .. board .. "ifdef(`_BRANCH_',-_BRANCH_)/packages", {
	SUBDIRS
})
dnl
dnl Fallback turris repository for not complete branches
dnl In testing branches we are compiling just a minimal set of packages to allow
dnl updater to use all packages we are adding nightly as fallback reposutory.
ifdef(`_BRANCH_FALLBACK_',
`Repository("turris-fallback", "https://repo.turris.cz/" .. board .. "-_BRANCH_FALLBACK_/packages", {
	SUBDIRS,
	priority = 40,
	ignore = {"missing"}
})
')dnl

dnl
divert(-1)

# Now just clean up after our self
popdef(`SUBDIRS')

divert(0)dnl

include(utils.m4)dnl Include utility macros
divert(-1)

# This is definition of subrepositories
pushdef(`SUBDIRS',`subdirs = {"base", "core" esyscmd(`awk "/^src-git/{printf \", \\\"%s\\\"\", \$'`2}" '_FEEDS_)}')

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

dnl Basic turris repository
Repository("turris", repo_base_uri .. "/packages/" .. board, {
	SUBDIRS
})
dnl
divert(-1)

# Now just clean up after our self
popdef(`SUBDIRS')

divert(0)dnl

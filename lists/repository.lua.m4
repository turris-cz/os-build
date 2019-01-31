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

-- Standard Turris OS package repository
Repository("turris", repo_base_uri .. "/packages/" .. board, {
	SUBDIRS
})
-- Minimal faster rolling package repository
if minimal_builds then
	Repository("turris-minimal", repo_base_uri .. "/packages-minimal/" .. board, {
		SUBDIRS,
		ignore = { "missing" }
	})
end
dnl
divert(-1)

# Now just clean up after our self
popdef(`SUBDIRS')

divert(0)dnl

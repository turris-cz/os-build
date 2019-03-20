include(utils.m4)dnl Include utility macros

if not turris_repo_included then -- single include guard

local subdirs = { "base", "core" esyscmd(`awk "/^src-git/{printf \", \\\"%s\\\"\", \$'`2}" '_FEEDS_)}

if features["relative_uri"] then
	local rroot = ".."
else
	local rroot = repo_base_uri or "https://repo.turris.cz/hbs"
end

local pkg_board = board
if pkg_board == "turris1x" then
	pkg_board = "turris"
end

for _, subdir in ipairs(subdirs) do
	-- Standard Turris OS package repository
	Repository("turris-" .. subdir, rroot .. "/packages/" .. pkg_board .. "/" .. subdir)

	-- Minimal faster rolling package repository
	if minimal_builds then
		Repository("turris-minimal-" .. subdir,
			rroot .. "/packages-minimal/" .. pkg_board .. "/" .. subdir,
			{ optional = true })
	end
end

turris_repo_included = true
Export('turris_repo_included')
end

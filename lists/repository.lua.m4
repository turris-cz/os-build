include(utils.m4)dnl

local feeds = { "base", "core" esyscmd(`awk "/^src-git/{printf \", \\\"%s\\\"\", \$'`2}" '_FEEDS_)}

local rroot
local optional_extra
if features.relative_uri then
	rroot = ".."
else
	rroot = repo_base_uri or "https://repo.turris.cz/hbs/" .. board
end

for _, feed in ipairs(feeds) do
	-- Standard Turris OS package repository
	Repository(feed, rroot .. "/packages/" .. feed)
end

INFO("Target Turris OS: _TURRIS_OS_VERSION_")
DBG("Current Turris OS: " .. tostring(os_release.VERSION))

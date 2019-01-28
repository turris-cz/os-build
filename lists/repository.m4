dnl This is common repository include
dnl It guards it against multiple inclusion in subscripts.
if not repo_base_uri then
	-- For backward compatibility we set base uri to HBS to update to updater version with repo_base_uri
	repo_base_uri = "https://repo.turris.cz/hbs"
	Export('repo_base_uri')
end
if not turris_repo_included then
	Script(repo_base_uri .. "/lists/repository.lua")
	turris_repo_included = true
	Export('turris_repo_included')
end

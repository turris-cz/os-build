dnl This is common repository include
dnl It guards it against multiple inclusion in subscripts.
if not turris_repo_included then
	list_script("repository.lua")
	turris_repo_included = true
	Export('turris_repo_included')
end

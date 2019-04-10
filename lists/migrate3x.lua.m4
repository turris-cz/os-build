--[[
This is migration script used to migrate/update system from Turris OS 3.x to 4.x.

We have to update updater first so we do immediate replan and update only updater
itself.
]]

if not version_match or not self_version or version_match(self_version, "<63.0") then

	local board
	if model:match("[Oo]mnia") then
		board = "omnia"
	elseif model:match("^[Tt]urris$") then
		board = "turris"
	else
		DIE("Unsupported Turris model: " .. tostring(model))
	end

	--[[
	We provide access to only HBS repository and to only minimal set of feeds. We
	don't need anything more to update updater.
	]]
	-- TODO move it to hbs when we have v63.0 in hbs
	Repository("turris", "https://repo.turris.cz/hbt/packages/" .. board, {
		subdirs = { "base", "core", "packages", "turrispackages"}
	})

	Install('updater-ng', { critical = true })

	Package('updater-ng', {
		replan = 'immediate',
		deps = { 'libgcc' }
	})
	--[[
	Updater package does not depend on libgcc but it requires it and dependency
	breaks otherwise.
	]]

else

	function for_l10n(fragment)
		-- Dummy function. Languages are ignored and installed later on.
	end
	Export('for_l10n')

	-- We have not yet updated base-files so we do not have /etc/os-release
	-- tos3to4.sh instead provides us with environment variable MODEL
	model = os.getenv('MODEL')
	Export('model')

	-- Call base script to update rest of the base system
	Script("base.lua")
	-- TODO add package containing migration script

end

-- We are potentially migrating from uClibc so reinstall everything depending
-- on it.
--Package("libc", { abi_change_deep = true })

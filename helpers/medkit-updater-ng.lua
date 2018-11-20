--[[
Root script for updater-ng configuration used for medkit generation.

This script expects following variables to be defined in environment:
  BRANCH: target branch for which medkit is being generated.
  L10N: commas separated list of languages to be installed in medkit.
  LISTS: commas separated list of lists to be included in medkit.
]]

-- Load requested localizations
l10n = {}
for lang in os.getenv('L10N'):gmatch('[^,]+') do
	table.insert(l10n, lang)
end
Export('l10n')

-- This is helper function for including localization packages.
-- (This is copy of standard entry function that can be found in pkgupdate conf.lua)
function for_l10n(fragment)
	for _, lang in pairs(l10n or {}) do
		Install(fragment .. lang, {ignore = {'missing'}})
	end
end
Export('for_l10n')

local script_options = {
	security = 'Remote',
	ca = system_cas,
	crl = no_crl,
	pubkey = {}
}
for key in os.getenv('TURRIS_KEYS'):gmatch('[^,]+') do
	table.insert(script_options.pubkey, "file://" .. key)
end
base_url = 'https://repo.turris.cz/' .. os.getenv('BRANCH') .. '/lists/'

-- Aways include base script
Script('turris-base',  base_url .. 'base.lua', script_options)

-- Now include any additional lists
for list in os.getenv('LISTS'):gmatch('[^,]+') do
	Script('turris-' .. list,  base_url .. list .. '.lua', script_options)
end

-- Add test keys
-- TODO: Add condition here for stable branches
Install('cznic-repo-keys-test')

-- Include any optional user script
user_script = os.getenv('UPDATER_SCRIPT')
if user_script and user_script ~= '' then
	Script('user-script', 'file://' .. user_script)
end

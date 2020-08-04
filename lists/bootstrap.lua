--[[
Root script for updater-ng configuration used for bootstrapping new root.

This script expects following variables to be possibly defined in environment:
  BOARD: board name (Mox|Omnia|Turris)
  L10N: commas separated list of languages to be installed in root.
  PKGLISTS: commas separated list of package lists to be included in root. To
    specify options you can optionally add parentheses at the end of package name
    and list pipe separated options inside them. (ex: foo(opt1|opt2),fee)
  CONTRACT: name of contract medkit is generated for. Do not specify for standard
    medkits
  TESTKEY: if definied non-empty then test kyes are included in installation
]]

-- Sanity checks
if root_dir == "/" then
	DIE("Bootstrap is not allowed on root.")
end

-- Load requested localizations
l10n = {}
local env_l10n = os.getenv('L10N')
if env_l10n then
	for lang in env_l10n:gmatch('[^,]+') do
		table.insert(l10n, lang)
	end
end
Export('l10n')

-- This is helper function for including localization packages.
-- (This is copy of standard entry function that can be found in pkgupdate conf.lua)
function for_l10n(fragment)
	for _, lang in pairs(l10n or {}) do
		Install(fragment .. lang, {optional = true})
	end
end
Export('for_l10n')

-- Aways include base script
Script('base.lua')
-- Include any additional lists
local env_pkglists = os.getenv('PKGLISTS')
if env_pkglists then
	for list in env_pkglists:gmatch('[^,]+') do
		local list_name = list:match('^[^(]+') .. ".lua"
		local list_options = list:match('%((.*)%)$')
		options = {}
		Export("options")
		if list_options then
			for opt in list_options:gmatch('[^|]+') do
				options[opt] = true
			end
		end
		Script(list_name .. '.lua')
	end
end
-- Include contract if specified
local env_contract = os.getenv('CONTRACT')
if env_contract and env_contract ~= "" then
	Script('contracts/' .. env_contract .. '.lua')
end

local env_testkey = os.getenv('TESTKEY')
if env_testkey and env_testkey ~= "" then
	Install('cznic-repo-keys-test')
end

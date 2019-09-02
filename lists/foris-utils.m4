
local function foris_plugin(...)
	for plugin in pairs({...}) do
		fplugin = "foris-" .. plugin .. "-plugin"
		Install(fplugin, { priority = 40 })
		if for_l10n then
			for_l10n(fplugin .. "-l10n-")
		end
	end
end



local function luci_app(...)
	for app in pairs(...) do
		Install("luci-app-" .. app, { priority = 40 })
		if for_l10n then
			Install("luci-i18n-" .. app .. "-en", { optional = true })
			for_l10n("luci-i18n-" .. app .. "-")
		end
	end
end

local function luci_proto(...)
	for proto in pairs(...) do
		Install("luci-proto-" .. proto, { priority = 40 })
	end
end


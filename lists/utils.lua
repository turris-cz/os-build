if not turris_utils_included then -- Multiple inclusions guard

if not board then
	model = model or os_release["LEDE_DEVICE_PRODUCT"]
	if model:match("[Mm]ox") then
		board = "mox"
	elseif model:match("[Oo]mnia") then
		board = "omnia"
	elseif model:match("^[Tt]urris$") then
		board = "turris1x"
	else
		DIE("Unsupported Turris model: " .. tostring(model))
	end
	Export('board')
end

turris_utils_included = true
Export('turris_utils_included')
end

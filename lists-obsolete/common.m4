define(`LIST',`--[[
This is temporally script to migrate previous Turris OS 4.0-alpha releases.
]]
if not board then
	local model = model or os_release["LEDE_DEVICE_PRODUCT"]
	if model:match("[Mm]ox") then
		board = "mox"
	elseif model:match("[Oo]mnia") then
		board = "omnia"
	elseif model:match("^[Tt]urris$") or model:match("[Tt]urris 1.x") then
		board = "turris1x"
	else
		DIE("Unsupported Turris model: " .. tostring(model))
	end
end

if features["relative_uri"] then
	Script("../" .. board .. "/lists/patsubst(__file__, `\.m4$', `')")
else
	Script((repo_base_uri or "https://repo.turris.cz/hbs") .. "/" .. board .. "/lists/patsubst(__file__, `\.m4$', `')")
end
')dnl

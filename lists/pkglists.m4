define(`LIST',`--[[
This is temporally script to migrate previous Turris OS 4.0-beta1 releases.
All package lists are now in subdirectory: pkglists
]]
if features["relative_uri"] then
	Script("pkglists/patsubst(__file__, `^.*/\([^/]*\)\.m4$', `\1')")
end')dnl

--[[
Root script for updater-ng configuration used for medkit generation.
]]

Script("https://repo.turris.cz/" .. os.getenv('BRANCH') .. '/lists/bootstrap.lua', {
	pubkey = {
		-- Turris release key
		"data:base64,dW50cnVzdGVkIGNvbW1lbnQ6IFR1cnJpcyByZWxlYXNlIGtleSBnZW4gMQpSV1Rjc2c1VFhHTGRXOWdObEdITi9vZmRzTTBLQWZRSVJCbzVPVlpJWWxWVGZ5STZGR1ZFT0svZQo=",
		-- Turris development key
		"data:base64,dW50cnVzdGVkIGNvbW1lbnQ6IFR1cnJpcyBPUyBkZXZlbCBrZXkKUldTMEZBMU51bjdKRHQwTDhTalJzRFJKR0R2VUNkRGRmczIxZmVpVytxcEdITk1oVlo5MzBoa3kK",
	}
})

-- Include any optional user script
user_script = os.getenv('UPDATER_SCRIPT')
if user_script and user_script ~= '' then
	Script('file://' .. user_script)
end

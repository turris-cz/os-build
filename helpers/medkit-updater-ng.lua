--[[
Root script for updater-ng configuration used for medkit generation.
]]

-- Get target board
model = os.getenv('BOARD')
if not model or model == "" then
	-- TODO we might ask interactively
	DIE("Target model has to be provided by BOARD environment variable.")
end
-- Note: this is named as model for backward compatibility with variable provided
-- by updater version <63
Export('model')

Script("https://repo.turris.cz/" .. os.getenv('BRANCH') .. '/' .. model .. '/lists/bootstrap.lua', {
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

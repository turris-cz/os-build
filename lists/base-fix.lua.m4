-- Fixes and hacks to migrate from older setups

-- ABI changed in libubus with version 2019-12-27
if not version_match or not installed or
		(installed["libubus"] and version_match(installed["libubus"].version, "<2019-12-27")) then
	Package("libubus", { abi_change = true })
end

-- Migrate from Samba3 to Samba4
if installed and installed["samba36-server"] and not installed["samba4-server"] then
	-- This effectively detects that users has Samba3 installed and is installing Samba4
	-- In such case we want to also install fix package to migrate samba config.
	local extra = {}
	if features.request_condition then
		extra.condition = "samba4-server"
	end
	Install("fix-samba-migrate-to-samba4", extra)
	Package("fix-samba-migrate-to-samba4", { replan = "finished" })
	--[[
	We do here hack. If updater is not supporting request conditions then we just
	install Samba4 server possibly just to migrate to it and remove it later. If
	it is requested then it stays installed. Later updater is going to detect
	migration correctly and run this fix.
	]]
end

-- Fix package alternatives with updater version 65.0
if not version_match or not installed or
		(installed["updater-ng"] and version_match(installed["updater-ng"].version, "<65.0")) then
	Install("fix-updater-v65.0-alternatives-update")
	Package("fix-updater-v65.0-alternatives-update", { replan = "finished" })
end

-- Migrate Quad9 DNS config (it was renamed/split)
if not version_match or not installed or
		(installed["resolver-conf"] and version_match(installed["resolver-conf"].version, "<0.0.1-32")) then
	Install("fix-dns-forward-quad9-split")
	Package("fix-dns-forward-quad9-split", { replan = "finished" })
end

-- Migrate original pkglists to separate config with options in place
if not version_match or not installed or
		(installed["pkglists"] and version_match(installed["pkglists"].version, "<1.3")) then
	Install("fix-pkglists-options")
	Package("fix-pkglists-options", { replan = "immediate" })
end

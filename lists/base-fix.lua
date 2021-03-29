-- Fixes and hacks to migrate from older setups

-- ABI changed in libubus with version 2019-12-27
if not version_match or not installed or
		(installed["libubus"] and version_match(installed["libubus"].version, "<2019-12-27")) then
	Package("libubus", { abi_change = true })
end


--[[
Fix packages triggers.
Following code installs in various cases special fix packages. Those packages are
provided primarily as a way to run script during update process.
Fix packages should be installed and then with replan removed. This means that
trigger that install them should be in general applicable only before fix is
applied. This means reading configuration but current updater languages allows us
only limited access so in general we rely on update of packages that are included
in appropriate release or on Turris OS release version.
]]

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
--[[
if not version_match or not installed or
		(installed["updater-ng"] and version_match(installed["updater-ng"].version, "<65.0")) then
	Install("fix-updater-v65.0-alternatives-update")
	Package("fix-updater-v65.0-alternatives-update", { replan = "finished" })
end
]]
-- For now keep this fix in place. The problem is with updater not yet handling
-- busybox not providing alternatives fully. We can return to previous version
-- once that is handled in updater appropriately.
Install("fix-updater-v65.0-alternatives-update")

-- Migrate Quad9 DNS config (it was renamed/split)
if not version_match or not installed or
		(installed["resolver-conf"] and version_match(installed["resolver-conf"].version, "<0.0.1-32")) then
	Install("fix-dns-forward-quad9-split")
	Package("fix-dns-forward-quad9-split", { replan = "finished" })
end

-- Migrate ends buffer size value in resolver config.
-- It was changed because of DNS flag day 2020.
if not version_match or not installed or
		(installed["resolver-conf"] and version_match(installed["resolver-conf"].version, "<0.0.2-8")) then
	Install("fix-edns-buffer-size")
	Package("fix-edns-buffer-size", { replan = "finished" })
end

-- Migrate original pkglists to separate config with options in place
if not version_match or not installed or
		(installed["pkglists"] and version_match(installed["pkglists"].version, "<1.3")) then
	Install("fix-pkglists-options")
	Package("fix-pkglists-options", { replan = "finished" })
end

-- Remove no longer generated task log from Updater
if not version_match or not installed or
		(installed["updater-supervisor"] and version_match(installed["updater-supervisor"].version, "<1.3.2")) then
	Install("fix-updater-rm-log")
end

-- Restore previous non-empty version of /etc/config/foris
-- With Turris OS 5.1.0 there was a bug, which removed content of /etc/config/foris and it slipped
-- through testing. This fix just reverts older version of affected file from
-- snapshots.
if root_dir == "/" and version_match(os_release.VERSION, "<5.1.1") then
	Install("fix-config-foris-restore")
	Package("fix-config-foris-restore", { replan = "finished" })
end

-- Contracted routers have in boot environment set contract variable that is used
-- in boot arguments. This variable should be preserved but due to bug in rescue
-- could have been corrupted on factory reset. This fix should recover it.
-- We apply it in 5.1.2 but because that version is already in RC we have to keep
-- it installed for that version in system.
-- We request reboot as contract is applied only after reboot.
if root_dir == "/" and version_match(os_release.VERSION, "<=5.1.2") then
	Install("fix-corrupted-contract-by-rescue")
	Package("fix-corrupted-contract-by-rescue", { replan = "finished", reboot = "delayed" })
end

-- Default configuration on Turris Shield was invalid in factory (Turris OS 5.0).
-- Only three LAN ports were correctly assigned. Fourth port was unassigned. This
-- uses shield-support package to detect old version of Shield and fix it.
if version_match and installed and installed["shield-support"] and
		version_match(installed["shield-support"].version, "<2.2.0") then
	Install("fix-all-lan-ports-in-lan")
	Package("fix-all-lan-ports-in-lan", { replan = "finished" })
end

-- Transmission previously implemented multiple variants but that was later
-- abandoned in favor of single SSL variant. This covers previously defined
-- variants of packages and simply marks them as virtual and request installation
-- of package instead.
for _, ssl in pairs({"openssl", "mbedtls"}) do
	for _, pkg in pairs({"transmission-daemon", "transmission-cli", "transmission-remote"}) do
		Package(pkg .. "-" .. ssl, { virtual = true, deps = pkg })
	end
end

-- With Turris OS 5.2.0 we removed long time obsolete package cznic-cacert-bundle.
-- This package was storing its certificates to backup storage. We have to remove
-- them from there.
if version_match and installed and installed["cznic-cacert-bundle"] then
	Install("fix-cleanup-cert-backup")
	Package("fix-cleanup-cert-backup", { replan = "finished" })
end

-- With Turris OS 5.2.0 packages luci-lighttpd and turris-webapps integration
-- included in luci-base was merged to single dedicated package
-- turris-webapps-luci. Problem is that luci-base was handled by patch that did
-- caused no version change so we can end up potentially with conflict between
-- previous luci-base and new turris-webapps-luci. This simply requests reinstall
-- when luci-lighttpd is installed. It is not the cause but it should be removed
-- at the same time as this error is being resolved.
if installed and installed["luci-lighttpd"] and not installed["turris-webapps-luci"] then
	-- Note: condition here makes this request prety much ignored and so we won't
	-- interfere with install priorities.
	Install("luci-base", { reinstall = true, condition = "luci-base" })
end

-- With uboot-envtools version 2018.03-4 environment configuration was fixed. Problem
-- is that it is not applied in default as script checks for existence of
-- /etc/config/ubootenv file and does nothing.
-- In case of Mox we also move fw_env.config from mox-support package. Because of
-- that we have to update mox-support first so we would not remove generated file.
if not version_match or not installed or
		(installed["uboot-envtools"] and version_match(installed["uboot-envtools"].version, "<2018.03-4")) then
	Package("uboot-envtools", { deps = "fix-uboot-env-reset" })
	if board == "mox" then
		Package("uboot-envtools", { deps = "mox-support" })
	end
end

-- Package dhparam was removed and replaced by turris-cagen ability to generate
-- dhparam instead. These files are expected to be in different locations so we
-- have to fix paths in existing server configurations. This does exactly that.
if installed and installed["dhparam"] then
	Install("fix-dhparam-to-cagen")
	Package("fix-dhparam-to-cagen", { replan = "finished" })
end

-- pkglists package 1.6.0 moved content of hardening package list to separate
-- options. This fix just enables those option, that are not in default enabled,
-- to users with hardening enabled.
if not version_match or not installed or
		(installed["pkglists"] and version_match(installed["pkglists"].version, "<1.6.0")) then
	Install("fix-pkglists-hardening-options")
end

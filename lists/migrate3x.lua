--[[
This is migration script used to migrate/update system from Turris OS 3.x to 4.x.

We have to update updater first so we do immediate replan and update only updater
itself.
]]

if not version_match or not self_version or version_match(self_version, "<64.0") then

	local board
	if model:match("[Oo]mnia") then
		board = "omnia"
	elseif model:match("^[Tt]urris$") then
		board = "turris1x"
	else
		DIE("Unsupported Turris model: " .. tostring(model))
	end

	--[[
	We provide access to only HBS repository and to only minimal set of feeds. We
	don't need anything more to update updater.
	]]
	Repository("turris", "https://repo.turris.cz/hbs/" .. board .. "/packages", {
		priority = 60,
		subdirs = { "base", "core", "packages", "turrispackages"}
	})

	Install('updater-ng', { critical = true })
	Package('updater-ng', {
		replan = 'immediate',
		deps = { 'libgcc', 'busybox' }
	})
	--[[
	Updater package does not depend on libgcc but it requires it and dependency
	breaks otherwise.
	]]

else

	if version_match(installed["tos3to4"].version, "<2.0.0") then
		--[[
		The first phase is to install new version of updater-ng. This is a second
		phase where we install tos3to4-early that migrates updater's configuration
		before we perform full system update.
		The tos3to4-early is downloaded from HBS no matter what branch user has
		configured as migration itself is performed by it later on and in case of
		no settings HBS is the default.
		With Turris OS 5.2.0 the package lists were migrated to separate file. The
		fixup scripts were created to migrate it but trigger for them won't work
		for us here as we install latest version of pkglists as part of this
		immediate replan.
		]]
		Install('tos3to4-early', 'fix-pkglists-hardening-options', { critical = true })
		Package('tos3to4-early', { replan = 'immediate' })
		Package('fix-pkglists-hardening-options', {
			replan = 'immediate',
			deps = 'fix-pkglists-options'
		})
		Package("fix-pkglists-options", {
			deps = 'tos3to4-early'
		})
	end

	--[[
	The process of update is that we first update only updater and minimal system
	dependencies with it. That replaces libc and pretty much breaks whole system.
	We do it by just including minimal subset of latest feeds together with Turris
	OS 3.x feeds. With next replan all Turris OS 3.x feeds are no longer used that
	unfortunately can cause update fault because there might be requests for
	packages that were available in Turris OS 3.x but are no more. In such
	situation system stays in broken state.

	Setting that all installs are optional solves this and ensures that update is
	going to proceed and that result is working system.

	This does not solve problem ultimately. It instead moves problem for user to
	solve later when migration is completed. User have to modify its requests.
	]]
	Mode("optional_installs")

	--[[
	We install newer version of tos3to4 that migrates switch configuration. The
	migration creates situation where we are running on kernel without DSA support
	and without switch-config tools and thus we can't configure LAN in any way.
	The solution is to just unconditionally reboot router after migration is
	finished.
	]]
	Package("tos3to4", { reboot = "finished" })

end

--[[
Ubus is used by init scripts to communicate with procd. The problem this creates
is that new version of ubus is unable to communicate with old ubusd. This means
that we have to restart ubusd as soon as possible. We do it in postinst of ubus
package but there can be multiple service restarts before that and every such call
to ubus takes few minutes because of ubus timeouts. It also causes action to not
be executed. This uses replan to trick updater to update ubus as soon as possible
without updating anything else. First updater is updated. Then ubus is updated and
then rest of the system.
]]
if version_match and installed and installed["ubus"]  and
		version_match(self_version, ">=63.0") and
		version_match(installed["ubus"].version, "<2018") then
	Package("ubus", { replan = 'immediate' })
end

--[[
This same package as in Turris OS 3.x which contains script pulling in this
script. The difference is that Turris OS 4.x contains version 2.x of this package
to ensure update and that it does not contain noted script. Instead it contains
script migrating system configuration. That way configuration is updated and at
the same time this script is left out of all following updater executions because
tos3to4 is going to be removed.
]]
Install("tos3to4")
Package("tos3to4", { replan = "finished" })

--[[
We are potentially migrating from uClibc so reinstall everything depending on it.
]]
Package("libc", { abi_change_deep = true })

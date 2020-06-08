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
	Repository("turris", "https://repo.turris.cz/hbk/" .. board .. "/packages", {
		priority = 60,
		subdirs = { "base", "core", "packages", "turrispackages"}
	})

	Install('updater-ng', { critical = true })

	Package('updater-ng', {
		replan = 'immediate',
		deps = { 'libgcc', 'busybox', 'tos3to4-early' }
	})
	--[[
	Updater package does not depend on libgcc but it requires it and dependency
	breaks otherwise.

	We added additional dependency in form of package tos3to4-early which contains
	script to migrate updater configuration. That means that when new updater is
	being installed the configuration is also migrated at the same time.
	]]

else

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
	solver later when migration is completed. User have to modify its requests.
	]]
	Mode("optional_installs")

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

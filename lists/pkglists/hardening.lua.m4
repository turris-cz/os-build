include(utils.m4)dnl
_FEATURE_GUARD_

-- Common passwords Foris filter --
if not options or options.common_passwords ~= false then
	Install('common_passwords', { priority = 40 })
end

-- ujail utils --
if options and options.ujail then
	Install("procd-ujail",  { priority = 40 })
end

-- Seccomp --
if options and options.seccomp and board ~= "turris1x" then
	Install("libseccomp", "scmp_sys_resolver",  { priority = 40 })
end

_END_FEATURE_GUARD_

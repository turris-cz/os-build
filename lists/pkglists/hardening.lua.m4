include(utils.m4)dnl
_FEATURE_GUARD_

-- ujail utils --
Install("procd-ujail",  { priority = 40 })

-- Seccomp --
if board == "omnia" then
	Install("procd-seccomp",  { priority = 40 })
end

Install("libseccomp", "scmp_sys_resolver",  { priority = 40 })

_END_FEATURE_GUARD_

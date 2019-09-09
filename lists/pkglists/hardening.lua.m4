include(utils.m4)dnl
_FEATURE_GUARD_

-- Procd utils --
Install("procd-seccomp", "procd-ujail",  { priority = 40 })

-- Seccomp utils --
Install("libseccomp", "scmp_sys_resolver",  { priority = 40 })

_END_FEATURE_GUARD_

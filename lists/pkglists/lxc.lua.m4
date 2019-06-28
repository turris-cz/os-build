include(utils.m4)dnl Include utility macros
_FEATURE_GUARD_

Install("lxc", { priority = 40 })
forInstall(lxc,attach,auto,console,create,info,ls,monitor,monitord,snapshot,start,stop)

Install("luci-app-lxc", { priority = 40 })

Install("kmod-veth", { priority = 40 })
Install("gnupg", "gnupg-utils", "getopt", "tar", "wget", { priority = 40 })

_END_FEATURE_GUARD_

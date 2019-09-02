include(utils.m4)dnl
include(luci-utils.m4)dnl
_FEATURE_GUARD_

Install("lxc", { priority = 40 })
forInstall(lxc,attach,auto,console,copy,create,destroy,freeze,info,ls,monitor,monitord,snapshot,start,stop,unfreeze)

luci_app("lxc")

Install("kmod-veth", { priority = 40 })
Install("gnupg", "gnupg-utils", "getopt", "tar", "wget", { priority = 40 })

_END_FEATURE_GUARD_

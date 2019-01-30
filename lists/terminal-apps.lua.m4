include(utils.m4)dnl Include utility macros
_FEATURE_GUARD_

Install("bash", "terminfo", "vim-full", { priority = 40 })
Install("coreutils", "diffutils", { priority = 40 })
Install("htop", "procps-ng-top", "procps-ng-ps", { priority = 40 })
Install("curl", "tcpdump", { priority = 40 })

_END_FEATURE_GUARD_

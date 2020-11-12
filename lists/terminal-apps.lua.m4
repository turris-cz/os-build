include(utils.m4)dnl
_FEATURE_GUARD_

-- Core shell and utils
Install("bash", "terminfo", "vim-full", { priority = 40 })
Install("coreutils", "diffutils", { priority = 40 })
Install("openssl-util", { priority = 40 })

-- Process monitoring
Install("htop", "psmisc", "procps-ng-top", "procps-ng-ps", { priority = 40 })

-- Network
Install("curl", "wget-ssl", "tcpdump", "rsync", { priority = 40 })

-- Filesystems
Install("partx-utils", "blkid", "lsblk", { priority = 40 })

-- SSH Clients additions
Install("openssh-client", "openssh-client-utils", "openssh-sftp-client", { priority = 40 })


_END_FEATURE_GUARD_

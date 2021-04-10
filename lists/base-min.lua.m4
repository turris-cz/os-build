include(utils.m4)dnl
include(repository.m4)dnl

list_script('base-fix.lua')
list_script('base-conditional.lua')

-- Updater itself
Install('updater-ng', 'updater-supervisor', { critical = true })
Package('updater-ng', { replan = 'finished' })

-- Kernel
Package("kernel", { reboot = "delayed" })
Package("kmod-mac80211", { reboot = "delayed" })
forInstallCritical(kmod,file2args(kmod.list))
if board == "mox" then
	forInstallCritical(kmod,file2args(kmod-mox.list))
	Install("mox-support", { critical = true })
	Install("zram-swap", { priority = 40 })
elseif board == "omnia" then
	forInstallCritical(kmod,file2args(kmod-omnia.list))
	Install("omnia-support", { critical = true })
elseif board == "turris1x" then
	forInstallCritical(kmod,file2args(kmod-turris.list))
	Install("turris1x-support", { critical = true })
end
Install("fstools", { critical = true })

-- Critical minimum
Install("base-files", "busybox", "procd", "ubus", "uci", { critical = true })
Install("netifd", "firewall", "dns-resolver", { critical = true})

-- OpenWrt minimum
Install("ebtables", "dnsmasq-full", "odhcpd", "odhcp6c", { priority = 40 })
Install("urandom-seed", { priority = 40 })
Install("opkg", "libustream-openssl", { priority = 40 })
Uninstall("wget-nossl", { priority = 40 }) -- opkg required SSL variant only

-- Turris minimum
Install("cronie", { priority = 40 })
Install("syslog-ng", "logrotate", { priority = 40 })
if board == "turris1x" then
	Install("unbound", "unbound-anchor", { priority = 40 })
	Install("turris1x-btrfs", { priority = 40 }) -- Currently only SD card root is supported
else
	Install("knot-resolver", { priority = 40 })
end

-- Certificates
Install("dnssec-rootkey", "cznic-repo-keys", { critical = true })
-- Note: We don't ensure safety of these CAs
Install("ca-certificates", { priority = 40 })

-- Network protocols
Install("ppp", "ppp-mod-pppoe", { priority = 40 })

_FEATURE_GUARD_

-- Updater utility
Install("updater-drivers", { priority = 40 })
Install("updater-opkg-wrapper", { priority = 40 })
Install('switch-branch', { priority = 40 })

Package('updater-drivers', { replan = 'finished' })
Package('l10n-supported', { replan = 'finished' })
Package('updater-opkg-wrapper', { replan = 'finished' })
Package('localrepo', { replan = 'finished' })
Package('switch-branch', { replan = 'finished' })

-- Network tools
Install("ip-full", "tc", "genl", "ip-bridge", "ss", "nstat", "devlink", "rdma", { priority = 40 })
Install("iputils-ping", "iputils-ping6", "iputils-tracepath", "iputils-tracepath6", "iputils-traceroute6", { priority = 40 })
Install("iptables", "ip6tables", "conntrack", { priority = 40 })
Install("bind-client", "bind-dig", { priority = 40 })
Install("umdns", { priority = 40 })

-- Admin utilities
Install("shadow", "shadow-utils", "uboot-envtools", "i2c-tools", { priority = 40 })
Install("openssh-server", "openssh-sftp-server", "openssh-moduli", { priority = 40 })
Uninstall("dropbear", { priority = 40 })
Install("pciutils", "usbutils", "lsof", "btrfs-progs", { priority = 40 })
Install("lm-sensors", { priority = 40 })
if board == "turris1x" or board == "omnia" then
	Install("haveged", { priority = 40 })
end

-- Turris utility
Install("turris-version", "start-indicator", { priority = 40 })
Install("turris-utils", "user-notify", "watchdog_adjust", { priority = 40 })
Install("turris-diagnostics", { priority = 40 })
if for_l10n then
	for_l10n("user-notify-l10n-")
end
if board == "mox" then
	Install("mox-otp", { priority = 40 })
elseif board == "omnia" then
	Install("turris-rainbow", { priority = 40 })
	Install("libatsha204", { priority = 40 })
elseif board == "turris1x" then
	Install("turris-rainbow", { priority = 40 })
	Install("libatsha204", "update_mac", { priority = 40 })
end
if board ~= "turris1x" then
	Install("schnapps", { priority = 40 })
end


-- Wifi
Install("hostapd-common", "wireless-tools", "wpad-openssl", "iw", "iwinfo", { priority = 40 })
if board == "mox" then
	Install("kmod-ath10k-ct", { priority = 40 })
	Install("mwifiex-sdio-firmware", "ath10k-firmware-qca988x-ct", { priority = 40 })
else
	Install("ath10k-firmware-qca988x", { priority = 40 })
end

_END_FEATURE_GUARD_

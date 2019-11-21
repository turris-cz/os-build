--[[
This is migration script used to migrate/update system from Turris OS 3.x to 4.x.

We have to update updater first so we do immediate replan and update only updater
itself.
]]

if not version_match or not self_version or version_match(self_version, "<63.0") then

	local board
	if model:match("[Oo]mnia") then
		board = "omnia"
	elseif model:match("^[Tt]urris$") then
		board = "turris1x"
	else
		DIE("Unsupported Turris model: " .. tostring(model))
	end

	-- TODO move it to hbs when we have v63.0 in hbs
	local branch = "hbk"
	if board == "turris1x" then
		-- Turris 1.x is only supported in HBK for now
		branch = "hbd"
	end

	--[[
	We provide access to only HBS repository and to only minimal set of feeds. We
	don't need anything more to update updater.
	]]
	Repository("turris", "https://repo.turris.cz/" .. branch .. "/" .. board .. "/packages", {
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

end

--[[
Ubus is used by init scripts to communicate with procd. The problem this creates
is that new version of ubus is unable to communicate with old ubusd. This means
that we have restart ubusd as soon as possible. We do it in postinst of ubus
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


--[[
To make migration little bit smooth we set some packages to be provided and to be
virtual just to minimize change of being stuck with request for missing package.
These happen primarily because users installed some package with opkg. In most
cases if this package was renamed in 4.0+ the provides for old names were dropped.

This does not solve problem ultimately. It instead moves problem for user to
solver later when migration is completed. User have to modify its requests.
]]
if features and features.provides then

-- Updater
Package("updater-ng", { provides = {"updater", "opkg-trans"} })
Package("localrepo", { provides = "updater-ng-localrepo" })
Package("updater-opkg-wrapper", { provides = "updater-ng-opkg" })
Package("updater-supervisor", { provides = "updater-ng-supervisor" })
Package("updater-ng-migration-helper", { virtual = true })
-- Userlits to package lists
Package("pkglists", { provides = "userlists" })
for _, l10n in pairs({"cs", "de", "fr", "hu", "ng", "pl", "ru", "sk"}) do
	Package("pkglists-l10n-" .. l10n, { provides = "userlists-l10n-" .. l10n })
end

-- System tools
Package("syslog-ng", { provides = "syslog-ng3" })
Package("dnsmasq-full", { provides = "dnsmasq" })
Package("cython", { provides = "cython3" })
Package("libuhttpd-openssl", { provides = "uhttpd-mod-tls" })
Package("procd", { provides = {"procd-nand", "procd-nand-firstboot"} })
Package("mariadb-server", { provides = "mysql-server" })
Package("ntfs-3g", { provides = "ntfsprogs_ntfs-3g" })
Package("blockd", { provides = "mountd" })
Package("dosfstools", { provides = {"mkdosfs", "dosfsck", "dosfslabel"} })
Package("mdnsd", { provides = "mdns" })
Package("conntrack", { provides = "conntrack-tools" })
Package("gettext-tools", { provides = "gettext" })
Package("findutils-find", { provides = "findutils" })
Package("emailrelay", { provides = "emailrelay-nossl" })

-- Foris
Package("foris-client", { provides = {"foris-client-bin", "foris-client-python3"} })
Package("foris-schema", { provides = "foris-schema-python3" })
Package("foris-client-python2", { virtual = true })
Package("foris-common", { virtual = true })
Package("foris-config", { virtual = true })
Package("foris-plugin-ups-pfc8591", { virtual = true })

-- Various replacements (these are not ideal replacements but something at least)
Packages("domoticz", { provides = "domoticz-turris-gadgets" })
Package("snmpd", { provides = "snmpd-static" })
Package("iperf", { provides = "iperf-mt" })
Package("shairport-sync-openssl", { provides = "shairport" })
Package("shadowsocks-libev-config", { provides = "shadowsocks-libev" })
Package("lxc-copy", { provides = "lxc-clone" })
Package("gst1-mod-camerabin", { provides = "gst1-mod-camerabin2" })
Package("gst1-mod-oss4", { provides = "gst1-mod-oss4audio" })
Package("canutils-log-conversion", {
	virtual = true, depends = {"canutils-log2asc", "canutils-log2long"} })
Package("netopeer2-keystored", { provides = "netopeer2-cli" })
Package("knxd", { provides = "knxd-tools" })
Package("luci-app-cshark", { provides = "cshark" })

-- Missing collectd modules (just ignore them)
local collectd_mods = {
	"dbi", "madwifi", "nut"
}
for _, mod in pairs(collectd_mods) do
	Package("collectd-mod-" .. mod, { virtual = true })
end
Package("nikola", { virtual = true })
Package("ssbackups", { virtual = true })

-- freeradius2 (just ignore it as we no longer provide it
local freeradius = {
	"", "-common", "-democerts", "-mod-always", "-mod-attr-filter",
	"-mod-attr-rewrite", "-mod-chap", "-mod-detail", "-mod-eap", "-mod-eap-gtc",
	"-mod-eap-md5", "-mod-eap-mschapv2", "-mod-eap-peap", "-mod-eap-tls",
	"-mod-eap-ttls", "-mod-exec", "-mod-expiration", "-mod-expr", "-mod-files",
	"-mod-ldap", "-mod-logintime", "-mod-mschap", "-mod-pap", "-mod-passwd",
	"-mod-preprocess", "-mod-radutmp", "-mod-realm", "-mod-sql", "-mod-sql-mysql",
	"-mod-sql-pgsql", "-mod-sql-sqlite", "-mod-sqlcounter", "-mod-sqllog",
	"-utils"
}
for _, pkg in pairs(freeradius) do
	Package("freeradius2" .. pkg, { virtual = true })
end

-- Kernel modules (no longer provided)
local kmods = {
	"8021q", "appletalk", "ata-ahci-platform", "ata-mvebu-ahci", "bridge",
	"crypto-marvell-cesa", "crypto-mv-cesa", "fs-9p", "fs-afs",
	"fs-nfs-common-v4", "hostap", "hostap-pci", "hostap-plx", "hwmon-gsc",
	"i2c-mv64xxx", "ide-aec62xx", "ide-core", "ide-generic", "ide-generic-old",
	"ide-it821x", "ide-pdc202xx", "ipvti", "leds-tlc59116", "ledtrig-morse",
	"ledtrig-netfilter", "ledtrig-usbdev", "lib-oid-registry", "lib-zlib", "llc",
	"mvsdio", "net-airo", "net-rtl8188eu", "nfnetlink-nfacct",
	"rotary-gpio-custom", "rtc-armada38x", "rtc-marvell", "rxrpc", "sched-esfq",
	"spi-gpio-old", "stp", "thermal", "thermal-armada", "usb-net-smsc75xx",
	"usb-serial-motorola-phone", "usb-udl", "video-gspca-sq930x", "video-sn9c102",
	"wdt-orion"
}
for _, kmod in pairs(kmods) do
	Package("kmod-" .. kmod, { virtual = true })
end

-- MTD utils (not available and as it seems not replaced)
local mtd_utils = {
	"", "-doc-loadbios", "-docfdisk", "-flash-erase", "-flash-eraseall",
	"-flash-lock", "-flash-otp-dump", "-flash-otp-lock", "-flash-otp-write",
	"-flash-unlock", "-flashcp", "-ftl-check", "-ftl-format", "-jffs2dump",
	"-jffs2reader", "-mkfs.jffs2", "-mkfs.ubifs", "-mtd-debug", "-mtdinfo",
	"-nanddump", "-nandtest", "-nandwrite", "-nftl-format", "-nftldump",
	"-recv-image", "-rfddump", "-rfdformat", "-serve-image", "-sumtool", "-tests",
	"-ubiattach", "-ubicrc32", "-ubidetach", "-ubiformat", "-ubimkvol", "-ubinfo",
	"-ubinize", "-ubirename", "-ubirmvol", "-ubirsvol", "-ubiupdatevol"
}
for _, mtd in pairs(mtd_utils) do
	Package("mtd-utils" .. mtd, { virtual = true })
end

-- uCollect (no longer avaialable)
local ucollect = {
	"badconf", "bandwidth", "config", "count", "diffstore", "fake", "flow",
	"fwup", "lib", "meta", "prog", "refused", "sniff", "spoof"
}
for _, ext in pairs(ucollect) do
	Package("ucollect-" .. ext, { virtual = true })
end
Package("server-uplink", { virtual = true })

-- NUCI (no longer available)
local nuci = {
	"", "-ca-gen", "-diagnostics", "-nethist", "-openvpn-client", "-smrt", "-tls"
}
for _, ext in pairs(nuci) do
	Package("nuci" .. ext, { virtual = true })
end

-- PHP5 not available so replace with PHP7
local php5 = {
	"", "-cgi", "-cli", "-fastcgi", "-fpm", "-mod-calendar", "-mod-ctype",
	"-mod-curl", "-mod-dom", "-mod-exif", "-mod-fileinfo", "-mod-ftp", "-mod-gd",
	"-mod-gettext", "-mod-gmp", "-mod-hash", "-mod-iconv", "-mod-intl",
	"-mod-json", "-mod-ldap", "-mod-mbstring", "-mod-mysqli", "-mod-opcache",
	"-mod-openssl", "-mod-pcntl", "-mod-pdo", "-mod-pdo-mysql", "-mod-pdo-pgsql",
	"-mod-pdo-sqlite", "-mod-pgsql", "-mod-session", "-mod-shmop",
	"-mod-simplexml", "-mod-soap", "-mod-sockets", "-mod-sqlite3", "-mod-sysvmsg",
	"-mod-sysvsem", "-mod-sysvshm", "-mod-tokenizer", "-mod-xml",
	"-mod-xmlreader", "-mod-xmlwriter", "-mod-zip", "-pecl-dio", "-pecl-libevent",
	"-pecl-propro", "-pecl-raphf"
}
for _, ext in pairs(php5) do
	Package("php7" .. ext, { provides = "php5" .. ext })
end
Package("php5-mod-mysql", { virtual = true })
Package("php5-mod-mcrypt", { virtual = true })
Package("php7-mod-mcrypt", { virtual = true })

-- Python 2 (no longer available, migrate to Python3)
local python2 = {
	"-bottle", "-bottle-i18n", "-cachetools", "-functools32", "-gmpy", "-jinja2",
	"-jsonschema", "-markupsafe", "-mysql", "-paho-mqtt", "-spidev",
	"-turris-gpio", "-uci", "2-turrishw"
}
for _, ext in pairs(python2) do
	Package("python" .. ext, { virtual = true })
end
Package("python-simplejson" , { provides = "simplejson" })
-- Python3
local python3 = {
	"astral", "augeas", "dns", "flasklogin", "maxminddb", "netdisco",
	"netifaces", "pytest", "turrisgpio", "zeroconf"
}
for _, ext in pairs(python3) do
	Package("python3-" .. ext, { virtual = true })
end
Package("python3-yaml", { provides = "python3-pyyaml" })
Package("turrishw", { provides = "python3-turrishw" })

-- Cups (removed as unmaintainable)
local cups = {
	"cups", "cups-bjnp", "cups-bsd", "cups-client", "cups-ppdc", "libcups",
	"libcupscgi", "libcupsimage", "libcupsmime", "libcupsppdc", "gutenprint-cups",
	"luci-app-cups", "openprinting-cups-filters", "hplip",
}
for _, pkg in pairs(cups) do
	Package(pkg, { virtual = true })
end

-- WiFi
Package("iw-full", { provides = "iw" })
Package("wpa-supplicant-mesh-openssl", { provides = "wpa-supplicant-mesh" })
Package("wpad-mesh-openssl", { provides = "wpad-mesh" })
Package("wpad", { provides = "wpad-mini" })

-- Hardware
Package("u-boot-omnia", { provides = "uboot-turris-omnia" })

-- Luci App for Asterisk (no longer available)
Package("luci-app-asterisk", { virtual = true })
local asterisk_langs = {
	"ca", "cs", "de", "el", "en", "es", "fr", "he", "hu", "it", "ja", "ms", "no",
	"pl", "pt", "pt-br", "ro", "ru", "sk", "sv", "tr", "uk", "vi", "zh-cn",
	"zh-tw"
}
for _, lang in pairs(asterisk_langs) do
	Package("luci-i18n-asterisk-" .. lang, { virtual = true })
end

-- nginx
Package("nginx-mod-luci", { virtual = true })
Package("nginx-mod-luci-ssl", { virtual = true })
Package("nginx", { provides = {"nginx-ssl", "nginx-all-module"} })

-- These pacakge do not compile so we mark them as virtual
local nobuild = {
	"alpine", "alpine-nossl", "gnunet-dv", "gnunet-flat", "gnunet-social",
	"yate-mod-sip_cnam_lnp", "yate-mod-speexcodec", "ppp-mod-pppoa"
}
for _, pkg in pairs(nobuild) do
	Package(pkg, { virtual = true })
end

-- Various libraries (should not harm to ignore them)
local libraries = {
	"libcyassl", "liberation-fonts", "libevent", "libevhtp", "libfreecwmp",
	"libijs", "libjbigkit", "libmaxminddb", "libmicroxml", "libmysqlclient",
	"libmysqlclient-r", "libncursesw", "libnetconf", "libnetconf2", "libnfc",
	"libnfsidmap", "libortp", "libpolarssl", "libresample", "libssh", "libtoxav",
	"libtoxcore", "libtoxdns", "libtoxencryptsave", "libwebsockets-cyassl",
}
for _, pkg in pairs(libraries) do
	Package(pkg, { virtual = true })
end

-- General removed packages
local dropped = {
	"btrfs-convert", "ctorrent", "ctorrent-nossl", "ctorrent-svn",
	"ctorrent-svn-nossl", "ups-pfc8591", "userspace_time_sync", "w_scan", "wol",
	"wshaper", "ubuntu-fonts", "udev", "thermometer", "tig", "tox-bootstrapd",
	"suricata-monitor", "suricata-rules", "qemu", "oneshot", "sfpswitch",
	"luci-app-majordomo", "luci-app-nut", "luci-app-shairport",
	"luci-i18n-shadowsocks-libev-sv", "luci-i18n-shadowsocks-libev-zh-cn",
	"luci-i18n-wireguard-zh-tw", "lxc-lua", "ghostscript",
	"ghostscript-fonts-std", "ghostscript-gnu-gs-fonts-other",
	"gst1-mod-dataurisrc", "gst1-mod-liveadder", "gst1-mod-mad",
	"gst1-mod-rawparse", "gst1-mod-souphttpsrc", "aiccu", "aiccu-gnutls",
	"lua-cqueues", "lcollect", "lcollect-majordomo", "mac-to-devinfo", "mcutool",
	"meek", "netdiscover-to-devinfo", "nethist", "nfc-utils", "ntox", "oor",
	"oprofile", "oprofile-utils", "pimbd", "poppler", "pynrf24", "qpdf",
	"quagga-babeld", "robocfg", "shflags", "shtool", "siproxd-mod-fix_bogus_via",
	"smap-to-devinfo", "l7-protocols", "l7-protocols-testing", "augeas",
	"authsae", "classpath", "classpath-tools", "dansguardian", "dmapd",
	"engine_pkcs11", "freecwmp", "freenetconfd", "freenetconfd-plugin-examples",
	"freesub", "home-assistant", "home-assistant-turris-gadgets", "hostap-utils",
	"iotivity-things-manager", "iotivity-things-manager-lib",
	"iptables-mod-nfacct", "lcms2",
}
for _, pkg in pairs(dropped) do
	Package(pkg, { virtual = true })
end

-- Samba4 is not available (in TOS 4.x)
local samba4 = {
	"admin", "client", "libs", "server", "utils"
}
for _, ext in pairs(samba4) do
	Package("samba4-" .. ext, { virtual = true })
end
Package("luci-app-samba4", { virtual = true })
local samba4_langs = {
	"ca", "cs", "de", "el", "en", "es", "fr", "he", "hu", "it", "ja", "ms", "no",
	"pl", "pt", "pt-br", "ro", "ru", "sk", "sv", "tr", "uk", "vi", "zh-cn",
	"zh-tw"
}
for _, lang in pairs(samba4_langs) do
	Package("luci-i18n-samba4-" .. lang, { virtual = true })
end

-- Packages from Turris not available in TOS 4.0+ (yet)
local notyet = {
	"ltemetr-core", "ssdeep", "suricata-emergingthreats-rules-ludus", "ludus",
	"ludus-gui", "atlas-probe atlas-sw-probe",
}
for _, pkg in pairs(notyet) do
	Package(pkg, { virtual = true })
end

end

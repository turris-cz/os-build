include(utils.m4)dnl Include utility macros
_FEATURE_GUARD_

Install("luci", "luci-lighttpd", { priority = 40 })
forInstall(luci,base,proto-ipv6,proto-ppp,app-commands)


--[[
All packages with localization packages
Generated using:
 curl https://repo.turris.cz/hbd/omnia/packages/luci/Packages | sed -n 's/^Package: luci-i18n-\([^-]\+\).*/\1/p' | sort | uniq | sed 's/^/"/;s/$/",/'
]]
local luci_i18n_pkgs = {
	"adblock",
	"advanced",
	"ahcp",
	"aria2",
	"base",
	"bcp38",
	"clamav",
	"commands",
	"ddns",
	"diag",
	"dnscrypt",
	"dynapoint",
	"firewall",
	"fwknopd",
	"hd",
	"https_dns_proxy",
	"minidlna",
	"mjpg",
	"mwan3",
	"nft",
	"nlbwmon",
	"noddos",
	"ntpc",
	"nut",
	"olsr",
	"openvpn",
	"opkg",
	"p910nd",
	"pagekitec",
	"polipo",
	"privoxy",
	"qos",
	"radicale",
	"radicale2",
	"rp",
	"samba",
	"samba4",
	"shadowsocks",
	"shairplay",
	"simple",
	"splash",
	"statistics",
	"tinyproxy",
	"transmission",
	"travelmate",
	"uhttpd",
	"unbound",
	"upnp",
	"vnstat",
	"vpnbypass",
	"watchcat",
	"wifischedule",
	"wireguard",
	"wol",
}

if l10n then
	local luci_i18n = {["en"] = true} -- we always install English localization
	for _, lang in pairs(l10n or {}) do
		luci_i18n[lang] = true
	end

	for lang in pairs(luci_i18n) do
		for _, pkg in pairs(luci_i18n_pkgs) do
			Install("luci-i18n-" .. pkg .. "-" .. lang, { optional = true, priority = 20 })
		end
	end
end

_END_FEATURE_GUARD_

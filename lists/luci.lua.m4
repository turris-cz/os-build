include(utils.m4)dnl Include utility macros
_FEATURE_GUARD_

Install("luci", "luci-lighttpd", { priority = 40 })
forInstall(luci,base,proto-ipv6,proto-ppp,app-commands)


--[[
All packages with localization packages
Generated using:
 curl https://repo.turris.cz/hbd/omnia/packages/luci/Packages | sed -n '/Package: luci-i18n-/,/^$/{ s/Depends:.*luci-app-\([^ ,]\+\).*/\1/p }' | sort | uniq | sed 's/^/"/;s/$/",/'
]]
local luci_apps = {
	"adblock",
	"advanced-reboot",
	"ahcp",
	"aria2",
	"bcp38",
	"clamav",
	"commands",
	"ddns",
	"diag-core",
	"dnscrypt-proxy",
	"dynapoint",
	"firewall",
	"fwknopd",
	"hd-idle",
	"https_dns_proxy",
	"minidlna",
	"mjpg-streamer",
	"mwan3",
	"nft-qos",
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
	"rp-pppoe-server",
	"samba",
	"samba4",
	"shadowsocks-libev",
	"shairplay",
	"simple-adblock",
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

--[[
Some packages have separate EN support. This is only few packages so we list them
instead of having warning for multiple packages missing.
Generated using:
 curl https://repo.turris.cz/hbd/omnia/packages/luci/Packages | sed -n 's/^Package: luci-i18n-\(.*\)-en.*/\1/p' | sort | sed 's/^/["/;s/$/"] = true,/'
]]
local luci_i18n_en = {
	["ahcp"] = true,
	["base"] = true,
	["commands"] = true,
	["diag-core"] = true,
	["firewall"] = true,
	["fwknopd"] = true,
	["hd-idle"] = true,
	["minidlna"] = true,
	["ntpc"] = true,
	["nut"] = true,
	["olsr"] = true,
	["openvpn"] = true,
	["opkg"] = true,
	["p910nd"] = true,
	["polipo"] = true,
	["qos"] = true,
	["radicale2"] = true,
	["rp-pppoe-server"] = true,
	["samba"] = true,
	["samba4"] = true,
	["splash"] = true,
	["statistics"] = true,
	["tinyproxy"] = true,
	["transmission"] = true,
	["uhttpd"] = true,
	["upnp"] = true,
	["vnstat"] = true,
	["watchcat"] = true,
	["wol"] = true,
}

if l10n then
	local luci_i18n = {}
	for _, lang in pairs(l10n or {}) do
		luci_i18n[lang] = true
	end

	Install("luci-i18n-base-en", { optional = true, priority = 20 })
	for lang in pairs(luci_i18n) do
		Install("luci-i18n-base-" .. lang, { optional = true, priority = 20 })
	end

	for _, app in pairs(luci_i18n_pkgs) do
		if installed["luci-app-" .. app] then
			if luci_i18n_en[app] then
				Install("luci-i18n-" .. app .. "-en", { optional = true, priority = 20 })
			end
			for lang in pairs(luci_i18n) do
				Install("luci-i18n-" .. app .. "-" .. lang, { optional = true, priority = 20 })
			end
		end
	end
end

_END_FEATURE_GUARD_

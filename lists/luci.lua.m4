include(utils.m4)dnl
_FEATURE_GUARD_

local luci_apps = {
	"acme",
	"adblock",
	"advanced-reboot",
	"ahcp",
	"aria2",
	"attendedsysupgrade",
	"banip",
	"bcp38",
	"bird1-ipv4",
	"bird1-ipv6",
	"bmx6",
	"bmx7",
	"cjdns",
	"clamav",
	"commands",
	"cshark",
	"dcwapd",
	"ddns",
	"diag-core",
	"dnscrypt-proxy",
	"dump1090",
	"dynapoint",
	"e2guardian",
	"firewall",
	"fwknopd",
	"hd-idle",
	"hnet",
	"https-dns-proxy",
	"ipfixprobe",
	"ksmbd",
	"lxc",
	"minidlna",
	"mjpg-streamer",
	"mosquitto",
	"mwan3",
	"nextdns",
	"nft-qos",
	"nlbwmon",
	"noddos",
	"ntpc",
	"nut",
	"ocserv",
	"olsr",
	"olsr-services",
	"olsr-viz",
	"openvpn",
	"opkg",
	"p910nd",
	"pagekitec",
	"polipo",
	"privoxy",
	"qos",
	"radicale",
	"radicale2",
	"rainbow",
	"rosy-file-server",
	"rp-pppoe-server",
	"samba",
	"samba4",
	"shadowsocks-libev",
	"shairplay",
	"siitwizard",
	"simple-adblock",
	"snmpd",
	"splash",
	"sqm",
	"squid",
	"statistics",
	"tinyproxy",
	"transmission",
	"travelmate",
	"ttyd",
	"udpxy",
	"uhttpd",
	"unbound",
	"upnp",
	"vnstat",
	"vpn-policy-routing",
	"vpnbypass",
	"watchcat",
	"wifischedule",
	"wireguard",
	"wol",
}

-- Conditional install requests for language packages
for _, lang in pairs({"en", unpack(l10n or {})}) do
	for _, name in pairs(luci_apps) do
		Install("luci-i18n-" .. name .. "-" .. lang, {
			priority = 10,
			optional = true,
			condition = "luci-app-" .. name
		})
	end
end


Install("luci", "luci-base", { priority = 40 })
if for_l10n then
	Install("luci-i18n-base-en", { optional = true, priority = 10 })
	for_l10n("luci-i18n-base-")
end

Install("luci-app-commands", { priority = 40 })
Install("luci-proto-ipv6", "luci-proto-ppp", { priority = 40 })
-- Install resolver-debug for DNS debuging
Install("resolver-debug", { priority = 40 })

_END_FEATURE_GUARD_

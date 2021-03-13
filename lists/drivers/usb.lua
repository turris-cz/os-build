--[[
Following table is database of USB devices identifiers and drivers in OpenWrt to
support them. Feel free to expand it with additional devices.

We do not essentially want to have here full list. It is not desirable to include
devices that are in main used as hotplug (such as USB flash stick) and devices
with generic driver (such as mass storage). It is rather desirable to have this as
list of devices such as modems, tunners and so on.

Every device has to have numberical 'vendor' and 'product' identifier and list of
'packages' defined. Please also comment with device name. There is also optional
'class' table. Those are used to enable selected subset of packages no matter if
the are present in device or not.

This expects variable 'devices' to be exported. It has to contain array. Elements
in array can be either string or table. String is considered as flag and any
device with matching flag is installed. Special flag is "all" that matches all
devices in database. Other option is table where keys are "vendor" and "product".
Values of those fields are compared with values in database and if they match then
appropriate packages are requested.
]]
local db = {
	-- DVB tunners ---------------------------------------------------------------
	{ -- TechnoTrend AG TT-connect CT-3650 CI
		vendor = 0x0b48,
		product = 0x300d,
		packages = {"kmod-dvb-usb-ttusb2", "kmod-dvb-tda10023", "kmod-dvb-tda10048", "kmod-media-tuner-tda827x"},
		class = {"dvb"}
	},
	{ -- TechniSat Digital GmbH CableStar Combo HD CI
		vendor = 0x14f7,
		product = 0x0003,
		packages = {"kmod-dvb-usb-ttusb2", "kmod-dvb-drxk", "kmod-dvb-usb-v2", "kmod-dvb-usb-az6007", "kmod-media-tuner-mt2063"},
		-- Note: additional not packaged firmware is required
		class = {"dvb"}
	},
	{ -- Computer & Entertainment, Inc. Astrometa DVB-T/T2/C FM & DAB receiver [RTL2832P]
		vendor = 0x15f4,
		product = 0x0131,
		packages = {"kmod-dvb-usb", "kmod-dvb-cxd2841er", "kmod-dvb-mn88473", "kmod-dvb-rtl2832", "kmod-dvb-usb-rtl28xxu", "kmod-media-tuner-r820t", "kmod-media-tuner-r820t"},
		class = {"dvb"}
	},
	{ -- Microsoft Corporation Xbox One Digital TV Tuner
		vendor = 0x045e,
		product = 0x02d5,
		packages = {"kmod-dvb-mn88472", "kmod-media-tuner-tda18250", "kmod-dvb-usb-dib0700"},
		-- Note: additional not packaged firmware is required
		class = {"dvb"}
	},
	-- LTE modems ----------------------------------------------------------------
	{ -- Qualcomm, Inc. Acer Gobi 2000 Wireless Modem
		vendor = 0x05c6,
		product = 0x9215,
		packages = {"kmod-usb-net-qmi-wwan", "kmod-usb-serial-qualcomm"},
		class = {"broadband"}
	},
	{ -- Huawei Technologies Co., Ltd. K5150 LTE modem
		vendor = 0x12d1,
		product = 0x1f16,
		packages = {"comgt-ncm", "umbim", "kmod-usb-net-cdc-ether"},
		class = {"broadband"}
	},
	{ -- TCL Communication Ltd Alcatel OneTouch L850V / Telekom Speedstick LTE
		vendor = 0x1bbb,
		product = 0x0195,
		packages = {"kmod-usb-net-rndis"},
		class = {"broadband"}
	},
	-- WiFi dongles --------------------------------------------------------------
	{ -- Realtek Semiconductor Corp. RTL8812AU 802.11a/b/g/n/ac 2T2R DB WLAN Adapter
		vendor = 0x0bda,
		product = 0x8812,
		packages = {"kmod-rtl8812au-ct"},
		class = {"wifi"}
	},
	{ -- Ralink Technology, Corp. RT2870/RT3070 Wireless Adapter
		vendor = 0x148f,
		product = 0x3070,
		packages = {"kmod-rt2800-usb"},
		class = {"wifi"}
	},
	{ -- NETGEAR, Inc. WN111(v2) RangeMax Next Wireless [Atheros AR9170+AR9101]
		vendor = 0x0846,
		product = 0x9001,
		packages = {"kmod-carl9170"},
		class = {"wifi"}
	},
	-- Serial --------------------------------------------------------------------
	{ -- Future Technology Devices International Limited, Bridge(I2C/SPI/UART/FIFO)
		vendor = 0x0403,
		product = 0x6015,
		packages = {"kmod-usb-acm"},
		class = {"serial"}
	},
	{ -- Sigma Designs, Inc. Aeotec Z-Stick Gen5 (ZW090) - UZB
		vendor = 0x0658,
		product = 0x0200,
		packages = {"kmod-usb-acm"},
		class = {"serial", "z-wave"}
	},
	-- Random number generator ---------------------------------------------------
	{ -- OpenMoko, Inc. USBtrng hardware random number generator
		vendor = 0x1d50,
		product = 0x60c6,
		packages = {"kmod-chaoskey"},
		class = {"random"}
	},
}
----------------------------------------------------------------------------------
-- First convert class arrays to set
for _, dbdev in pairs(db) do
	local class_set = {}
	for _, cl in pairs(dbdev.class or {}) do
		class_set[cl] = true
	end
	dbdev.class = class_set
end

-- Now request packages for requested devices
for _, device in pairs(devices) do
	for _, dbdev in pairs(db) do
		if (type(device) == "string" and (device == "all" or dbdev.class[device])) or
				(type(device) == "table" and device.vendor == dbdev.vendor and device.product == dbdev.product) then
			Install(unpack(dbdev.packages), { priority = 40 })
		end
	end
end

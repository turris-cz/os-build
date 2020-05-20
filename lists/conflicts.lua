--[[
These are packages that are known to provide same functionality but upstream does
not specify conflict.
]]

Package("ath10k-firmware-qca988x-ct-htt", { deps = Not("ath10k-firmware-qca988x-ct") })

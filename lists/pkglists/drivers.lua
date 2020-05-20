include(utils.m4)dnl
_FEATURE_GUARD_
if options then

if options.ath10k_ct or options.ath10k_ct_htt then
	Install("kmod-ath10k-ct", { priority = 40 })
	if options.ath10_ct_htt then
		Install("ath10k-firmware-qca988x-ct-htt", { priority = 40 })
	else
		Install("ath10k-firmware-qca988x-ct", { priority = 40 })
	end
end

end
_END_FEATURE_GUARD_

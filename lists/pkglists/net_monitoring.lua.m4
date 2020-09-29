include(utils.m4)dnl
_FEATURE_GUARD_

if options and options.netmetr then
	Install("netmetr", { priority = 40 })
end

if options and options.dev_detect then
	Install("dev-detect", { priority = 40 })
end

if options and options.pakon then
	Install("pakon", { priority = 40 })
end

_END_FEATURE_GUARD_

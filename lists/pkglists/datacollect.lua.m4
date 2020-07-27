include(utils.m4)dnl
_FEATURE_GUARD_

Install("reforis-data-collection-plugin", { priority = 40 })

if not options or options.survey ~= false then
	Install("turris-survey", { priority = 40 })
end

if not options or options.dynfw ~= false then
	Install("sentinel-dynfw-client", { priority = 40 })
end

if not options or options.nikola ~= false then
	Install("sentinel-nikola", { priority = 40 })
end

if not options or options.minipot ~= false then
	Install("sentinel-minipot", { priority = 40 })
end

if options and options.haas then
	Install("haas-proxy", { priority = 40 })
end

_END_FEATURE_GUARD_

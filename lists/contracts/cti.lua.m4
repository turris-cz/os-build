include(utils.m4)dnl
_FEATURE_GUARD_

-- Extra security
Install('common_passwords')

Install("sentinel-dynfw-client")
Install("sentinel-minipot", "sentinel-nikola", "turris-survey")

_END_FEATURE_GUARD_

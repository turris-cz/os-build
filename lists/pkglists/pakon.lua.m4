include(utils.m4)dnl
include(foris-utils.m4)dnl
_FEATURE_GUARD_

foris_plugin("pakon")
Install("pakon", "pakon-lists", "suricata-pakon", { priority = 40 })

_END_FEATURE_GUARD_

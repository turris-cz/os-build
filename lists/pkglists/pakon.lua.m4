include(utils.m4)dnl
_FEATURE_GUARD_

Install("foris-pakon-plugin", { priority = 40 })
Install("pakon", "pakon-lists", "suricata-pakon", { priority = 40 })

_END_FEATURE_GUARD_

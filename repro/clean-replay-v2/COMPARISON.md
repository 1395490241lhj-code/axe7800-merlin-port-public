# Comparison across trees

| | experimental | clean replay v1 | clean replay v2 |
|---|---|---|---|
| base commit | ccd139a31d | ccd139a31d | ccd139a31d |
| origin | incremental, hand-built over many dispatches | replay.sh (incomplete) | replay.sh (corrected) |
| tracked files modified | 28 | 4 | 4 |
| hosttools_common | passed (artifact pre-existed) | **FAILED** (missing lzop staging) | **passed** |
| zImage | yes (dispatch-13) | never reached | yes |
| first fatal | shared/private.c | hosttools_common | shared/private.c |
| build exit | rc=2 | rc=2 | rc=2 |

## vs checkpoint 2026-08-14-dhdap-validated (experimental, dispatch-13)
Identical outcome reproduced from zero:
- RTCONFIG_DHDAP=y ................ both
- CONFIG_DHDAP absent ............. both (HND_ROUTER=y gate)
- dhd.ko 1,180,156 B ELF32 ARM .... byte-identical size in both
- wl.ko  8,731,152 B ELF32 ARM .... byte-identical size in both
- archer/bcm_license/bcmmcast .ko . both
- zImage ready .................... both
- first fatal = shared/private.c .. both

The clean replay reproduces the validated experimental result from a pristine checkout using
only pinned refs, with a 4-file tracked diff instead of 28 (the other 24 in the experimental
tree are build-staging churn, not port changes).

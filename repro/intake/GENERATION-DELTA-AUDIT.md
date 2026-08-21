# Generation-delta audit: GPL 388.34458 · shipping 388_25206 · pinned Merlin `ccd139a31d`

**Read-only, 2026-08-20.** No build, no source edit, no stub, no donor binary, no feature
disabled, nothing flashed. Stock firmware used strictly as an ABI/runtime oracle; no
proprietary implementation was reverse engineered and no embedded credential value was read.

Build frontier remains **frozen** at `invalid_nvram_get_program` / `invalid_program_check`.

## Headline finding

**The generation gap is narrow and localized, not systemic.** Across ~20 shared libraries
present in both the authentic 34458 supply and shipping 388_25206, exported-ABI deltas are
0–9 symbols out of 7–3300, and several are byte-for-byte ABI-identical. The port is not
facing a wholesale userspace divergence: three components account for essentially all of it.

## Delta table

| # | component | 34458 generation | 25206 shipping | pinned Merlin | evidence | class | impact |
|---|---|---|---|---|---|---|---|
| 1 | **shared / libshared** | older surface | 1195 exports | 1191 exports, 40 not in stock | 44 stock-only symbols; **0 of the 44 are provided by the 16 authentic shared prebuilts** | **PRIVATE-GENERATION-GAP** | 2 of the 44 (`invalid_*`) block today; the other 42 are latent ABI surface, not blockers |
| 2 | **libwebapi** | **component wholly absent** — 0 index entries for `libwebapi`, `webapi.c`, `priv_webapi` in 303,020 | exports 91, consumers exercise 34 | builds it; open `webapi.c` supplies 12 of the 34 | LIBWEBAPI-A evidence | **PRIVATE-GENERATION-GAP** | next demonstrated blocker after the frontier |
| 3 | **rc / S46** | `s46map_rptd` (`OBJS += s46map_rptd.o`, `s46_jpne_*` API) | `s46comm` (`wan46det`, `ocnvcd`, `v6plusd`, `s46reset`; **no** `s46map_rptd` applet) | `s46comm` | supply has `s46map_rptd.o`, **not** `s46comm.o` | **PRIVATE-GENERATION-GAP** | third demonstrated blocker |
| 4 | **nvram / libnvram** | — | 74 exports | consumes it | **ABI IDENTICAL: 74 = 74, zero differences either way** | **SAME-GENERATION** | none. The `invalid_*` gap is *not* an nvram generation issue — libnvram is the same on both sides; only its **provider** differs |
| 5 | **httpd** | prebuilds `pwenc.o`, `web-broadcom.o`, `web_hook.o`, `web-broadcom_private.o` | 493 dynamic imports | **identical** prebuild object set | set matches exactly | **SAME-GENERATION** | none directly; inherits libwebapi's gap as a consumer |
| 6 | **wireless userspace** | `net/wl/impl87` | — | `impl87` | same impl in both trees | **SAME-GENERATION** | none |
| 7 | **AiMesh / AMAS** | — | `libamas-utils.so` 96 exports | 96 exports | 1 symbol each way | **SAME-GENERATION** | none |
| 8 | **security / cfg / logging** (`libasd`, `libcfgmnt`, `libasuslog`, `libasc`, `libnt`) | — | — | — | deltas 1–7 symbols | **SAME-GENERATION** | none |
| 9 | **bwdpi / natnl / shn** (`libbwdpi`, `libbwdpi_sql`, `libasusnatnl`, `libshn_*`) | — | — | — | `libshn_pctrl` 3303 = 3303 identical; others ≤4 | **SAME-GENERATION** | none |
| 10 | **scripts / services** | — | 129 `/sbin` rc applets | 296 `ln -sf rc` stanzas (config-gated superset spanning many models) | count asymmetry is expected | **NO ACTIVE EVIDENCE** | none — do not treat the superset as a gap |

## libwebapi follow-up — the six unattributed exports, now resolved

Provenance only. No implementation was reconstructed.

| symbol | provider relationship | status |
|---|---|---|
| `b64_decode` | **OPEN ASUS/OpenWrt source under another component**: defined at `libubox/base64.c:199`, plus a separate static definition at `httpd/web.c:21372`. `libubox` is present in GPL 388.34458 (58 index entries). Stock's `libwebapi.so` export is a static-link copy. | **RESOLVED — not a gap** |
| `jffs_backup_profile_t` | **Not a function.** It is exported **data**: `extern struct JFFS_BACKUP_PROFILE_S jffs_backup_profile_t[]`, declared at `libwebapi/webapi.h:73`. Belongs to libwebapi's own surface. | part of the libwebapi gap |
| `set_ASUS_privacy_policy` | consumed by **open** Merlin code — `aws-iot/src/awsiot.c:3883, 4454, 4489` — with no open definition | **unresolved private supply** |
| `set_app_mnt` | consumed by **open** Merlin code — `aws-iot/src/awsiot.c:3379` | **unresolved private supply** |
| `do_chpass` | no open definition, no open Merlin caller | **unresolved private supply** |
| `get_app_mnt` | no open definition, no open Merlin caller | **unresolved private supply** |

All six are imported by stock `/usr/sbin/httpd`, so all six are exercised on the shipping
device. Correction worth carrying forward: the earlier "6 in neither" framing was too
pessimistic — `b64_decode` is plainly open, and `jffs_backup_profile_t` is data, not code.
Four remain genuinely private, and two of those (`set_ASUS_privacy_policy`, `set_app_mnt`)
now have **demonstrated open Merlin callers**, which raises them from theoretical to active.

## Answers

**1. What other major blockers are likely after libnvram?**
In order: `libwebapi`/`priv_webapi.o` (whole component absent from the published GPL; 22 of
the 34 shipping-contract symbols unaccounted for), then `rc`/`s46comm.o`. Latent behind those:
the remaining 42 stock-only `libshared` symbols, which become blockers only if a consumer
references them — none does today.

**2. Which would disappear automatically with a matching 388_25xxx package?**
Plausibly all three demonstrated gaps — the `invalid_*` pair, `libwebapi`, and `s46comm` —
**provided** the package is the `s46comm` generation and ships `libwebapi`. That is precisely
what `repro/intake/ACCEPTANCE-MATRIX.md` is built to test, and it is why the request is scoped
to the whole package rather than to individual objects.

**3. Which would still need Merlin-side source adaptation?**
The cross-product-line inheritance class — dependencies Merlin acquired by merging *other*
ASUS product lines, which no RT-AXE7800 package can supply. Both already-completed adaptations
are of exactly this kind: `get_fh_if_prefix_by_unit` (from RT-BE86U) and `hnd_boardid_cmp`
(from RT-BE96U). Expect more of this class as the build advances; it is orthogonal to anything
ASUS delivers.

**4. Any component where pinned Merlin is closer to old 34458 than to current stock?**
**No — not one of the audited components.** Merlin consistently tracks the *shipping*
generation: `s46comm` not `s46map_rptd`, and it expects the `invalid_*` pair that stock has and
34458 lacks. This is a useful directional result: the published GPL is the outlier, and Merlin
and the device agree.

**5. Does any new evidence change the ASUS request scope?**
**No — and it strengthens the existing wording.** Two refinements worth recording rather than
re-scoping: `libnvram` itself is ABI-identical across both lines, so the request is correctly
about the *package*, not about nvram; and the narrowness of the gap confirms that asking for
the complete matching source package is proportionate. Do not expand the request into
individual objects or symbols.

## Method notes

Library comparison used `nm -D --defined-only` over authentic 34458-supplied prebuilts staged
by `clean-replay-v11` versus the corresponding stock `388_25206` files, plus the cached
303,020-entry archive inventory for presence questions. Symbol *counts* and *names* only —
never implementation, never credential values.

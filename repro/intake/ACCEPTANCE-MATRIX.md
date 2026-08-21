# RT-AXE7800 source-package intake: acceptance matrix

**Read-only verification plan.** Applies to any future ASUS RT-AXE7800 `388_25xxx` GPL/source
package. Nothing here authorises a build, a stub, a donor binary, or a bypass.

Companion tooling:
- `tools/verify-asus-gpl-drop.sh` — package **identity** and P0–P3 supply closure (existing).
- `tools/inspect-gpl-generation-gaps.sh` — the **generation** gaps below (new; the existing
  verifier has zero coverage of `s46map_rptd`, `wan46det`, `invalid_*` or `hnd_boardid_cmp`).

Run identity first. A package that fails identity is not evidence for anything else.

## Verdict vocabulary

| verdict | meaning |
|---|---|
| **PASS** | the gap is closed by same-model evidence in this package |
| **FAIL** | the package positively demonstrates the gap is *not* closed |
| **INCONCLUSIVE** | evidence is missing or ambiguous — the default; never upgrade it by assumption |

Absence of a file is **INCONCLUSIVE**, never FAIL, until archive layout is confirmed
(raw-ASUS flat `<component>/prebuild/<obj>` vs Merlin `<component>/prebuild/RT-AXE7800/<obj>`).

---

## 1. shared / libnvram private ABI

Frozen frontier. Both symbols are demanded by the **prebuilt** `libnvram.so`, have **no open
caller**, and are exercised on the shipping device.

| | `invalid_nvram_get_program` | `invalid_program_check` |
|---|---|---|
| expected provider | `shared/` (stock `libshared.so` defines both) | same |
| expected consumer | `libnvram.so` (prebuilt) | same |
| stock 388_25206 evidence | `/lib/libnvram.so` (31,740 B, sha256 `3c1c4e83…`) imports it; `libshared.so` defines it | same |
| pinned-Merlin requirement | declared `shared/shared.h:4927-4928`; unresolved at the `write_smb_conf` link | same |

**PASS** requires *either*:
- **source**: a compilable definition in the package's `shared/` tree (e.g. a real `spwenc.c`),
  **or**
- **authentic same-model prebuilt**: an object under `shared/prebuild/` (raw) or
  `shared/prebuild/RT-AXE7800/` (Merlin layout) whose symbol table **defines** the symbol.

Record which of the two it is — they are different licensing and reproducibility situations.

**INCONCLUSIVE** if: the symbol appears only in a header/declaration; only in another model's
object; only as an *undefined* reference; or if `shared/prebuild` is absent from the archive
without layout confirmation.

**FAIL** if: the package ships a `shared/` supply set that is complete for its own generation
and demonstrably does not contain these symbols anywhere (i.e. it is a *different* generation,
the 388.34458 situation repeated).

> Do not require open source. Authentic package-supplied prebuilt closes the build gap even
> though it does not close the source-availability question. Record both facts separately.

---

## 2. libwebapi — classification LIBWEBAPI-A

Demonstrated shipping contract (see `repro/source-adaptation-v1/evidence/libwebapi-consumer-contract.md`):
stock `libwebapi.so` exports **91**; shipping consumers exercise **34**; Merlin's open
`webapi.c` supplies **12**; the residual is private. Baseline committed as
`repro/intake/libwebapi-shipping-contract.txt`.

| check | PASS | INCONCLUSIVE |
|---|---|---|
| `router/libwebapi/` present | directory exists in the archive index | absent **and** layout unconfirmed |
| `webapi.c` | present as source | absent |
| `priv_webapi` supply | `priv_webapi.c` **or** an object under `libwebapi/prebuild[/RT-AXE7800]/` | neither, or only a header |
| exported ABI | located prebuilt's symbol table read directly | no ELF located |
| **contract closure** | every one of the 34 contract symbols is defined by open `webapi.c` **or** by the package's own `priv_webapi` supply | any symbol unaccounted for |

**The 34-symbol contract is the acceptance criterion, not the 66-function count of another
model's `priv_webapi.o`.** That count was only ever an indicative cross-model oracle.

Six of the 34 were previously unattributed. Their provenance is now resolved in
[`GENERATION-DELTA-AUDIT.md`](GENERATION-DELTA-AUDIT.md): `b64_decode` is open
(`libubox/base64.c:199`), `jffs_backup_profile_t` is exported **data**, not a function, and the
remaining four — `do_chpass`, `get_app_mnt`, `set_ASUS_privacy_policy`, `set_app_mnt` — are
genuinely private. Two of those four have demonstrated open Merlin callers in
`aws-iot/src/awsiot.c`, so a candidate package must be checked for them specifically.

---

## 3. S46 / `s46comm` generation

**Version numbers do not imply generation.** GPL 388.34458 (2023) uses the older
`s46map_rptd` generation while shipping 388_25206 (2026) uses `s46comm` — the number is
larger on the *older-generation* package. Determine generation from content only.

| discriminator | `s46map_rptd` generation | `s46comm` generation |
|---|---|---|
| `rc/Makefile` under `RTCONFIG_SOFTWIRE46` | `OBJS += s46map_rptd.o` | `$(if $(RTCONFIG_SOFTWIRE46), s46comm.o)` |
| `rc/rc.h` API | `s46_jpne_hgw`, `s46_jpne_maprules`, `s46_jpne_report`, `s46map_rptd_main`, `check_s46map_rptd` | `wan46det`, `wan_hgw_detect`, `get_s46_ra`, `get_s46_prefix_host`, `s46reset` |
| `/sbin` applet symlinks created | `mapcalc` **and** `s46map_rptd` | `mapcalc`, `s46reset`, `dslited`, `ocnvcd`, `v6plusd`; **no** `s46map_rptd` |
| prebuilt supplied | `rc/prebuild[/RT-AXE7800]/s46map_rptd.o` | `…/s46comm.o` |
| carrier data symbols (existence and size only — **never read values**) | `JPNE_MF_CODE` (36 B) | `JPIX_MF_CODE` (36 B) + `OCN_API_KEY` (56 B) |

**PASS** for the s46 gap: the package is the `s46comm` generation **and** supplies
`s46comm.o` (or its source) for RT-AXE7800.

**INCONCLUSIVE**: mixed or unrecognised generation, or the correct generation with no supply.

**FAIL**: another self-consistent `s46map_rptd`-generation package — i.e. the 388.34458 result
reproduced, meaning the request was answered with the wrong source line again.

A third, unseen generation is possible. Report the observed API set verbatim rather than
forcing it into one of the two known buckets.

---

## 4. Other components — status separated by evidence class

### Demonstrated active requirements
| component | evidence |
|---|---|
| `shared` `invalid_*` pair | unresolved at the `write_smb_conf` link in the reproducible `clean-replay-v11` build |
| `libwebapi` / `priv_webapi.o` | active build dependency of `libwebapi.so`; `httpd` imports 33 symbols at runtime |
| `rc` / `s46comm.o` | `rc/Makefile:413` under `RTCONFIG_SOFTWIRE46=y`; stock ships the machinery |

### Predicted only — do not treat as blockers
| component | why predicted | why not a blocker |
|---|---|---|
| `shared/amas_apg_shared.o`, `uu_utils.o` | raw supplies 16 objects, Merlin's per-model set is 18; both are 0 in the official archive | not reached by any build; no demonstrated consumer contract |

### Disproven / superseded — do not re-raise
| item | resolution |
|---|---|
| `get_fh_if_prefix_by_unit` | resolved by accepted source adaptation (patch 0007), 0 undefined occurrences in the clean build |
| `hnd_boardid_cmp` | CONFIG-MISMATCH, resolved by model-correct guard (patch 0008); no stock consumer imports it |
| `shared/prebuild/RT-AXE7800` "whole-directory absence" | superseded — 16 authentic objects are supplied and staged |
| `s46comm.o` "omitted from GPL 388.34458" | refuted — that package does not use the object at all |
| `asus_rbd`, `aura_sw`, `bluez-5.56`, `dnsqd` | absent or near-absent from the GPL but never demonstrated as active RT-AXE7800 dependencies |

> Rule enforced throughout: a component is promoted to blocker only on an **active build
> dependency** or a **demonstrated consumer contract** — never on file absence alone.


### Late additions from the pre-ASUS closure (see `PRE-ASUS-CLOSURE.md`)

| check | PASS | INCONCLUSIVE |
|---|---|---|
| `is_rtl8372_boardid` provider | package's `shared`/`rc` supply defines it, **or** its source carries no unguarded RT-AXE7800 reference | neither demonstrable — the documented fallback guard (patch-0008 pattern) then applies |
| `init_asus_pp_eula` / `ASUS_PP` provider | package supplies the symbol (source or authentic prebuilt); stock rc demonstrably implements it internally (`ASUS_PP_CRC/OBJ/UPDATE`) | no provider located |

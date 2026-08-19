# RT-AXE7800 — future blocker map (static audit)

> ## ⚠️ HISTORICAL — predictions partly borne out, partly wrong
>
> This audit was made at the clean-replay-v2 milestone. Recorded outcome:
> `shared` (#1) is **solved**; `rc` (#3) and `httpd` (#4) were correctly predicted and are
> now the live supply boundary. However `libwebapi` was listed here as *"not reachable unless
> features are enabled later"* — that was **wrong**: it is reachable in the current
> configuration and is the **current clean blocker**.
>
> Kept for the record. See [`../docs/STATUS-2026-08-19.md`](../docs/STATUS-2026-08-19.md).
>
> Note also that this map describes the **pinned Merlin union** lineage. The raw GPL 388.34458
> generation has a different component set and builds `rc` and `httpd` without `libwebapi`.

Audited: clean-replay-v2 tree at RMerlin pin `ccd139a31d94de15d2da744083dbafbcfe97dcdf`.
Read-only. No donor file was copied or substituted.

## Predicted blocker order (enabled components only)

From `obj-y`/`obj-$(RTCONFIG_*)` order in `release/src/router/Makefile` combined with
RT-AXE7800's generated `.config`. 24 components ship per-model directories; only these are
reachable in the current configuration:

| # | component | line | gate | status |
|---|---|---|---|---|
| 1 | `shared` | 833 | always | **current blocker** |
| 2 | `protect_srv` | 847 | `RTCONFIG_PROTECTION_SERVER=y` | **solved** (chip-generic `arm_6756hnd`) |
| 3 | `rc` | 1151 | always | next |
| 4 | `httpd` | 1155 | always | after that |
| 5 | `bsd` | 1332 | `RTCONFIG_BCMBSD=y` | later |
| 6 | `networkmap` | 1729 | always | later |
| 7 | `fsmd` | 2070 | `RTCONFIG_FSMD=y` | later |

Not reachable unless features are enabled later: `sw-hw-auth`, `wlc_nt`, `nt_center`,
`libasuslog`, `cfg_mnt`, `bwdpi_source`, `asd`, `ahs`, `libasc`, `libwebapi`, `dns_ping`,
`asus_rbd`, `amas-utils`, `aaews`, `bluez-5.56`, `wlceventd`.

## The 17-vs-18 reconciliation

Both earlier counts were correct; they described **different donors**:

- **18** = `shared/prebuild/GT-AX6000/` (BCM4912, RMerlin tree)
- **17** = `shared/prebuild/{TUF-AX3000_V2,RT-AX58U_V2}/` (both BCM6756, GNUton)

The set difference is exactly one file: **`amas_apg_shared.o`**, present only in the 4912
donor. It is gated by `ifeq ($(RTCONFIG_MULTILAN_CFG),y)` at `shared/Makefile:232`, and
`RTCONFIG_MULTILAN_CFG` is not set for RT-AXE7800. The 17 are a strict subset of the 18.

**17 is the correct expectation for a BCM6756 model** — it is what ASUS ships for both
existing 6756 models.

## Required vs merely present in a donor directory

"Present in a donor dir" is not "required by the RT-AXE7800 build". Objects reach the link via
`$(if $(wildcard <src>.c),<src>.o,prebuild/<src>.o)` — public source wins when present — and
most sit inside `RTCONFIG_*` conditionals. Evaluating each against the tree and the generated
`.config`, for `shared`:

- **4 required and materially unresolved** (`MODEL-PREBUILT-MISSING`):
  `api-broadcom.o` (unconditional, `:327`), `tcode.o` (`RTCONFIG_TCODE=y`, `:411`),
  `amas_utils.o` (`RTCONFIG_BCMBSD=y`, `:462`), `private.o` (`:612` + the observed build error)
- **1 divergent but NOT required now**: `uu_utils.o` — gated by `RTCONFIG_GEARUPPLUGIN`
  (disabled). It is also the one object that matched RT-AX58U_V2 exactly (2/2 symbols).
- **4 further not required now**: `notify_ahs.o` (`RTCONFIG_AHS`), `amas_wgn_shared.o`
  (`RTCONFIG_AMAS_WGN`), `spwenc.o` (`RTCONFIG_ISP_CUSTOMIZE`). Separately, `amas_apg_shared.o`
  (`RTCONFIG_MULTILAN_CFG`) is **not part of either BCM6756 set at all** — it exists only in the
  BCM4912 GT-AX6000 donor, so it is classified non-6756-optional rather than feature-gated.
- **9 required but chip-generic** (`DONOR-ONLY`): byte-identical across both BCM6756 models —
  `bcmutils.o`, `bcmwifi_channels.o`, `bcmxtlv.o`, `ethswctl.o`, `ethctl_cmd.o`,
  `notify_rc.o`, `amas_dwb.o`, `nvpriv.o`, `shutils_private.o`

**The honest count of truly missing model-specific build inputs for `shared` is 4, not 5.**

Machine-readable detail: `RT-AXE7800-BUILD-INPUT-MANIFEST.tsv` (74 rows).

### Method limits
Gate attribution uses the nearest preceding `if*` line per object, which can mis-attribute
where blocks nest or close early. The four `MODEL-PREBUILT-MISSING` entries are corroborated
independently: `private.o` by the actual build error, and `tcode.o` / `api-broadcom.o` /
`amas_utils.o` by measured symbol and function-size divergence against the shipped
`libshared.so`. `rc` (52 objects) and `httpd` (4) are recorded **only as donor per-model inventories**, not as
verified requirement lists. Their exact current-config required subsets remain **unverified**
and every such row is marked `unverified-subset` in the manifest. Deliberately not enumerated
at this stage.

## Build-input vs final-executable split

- `shared`, `rc`, `httpd` need **ELF32 ARM relocatable objects**, which exist only before
  linking. Stock firmware holds only the linked results, so they cannot be recovered from it
  and require ASUS input (or the corresponding source).
- `bsd`, `networkmap`, `fsmd` (and `protect_srv`, solved) take **complete executables /
  shared objects**. A final executable is not a build input and does not reproduce the build;
  stock is noted only as evidence these rank below P0–P2.

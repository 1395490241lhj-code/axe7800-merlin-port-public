# RT-AXE7800 / BCM6756 Asuswrt-Merlin porting research

> ## ⚠️ NOT FLASH-READY — DO NOT FLASH ANYTHING BUILT FROM THIS RESEARCH
>
> This is **experimental RT-AXE7800 / BCM6756 Asuswrt-Merlin porting research**.
> - **No image produced by this work is flash-ready.** Do **not** flash generated images.
> - **No ASUS firmware binaries are redistributed here.** No stock/extracted firmware, no
>   `.o` / `.ko` / `.so` / ELF objects, no dongle firmware, no donor binaries.
> - The build **intentionally stops** at missing model-specific inputs (see below).
> - **Runtime ABI compatibility and flash safety are NOT established.**
> - This repository documents **research and reproducibility. It is not a firmware release.**
> - No router flash, NVRAM, MTD, bootloader or partition operation is part of this workflow.

## What this is

A reproducibility lab for porting Asuswrt-Merlin to the **ASUS RT-AXE7800**
(Broadcom **BCM6756**, profile **96756GW**, 32-bit ARM). Every change is derived from pinned
upstream commits and can be replayed from a clean checkout.

Reproducibility baseline: **RMerlin `asuswrt-merlin.ng`, branch `3006.102-wifi6`, commit
`ccd139a31d94de15d2da744083dbafbcfe97dcdf`**.

> This pinned lineage is *our* reproducibility baseline. It is **not** claimed to be the exact
> ASUS source tree used to produce the official 3.0.0.4.388_25206 firmware.

## Current state (2026-08-18)

The clean port has advanced well past the state described in the first public release. It now
reaches the **model-specific userspace supply boundary**.

### Crossed, in the clean port

- RT-AXE7800 target dispatch
- BCM6756 / 96756GW ARM32 profile selection
- kernel build, `arch/arm/boot/zImage is ready`
- Broadcom driver phase (`dhd.ko`, `wl.ko`, `archer.ko`, `bcm_license.ko`, `bcmmcast.ko`)
- **authentic RT-AXE7800 GPL provenance** established for the P0/P1 objects, from the official
  ASUS GPL 388.34458 package (verified by hash; the package itself is not redistributed here)
- **P0** — the four `shared/prebuild/RT-AXE7800/` objects
- **P1** — five further shared-link objects
- `libshared.so` / `libshared.a` produced
- **WLAN utility ordering** — a build-ordering defect corrected; the utility scripts install
  identically to stock
- **nvram** — a packaging defect corrected; the resulting binary matches stock by hash
- **SYSSTATE_P2** — build/copy stage crossed
- **LIBBCM_P3** — build/copy stage crossed
- **bcm_util include-path defect** corrected and crossed
- **official RT-AXE7800 `ODMPID` target flag restored**, after confirming it in the official
  GPL target stanza
- **`webapi.c` now compiles and `webapi.o` is produced**

> "Crossed" means the build stage completes. Where a produced binary is described as matching
> stock, that is a **build/copy** comparison by hash. **It is not a claim of runtime ABI
> compatibility, and it is not a claim of flash safety.** Neither has been established.

### Current clean blocker

`release/src/router/libwebapi` requires a model-specific object:

    release/src/router/libwebapi/prebuild/RT-AXE7800/priv_webapi.o

The build demands it unconditionally and can only obtain it from that per-model directory,
which does not exist.

- **No authentic RT-AXE7800 copy or source has been found in the material examined.**
- The available **RT-AXE7800 GPL 388.34458 package contains no `libwebapi` component** — no
  directory, no `webapi.c`, no `priv_webapi.c`, no `priv_webapi.o`. The reason for that
  component's absence from this model-specific package has not been established.
- **Cross-model candidates were analyzed but are interface-divergent and have NOT been
  adopted.** No donor binary is published here.

## The supply boundary

`priv_webapi.o` is **no longer believed to be an isolated missing input.**

To find out what lies behind it, a **strictly isolated NON-CLEAN same-model stock-oracle
dependency-mapping experiment** was run. It bypassed `libwebapi` only, purely to observe the
next unmet dependency. It demonstrated that the next blocker is:

    release/src/router/rc/prebuild/RT-AXE7800/

> ### The stock-oracle experiment is NOT part of the clean port
>
> That experiment was **same-model**, **isolated**, and **dependency-mapping only**. It is
> **not clean-port input**, **not source-complete**, **not distributable**, **not runtime
> compatible**, and **not flashable**. **No stock binary is proposed for the final port**, and
> none is published here.

### Evidence levels

These are deliberately kept distinct and are not interchangeable.

| Level | Finding |
|---|---|
| **DEMONSTRATED** | the clean `priv_webapi.o` blocker |
| **DEMONSTRATED** | the `rc` per-model prebuild blocker, in the isolated downstream mapping |
| **STRUCTURALLY PRESENT** | the analogous `httpd` per-model prebuild requirement |
| **PREDICTED** | a residual `bwdpi_source` `bin` / `modules` concern |

## rc — scale of the requirement

- The donor/reference `rc` prebuild directory contains **52 object files**.
- Under the **current** configuration, only **14** are active.
- **13 of those 14 have no corresponding source in the examined tree.**
- Under the **official 388.34458-derived RT-AXE7800 configuration**, analysis predicts
  **43** active objects.
- **42 of those 43 have no corresponding source in the examined tree.**

> This is an **analytical configuration projection**. It is **not** a claim that the internal
> build configuration of 388_25206 is byte-for-byte identical to the reconstruction.

Several of the active objects are **model-unique across all 17 available model directories**.
**No cross-model rc donor has been accepted.**

## httpd

- `httpd` has the **analogous model-specific prebuild mechanism**.
- The **RT-AXE7800 directory is absent**.
- **Four** per-model objects are involved in the examined lineage.
- **None has corresponding source in the examined tree.**

This is **STRUCTURALLY PRESENT** — it is not yet a demonstrated full-build blocker, because no
build has reached it.

## Model-set observation

In the examined lineage, `libwebapi`, `rc`, `httpd` and `bwdpi_source` share the **same
17-model prebuild-directory set**, and **RT-AXE7800 is absent from all four**.

Recorded as an observation only. **No inference about ASUS's intent is drawn from it.**

## ASUS source status

**No newer publicly discoverable RT-AXE7800 GPL package was found through the ASUS support
API, verified deterministic CDN paths, and the public history examined.**

This is a statement about what was found. It is **not** a claim that ASUS never published one.

**An ASUS request for the corresponding source and/or build inputs is pending.**
See [`docs/MISSING-BUILD-INPUTS.md`](docs/MISSING-BUILD-INPUTS.md).

## Wireless

**Wireless runtime compatibility remains unresolved, particularly cross-version BCM6715 DHD
firmware / CLM / regulatory compatibility relative to stock 388_25206.**

## No donor substitution

**No donor object has been imported merely to make the build pass.** Candidate objects from
other models were analyzed against the shipped runtime; where they diverged, they were rejected
and the blocker was left in place. Cross-model substitution could introduce model-specific
ABI, feature, or board-behavior mismatches and would invalidate the provenance assumptions of
this port.

## Layout

    docs/MISSING-BUILD-INPUTS.md   what is missing and why substitution is not valid
    docs/STATUS-2026-08-18.md      dated status snapshot
    prep/                          blocker map, build-input manifest, stock ABI index
    research/public-oracle/        public lineage/provenance research
    repro/clean-replay-v2/         replay script, patches, provenance manifests
    tools/verify-asus-gpl-drop.sh  read-only verifier for a candidate source drop

See [`NOTICE.md`](NOTICE.md) for provenance and licensing.

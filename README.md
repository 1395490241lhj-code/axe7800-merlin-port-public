# RT-AXE7800 / BCM6756 Asuswrt-Merlin porting research

> ## ⚠️ NOT FLASH-READY — DO NOT FLASH ANYTHING BUILT FROM THIS RESEARCH
>
> This is **experimental RT-AXE7800 / BCM6756 Asuswrt-Merlin porting research**.
> - **No image produced by this work is flash-ready.** Do **not** flash generated images.
> - **No ASUS firmware binaries are redistributed here.** No stock/extracted firmware, no
>   `.o` / `.ko` / ELF objects, no dongle firmware.
> - The build **intentionally stops** at missing model-specific inputs (see below).
> - This repository documents **research and reproducibility. It is not a firmware release.**
> - No router flash, NVRAM, MTD, bootloader or partition operation is part of this workflow.

## What this is

A reproducibility lab for porting Asuswrt-Merlin to the **ASUS RT-AXE7800**
(Broadcom **BCM6756**, profile **96756**, 32-bit ARM). Every change is derived from pinned
upstream commits and can be replayed from a clean checkout.

Reproducibility baseline: **RMerlin `asuswrt-merlin.ng`, branch `3006.102-wifi6`, commit
`ccd139a31d94de15d2da744083dbafbcfe97dcdf`**.

> This pinned lineage is *our* reproducibility baseline. It is **not** claimed to be the exact
> ASUS source tree used to produce the official 3.0.0.4.388_25206 firmware.

## Current state

### Verified working
- RT-AXE7800 target dispatch
- BCM6756 / 96756 ARM32 profile selection
- `DHDAP=y` together with `HND_WL=y`
- `dhd.ko` and `wl.ko` build as valid **ELF32 ARM**
- Broadcom driver phase (`archer.ko`, `bcm_license.ko`, `bcmmcast.ko` link)
- `arch/arm/boot/zImage is ready`
- **Clean replay** from a pristine checkout reaches the identical, deterministic blocker

### BUILD-BLOCKING-P0 — where the build stops
Missing model-specific build inputs under `release/src/router/shared/prebuild/RT-AXE7800/`:

- `api-broadcom.o`
- `tcode.o`
- `amas_utils.o`
- `private.o`

These are relocatable ELF32 ARM objects. They exist only *before* linking, so they cannot be
recovered from any firmware image.

### RUNTIME-COMPLETENESS-P0R
- an **RT-AXE7800-specific `6715b0/rtecdc.bin`** (wl1, the PCIe 5 GHz DHD-attached radio)

The RT-AXE7800-specific asset is absent from the public tree. The build tree **can fall back to
a different default `6715b0` firmware** — but that fallback does **not** match the firmware
shipped in official RT-AXE7800 3.0.0.4.388_25206. This is a runtime-completeness gap, not a
build blocker.

## No donor substitution

**No donor object has been imported merely to make the build pass.** Candidate objects from
other models were compared against the shipped runtime by symbol and function size; where they
did not match, they were rejected and the blocker was left in place. Making the build succeed
by substituting another model's binaries would silently bake in wrong board, radio and
regulatory behaviour.

An ASUS GPL/support request is currently pending for the missing model-specific inputs.
See [`docs/MISSING-BUILD-INPUTS.md`](docs/MISSING-BUILD-INPUTS.md).

## Layout

    docs/MISSING-BUILD-INPUTS.md   what is missing and why substitution is not valid
    prep/                          blocker map, build-input manifest, stock ABI index
    research/public-oracle/        public lineage/provenance research
    repro/clean-replay-v2/         replay script, patches, provenance manifests
    tools/verify-asus-gpl-drop.sh  read-only verifier for a candidate source drop

See [`NOTICE.md`](NOTICE.md) for provenance and licensing.

# Status

> ## ⚠️ SUPERSEDED — this snapshot is outdated
>
> This file describes the **clean-replay-v2** milestone. The four
> `shared/prebuild/RT-AXE7800/` objects listed below as "Unresolved" have since been
> **resolved** with authentic ASUS GPL 388.34458 inputs, and the build now stops much later,
> at `libwebapi/prebuild/RT-AXE7800/priv_webapi.o`.
>
> **See [`README.md`](README.md) for the current status.**
>
> Since that snapshot: the standalone GPL build is **established**, the `rc`/`httpd`
> "absent supply" framing has been corrected (the package ships both), and — as of Public
> v3 — a deterministic clean replay exists whose first blocker is
> **`invalid_nvram_get_program` / `invalid_program_check`**, not `priv_webapi.o`.
> See [`README.md`](README.md) for current state.
> The "Established facts" and "Intentionally not attempted" sections below remain accurate and
> are kept for the record.

Frozen at the **clean-replay-v2** milestone. Reproducibility baseline: RMerlin
`3006.102-wifi6` @ `ccd139a31d94de15d2da744083dbafbcfe97dcdf`.

## Validated
Reproduced from a pristine checkout by `repro/clean-replay-v2/replay.sh`, then one
from-scratch build:

- host tools stage passes
- `RTCONFIG_DHDAP=y` generated
- `dhd.ko` ELF32 ARM · `wl.ko` ELF32 ARM
- `archer.ko`, `bcm_license.ko`, `bcmmcast.ko` link
- `arch/arm/boot/zImage is ready`
- first fatal error is the known blocker only — no earlier unrelated failure
- resulting tracked diff: 4 files

### Established facts
- **BCM6756 is 32-bit ARM.** BCM4912 (GT-AX6000 class) objects are AArch64 and wrong here.
- `EXT_PHY="BCM84880"` is a **live build variable** — it generates `RTCONFIG_EXTPHY_BCM84880`,
  consumed by ~14 rc/shared/httpd files. It is a build token, not a description of the physical
  PHY (the DTS separately declares a GPY211 external PHY).
- `SWITCH2="BCM53134"` corroborated by the model's own DTS (external SF2 switch, 4 ports).
- `DHDAP=y` corroborated independently by the published runtime layout and by a public
  third-party RT-AXE7800 target definition.
- Radio topology: wl0 2.4 GHz SoC · wl1 5 GHz PCIe (the DHD-attached radio) · wl2 6 GHz SoC.

## Unresolved
`release/src/router/shared/prebuild/RT-AXE7800/` — `api-broadcom.o`, `tcode.o`,
`amas_utils.o`, `private.o`. No published model's build matches, and the closest candidate
differs per object, so substitution is not valid.

## Intentionally not attempted
- No substitution of unresolved objects to force a green build
- No flashing; nothing here writes to a device
- No redistribution of vendor firmware
- No reconstruction of withheld proprietary objects
- No changes to `EXT_PHY` / `SWITCH2`, which were audited and found correct

## Next input required
Publication of the missing model-specific build inputs, or the corresponding source. An ASUS
GPL/support request is currently pending.

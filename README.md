# RT-AXE7800 / BCM6756 Asuswrt-Merlin porting research

> ## ⚠️ NOT FLASH-READY — DO NOT FLASH ANYTHING BUILT FROM THIS RESEARCH
>
> This is **experimental RT-AXE7800 / BCM6756 porting research**.
> - **No image produced by this work is flash-ready.** Do **not** flash generated images.
> - **No ASUS firmware binaries are redistributed here.** No stock/extracted firmware, no
>   `.o` / `.ko` / `.so` / ELF objects, no dongle firmware, no donor binaries, no images.
> - **Runtime ABI compatibility and flash safety are NOT established.**
> - This repository documents **research and reproducibility. It is not a firmware release.**
> - No router flash, NVRAM, MTD, bootloader or partition operation is part of this workflow.

## What this is

A reproducibility lab for porting Asuswrt-Merlin to the **ASUS RT-AXE7800**
(Broadcom **BCM6756**, profile **96756GW**, 32-bit ARM).

Two separate tracks are now in play, and keeping them apart matters:

| Track | What it is | Status |
|---|---|---|
| **Merlin port** | adding RT-AXE7800 to the newer Asuswrt-Merlin lineage | blocked at a newer-generation interface |
| **Standalone GPL build** | building RT-AXE7800 from ASUS's own published GPL package | **works** |

Merlin baseline: **`asuswrt-merlin.ng`, branch `3006.102-wifi6`, commit
`ccd139a31d94de15d2da744083dbafbcfe97dcdf`**. That pinned lineage is *our* reproducibility
baseline; it is **not** claimed to be the source tree ASUS used for any retail firmware.

## Standalone GPL build — ESTABLISHED

The official **RT-AXE7800 GPL 3.0.0.4.388.34458** package builds RT-AXE7800 **by itself**.

- Validated against a **complete** extraction of the package (an earlier, much smaller partial
  extraction had produced misleading "absent" results and has been retired).
- A **clean one-shot `make rt-axe7800` from a brand-new extraction succeeds**, end to end,
  through kernel, drivers, userspace, rootfs and image packaging.
- Reproduced twice from independent pristine extractions.

What the raw generation does with its own contents:

| Component | Result |
|---|---|
| kernel + modules | built |
| `libshared` / `libbcm` / `sysstate` | built |
| **`rc`** | built, consuming **all 42** of its own flat `rc/prebuild` objects |
| **`httpd`** | built, from **all 4** of its own package objects |
| **bwdpi** | `libbwdpi` and `libbwdpi_sql` built |
| **`libwebapi`** | **not present, and never requested** |

### Buildability vs image soundness — not the same claim

**RAW GPL BUILDABILITY: ESTABLISHED.**
**FINAL IMAGE SOUNDNESS: NOT ESTABLISHED.**

`make` exiting 0 is not evidence of a sound image. Nothing here has been booted, flashed or
validated, and the build tolerates a number of non-fatal errors by ASUS's own design (audited
individually; all belong to alternate packaging paths or optional sample programs).

Any artifact is classified only as **RAW ASUS GPL BUILD ARTIFACT / UNTESTED** — never
flash-safe, boot-validated, runtime-validated or Merlin-compatible. No artifact is published
here.

Host requirements are ordinary and documented: the packages ASUS's own `README.TXT` lists
(including `docbook-xsl`), plus an Autoconf version contemporary with the package's autotools
inputs, provided through an isolated user-owned prefix rather than by changing the system
toolchain.

## What this means for the Merlin port

The current Merlin-side blocker is `libwebapi/prebuild/RT-AXE7800/priv_webapi.o`.

**The raw GPL generation contains no `libwebapi` component at all and never asks for it**, yet
still builds `rc` and `httpd` — the two consumers of `-lwebapi` in the newer Merlin tree — to
complete executables.

So the `priv_webapi.o` requirement is a **newer-generation integration boundary**, not evidence
that GPL 388.34458 is incomplete. That reframes the whole problem: the question is no longer
"which prebuilt is missing from the package?" but "what generation gap sits between the
package and the newer Merlin lineage?"

> ### Do not project newer-Merlin figures backward
>
> Earlier analyses of the **newer Merlin** tree produced rc counts such as **8/14** and
> **37/43**. Those are integration analyses of that newer generation. They describe what a
> newer-Merlin configuration would want; **they must not be applied to raw GPL 388.34458**,
> which needs exactly what its own package ships — all 42 of its flat objects, no more.

## Active research direction

**Fuller GPL-generation merge-scope analysis.** The aim is to determine the minimum coherent
generation scope that must be reconciled to add RT-AXE7800 to the newer Merlin lineage —
rather than continuing to chase one missing prebuilt at a time.

No merge has been started, and none is implied by this milestone.

## ASUS source status

A newer or current corresponding RT-AXE7800 source package remains **useful**, particularly for
the newer-generation `libwebapi` and related interfaces. It is **no longer a prerequisite for
research progress**: building from the published GPL generation is now a demonstrated route.

## Wireless

**Wireless runtime compatibility remains unresolved**, particularly cross-version BCM6715 DHD
firmware / CLM / regulatory compatibility relative to shipping firmware.

## No donor substitution

**No donor object has been imported merely to make a build pass.** Candidate objects from other
models were analyzed and rejected where they diverged. Cross-model substitution could introduce
model-specific ABI, feature, or board-behavior mismatches and would invalidate the provenance
assumptions of this port.

## Layout

    docs/MISSING-BUILD-INPUTS.md   what is and is not missing, per generation
    docs/STATUS-2026-08-19.md      dated status snapshot
    prep/                          blocker map, build-input manifest, stock ABI index
    research/public-oracle/        public lineage/provenance research
    repro/clean-replay-v2/         replay script, patches, provenance manifests
    tools/verify-asus-gpl-drop.sh  read-only verifier for a candidate source drop

See [`NOTICE.md`](NOTICE.md) for provenance and licensing.

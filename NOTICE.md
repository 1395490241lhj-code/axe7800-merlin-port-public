# NOTICE — provenance and licensing

This repository mixes **original work produced by this project** with **references to
third-party upstream projects**. These are separate and are not covered by any single license
choice made here.

## 1. Original material produced by this project

- `tools/verify-asus-gpl-drop.sh`
- `docs/`, `prep/`, `research/public-oracle/` documentation and TSV analyses
- `repro/clean-replay-v2/replay.sh` and the provenance manifests
- `README.md`, `STATUS.md`, this `NOTICE.md`

**No license is granted at this time.** A license has deliberately **not** been chosen: the
material is analytical documentation about third-party GPL projects and vendor firmware, and
picking a license without care could misrepresent the status of the surrounding material.
Absent an explicit grant, default copyright applies. If you want to reuse any of it, please ask.

This conservative position is intentional and may be revisited.

## 2. RMerlin — `asuswrt-merlin.ng`

<https://github.com/RMerl/asuswrt-merlin.ng> — branch `3006.102-wifi6`, pinned commit
`ccd139a31d94de15d2da744083dbafbcfe97dcdf`. Upstream firmware project; its own licensing
(GPL and other terms, per file) applies to its sources. **No RMerlin source tree is included
here.** `repro/clean-replay-v2/patches/*.patch` are small diffs *against* that upstream tree
and necessarily quote a few lines of upstream context.

## 3. GNUton — `asuswrt-merlin.ng`

<https://github.com/gnuton/asuswrt-merlin.ng> — referenced as a BCM6756 comparison source.
Its own licensing applies. **No GNUton content is redistributed here**; only hashes, paths and
analysis.

## 4. SWRT-dev — `asuswrt-bcm`

<https://github.com/SWRT-dev/asuswrt-bcm> — consulted read-only to corroborate an RT-AXE7800
target definition. Its own licensing applies. **Its files are not redistributed here**; only
the extracted flag comparison appears, in `research/public-oracle/TARGET-FLAGS.tsv`.

## 5. ASUS-published GPL / source material and firmware

ASUS publishes GPL source drops and official firmware images for its products. Those remain
under ASUS's terms and any applicable upstream licenses.

**No ASUS firmware or binary is redistributed in this repository** — no stock or extracted
firmware, no `.o` / `.ko` / ELF objects, no `rtecdc.bin`, no checkpoint archives. Official
firmware was used **read-only as a verification oracle**; only sizes, SHA256 values, symbol
counts and paths are published as analysis.

Third-party names and trademarks (ASUS, Broadcom, and the projects above) belong to their
respective owners. This project is independent and unaffiliated.

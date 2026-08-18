# Missing model-specific build inputs

Product: ASUS RT-AXE7800 (BCM6756 / 96756GW, 32-bit ARM).
Reference firmware for comparison: **RT-AXE7800 3.0.0.4.388_25206** (official, publicly
downloadable; used read-only as an oracle and **not** redistributed here).

**An ASUS request for the corresponding source and/or build inputs is pending.** The case
identifier is intentionally not published.

## What is needed

**Model-specific build inputs, or the corresponding source, required to reproduce the published
RT-AXE7800 build.** This is a practical reproducibility request; no legal conclusion about any
particular proprietary object is asserted.

## Resolved since the first public release

The original P0 set — `api-broadcom.o`, `tcode.o`, `amas_utils.o`, `private.o` under
`release/src/router/shared/prebuild/RT-AXE7800/` — is **no longer blocking**. Those objects,
and five further shared-link objects, were obtained from the **official ASUS GPL 388.34458
package for this model** and verified by hash. Per-model inputs for `sysstate` and `libbcm`
came from the same package.

The package itself is not redistributed here.

## Current build-blocking input

    release/src/router/libwebapi/prebuild/RT-AXE7800/priv_webapi.o

`libwebapi/Makefile` adds `priv_webapi.o` to its object list unconditionally, and supplies it
only from `prebuild/$(BUILD_NAME)/`. With no RT-AXE7800 directory, the build stops at
dependency resolution.

- No `priv_webapi.c` was found in any source examined.
- The **RT-AXE7800 GPL 388.34458 package contains no `libwebapi` component at all**: no
  directory, no `webapi.c`, no `priv_webapi.c`, no `priv_webapi.o`. The package does ship
  `release/src/router` with many other components, so this is a specific absence rather than a
  truncated archive.
- The shipped 388_25206 firmware **does** contain `/usr/lib/libwebapi.so`, so the component
  exists for this model.

### Why another model's object cannot be substituted

Objects from other models were analyzed and linked in isolation against a reconstructed
RT-AXE7800 configuration. Every one is **interface-divergent**: the closest candidate still
fails to provide several symbols the shipped library exports, and adds others it does not.
RT-AXE7800 is additionally the only BCM6756 / `96756GW` model in the examined lineage, so no
same-chip candidate exists at all. Several candidates also contain an internal model-check
symbol that the shipped RT-AXE7800 binaries do not.

**No candidate was adopted, and no donor binary is published here.**

## Behind it — rc

    release/src/router/rc/prebuild/RT-AXE7800/

Demonstrated as the next blocker by an isolated NON-CLEAN dependency-mapping experiment (see
the README; it is not part of the clean port and contributes nothing to it).

- The donor/reference `rc` prebuild directory contains **52 object files**.
- Under the **current** configuration, **14** are active; **13 of those 14 have no
  corresponding source in the examined tree**.
- Under the **official 388.34458-derived configuration**, analysis predicts **43** active;
  **42 of those 43 have no corresponding source in the examined tree**.

> This is an **analytical configuration projection**, not a claim that the internal build
> configuration of 388_25206 is byte-for-byte identical to the reconstruction.

Several active objects are **model-unique across all 17 available model directories**. **No
cross-model rc donor has been accepted.**

## Structurally present — httpd

`httpd` has the analogous model-specific prebuild mechanism, the **RT-AXE7800 directory is
absent**, **four** per-model objects are involved in the examined lineage, and **none has
corresponding source in the examined tree**.

This is **STRUCTURALLY PRESENT**, not a demonstrated full-build blocker — no build has reached
it.

## Model-set observation

In the examined lineage, `libwebapi`, `rc`, `httpd` and `bwdpi_source` share the **same
17-model prebuild-directory set**, with **RT-AXE7800 absent from all four**. Recorded as an
observation; **no inference about ASUS's intent is drawn from it**.

## ASUS source status

**No newer publicly discoverable RT-AXE7800 GPL package was found through the ASUS support
API, verified deterministic CDN paths, and the public history examined.** This describes what
was found; it is not a claim that ASUS never published one.

## Runtime completeness — wireless

**Wireless runtime compatibility remains unresolved, particularly cross-version BCM6715 DHD
firmware / CLM / regulatory compatibility relative to stock 388_25206.**

This is described neutrally as a runtime/build asset question for the published firmware. No
GPL claim is made about it, and it is tracked separately from the build inputs above.

## Verification offered

`tools/verify-asus-gpl-drop.sh` is a read-only checker for a candidate source drop. It reports
presence, architecture, SHA256 and defined symbols for the shared-prebuild objects, detects
source shipped instead of prebuilts, and reports runtime assets separately without affecting
the build-input result. It predates the `libwebapi` / `rc` / `httpd` findings and does not yet
cover them.

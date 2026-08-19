# What is missing — per generation

Product: ASUS RT-AXE7800 (BCM6756 / 96756GW, 32-bit ARM).

The word "missing" only means something once you say **which generation** you are building.

## Raw ASUS GPL 3.0.0.4.388.34458 — nothing is missing

The published package builds RT-AXE7800 by itself. A clean one-shot `make rt-axe7800` from a
fresh extraction completes and packages an image, using only the package's own contents plus
documented host prerequisites.

| Component | Supplied by the package | Result |
|---|---|---|
| `shared` | per-target prebuilt objects | `libshared` built |
| `rc` | **42 flat objects** | all 42 consumed, `rc` links |
| `httpd` | **4 objects** | consumed, `httpd` links |
| `bwdpi_source` | prebuilt content + chip sysdeps | `libbwdpi`, `libbwdpi_sql` built |
| `sysstate`, `libbcm` | prebuilt content | built |
| `libwebapi` | **not present** | **never requested** |

> **Correction.** Earlier revisions of this document stated that `rc` and `httpd` supply was
> absent from the package. That was wrong — it came from an incomplete extraction. Both are
> shipped and both are consumed.

## Pinned Merlin union lineage — one interface is missing

    release/src/router/libwebapi/prebuild/RT-AXE7800/priv_webapi.o

The pinned Merlin tree carries a `libwebapi` component that `rc` and `httpd` link against. It
requires a model-specific object that the 388.34458 package does not contain and never
references. `libwebapi` reached Merlin from a different ASUS product line (RT-AX88U /
5.02axhnd, build 388_22525) than the RT-AXE7800 package (5.04axhnd.675x, build 388_34458).

Because the raw package builds `rc` and `httpd` **without** `libwebapi` existing at all, this is
a **cross-product-line integration boundary**, not a hole in the published package. The
RT-AXE7800 build number is the higher of the two, so no chronological ordering is claimed.

### Why cross-model substitution is not the answer

Objects from other models were analysed and linked in isolation. Every candidate is
interface-divergent, RT-AXE7800 is the only BCM6756 / `96756GW` model in the examined lineage,
and several candidates carry an internal model-check symbol that shipping RT-AXE7800 binaries
do not. **No candidate was adopted, and no donor binary is published here.**

## ASUS source status

A newer or current corresponding RT-AXE7800 source package remains **useful**, particularly for
the `libwebapi` interface and related Merlin-side integration requirements.

It is **no longer a prerequisite for progress.** Building from the published GPL generation is
a demonstrated route, and generation-merge analysis can proceed without it.

## Runtime completeness — wireless

**Wireless runtime compatibility remains unresolved**, particularly cross-version BCM6715 DHD
firmware / CLM / regulatory compatibility relative to shipping firmware. Tracked separately
from build inputs; no GPL claim is made about it.

## Verification offered

`tools/verify-asus-gpl-drop.sh` is a read-only checker for a candidate source drop. It reports
presence, architecture, SHA256 and symbols per component across both raw-flat and per-model
layouts, and verifies that an extraction is complete before drawing any absence conclusion —
a guard added precisely because an incomplete extraction previously produced false absences.

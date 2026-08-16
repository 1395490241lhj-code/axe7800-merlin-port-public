# Missing model-specific build inputs

Product: ASUS RT-AXE7800 (BCM6756 / 96756, 32-bit ARM).
Reference firmware for comparison: **RT-AXE7800 3.0.0.4.388_25206** (official, publicly
downloadable; used read-only as an oracle and **not** redistributed here).

**An ASUS GPL/support request is currently pending** for the items below. The case identifier
is intentionally not published.

## What is needed

**Model-specific build inputs, or the corresponding source, required to reproduce the published
RT-AXE7800 build.** This is a practical reproducibility request; no legal conclusion about any
particular proprietary object is asserted.

## P0 — build-blocking

    release/src/router/shared/prebuild/RT-AXE7800/

Required by the current configuration:

| object | referenced at | gate |
|---|---|---|
| `api-broadcom.o` | `shared/Makefile:327` | unconditional |
| `tcode.o` | `shared/Makefile:411` | `RTCONFIG_TCODE=y` |
| `amas_utils.o` | `shared/Makefile:462` | `RTCONFIG_BCMBSD=y` |
| `private.o` | `shared/Makefile:612` + observed build error | empirically required |

Also shipped for other BCM6756 models but not reached by this configuration: `uu_utils.o`,
`notify_ahs.o`, `amas_wgn_shared.o`, `spwenc.o`.

Equally acceptable: the corresponding source (`shared/sysdeps/api-broadcom.c`,
`shared/amas_utils.c`, `tcode.c`, `uu_utils.c`, and a Broadcom `private.c`).

### Why another model's directory cannot be substituted

Comparing candidates' global symbols and function sizes against the shipped `libshared.so`:

| object | closest published model | measured difference |
|---|---|---|
| `tcode.o` | neither | `noasusddns` 212 B vs 180 B; `asus_ctrl_nv` 604 B vs 304 B |
| `api-broadcom.o` | a dual-band 6756 model (38/40) | `get_bonding_port_status` is a real 124 B function in the shipped build vs an 8 B stub |
| `amas_utils.o` | neither (both 18/24) | tri-band vs dual-band band-mapping functions differ |
| `private.o` | a dual-band 6756 model (30/31) | `wl_list_5g_chans` 776 B vs 812 B |

## P0R — runtime completeness (not a GPL claim)

    .../impl87/sys/src/dongle/sysdeps/RT-AXE7800/6715b0/rtecdc.bin

The dongle firmware for **wl1**, the PCIe 5 GHz DHD-attached radio. Installed to
`rom/etc/wlan/dhd/6715b0/rtecdc.bin` when `DHD_6715B0=y`.

The RT-AXE7800-specific asset is **missing from the public tree**. The build tree **can fall
back to a different default `6715b0` firmware**, so the radio is not simply left without
firmware — but **that fallback does not match the firmware shipped in official
3.0.0.4.388_25206** (verified: different SHA256). A publicly extracted RT-AXE7800 filesystem
from a *different* build also differs from the 388_25206 file despite an identical byte size.

This is described neutrally as a **runtime/build asset used by the published RT-AXE7800
firmware**. No GPL claim is made about it, and it is listed separately from the P0 build inputs.

## Verification offered

`tools/verify-asus-gpl-drop.sh` is a read-only checker for a candidate source drop. It reports
presence, architecture, SHA256 and defined symbols for the P0 objects, detects source shipped
instead of prebuilts (path-qualified, so an other-platform implementation cannot satisfy a
requirement), and reports the runtime asset separately without affecting the build-input result.

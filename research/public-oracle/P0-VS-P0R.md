# RT-AXE7800 missing-input classes

## BUILD-BLOCKING-P0 — stops the build today
Path: `release/src/router/shared/prebuild/RT-AXE7800/`

| object | why required | evidence |
|---|---|---|
| `api-broadcom.o` | unconditional, `shared/Makefile:327` | measured divergence vs stock `libshared.so` |
| `tcode.o` | `RTCONFIG_TCODE=y`, `:411` | measured divergence |
| `amas_utils.o` | `RTCONFIG_BCMBSD=y`, `:462` | measured divergence (tri-band vs dual-band) |
| `private.o` | `:612` + observed build error | no trustworthy Broadcom source path published |

These are **relocatable ELF32 ARM objects**; they exist only before linking and cannot be
recovered from any firmware image.

## RUNTIME-CRITICAL-P0R — does not block the build; affects the running device
| asset | expected build-tree location | destination in image |
|---|---|---|
| RT-AXE7800 `6715b0/rtecdc.bin` | `release/src-rt-5.04axhnd.675x/bcmdrivers/broadcom/net/wl/impl87/sys/src/dongle/sysdeps/RT-AXE7800/6715b0/rtecdc.bin` | `rom/etc/wlan/dhd/6715b0/rtecdc.bin` |

Path resolved from `675x/Makefile:685-687`
(`$(SRCBASE)/../../../bcm9$(BRCM_CHIP)/$(DHD_DIR)/src/dongle/sysdeps/$(BUILD_NAME)/6715b0/rtecdc.bin`
with `BRCM_CHIP=6756`, `DHD_DIR=sys`, `BUILD_NAME=RT-AXE7800`, `BCM_WLIMPL=87`), confirmed by
the existing concrete analogue `.../dongle/sysdeps/GT-AX6000/6715b0/`. The RT-AXE7800 directory
is **absent**, so the `sysdeps/default/6715b0` fallback (`Makefile:690`) would apply.

Installation is gated by `DHD_6715B0=y` at `targets/buildFS:473`; the directory
`rom/etc/wlan/dhd/6715b0` is created regardless, only the firmware copy is gated.

`DHD_6715B0=y` is independently supported by **two** sources: the public SWRT-dev RT-AXE7800
target stanza sets it, and the stock 388_25206 runtime layout ships the firmware at that path.

This is a **runtime/build asset used by the published RT-AXE7800 firmware**. It is deliberately
**not** classified as GPL-required — it is proprietary radio firmware, listed separately from
the build inputs above.

No public copy matches stock: the `sysdeps/*` candidates all differ, and the public
crawler-out extraction differs too (see `CRAWLER-OUT-ORACLE.md`).

# RT-AXE7800 public oracle bundle (read-only research)

Produced while the port is frozen at **clean-replay-v2**. No build, no Asuswrt worktree
modification, no third-party binary copied into the port, no router contact.

| file | contents |
|---|---|
| `RMERLIN-LINEAGE.md` | pinned vs current RMerlin lineage; which public refs define RT-AXE7800 |
| `TARGET-FLAGS.tsv` | normalized flag comparison: ours vs the public SWRT RT-AXE7800 stanza, with class |
| `PLATFORM-ARTIFACTS.tsv` | RT-AXE7800 board artifacts with ref, blob sha, sha256, cross-repo identity |
| `DHD-6715B0.md` | end-to-end trace of the flag through buildFS, and the firmware-identity result |
| `HISTORICAL-STOCK-COMPARISON.md` | crawler-out historical rootfs vs our verified 388_25206 oracle |
| `SHARED-P0-LINEAGE.tsv` | public-source lineage for the four P0 shared blockers |
| `CRAWLER-OUT-ORACLE.md` | identification of the public extracted rootfs and its 6715b0 firmware |
| `P0-VS-P0R.md` | build-blocking vs runtime-critical missing-input classes |
| `TARGET-DELTA-LEDGER.md` | future target-flag ledger (nothing enabled) |
| `SOURCE-URLS.txt` | every public source consulted, with refs/commits |

Note: SWRT's `target.mak` was fetched read-only for the flag comparison and deliberately
**not** committed; `TARGET-FLAGS.tsv` carries the extracted result. See `SOURCE-URLS.txt`.

## Headline results

1. **Our pin is a direct ancestor of branch `3006.102-wifi6`** (head `91b625c0`, ahead 0 /
   behind 16, merge-base = the pin). RMerlin's **default branch `main` (`d2701f4e`) is a
   separate, diverged lineage.** None of the 16 commits touch RT-AXE7800 or 6756; the
   RT-AXE7800 file set is identical. **Nothing changes clean-replay-v2.**
2. **No RMerlin or GNUton ref defines an RT-AXE7800 target stanza.** SWRT-dev/asuswrt-bcm does.
3. Our four verified flags — `EXT_PHY="BCM84880"`, `SWITCH2="BCM53134"`, `DHDAP=y`, `HND_WL=y`
   (plus `BCMWL6/BCMWL6A=y`) — **match the public SWRT stanza exactly**. Independent
   corroboration of the DHDAP change that was derived from stock firmware evidence.
4. **`DHD_6715B0` gates exactly one action**: copying the wl1 (PCIe 5 GHz) dongle firmware into
   `rom/etc/wlan/dhd/6715b0/`. Our minimal target omits it, and **no public copy matches stock**
   — including the public crawler-out extraction, which is the **same size (2,750,488) but a
   different SHA256**. Tracked as RUNTIME-CRITICAL-P0R, separate from the build blockers.
5. **crawler-out is a different firmware generation**: `image_version` `5042p1GW0130527` vs our
   stock `5042p1GW1262125`; 4 of 7 fingerprints differ.
6. **No public source removes the ASUS dependency.** SWRT ships 26 model dirs under
   `shared/prebuild/` — RT-AXE7800 is **not** among them, and neither are the `rc`, `httpd`,
   `networkmap`, `fsmd`, `bsd` or `protect_srv` RT-AXE7800 directories.

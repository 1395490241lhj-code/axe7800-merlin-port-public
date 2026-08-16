# Historical stock filesystem comparison (crawler-out)

Source: `GuilhermeMBertolino/crawler-out`, path `asus/RT-AXE7800/`.
**Treated as an untrusted historical comparison source, not authoritative build input.**
Compared **metadata / path layout only** via the GitHub API. **Nothing was downloaded into the
port; no executable or binary was imported.**

Reference: our locally verified stock oracle, RT-AXE7800 3.0.0.4.388_25206
(pkgtb sha256 `809f32c9…54854`), extracted read-only outside the worktrees.

## Top-level layout
crawler-out `asus/RT-AXE7800/` exposes `bin dev lib opt rom sbin tmp usr var www` plus
`.init_enable_core` — the same shape as our extracted rootfs.

## rom/etc comparison

| item | verdict |
|---|---|
| `rom/etc/96756GW` | **MATCH** — 14,731 bytes in both (ours sha256 `1775e1e31f5d82a2b742d65d…`) |
| `adsl1`, `arl`, `build_profile`, `default.script`, `dhcp/`, `dhcp6c/6s.conf.sample`, `dyndscp.sh`, `e2fsck.conf`, `ethertypes`, `filesystems`, `fstab`, `fw/`, `get_rootfs_dev.sh`, `hotplug2.rules`, `hp_wrapper.sh`, `image_version`, `init.d/`, `ipv6_start.sample`, `ld.so.conf`, `lte_start.sh`, `make_mmc_links.sh`, `make_static_devnodes.sh` | **MATCH** (present in both, same names/ordering) |
| `adsl` | **CURRENT-STOCK-ONLY** — present in 388_25206, not in the crawler-out listing |
| `mdev.conf` | **PUBLIC-HISTORICAL-ONLY** in the listing window examined (our listing was truncated at the same depth; treat as UNKNOWN rather than a real difference) |

## Assessment
The historical public rootfs and our verified 388_25206 oracle agree on model-specific layout
(`rom/etc/96756GW` byte-size identical, same wireless firmware path shape
`rom/etc/wlan/dhd/<chip>/`). No contradiction with any clean-replay-v2 finding was observed.

**Limitation, stated plainly:** this was a shallow, listing-level comparison of `rom/etc` only.
Per-file hashing across the whole tree was not performed, and the crawler-out image's firmware
version was not established. Items marked UNKNOWN above should not be read as real differences.

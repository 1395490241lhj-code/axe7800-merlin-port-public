# crawler-out public runtime oracle — identification

Source: `GuilhermeMBertolino/crawler-out`, `asus/RT-AXE7800/` (branch `main`).
**Untrusted public historical comparison source.** The one binary downloaded was placed in a
temporary research directory outside every Asuswrt worktree and is **not** committed, **not**
imported into the port, and **not** treated as a redistributable build input.

## TASK 2 — 6715b0 firmware identity

| | value |
|---|---|
| path | `asus/RT-AXE7800/rom/etc/wlan/dhd/6715b0/rtecdc.bin` |
| size | 2,750,488 bytes |
| GitHub blob SHA | `56b80e70fb41717f6e6f59b13019b5126291bffe` (validated: `git hash-object` of the download matches) |
| `file` | `data` (raw dongle firmware image) |
| **SHA256** | **`6a938e0bbe3225f84ac649d7c94e49327bf5941b37206e3f7d8846a254605844`** |
| stock 388_25206 SHA256 | `d4c760d14b4d953df716f6787af5f9b94d311c75143bc2a3521af29a9a7eca81` |

### VERDICT: **DIFFERENT**

The sizes are byte-for-byte equal (2,750,488) but the **full SHA256 differs**. Size equality is
not identity — this is precisely why a truncated hash must never be used for this comparison.

Against every public 6715b0 candidate already inventoried (`sysdeps/default`, `GT-AX6000`,
`GT-AXE16000`, `GT-AX11000_PRO`, `RT-AX86U_PRO`, `RT-AX88U_PRO`): **DIFFERENT from all**.

So **no public copy of the RT-AXE7800 6715b0 firmware matching our verified 388_25206 stock is
known** — including this one.

## TASK 3 — which firmware generation is crawler-out?

Explicit version metadata exists, so no inference from upload date was needed:

| file | crawler-out | our stock 388_25206 |
|---|---|---|
| `rom/etc/image_version` | `5042p1GW0130527` | `5042p1GW1262125` |

Fingerprint set (git blob SHA = exact content comparison):

| file | crawler size | stock size | verdict |
|---|---|---|---|
| `rom/etc/96756GW` | 14,731 | 14,731 | **IDENTICAL** |
| `rom/etc/wlan/dhd/6715b0/rtecdc.bin` | 2,750,488 | 2,750,488 | **SAME-SIZE, DIFFERENT CONTENT** |
| `/sbin/rc` | 2,016,348 | 2,028,732 | DIFFERENT |
| `/usr/lib/libshared.so` | 542,460 | 542,232 | DIFFERENT |
| `/usr/sbin/bsd` | 204,260 | 204,260 | **IDENTICAL** |
| `/usr/sbin/networkmap` | 97,784 | 93,684 | DIFFERENT |
| `/usr/sbin/fsmd` | 18,048 | 18,048 | **IDENTICAL** |

### CLASSIFICATION: **OLDER/DIFFERENT-BUILD** (closely related)

`image_version` differs explicitly, and 4 of 7 fingerprints differ, so it is **not** 388_25206.
Several components (`96756GW` board config, `bsd`, `fsmd`) are byte-identical, which is normal
for parts unchanged between releases of the same model — hence "closely related".

**Ordering caveat:** the two `image_version` strings differ, but nothing in them reliably
establishes which is newer, and no ordering is asserted here. Equally, the fact that `bsd` and
`fsmd` match does **not** imply the images are the same generation — that is exactly the
single-blob inference the audit was designed to avoid.

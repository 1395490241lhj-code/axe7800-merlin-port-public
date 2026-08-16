# clean-replay-v2 — reproducibility artifacts

Text artifacts describing the validated replay. **No binaries, no build logs, no firmware.**

`replay.sh` reconstructs the port from a pristine checkout of the pinned upstream commit using
only pinned refs, verifying every imported item by SHA256 and asserting the resulting target
values. It does **not** build; `make rt-axe7800` is run separately.

| file | contents |
|---|---|
| `replay.sh` | deterministic replay script |
| `patches/0001-add-RT-AXE7800-target.patch` | adds the RT-AXE7800 target definition |
| `patches/0002-phy-chip-scoped-prebuilt-selection.patch` | chip-scoped phy prebuilt selection so ARM32 (6756) and AArch64 (4912) can share one tree |
| `binary-provenance-manifest.txt` | sha256/size/type/source/rationale for each imported item |
| `hosttools-lzop-evidence.txt` | host-tool staging evidence, incl. an executed identical-input compression test |
| `ui-blobs.txt` | git blob ids + sha256 for authentic model UI files (metadata only) |
| `config-and-module-evidence.txt` | generated config values and built module arch/size/sha256 |
| `first-fatal-error.txt` | the exact blocker the build stops at |
| `COMPARISON.md`, `git-diff-stat.txt`, `replay-head.txt` | replay tree state |

Outcome: host tools pass · `RTCONFIG_DHDAP=y` · `dhd.ko`/`wl.ko` ELF32 ARM ·
`archer.ko`/`bcm_license.ko`/`bcmmcast.ko` link · `zImage` ready · first fatal error is the
documented missing-input blocker.

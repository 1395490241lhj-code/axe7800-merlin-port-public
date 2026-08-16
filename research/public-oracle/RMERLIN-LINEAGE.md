# RMerlin lineage audit

| | value |
|---|---|
| pinned baseline | `ccd139a31d94de15d2da744083dbafbcfe97dcdf` ("Bumped revision to 3006.102.8_2", 2026-07-28) |
| contained in | `refs/heads/3006.102-wifi6`, `refs/remotes/origin/3006.102-wifi6` |
| head of branch **3006.102-wifi6** | `91b625c0e78ff84e9f4f6ef004c0d629729f769e` |
| merge-base | `ccd139a31d…` (= the pin itself) |
| relationship | **pinned is a direct ANCESTOR — fast-forward lineage, NOT diverged** |
| pin vs branch head | **ahead 0 / behind 16** |
| release family | 3006.102 "wifi6" line (the only branch RMerlin now publishes on this remote) |

## Branch attribution (corrected)

`91b625c0` is the head of **branch `3006.102-wifi6`** — the continuation of our lineage. It is
**not** "the repository current head": RMerlin's **default branch is `main`**, head
`d2701f4e238c2f423849fc78368223d883efbf44`, and GitHub's compare API reports our pin as
**`diverged`** from `main`. `main` is a separate lineage/ref and is not the continuation of the
pinned 3006.102 line.

    pin ccd139a31d  ->  3006.102-wifi6 head 91b625c0e7
    ahead 0 / behind 16 ; merge-base = ccd139a31d (the pin itself)

## Do the 16 newer commits touch RT-AXE7800 or 6756?

**No.** `git log $PIN..$HEAD --name-only -- '*AXE7800*' '*6756*'` returns nothing. The 16
commits are webui/libovpn/httpd/miniupnpd/openvpn hardening and documentation. The RT-AXE7800
file set is **identical (19 files)** between the pin and the current head.

## Does any public RMerlin or GNUton ref define an RT-AXE7800 target?

**No.** Scanning every fetched ref's `release/src-rt/target.mak` for `export RT-AXE7800`
returns zero matches in both remotes. RT-AXE7800 board data (DTS, .nvm, bootloader configs,
target profile, icons, runin script) is published, but **no target stanza** is.

The stanza our port uses is project-authored — and, per `TARGET-FLAGS.tsv`, its four
hardware/mechanism flags match the independent SWRT-dev stanza exactly.

## SWRT-dev/asuswrt-bcm

Does contain a full public `export RT-AXE7800` stanza (37 code-search hits across the repo).
Treated as an ASUS-GPL-derived third-party fork: useful for **flag corroboration**, not as a
binary source. See `TARGET-FLAGS.tsv`.

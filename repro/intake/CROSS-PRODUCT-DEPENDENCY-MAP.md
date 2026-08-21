# Cross-product inherited-dependency map (RT-AXE7800, pinned Merlin `ccd139a31d`)

**Read-only audit, 2026-08-20.** Frontier stays frozen at the `invalid_*` pair; no build, no
source edit, no stub. Purpose: separate what a future matching RT-AXE7800 `388_25xxx` package
will fix from what it **cannot** fix — dependencies Merlin inherited from other product lines.

## Method

Post-preprocessing truth, not text greps: `nm -u` over objects actually compiled under the
RT-AXE7800 configuration (56+5 clean-lineage shared/libdisk objects; 47 rc objects from the
old lineage — used strictly as *preprocessing* evidence, since the synthetic objects there
faked link-time providers, never what open code references). Undefined pool (686 distinct)
minus a same-model provider universe (38,039 symbols: our clean `libshared.so`, the authentic
supply, every stock `388_25206` library export) → 219 orphans → definition-scan shrink → 78 →
model-prebuilt oracle + second-pass shrink → **3 true orphans**, of which one is libc noise
(`mknod`). Stock is an ABI oracle only; no credential values read.

## Prioritized table

| # | item | origin lineage | RT-AXE7800 reachability | classification |
|---|---|---|---|---|
| 1 | **`is_rtl8372_boardid`** (`shared.h:3353`) | GT-BE98 / GT-BE96 / GT-BE19000 line (RTL8372 2.5G switch) | **survives compilation — compiled `rc/init.o` references it.** Both `init-broadcom.c` sites are inside `#elif defined(GTBE98)‖…` (compiled out); the surviving reference enters via `rc/init.c`. Stock exports it nowhere; no model rc prebuilt defines it; raw 34458 `private.o` lacks it (it is a Merlin-line `private.o` extra). RT-AXE7800's switch is BCM53134 — RTL8372 semantics are model-foreign | **CROSS-PRODUCT-CONFIG-MISMATCH (candidate)** — will surface at the rc link; **no ASUS package fixes it** |
| 2 | **`init_asus_pp_eula`** | ASUS privacy-policy generation (BE-era `ASUS_PP_*` surface) | referenced by compiled rc code; not exported by any stock library — but rc-internal definition inside stock's stripped `/sbin/rc` cannot be ruled out | **UNKNOWN** — one probe needed |
| 3 | `hnd_boardid_cmp` | RT-BE96U | resolved | **done** (patch 0008) — pattern proof |
| 4 | `get_fh_if_prefix_by_unit` | RT-BE86U (102_36216) | resolved | **done** (patch 0007) — pattern proof |
| 5 | VPN/tunnel helpers `is_tpvpn_configured`, `vpnc_use_tunnel`, `vpns_use_tunnel`, `is_wgs_use_tunnel` | newer ASUS lines via Merlin merges | open callers in Merlin's own VPN code (`services.c`, `wireguard.c`, `misc.c`, `vpn_utils.c`); **stock exports all four** (they are in the 44), stock consumers import none | **MATCHING-GPL-SHOULD-FIX** for the link; runtime relevance is Merlin-feature-driven |
| 6 | `update_ntp_ts`, `str_to_md5`, `live_update_rsa_ver` | newer `spwenc.o`/`shared` generation | open callers (`ntpd.c`, `tc_utils.c`, `version.c`); stock exports them | **MATCHING-GPL-SHOULD-FIX** |
| 7 | GPY211 WAR family: `GPY211_SPEED_WAR_1G`, `GPY211_SPEED_WAR_AUTO`, `GPY211_WAR_ANEG`, `gpy211_monitor_main` | GPY211-PHY platform family (GT-AX6000 etc.) | callers in `rc.c`/`lan.c`; **RT-AXE7800 genuinely has a GPY211 PHY (DTS)**; defined in other models' `gpy211_war.o`, absent from our 34458-gen 42 | **MATCHING-GPL-SHOULD-FIX** — legitimate, provider is generational |
| 8 | `lan_phy_led_pinmux` | TUF-AX3000_V2 platform family | guard **explicitly lists `RTAXE7800`**; provider is the s46comm-era `broadcom.o` (seen in RT-AX88U_PRO's), while our authentic 34458 `broadcom.o` lacks the symbol — a generation gap *inside* one object | **MATCHING-GPL-SHOULD-FIX** — crisp example that same-named objects differ by generation |
| 9 | s46 applet mains `ocnvcd_main`, `dslited_main`, `auto46det_main` (+ 14 orphans defined by other-model rc prebuilts) | s46comm generation | applet dispatch in `rc.c` | folds into known gap #3 (`s46comm.o` family) — **MATCHING-GPL-SHOULD-FIX** |
| 10 | remaining latent stock-only `libshared` symbols with rc/httpd callers (`acs_set_chwt`, `avbl_reset_exclvalid`, `chk_acscli2_cmds`, `check_wlx_nband_type`, `create_amas_sys_folder`, `get_ASUS_privacy_policy[_state]`, `get/set_gpio_rc`, `gu_enable_status`, `noasusddns`, `wl_get_chlist_band`, `invalid_nvram_get_name`) | newer shared generation | 12 of them are **imported by stock rc/httpd** — genuinely exercised on-device | **MATCHING-GPL-SHOULD-FIX** — these become the next `libshared` surface once a 25xxx package lands |

## Task 5 verdict — the 42 latent libshared symbols

**21 CURRENTLY REFERENCED** by open Merlin `.c` (list above, rows 5/6/10 plus `hnd_boardid_cmp`);
**21 NO CURRENT CONSUMER**. None of the 21 references appears in any object compiled so far
(shared/libdisk: 0 hits) — they live in rc/httpd, i.e. **behind** the frozen frontier. They are
future link-surface, not present blockers, and every one of them is a stock export — so a
matching package's newer `libshared` resolves them. ABI-difference counts did not become a
blocker list.

## Top 2 independently actionable candidates (adaptations NOT implemented)

1. **`is_rtl8372_boardid`** — smallest experiment: locate the surviving `rc/init.c` call
   site(s) and their guard stack; confirm the runtime branch is model-inapplicable (BCM53134
   vs RTL8372); if so, propose a model-correct guard exactly like patch 0008. Read-only; one
   grep + one preprocessing check of `init.c` under the RT-AXE7800 macro set.
2. **`init_asus_pp_eula`** — smallest experiment: find its caller + guard, and check whether
   stock's rc implements the ASUS_PP EULA flow internally (S46_DBG-style `__FUNCTION__`
   literals in stock rc). If stock exercises it, reclassify MATCHING-GPL-SHOULD-FIX and drop.
3. *(no third — the sweep found no other package-unfixable candidate that survives
   compilation; that is itself the result)*

## What a matching 388_25xxx package fixes vs cannot fix

**Fixes** (evidence-backed): the `invalid_*` frontier pair, `libwebapi`, `s46comm.o` + its
applet family, the GPY211 WAR provider, the generational `broadcom.o` delta
(`lan_phy_led_pinmux`), and all 21 latent `libshared` consumer references.
**Cannot fix**: `is_rtl8372_boardid` (stock itself does not export it) and any future
dependency of the same class; plus everything already resolved by patches 0007/0008. The
package-unfixable class is currently **one live candidate deep** — the port's cross-product
debt is nearly settled.

## 388.34458-backport route (planning answer only)

If Merlin features were instead backported onto the official 34458 base, the hardest
transplants would be, in order: (1) the **s46comm-generation S46 stack** — Merlin's open
`wan.c`/`udhcpc.c`/`services.c`/`multi_wan.c` assume an API generation the 34458 base does not
have, and the private providers don't exist in that generation at all; (2) **Merlin features
bound to newer `libshared`/`spwenc` surface** (VPN tunnel helpers, NTP timestamping, privacy
policy, `aws-iot`) — rows 5/6/10 above would each need adaptation or a newer private object;
(3) the **multi-WAN framework** (no `multi_wan.c` in 34458); (4) UI/www generation. The
current forward route (Merlin base + matching package) leaves all of that intact and is
structurally cheaper; the backport route would convert every row above from
"package-should-fix" into "hand-port".

## Caveats

Old-lineage rc objects were used only as preprocessing evidence; the stanza (patch 0009)
originated from that same tree, so macro state matches the clean lineage. `httpd` objects do
not exist in either lineage — httpd-side surface is inferred from stock imports only.
`mknod` in the residue is provider-universe noise (libc), not a finding.

# Final pre-ASUS closure: the last two candidates, and the waiting-state map

**Read-only, 2026-08-20.** Frontier stays frozen at `invalid_nvram_get_program` /
`invalid_program_check`. No build, no edit, no stub. Stock used as ABI/runtime oracle only.

## 1. `is_rtl8372_boardid` — closed as LIKELY-GENERATION-GAP (package-should-resolve)

**What the caller decides.** The RTL8372 is a Realtek 2.5G switch used on the
GT-BE98 / GT-BE96 / GT-BE19000 families. `is_rtl8372_boardid()` is a local-board-variant
test (the `hnd_boardid_cmp` shape). Of its ~50 call sites across `rc/` and `shared/`, all
`shared/`-side sites are compiled out for RT-AXE7800 (our `libshared.so` linked with zero
references), and nearly all `rc/` sites sit under `#if defined(GTBE98)‖GTBE98_PRO‖GTBE96‖
GTBE19000…` guards. At least one `rc/init.c` site survives — compiled `init.o` carries
exactly one undefined reference (hard `nm` evidence). The demonstrably-live site at
`init.c:26754` builds AMAS/onboarding interface lists: RTL8372 boards route WAN over
`vlan4094`, others add `eth1`. On RT-AXE7800 (BCM53134 per DTS; no RTL8372 anywhere in its
topology) the function returns false at runtime and the generic `eth1` branch is taken —
**runtime-benign, link-live**.

**Why this is NOT confirmed cross-product mismatch.** Stock `388_25206` `/sbin/rc` contains
Realtek switch-command strings (`rtkswitch 4219`, `4119`, `36/37/39` — 8 hits) that appear
nowhere in Merlin's open rc — i.e. the 25xxx generation's own **private** rc code carries
Realtek handling for this multi-model source. ASUS builds RT-AXE7800 from the same shared
tree, so their 25xxx build either supplies the definition (an rc-linked private object —
invisible in the stripped stock binary, which is why no stock *library* exports it) or their
slightly older source lacks the newest call sites. Either way the matching package is
expected to resolve it. It is therefore **removed from the package-unfixable class** and
becomes an **intake check**.

**Fallback (prepared, not applied):** if the package neither provides the symbol nor omits
the references, scope the surviving `rc/init.c` site(s) with the same
`#if defined(GTBE98) || defined(GTBE98_PRO) || defined(GTBE96) || defined(GTBE19000) ||
defined(GTBE19000AI) || defined(GTBE96_AI)` guard its ~40 siblings already use — the
patch-0008 pattern exactly, behavior-preserving on the RTL8372 models.

*Method caveat, recorded honestly:* the per-site liveness table was produced with a guard
walker that does not model `#else` branches; the authoritative fact is the compiled-object
evidence (≥1 live site), and the exact live set needs enumerating only if the fallback is
ever actually needed.

## 2. `init_asus_pp_eula` — closed as A. STOCK-INTERNAL

Merlin's caller is **unconditional**: the tail of `init_nvram2()` (`rc/init.c:23567`),
immediately after `detect_vul_scan()` — a known libwebapi private. Declared at
`shared/shared.h:5568`. Absent from official 388.34458 entirely (newer-generation surface).
Stock `/sbin/rc` contains the machinery internally: `ASUS_PP_CRC`, `ASUS_PP_OBJ`,
`ASUS_PP_UPDATE` strings, and stock `libshared.so` exports the sibling `ASUS_PP_t` /
`get_ASUS_privacy_policy*` surface. The provider is stock-internal (rc-linked private code),
so **a matching package/source generation should naturally resolve it**. Intake check added.

## 3. Waiting-state map — final

**Package-dependent blockers** (all expected from a matching RT-AXE7800 `388_25xxx` package):
`invalid_nvram_get_program` · `invalid_program_check` · the libwebapi private contract
(22/34 symbols incl. 4 security validators) · s46comm-generation S46 (`s46comm.o` + applet
mains) · GPY211 WAR provider (`gpy211_war.o`) · generation-correct `broadcom.o` /
`shared` / `spwenc` surfaces (incl. the 21 referenced latent `libshared` symbols) ·
`is_rtl8372_boardid` provider · `init_asus_pp_eula` provider.

**Merlin-side independent adaptations:** `get_fh_if_prefix_by_unit` (patch 0007, done) ·
`hnd_boardid_cmp` (patch 0008, done) · **nothing else pending** — one contingent fallback
guard documented above, actionable only after intake says it is needed.

**The package-unfixable class now stands at zero.**

## 4. Is more pre-ASUS research worthwhile? — **No.**

The orphan sweep bottomed out (686 undefineds → 3 true orphans → all three now classified,
one as libc noise). Every remaining unknown — whether the package defines
`is_rtl8372_boardid`, ships `libwebapi`, is the s46comm generation — is decidable only by
the package itself, and the intake tooling to decide it in minutes already exists.
**Recommendation: freeze technical work here and wait for ASUS.** The next technical action
is running the intake flow against whatever ASUS returns.

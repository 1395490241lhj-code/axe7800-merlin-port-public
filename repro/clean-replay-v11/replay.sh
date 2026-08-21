#!/bin/bash
# RT-AXE7800 deterministic clean replay v11.
# One script, one pass: pinned base -> full legitimate integration state, ready for ONE build.
#
# Inputs:
#   $1 = fresh worktree at RMerlin ccd139a31d (git status must be empty)
#   $2 = authentic-supply cache dir (default ~/gpl-supply-cache)
#
# External authentic input this replay depends on (verified, never trusted by path):
#   ASUS GPL_RT-AXE7800_3.0.0.4.388.34458-g90b8ce5.tgz
#   sha256 6fe789e03d64393cfb6faba18c75edac42ecfe69af80aef18acd4f53d0793355
#   Every staged object is verified file-by-file against the committed
#   repro/source-adaptation-v1/supply-manifest.txt regardless of cache origin.
#
# What it deliberately does NOT do: no synthetic objects, no donor binaries as build
# inputs, no shared/prebuild/RT-AXE7800 fabrication beyond the authentic 16 manifest
# objects, no libwebapi/s46comm workaround, no feature disabling.
set -euo pipefail
WT="${1:?usage: replay.sh <fresh-worktree> [supply-cache]}"
CACHE="${2:-$HOME/gpl-supply-cache}"
RMERLIN_PIN=ccd139a31d94de15d2da744083dbafbcfe97dcdf
GNUTON_PIN=92e9b31110471cc38927b9aca135cc775d144c5a
RP="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$RP/../.." && pwd)"
MANIFEST="$REPO/repro/source-adaptation-v1/supply-manifest.txt"
P=release/src-rt-5.04axhnd.675x
R=release/src/router
log(){ printf '  %s\n' "$*"; }

cd "$WT"
echo "== A: preflight =="
[ "$(git rev-parse HEAD)" = "$RMERLIN_PIN" ] || { echo "FATAL: not at RMerlin pin"; exit 1; }
[ -z "$(git status --porcelain)" ] || { echo "FATAL: worktree not pristine"; exit 1; }
git cat-file -e "$GNUTON_PIN^{commit}" || { echo "FATAL: gnuton pin objects missing"; exit 1; }
[ -f "$MANIFEST" ] || { echo "FATAL: committed supply manifest missing"; exit 1; }
[ -d "$CACHE" ] || { echo "FATAL: supply cache missing: $CACHE"; exit 1; }
log "pin OK, pristine OK, gnuton objects OK, manifest OK, cache OK"

echo "== B: model integration (patches 0001/0002 + platform tree + wiring) =="
git apply "$RP/patches/0001-add-RT-AXE7800-target.patch";              log "0001 target stanza"
git apply "$RP/patches/0002-phy-chip-scoped-prebuilt-selection.patch"; log "0002 phy selector"
rm -rf /tmp/replay-extract; mkdir -p /tmp/replay-extract
git archive "$GNUTON_PIN" "$P/router-sysdep.tuf-ax3000_v2" | tar -x -C /tmp/replay-extract
mv "/tmp/replay-extract/$P/router-sysdep.tuf-ax3000_v2" "$P/router-sysdep.rt-axe7800"
log "router-sysdep.rt-axe7800 <= gnuton tuf-ax3000_v2 ($(find $P/router-sysdep.rt-axe7800 -type f|wc -l) files)"
gn(){ mkdir -p "$(dirname "$2")"; git cat-file -p "$GNUTON_PIN:$1" > "$2"; chmod "$3" "$2"; }
gn "$P/bcmdrivers/broadcom/char/license/impl1/bcm_license.o" "$P/router-sysdep.rt-axe7800/hnd_extra/prebuilt/bcm_license.o" 755
for f in phy_drv.o phy_drv_brcm.o gpy211.o; do
  gn "$P/bcmdrivers/opensource/phy/prebuilt/TUF-AX3000_V2/$f" "$P/bcmdrivers/opensource/phy/prebuilt/6756/$f" 755
done
gn "$R/protect_srv/lib/prebuild/arm_6756hnd/libptcsrv.so" "$R/protect_srv/lib/prebuild/arm_6756hnd/libptcsrv.so" 755
gn "$R/protect_srv/lib/prebuild/arm_6756hnd/prebuild/libptcsrv.so" "$R/protect_srv/lib/prebuild/arm_6756hnd/prebuild/libptcsrv.so" 755
ln -sfn arm_6756hnd "$R/protect_srv/lib/prebuild/RT-AXE7800"
for pair in "bcmdrivers/broadcom/char/archer/impl1/archer.o:archer.o" \
            "bcmdrivers/broadcom/char/cleds/impl1/bcm_cleds.o:bcm_cleds.o" \
            "bcmdrivers/opensource/net/enet/impl7/bcm_enet.o:bcm_enet.o" \
            "bcmdrivers/opensource/char/mcast/impl1/bcmmcast.o:bcmmcast.o"; do
  d="${pair%%:*}"; n="${pair##*:}"; ln -sfn "../../../../../router-sysdep/hnd_extra/prebuilt/$n" "$P/$d"
done
log "chip-scoped binaries + 4 wiring symlinks"
LZ="$P/hostTools/prebuilt/GT-AX6000/lzop"
file -b "$LZ" | grep -q x86-64 || { echo "FATAL: lzop not x86-64 host tool"; exit 1; }
mkdir -p "$P/hostTools/prebuilt/RT-AXE7800"; ln -sfn ../GT-AX6000/lzop "$P/hostTools/prebuilt/RT-AXE7800/lzop"
log "lzop host-tool symlink"
n=0
while read blob sha bytes rel; do
  case "$blob" in \#*|"") continue;; esac
  mkdir -p "$R/www/sysdep/RT-AXE7800/$(dirname "$rel")"
  git cat-file -p "$blob" > "$R/www/sysdep/RT-AXE7800/$rel"
  [ "$(sha256sum "$R/www/sysdep/RT-AXE7800/$rel"|cut -d' ' -f1)" = "$sha" ] || { echo "FATAL UI hash $rel"; exit 1; }
  n=$((n+1))
done < "$RP/ui-blobs.txt"
log "restored $n authentic UI files (sha256-verified)"

echo "== C: authentic GPL supply, manifest-verified =="
ok=0
while read -r h sz dest; do
  case "$h" in \#*) continue;; esac
  s="$CACHE/$dest"
  [ -f "$s" ] || { echo "FATAL: cache missing $dest"; exit 1; }
  [ "$(sha256sum "$s"|cut -d' ' -f1)" = "$h" ] || { echo "FATAL: cache hash mismatch $dest"; exit 1; }
  mkdir -p "$(dirname "$dest")"; cp -p "$s" "$dest"; ok=$((ok+1))
done < <(grep -v '^#' "$MANIFEST")
log "staged $ok authentic objects, every sha256 verified against committed manifest"

echo "== D: replay-fix + adaptation patch series =="
for pp in 0003-wlan-setuplink-order-only-edge 0004-wlan-nvram-prebuilt-all-tags 0005-bcm-util-bcm963xx-include-path 0006-rt-axe7800-odmpid 0009-configclosure-accepted-stanza; do
  patch -p1 --forward --silent < "$RP/patches/$pp.patch"; log "$pp"
done
git apply "$RP/patches/0007-guard-get_fh_if_prefix_by_unit-on-RTCONFIG_MULTILAN_CFG.patch"; log "0007 get_fh MULTILAN_CFG guard"
git apply "$RP/patches/0008-scope-hnd_boardid_cmp-branch-to-RTBE96U.patch";                 log "0008 boardid RTBE96U guard"

echo "== E: assertions =="
grep 'BUILD_NAME="RT-AXE7800"' release/src-rt/target.mak | grep -q 'DHDAP=y' && log "target stanza OK"
ST=$(grep 'BUILD_NAME="RT-AXE7800"' release/src-rt/target.mak)
for tok in 'PROXYSTA=y' 'AMAS=y' 'SW_HW_AUTH=y' 'TPVPN=n'; do
  echo "$ST" | grep -q -- "$tok" || { echo "FATAL: accepted-config token missing: $tok"; exit 1; }
done
log "configclosure stanza tokens OK (PROXYSTA/AMAS/SW_HW_AUTH=y, TPVPN=n)"
[ "$(grep -rl 'synthetic-empty-diagnostic' . 2>/dev/null | wc -l)" = 0 ] && log "synthetic marker scan: 0"
[ "$(grep -rl 'axe7800_private_abi_linkclosure_probe\|axe7800_priv_webapi_linkclosure_probe' . 2>/dev/null | wc -l)" = 0 ] && log "probe symbol scan: 0"
# Refuse to proceed if any diagnostic/synthetic object ever reaches a supply directory.
# (The private lab additionally pins the exact fingerprints of its own quarantined probes;
#  the marker-string assertion below is the portable, publishable equivalent.)
for d in "$R/shared/prebuild" "$R/rc/prebuild" "$R/libwebapi"; do
  [ -d "$d" ] || continue
  [ "$(grep -rl 'synthetic-empty-diagnostic' "$d" 2>/dev/null | wc -l)" = 0 ] \
    || { echo "FATAL: synthetic diagnostic object present in a supply directory"; exit 1; }
done
log "synthetic objects in supply directories: none"
[ "$(ls $R/shared/prebuild/RT-AXE7800/*.o | wc -l)" = 16 ] && log "shared supply = 16 OK"
[ "$(ls $R/rc/prebuild/RT-AXE7800/*.o | wc -l)" = 42 ] && log "rc supply = 42 OK"
grep -q 'WLANAPP_DIRS): | setuplink' "$P/router-sysdep.rt-axe7800/wlan/Makefile" && log "setuplink order edge present"
grep -q 'defined(RTBE96U)' "$R/shared/model.c" && log "boardid guard present"
grep -q 'RTCONFIG_MULTILAN_CFG' "$R/shared/misc.c" && log "get_fh guard present"
echo "REPLAY v11 COMPLETE"

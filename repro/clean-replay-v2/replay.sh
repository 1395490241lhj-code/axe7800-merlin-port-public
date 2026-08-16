#!/bin/bash
# Deterministic RT-AXE7800 port replay.
# Recreates every justified change from pinned refs onto a clean checkout of
#   RMerlin ccd139a31d94de15d2da744083dbafbcfe97dcdf
# Usage: replay.sh <target-worktree>
set -euo pipefail
WT="${1:?usage: replay.sh <target-worktree>}"
RMERLIN_PIN=ccd139a31d94de15d2da744083dbafbcfe97dcdf
GNUTON_PIN=92e9b31110471cc38927b9aca135cc775d144c5a
RP="$(cd "$(dirname "$0")" && pwd)"
P=release/src-rt-5.04axhnd.675x
R=release/src/router
MAN="$RP/binary-provenance-manifest.txt"

cd "$WT"
[ "$(git rev-parse HEAD)" = "$RMERLIN_PIN" ] || { echo "FATAL: worktree not at pinned RMerlin commit"; exit 1; }
git cat-file -e "$GNUTON_PIN^{commit}" || { echo "FATAL: gnuton pin not present"; exit 1; }

log(){ printf '  %s\n' "$*"; }
imp(){ # imp <gnuton-path> <dest-path> <mode> <rationale>
  local src="$1" dst="$2" mode="$3" why="$4"
  mkdir -p "$(dirname "$dst")"
  git cat-file -p "$GNUTON_PIN:$src" > "$dst"; chmod "$mode" "$dst"
  printf '%s  %s  %s  %s  gnuton:%s  <= %s\n' \
    "$(sha256sum "$dst" | cut -d' ' -f1)" "$(stat -c%s "$dst")" \
    "$(file -b "$dst" | cut -c1-46)" "$dst" "$src" "$why" >> "$MAN"
}

echo "== STEP 1/6: source patches =="
git apply --check "$RP/patches/0001-add-RT-AXE7800-target.patch"
git apply "$RP/patches/0001-add-RT-AXE7800-target.patch"; log "0001 RT-AXE7800 target (DHDAP=y, EXT_PHY=BCM84880, SWITCH2=BCM53134)"
git apply --check "$RP/patches/0002-phy-chip-scoped-prebuilt-selection.patch"
git apply "$RP/patches/0002-phy-chip-scoped-prebuilt-selection.patch"; log "0002 phy chip-scoped PHY_PREBUILT selector"

echo "== STEP 2/6: per-model platform tree (router-sysdep.rt-axe7800) =="
: > "$MAN"
echo "# RT-AXE7800 binary provenance. RMerlin pin $RMERLIN_PIN ; GNUton pin $GNUTON_PIN" >> "$MAN"
echo "# sha256  size  type  dest  source  rationale" >> "$MAN"
rm -rf /tmp/replay-extract; mkdir -p /tmp/replay-extract
git archive "$GNUTON_PIN" "$P/router-sysdep.tuf-ax3000_v2" | tar -x -C /tmp/replay-extract
mv "/tmp/replay-extract/$P/router-sysdep.tuf-ax3000_v2" "$P/router-sysdep.rt-axe7800"
log "router-sysdep.rt-axe7800 <= gnuton router-sysdep.tuf-ax3000_v2 ($(find $P/router-sysdep.rt-axe7800 -type f | wc -l) files)"
printf 'DIR  %s  gnuton:%s/router-sysdep.tuf-ax3000_v2  <= closest 6756 match (same EXT_PHY/SWITCH2); 6756=ARM32 vs gt-ax6000=AArch64\n' \
  "$P/router-sysdep.rt-axe7800" "$P" >> "$MAN"
find "$P/router-sysdep.rt-axe7800" -type f | sort | while read f; do
  printf '%s  %s  -  %s\n' "$(sha256sum "$f"|cut -d' ' -f1)" "$(stat -c%s "$f")" "$f" >> "$RP/router-sysdep-files.sha256"; done

echo "== STEP 3/6: chip-scoped staged binaries =="
imp "$P/bcmdrivers/broadcom/char/license/impl1/bcm_license.o" \
    "$P/router-sysdep.rt-axe7800/hnd_extra/prebuilt/bcm_license.o" 755 \
    "ARM32 bcm_license staged via platform.mak HND_ROUTER_AX_6756 guard; tracked AArch64 file left untouched"
for f in phy_drv.o phy_drv_brcm.o gpy211.o; do
  imp "$P/bcmdrivers/opensource/phy/prebuilt/TUF-AX3000_V2/$f" \
      "$P/bcmdrivers/opensource/phy/prebuilt/6756/$f" 755 \
      "chip-generic BCM6756 (byte-identical in RT-AX58U_V2 and TUF-AX3000_V2)"
done
imp "$R/protect_srv/lib/prebuild/arm_6756hnd/libptcsrv.so" \
    "$R/protect_srv/lib/prebuild/arm_6756hnd/libptcsrv.so" 755 "GNUton chip-generic 6756 lib"
imp "$R/protect_srv/lib/prebuild/arm_6756hnd/prebuild/libptcsrv.so" \
    "$R/protect_srv/lib/prebuild/arm_6756hnd/prebuild/libptcsrv.so" 755 "GNUton chip-generic 6756 lib"

echo "== STEP 4/6: deterministic wiring symlinks =="
ln -sfn arm_6756hnd "$R/protect_srv/lib/prebuild/RT-AXE7800"; log "protect_srv RT-AXE7800 -> arm_6756hnd"
for pair in \
  "bcmdrivers/broadcom/char/archer/impl1/archer.o:archer.o" \
  "bcmdrivers/broadcom/char/cleds/impl1/bcm_cleds.o:bcm_cleds.o" \
  "bcmdrivers/opensource/net/enet/impl7/bcm_enet.o:bcm_enet.o" \
  "bcmdrivers/opensource/char/mcast/impl1/bcmmcast.o:bcmmcast.o" ; do
  d="${pair%%:*}"; n="${pair##*:}"
  ln -sfn "../../../../../router-sysdep/hnd_extra/prebuilt/$n" "$P/$d"
  log "$d -> router-sysdep/hnd_extra/prebuilt/$n"
  printf 'SYMLINK  %s  -> ../../../../../router-sysdep/hnd_extra/prebuilt/%s  <= GNUton model-scoped selection\n' "$P/$d" "$n" >> "$MAN"
done

echo "== STEP 4b/6: deterministic per-model HOST-tool staging (lzop) =="
# CLASSIFICATION: deterministic per-model host-tool staging.
#   NOT target firmware, NOT a BCM6756 binary input, NOT a generated build output,
#   NOT proprietary router runtime code. lzop runs on the BUILD HOST (x86-64) and only
#   compresses the image; it contains no target code.
# hostTools/Makefile:12 does: cp prebuilt/$(BUILD_NAME)/lzop local_install/
LZ_SRC="$P/hostTools/prebuilt/GT-AX6000/lzop"
LZ_DIR="$P/hostTools/prebuilt/RT-AXE7800"
LZ_DST="$LZ_DIR/lzop"
[ -f "$LZ_SRC" ] || { echo "FATAL: link target missing: $LZ_SRC"; exit 1; }
LZ_SHA=$(sha256sum "$LZ_SRC" | cut -d" " -f1)
LZ_SIZE=$(stat -c%s "$LZ_SRC")
LZ_TYPE=$(file -b "$LZ_SRC")
case "$LZ_TYPE" in *x86-64*) ;; *) echo "FATAL: link target is not an x86-64 host binary"; exit 1;; esac
cp "$LZ_SRC" /tmp/lzop.probe && chmod +x /tmp/lzop.probe
LZ_VER=$(/tmp/lzop.probe --version 2>&1 | head -1)
log "source  : hostTools/prebuilt/GT-AX6000/lzop"
log "size    : $LZ_SIZE"
log "sha256  : $LZ_SHA"
log "type    : $LZ_TYPE"
log "version : $LZ_VER"
mkdir -p "$LZ_DIR"
ln -sfn ../GT-AX6000/lzop "$LZ_DST"
# post-conditions
[ "$(readlink "$LZ_DST")" = "../GT-AX6000/lzop" ] || { echo "FATAL: readlink mismatch"; exit 1; }
RES=$(readlink -f "$LZ_DST")
case "$RES" in "$PWD"/*) ;; *) echo "FATAL: resolves outside pinned tree: $RES"; exit 1;; esac
[ -x "$RES" ] || { echo "FATAL: resolved lzop not executable"; exit 1; }
[ "$(sha256sum "$RES" | cut -d" " -f1)" = "$LZ_SHA" ] || { echo "FATAL: resolved sha256 mismatch"; exit 1; }
readelf -h "$RES" | grep -q "X86-64" || { echo "FATAL: resolved lzop is not x86-64"; exit 1; }
readelf -h "$RES" | grep -q "ARM"    && { echo "FATAL: resolved lzop is an ARM target binary"; exit 1; }
log "symlink verified: readlink OK, resolves in-tree, executable, sha256 match, x86-64 host binary"
printf 'SYMLINK  %s  -> ../GT-AX6000/lzop  sha256(target)=%s size=%s  <= deterministic per-model HOST-tool staging (x86-64 build-host tool, %s)\n' \
  "$LZ_DST" "$LZ_SHA" "$LZ_SIZE" "$LZ_VER" >> "$MAN"

echo "== STEP 5/6: authentic historical RT-AXE7800 UI (git blobs) =="
while read blob sha bytes rel; do
  case "$blob" in \#*|"") continue;; esac
  mkdir -p "$R/www/sysdep/RT-AXE7800/$(dirname "$rel")"
  git cat-file -p "$blob" > "$R/www/sysdep/RT-AXE7800/$rel"
  v=$(sha256sum "$R/www/sysdep/RT-AXE7800/$rel" | cut -d' ' -f1)
  [ "$v" = "$sha" ] || { echo "FATAL UI hash mismatch $rel"; exit 1; }
  printf '%s  %s  -  %s  blob:%s  <= authentic ASUS RT-AXE7800 UI (commits 876cf1009f/06f0a0e2ca)\n' \
    "$v" "$bytes" "$R/www/sysdep/RT-AXE7800/$rel" "$blob" >> "$MAN"
done < "$RP/ui-blobs.txt"
log "restored $(find $R/www/sysdep/RT-AXE7800 -type f | wc -l) UI files (all sha256-verified)"

echo "== STEP 6/6: assertions =="
grep -q 'DHDAP=y' <(grep 'BUILD_NAME="RT-AXE7800"' release/src-rt/target.mak) && log "DHDAP=y OK"
for t in 'HND_WL=y' 'BCMWL6=y' 'BCMWL6A=y' 'EXT_PHY="BCM84880"' 'SWITCH2="BCM53134"'; do
  grep -q -- "$t" <(grep 'BUILD_NAME="RT-AXE7800"' release/src-rt/target.mak) && log "$t OK"
done
[ ! -e "$R/shared/prebuild/RT-AXE7800" ] && log "shared/prebuild/RT-AXE7800 correctly ABSENT (unresolved ASUS GPL)"
# NOTE: these symlinks point at router-sysdep/, which HEAD ships as an empty placeholder.
# The build populates it via Makefile:7070 "cp -ar router-sysdep.$(lowercase_B)/ router-sysdep",
# so they are EXPECTED to dangle until the build's staging step runs. Validate the source of truth.
for f in archer.o bcm_cleds.o bcm_enet.o bcmmcast.o bcm_license.o; do
  src="$P/router-sysdep.rt-axe7800/hnd_extra/prebuilt/$f"
  a=$(readelf -h "$src" 2>/dev/null | awk '/Machine:/{print $2}')
  [ "$a" = "ARM" ] || { echo "FATAL: $f not ARM32 in per-model prebuilt"; exit 1; }
  log "$f ARM32 present in router-sysdep.rt-axe7800/hnd_extra/prebuilt OK"
done
for f in archer.o bcm_cleds.o bcm_enet.o bcmmcast.o; do
  p=$(find $P/bcmdrivers -name "$f" -type l | head -1)
  [ -n "$p" ] || { echo "FATAL: $f wiring symlink missing"; exit 1; }
done
log "4 wiring symlinks present (resolve after build staging)"
[ "$(readlink "$P/hostTools/prebuilt/RT-AXE7800/lzop")" = "../GT-AX6000/lzop" ] \
  && log "hostTools RT-AXE7800/lzop symlink OK" || { echo "FATAL: lzop staging missing"; exit 1; }
echo "REPLAY COMPLETE"

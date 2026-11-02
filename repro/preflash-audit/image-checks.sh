#!/bin/bash
# Compiled-image checks for the RT-AXE7800 build. Read-only. Every command is printed before its output,
# so the evidence file this writes records its own method.
#
#   usage: image-checks.sh <platform-dir> <cross-objdump>
#     <platform-dir>   built tree's release/src-rt-5.04axhnd.675x
#     <cross-objdump>  the ARM objdump of the build toolchain (a host objdump cannot read ARM)
set -euo pipefail
P="$(cd "${1:?platform-dir}" && pwd)"; OD="${2:?cross-objdump}"
cd "$P"
FS=targets/96756GW/fs
run(){ printf '$ %s\n' "$1"; bash -o pipefail -c "$1" || true; echo; }

echo "== MXIC NAND fixes (patches 0007/0008): unique strings and code they add"
for f in kernel/linux-4.19/vmlinux bcmdrivers/opensource/char/board/bcm963xx/impl1/bcm63xx_flash.o kernel/linux-4.19/drivers/mtd/ubi/wl.o; do
  run "strings -a $f | grep -c 'Error writing page. retry count'"
  run "strings -a $f | grep -c 'WAR: failed to erase PEB'"
done
for f in bootloaders/obj/uboot/lib/hashtable.o bootloaders/obj/nand_spl/lib/hashtable.o bootloaders/obj/emmc_spl/lib/hashtable.o; do
  run "'$OD' -d --disassemble=hexport_r $f | grep -c 'mov[[:space:]]*r1, #255'"
done

echo "== kernel modules"
run "find $FS -name '*.ko' | wc -l"
run "find $FS/lib/modules -name '*.ko' | wc -l"

echo "== radio firmware (DNGL: GPL 25206 copy expected, d5b3b559...)"
run "sha256sum $FS/rom/etc/wlan/dhd/6715b0/rtecdc.bin | cut -d' ' -f1"

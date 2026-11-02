#!/bin/bash
# router-ro.sh '<read-only command>' — run one READ-ONLY command on the owner's router and log it.
set -o pipefail
[ -n "${1:-}" ] || { echo "usage: $0 '<read-only command>'" >&2; exit 2; }
LOG="$(cd "$(dirname "$0")/.." && pwd)/repro/preflash-audit/evidence/router-commands.txt"
# ponytail: a denylist is best-effort, not a sandbox. It stops obvious writes (NVRAM, flash, UBI,
# file deletion/redirection, reboot), not a determined one. Harmless redirects are stripped first.
c=$(printf '%s' "$1" | sed -E 's#[0-9]*>[[:space:]]*/dev/null##g; s#[0-9]*>&[0-9]##g')
if printf '%s' "$c" | grep -qE 'nvram[[:space:]]+(set|unset|commit|restore|erase|loadfile)|mtd[-_](write|erase)|flash_erase|flashcp|nandwrite|ubi(updatevol|mkvol|rmvol|format)|(^|[^a-z_])(dd|rm|reboot|halt|poweroff)([[:space:]]|$)|>[[:space:]]*[^[:space:]"0-9]'; then
  echo "REFUSED: not a read-only command: $1" >&2; exit 2
fi
printf '%s\t%s\n' "$(date -u +%FT%TZ)" "$1" >> "$LOG" || { echo "FATAL: cannot write $LOG" >&2; exit 2; }
ssh -o BatchMode=yes -o IdentitiesOnly=yes -i ~/.ssh/axe7800_readonly -p 4324 admin@192.168.8.1 "$1" 2>&1 \
  | { grep -v 'openssh.com/pq\|post-quantum\|store now, decrypt\|server may need' || true; }

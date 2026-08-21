# RT-AXE7800 source-package intake: authenticity / provenance checklist

**Complete this before running any acceptance check.** A package that fails provenance is not
evidence, however promising its contents look.

Automated identity tiering already exists in `tools/verify-asus-gpl-drop.sh`
(KNOWN-ARCHIVE-EXACT → KNOWN-P0-SET-EXACT → PROVENANCE-DECLARED → MERLIN-PATH-SCOPED →
UNVERIFIED, fail-safe). This checklist is the human record that accompanies it.

## Why this exists

The 388.34458 investigation produced two concrete traps, both worth re-reading before
accepting anything:

1. **Filename and version numbers mislead.** `GPL_RT-AXE7800_3.0.0.4.388.34458` is published
   *for* RT-AXE7800, yet its `target.mak` carries ~177 model stanzas and TUF-AX3000_V2 has
   more index entries (126) than RT-AXE7800 (36). Path markers never prove identity.
   Separately, its build number (34458) is *higher* than the shipping firmware's (25206)
   while being three years older and a different S46 generation.
2. **Local directories named after a version can be fixtures.** Two 160 KB directories named
   `GPL_RT-AXE7800_388_25206` existed on the build host and were synthetic verifier test
   fixtures, not packages. Never accept a directory as a package on its name.

## Record for every candidate package

| # | field | notes |
|---|---|---|
| 1 | original filename | verbatim, including any `?model=` query string |
| 2 | download / source URL | full URL; if received by mail or ticket attachment, say so explicitly |
| 3 | acquisition channel & date | ASUS CDN, support ticket, or other; UTC timestamp |
| 4 | HTTP headers | `Last-Modified`, `Content-Length`, `ETag` where the transport provides them |
| 5 | package size | exact bytes |
| 6 | **sha256** | of the archive as received, before any extraction |
| 7 | archive root & layout | root dir name; raw-ASUS flat vs Merlin per-model layout |
| 8 | model identity | which tier of `verify-asus-gpl-drop.sh` established it, not a path guess |
| 9 | firmware / source version identifiers | from `version.conf` (`SERIALNO`, `RCNO`), not the filename |
| 10 | internal build markers | any `image_version` / `extendno`; note explicitly if none matches the retail build |
| 11 | generation vs stock 388_25206 | S46 discriminators from acceptance matrix §3 |
| 12 | internal self-consistency | does its `rc/Makefile` demand objects its own supply provides? |

## Explicit rules

- **Never declare a package "matching" from its filename.** Identity comes from the verifier's
  tier plus content discriminators.
- **No publisher checksum exists.** ASUS publishes no hash or signature for GPL packages, so a
  recorded sha256 is a first-acquisition fingerprint, not vendor authentication. Say so
  whenever quoting it.
- **Record what the tree says about itself**, in its own words. For 388.34458 the honest
  finding was: confirms series `388` via `SERIALNO=388`, contains no field reading "34458",
  and matches no retail `extendno` — therefore "the 388-series GPL drop labelled 34458", not
  "the source of firmware X".
- **Self-consistency is a real signal.** 388.34458 was internally *consistent*: its `rc`
  wanted `s46map_rptd.o` and it shipped `s46map_rptd.o`. That is what proved the gap was a
  generation mismatch rather than an omission.
- **Never extract embedded credentials.** `OCN_API_KEY`, `JPIX_MF_CODE`, `JPNE_MF_CODE` and
  the like are recorded by **existence and size only**. Their values are never read, quoted,
  or committed.
- **Read-only.** Never extract into, modify, or stage from the supplied package. Inspect a
  temporary copy and delete it.

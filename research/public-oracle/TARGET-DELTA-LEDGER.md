# Future target-flag ledger (nothing enabled now)

The frozen clean-replay-v2 target is unchanged. This records what a later, fuller target would
need and how well each flag is evidenced.

## VALIDATED-MUST-ADD-LATER
| flag | evidence |
|---|---|
| `DHD_6715B0=y` | **two independent sources**: public SWRT RT-AXE7800 stanza sets it, and stock 388_25206 ships `rom/etc/wlan/dhd/6715b0/rtecdc.bin`. buildFS behaviour fully traced. Blocked in practice by the missing per-model firmware (P0R) — enabling it today would install the non-matching `default` firmware. |

## STRONG-EVIDENCE (in the public SWRT RT-AXE7800 stanza; hardware/wireless topology)
| flag | class | note |
|---|---|---|
| `HAS_5G_2=y` | WIRELESS-TOPOLOGY | consistent with wl2 third radio |
| `WIFI6E=y` | WIRELESS-TOPOLOGY | consistent with the 6 GHz radio and the authentic UI |
| `LACP=y` | HARDWARE-TOPOLOGY | stock `libshared.so` has a real 124 B `get_bonding_port_status` (TUF's is an 8 B stub built `LACP=n`) |
| `BONDING=y` | HARDWARE-TOPOLOGY | same bonding evidence |
| `BONDING_WAN=y` | HARDWARE-TOPOLOGY | same |

## OPTIONAL-NOT-YET-ENABLED (feature scope; each pulls in more per-model prebuilt dirs)
| flag | components it activates |
|---|---|
| `AMAS=y` | `amas-utils/prebuild/RT-AXE7800` + AMAS paths in rc/shared |
| `DWB=y` | AMAS DWB paths |
| `BWDPI=y` | `bwdpi_source/{,asus,asus_sql}/prebuild/RT-AXE7800` |
| `NOTIFICATION_CENTER=y` | `nt_center`, `wlc_nt/prebuild/RT-AXE7800` |
| `ASD=y` | `asd/prebuild/RT-AXE7800` |
| `AHS=y` | `ahs/prebuild/RT-AXE7800` |

Enabling any of these **increases** the number of missing model-specific inputs; none should be
enabled before the P0 set is resolved.

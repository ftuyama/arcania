# Vertical Slice Playtest Protocol

> **Backlog:** P0-05 — time the Threshold → Root Warden critical path (target **45–90 min** first run).  
> **Instrumentation:** `PlaytestTracker` autoload + F3 debug overlay + F4 manual report export.

---

## How to Run

1. Launch the game and choose **New Game** (tracking only runs on fresh sessions; Continue/Load disables it).
2. Press **F3** to show the debug overlay — elapsed time and checkpoint progress appear on the HUD.
3. Play through the critical path below without cheats or dev teleports.
4. On **Root Warden** defeat, a toast reports whether slice time is inside the 45–90 min window.
5. Press **F4** anytime to dump `user://playtest_slice_report.json` and print a summary to the Godot console.

Report path on disk (macOS editor):

`~/Library/Application Support/Godot/app_userdata/Arcania/playtest_slice_report.json`

---

## Critical Path (in order)

| # | Checkpoint | Room / beat | Budget (cumulative) |
|---|------------|-------------|---------------------|
| 1 | Session start | New Game → `at_01_threshold_hub` | 0:00 |
| 2 | Threshold hub | Talk to Magister Corin; learn Ember Sigil | ≤ 8 min |
| 3 | Whisperwood entered | `at_03_east_road` → `ww_01_forest_gate` | ≤ 15 min |
| 4 | Veil Step acquired | `at_03_east_road` shrine (phase barrier shortcut) | ≤ 22 min |
| 5 | Rootbind acquired | `ww_07_heartwood_chamber` pickup | ≤ 35 min |
| 6 | Matron defeated | `ww_11_heartwood_grove` — MB-01 | ≤ 50 min |
| 7 | Arc Step acquired | Post-Matron reward | ≤ 55 min |
| 8 | Focus Crucible save | Rest at any Crucible anchor | ≤ 65 min |
| 9 | Warden defeated | `ww_15_ironroot_depths` — BOSS-01 (**slice end**) | ≤ 90 min |

**Room sequence reference:** `at_01` → `at_03` → `ww_01`–`ww_16` critical path per [11-scoped-release.md](11-scoped-release.md).

---

## Sign-Off

| Field | Value |
|-------|-------|
| Tester | |
| Date | |
| Build / commit | |
| Slice time (Warden defeat) | |
| Within 45–90 min? | ⬜ Yes · ⬜ No |
| Softlocks / blockers | |
| Pacing notes (too fast / slow segments) | |
| Death count | |

Paste the `playtest_slice_report.json` checkpoint table into the sprint log when filing follow-up backlog items.

---

## First-Run Results

| Run | Date | Slice time | Pass? | Notes |
|-----|------|------------|-------|-------|
| — | — | — | — | Pending first dev playtest session |

---

## Cross-References

- [10-development-roadmap.md](10-development-roadmap.md) — Phase 3 acceptance: slice playtime
- [08-technical-architecture.md §19](08-technical-architecture.md) — Manual QA checklist
- [12-improvements-backlog.md](12-improvements-backlog.md) — P0-06 FPS profiling (next)

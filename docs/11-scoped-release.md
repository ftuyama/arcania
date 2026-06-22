# 11 — Scoped Release Plan

> Intentional scope cut derived from the [Comprehensive Project Review](10-development-roadmap.md) (June 2026). This document locks what **Arcania 1.0** ships versus stretch goals.

---

## 1.0 Scope (Ship Target)

| Category | Full GDD | Scoped 1.0 |
|----------|----------|------------|
| **Regions** | 12 | **6** — Ashen Threshold, Whisperwood, Sunken Catacombs, Archive of Echoes, Bleakfen Marsh, Lumineth Caverns |
| **Spells** | 14 | **10** — through Storm Lash on critical path; Unravel + World Thread deferred |
| **Relics** | 24 | **12** — Tier I–II only; Tier III legendary deferred |
| **Endings** | 3 | **2** — Mend / Unravel; third ending post-1.0 |
| **Whisperwood rooms** | 42 | **19** — 16 critical path + 3 secrets (`ww_s01`–`ww_s03`); filler `ww_17`–`ww_37` removed from registry |
| **Dev rooms** | — | **Removed** from `room_loader.gd` player registry |

---

## Deferred to Post-1.0

- Regions 7–12 (Obsidian Atelier through Somnium)
- Spells: Temporal Echo, Shadow Blink (if cut), Unravel, World Thread
- 12 relics (Tier III + cut Tier II)
- Third ending branch
- Fast travel full network (Sigil Recall MVP only in scoped 1.0)
- NG+, co-op, automated aim assist

---

## Content Quality Rules

1. **No greybox room sprawl** — generator output is blockout only; rooms enter registry after gameplay pass.
2. **Dual-purpose magic** — every shipped spell must have verified combat + exploration hooks in code.
3. **One polished hour** before scaling — Threshold tutorial → Whisperwood → Matron → Warden must feel complete.
4. **Honest roadmap** — acceptance criteria checked only after QA pass ([08-technical-architecture.md §19](08-technical-architecture.md)).

---

## Registry Notes

- Filler Whisperwood rooms (`ww_17`–`ww_37`) remain on disk for future sprints but are **not** in `RoomLoader.ROOM_SCENES`.
- Dev rooms (`combat_test_arena`, `test_room_*`) remain in `scenes/rooms/dev/` for manual QA; not boot-accessible.

---

## Cross-References

- [01-gdd.md](01-gdd.md) — full design lock
- [10-development-roadmap.md](10-development-roadmap.md) — phased build plan
- [08-technical-architecture.md](08-technical-architecture.md) — implementation blueprint
- [12-improvements-backlog.md](12-improvements-backlog.md) — prioritized improvement backlog

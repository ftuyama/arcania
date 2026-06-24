# 12 — Improvements Backlog

> Prioritized improvement backlog derived from the **June 2026 Comprehensive Project Review**. Use this document to pick sprint work; scope boundaries live in [11-scoped-release.md](11-scoped-release.md).

**Last updated:** June 24, 2026
**Cadence assumption:** ~15 hrs/week solo dev
**Status legend:** ✅ Done · 🔄 In progress · ⬜ Backlog · 🚫 Deferred (post-1.0)
**Effort legend:** XS · S · M · L · XL · XXL (T-shirt sizes; relative scope only)

| Size | Scope |
|------|-------|
| **XS** | Tiny — wiring fix, doc tweak, single hook |
| **S** | Small — one UI slice, short playtest, localized behavior |
| **M** | Medium — one system or content pass |
| **L** | Large — multi-room content, inventory tab, audio pass |
| **XL** | Extra large — spell, region blockout, narrative arc |
| **XXL** | Epic — full tileset/art pass, major vertical slice |

---

## How to Use

1. **Pick from P0 first** — these unblock the "one polished hour" vertical slice ([§ Strategic North Star](#strategic-north-star)).
2. **Check ✅ Done** before re-implementing — several review items landed in the June 2026 pass.
3. **Respect [11-scoped-release.md](11-scoped-release.md)** — do not expand room count or spell count beyond scoped 1.0 without updating that doc.
4. **Mark items done** in this file when merged; link to PR/commit in the Notes column if helpful.

---

## Strategic North Star

Prove the fantasy in **one polished hour** before scaling content:

> Threshold story hook → ember gate → Whisperwood → Rootbind geography change → Matron fight with readable spectacle → Arc Step opens unreachable path → Crucible save with emotional beat.

If this hour is not compelling, more greybox rooms will not save the project.

---

## Summary by Priority

| Priority | Open Items | Effort range |
|----------|------------|--------------|
| **P0 — Critical** | 7 | S–XXL |
| **P1 — High** | 16 | XS–XL |
| **P2 — Medium** | 14 | XS–XL |
| **P3 — Low / Polish** | 9 | XS–M |
| **✅ Done (review pass)** | 23 | — |

---

## ✅ Completed (June 2026 Review Pass)

| ID | Item | Area |
|----|------|------|
| REV-01 | Matron Phase II arena shrink | Boss |
| REV-02 | Root Warden mass-pull counter window | Boss |
| REV-03 | Thornweft Larva knockback bug fix | Combat |
| REV-04 | Veil Step / Arc Step phase barrier pass-through | Exploration / USP |
| REV-05 | Ember Bolt ignites ember-receptor gates | USP |
| REV-06 | Combat juice autoload (hit-stop, screen shake, telegraph SFX) | Combat |
| REV-07 | Poise → stagger wiring on enemies | Combat |
| REV-08 | Gamepad bindings via `InputSetup` autoload | Platform |
| REV-09 | Settings panel (volume + damage numbers toggle) | UI/UX |
| REV-10 | `I` key inventory / aim-up conflict fix | UI/UX |
| REV-11 | Boss phase audio pitch crossfade stub | Audio |
| REV-12 | Boss visual accent layers (placeholder upgrade) | Art |
| REV-13 | Dialogue box + Magister Corin NPC (Threshold hub) | Narrative |
| REV-14 | Focus Shard mana segments + 3 world pickups | Progression |
| REV-15 | HUD shard pips + region name toast | UI/UX |
| REV-16 | Scoped 1.0 doc ([11-scoped-release.md](11-scoped-release.md)) | Process |
| REV-17 | Room registry trim (dev + filler `ww_17`–`ww_37` removed) | Level design |
| REV-18 | QA checklist updated in [08-technical-architecture.md §19](08-technical-architecture.md) | Process |
| REV-19 | Unit test runner (`ModifierStack`, `ManaComponent`) | Tech |
| REV-20 | Broken `amb_01_threshold.ogg` restored | Audio |
| REV-21 | Roadmap false-positive notes corrected | Process |
| REV-22 | README + build status sync | Process |
| P0-05 | Playtest + time vertical slice | Process / QA |
| P0-06 | 60 FPS profiling in ww_07 + 4 enemies | Tech / Performance |
| P0-09 | Expand automated tests (SaveManager, SpellManager, gate save/load) | Tech / QA |

---

## P0 — Critical (Do Before Content Scale)

| ID | Item | Why | Effort | Impact | Status |
|----|------|-----|--------|--------|--------|
| P0-03 | **Whisperwood + Threshold tileset art pass** | Region identity; competes with HK/Nine Sols screenshots | XXL | Critical | ⬜ |
| P0-04 | **Boss + region audio** — unique tracks, combat stems | Silent or generic audio kills dark-fantasy tone | L | High | ⬜ |
| P0-07 | **Crystal Bridge spell** (next critical-path unlock) | Gates Sunken Catacombs per [11-scoped-release.md](11-scoped-release.md) | XL | Critical | ⬜ |
| P0-08 | **Sunken Catacombs region blockout** (critical path only) | First region beyond Whisperwood; proves content pipeline | XL | Critical | ⬜ |
| P0-10 | **Handcraft 3 Whisperwood landmark rooms** | Generator greybox lacks "wow" moments | L | High | ⬜ |
| P0-11 | **Complete Ashen Threshold** (5 rooms per world design) | Hub feels empty; weak first 10 minutes | L | High | ⬜ |
| P0-12 | **External playtest** (5 testers, NPS survey) | No outside validation of fun | M | High | ⬜ |

---

## P1 — High (Next Sprint Queue)

### Core Game Loop & Retention

| ID | Item | Why | Effort | Status |
|----|------|-----|--------|--------|
| P1-01 | Narrative beat every ~30 min of critical path | Loop is still explore → fight → gate without emotional payoff | XL | ⬜ |
| P1-02 | Reward cadence — relic/secret every 8–10 min in Whisperwood | Long gaps between bosses cause boredom | L | ⬜ |
| P1-03 | Boss intro text / VO stub before Matron and Warden | Fights lack narrative setup | S | ⬜ |
| P1-04 | Gate failure feedback (try wrong spell → UI hint) | Teaches dual-purpose magic without tooltip walls | S | ✅ |
| P1-05 | Quest signposting after `ww_08` (objective + environmental cues) | Players get lost on critical path | S | ⬜ |

### Progression & Systems

| ID | Item | Why | Effort | Status |
|----|------|-----|--------|--------|
| P1-06 | **Robes + Focus equipment** tabs in inventory (2 starter items each) | Build diversity; GDD §6 unimplemented | L | ⬜ |
| P1-07 | **Fast travel MVP** — Waystone activation + Sigil Recall spell stub | Backtracking friction kills mid-game | L | ⬜ |
| P1-08 | **Kindling Ward + Gleamflare** spells (Catacombs unlocks) | Required for region 3 progression | XL | ⬜ |
| P1-09 | Remaining **6 scoped relics** placed in-world (12 total per scope doc) | Collectible loop underfed | M | ⬜ |
| P1-10 | Focus Crucible **upgrade menu** or merchant sink for essence/currency | Rewards currently have no spend path | M | ⬜ |
| P1-11 | **Autosave slot** (doc §10: 3 manual + 1 autosave) | Player friction at Crucibles-only save | S | ⬜ |

### Combat & Feel

| ID | Item | Why | Effort | Status |
|----|------|-----|--------|--------|
| P1-12 | **Overcast vulnerability window** (0.3s) + thread-fray VFX/SFX | GDD §5.4 risk/reward undertuned | S | ⬜ |
| P1-13 | **Rootbind enemy root/trap** (data promises combat use) | Dual-purpose spell incomplete | S | ⬜ |
| P1-14 | **Status effects** — burn DoT, root, freeze stubs | Relic modifiers (burn mult) partially wired | M | ⬜ |
| P1-15 | **Air melee / down-air** attack state | GDD §5.1 platforming combat depth | S | ⬜ |
| P1-16 | Enemy resistances force spell loadout decisions | Ember Bolt + Stalker loop dominates | M | ⬜ |
| P1-17 | Deploy custom enemies widely (Mothling, Bark Wraith, Larva, Hunter) | Scripts exist; slice still Stalker-heavy | M | ⬜ |

### UI/UX & Platform

| ID | Item | Why | Effort | Status |
|----|------|-----|--------|--------|
| P1-18 | **Quick spell slot HUD** (on-screen 1–4 icons + cooldown radial) | GDD §9.1; keyboard-only discoverability | S | ⬜ |
| P1-19 | **Damage numbers** render path (toggle exists in settings) | Setting without feature confuses players | S | ⬜ |
| P1-20 | **Map connection lines** between visited rooms | Fog grid alone hurts navigation literacy | S | ⬜ |
| P1-21 | **Input remapping UI** | Gamepad added; no rebind screen for Steam | M | ⬜ |

---

## P2 — Medium (Quality & Scale)

### Exploration & Metroidvania

| ID | Item | Effort | Status |
|----|------|--------|--------|
| P2-01 | Ley Sight secrets (or interactable hint stubs until spell ships) | L | ⬜ |
| P2-02 | 1–2 intentional sequence breaks / skips per region | — | 🚫 |
| P2-03 | Re-author filler Whisperwood rooms (`ww_17`–`ww_37`) before re-registering | L | ⬜ |
| P2-04 | Hazard telegraphs (thorn DoT, falling branches) — ATS T5 | M | ⬜ |
| P2-05 | Environmental storytelling pass (lore tablets, effigies) in Threshold + Whisperwood | L | ⬜ |

### Technical Architecture

| ID | Item | Effort | Status |
|----|------|--------|--------|
| P2-06 | **Data-driven room registry** from `RegionData` resources | M | ⬜ |
| P2-07 | CI smoke test (headless boot + unit tests on push) | S | ⬜ |
| P2-08 | Clean up `SpellCaster` dead branches for veil/arc | XS | ⬜ |
| P2-09 | Spell tiers (Attuned / Resonant) + save schema | L | ⬜ |
| P2-10 | Object pools per [08 §20](08-technical-architecture.md) (damage numbers, particles) | M | ⬜ |
| P2-11 | Document custom-enemy vs StateMachine pattern in [08](08-technical-architecture.md) | XS | ⬜ |

### Audio & Art Polish

| ID | Item | Effort | Status |
|----|------|--------|--------|
| P2-12 | Combat music layer stems (explore → combat crossfade) | M | ⬜ |
| P2-13 | ATS telegraph color standardization in shaders/VFX | S | ⬜ |
| P2-14 | Footstep surface variety (stone, crystal, organ wood) | S | ⬜ |
| P2-15 | Global UI theme (replace per-screen StyleBoxFlat) | M | ⬜ |

### Content (Scoped 1.0 Regions 3–6)

| ID | Item | Effort | Status |
|----|------|--------|--------|
| P2-16 | Archive of Echoes blockout + Ley Sight unlock | XL | ⬜ |
| P2-17 | Bleakfen Marsh blockout + Mistveil / Tidecaller | XL | ⬜ |
| P2-18 | Lumineth Caverns blockout + Frost Bind | XL | ⬜ |
| P2-19 | MB-02 Reliquary Sentinel + region mini-boss pipeline | L | ⬜ |

---

## P3 — Low / Polish / Defer-Friendly

| ID | Item | Effort | Status |
|----|------|--------|--------|
| P3-01 | Spell wheel hold-to-open + optional slow-mo (GDD §9.3) | S | 🚫 |
| P3-02 | Spell wheel slow-mo cut from scope | — | 🚫 per [11](11-scoped-release.md) |
| P3-03 | Essence HUD removal until shop exists | XS | ⬜ |
| P3-04 | Accessibility presets (assist options per GDD §11) | M | ⬜ |
| P3-05 | `cheat_panel.tscn` for debug builds | S | ⬜ |
| P3-06 | Title screen + ending slideshow cinematics | M | ⬜ |
| P3-07 | NG+ mode | — | 🚫 |
| P3-08 | Steam Input formal API layer (beyond runtime joypad map) | S | ⬜ |
| P3-09 | Pixel-perfect screenshot / trailer capture checklist | S | ⬜ |

---

## 🚫 Deferred (Post-1.0)

Per [11-scoped-release.md](11-scoped-release.md) — do not pull into current sprint without explicit scope change.

| Item | Rationale |
|------|-----------|
| Regions 7–12 (Obsidian Atelier → Somnium) | Beyond scoped 6-region 1.0 |
| Spells: Temporal Echo, Unravel, World Thread | High complexity / endgame |
| 12 cut relics (Tier III + excess Tier II) | Balance burden |
| Third ending branch | Requires faction depth not built |
| Full Sigil Recall fast-travel network | MVP only in scoped 1.0 |
| 42-room Whisperwood target | 19 authored rooms is ship target |
| Co-op, NG+, automated aim assist | GDD §11 out of scope for v1 |

---

## Top 10 Risks (Monitor)

| # | Risk | Mitigation |
|---|------|------------|
| 1 | Scope delusion (12 regions / 14 spells at 15 hrs/week) | Enforce [11-scoped-release.md](11-scoped-release.md) |
| 2 | Documentation drift vs build | QA checklist sign-off before marking roadmap ✅ |
| 3 | AI art inconsistency | Style lock + manual cleanup pass per [03-art-bible.md](03-art-bible.md) |
| 4 | Dual-purpose pillar collapse | Verify combat + exploration hook per spell before shipping |
| 5 | Boss spectacle failure | P0-02 before any public demo |
| 6 | Greybox room sprawl | No registry add without gameplay pass |
| 7 | Solo burnout | One polished hour before region 3 |
| 8 | Save/load regressions | P0-09 test expansion |
| 9 | "Hollow Knight clone" perception | Lead marketing with spell-as-key USP + distinct art |
| 10 | Steam launch without controller polish | P1-21 before store page |

---

## Suggested Timeline

### Next 1 Week (~15 hrs)

- P1-04 Gate failure feedback
- P1-22 Menu UI SFX wiring

### Next 1 Month (~60 hrs)

- P0-10 Handcraft 3 Whisperwood landmarks
- P0-11 Complete Ashen Threshold (5 rooms)
- P1-03 Boss intro beats
- P1-12 Overcast vulnerability
- P1-18 Quick spell HUD
- P1-19 Damage numbers
- P0-04 Region + boss audio pass (slice)

### Next 3 Months (~180 hrs)

- P0-01–03 Art passes (Elara, bosses, tilesets)
- P0-07–08 Crystal Bridge + Catacombs
- P1-06–07 Robes/Focus + fast travel MVP
- P0-12 External playtest
- P2-12 Combat music stems
- Steam demo build candidate

### Early Access Gate (~8–10 months)

- 3+ regions polished (not greybox)
- 8+ spells with verified dual-purpose hooks
- 4+ bosses with real art/audio
- 3–5 hours polished content
- Controller + Steam page + trailer
- External playtest NPS > 7

### Full 1.0 Gate (~18–24 months)

- Scoped [11-scoped-release.md](11-scoped-release.md) criteria OR documented intentional expansion

---

## Cross-References

| Doc | Use when |
|-----|----------|
| [01-gdd.md](01-gdd.md) | Design lock, combat feel, progression targets |
| [11-scoped-release.md](11-scoped-release.md) | What ships in 1.0 vs deferred |
| [10-development-roadmap.md](10-development-roadmap.md) | Phase milestones and acceptance criteria |
| [08-technical-architecture.md](08-technical-architecture.md) | Implementation patterns, QA checklist |
| [03-art-bible.md](03-art-bible.md) | Art pass priorities |
| [05-boss-bible.md](05-boss-bible.md) | Boss phase and ATS standards |
| [06-magic-system.md](06-magic-system.md) | Spell stats, relic tables |

---

## Changelog

| Date | Change |
|------|--------|
| 2026-06-22 | Initial backlog from Comprehensive Project Review; 22 items marked done from review pass |
| 2026-06-22 | P0-01 — Elara combat anim pass: 6-frame melee/cast, hit recoil, dash after-images; Hit state wired |
| 2026-06-22 | P1-22 — UiSfx helper wires select/confirm SFX on all menu buttons (title, pause, game over, settings, spell wheel) |
| 2026-06-22 | Effort column switched from calendar estimates to T-shirt sizes (XS–XXL) |
| 2026-06-22 | P0-02 — Matron + Warden 96px sprite sheets; AnimatedSprite2D wired in boss scenes with idle/attack/telegraph/phase anims |
| 2026-06-22 | STARTED: P0-05 — Playtest + time vertical slice |
| 2026-06-22 | P0-05 — PlaytestTracker autoload, F3/F4 debug hooks, playtest-vertical-slice.md protocol |
| 2026-06-22 | P1-04 — GateFailureFeedback helper + wrong-spell UI toasts on all ability gate types |
| 2026-06-22 | STARTED: P0-06 — 60 FPS profiling in ww_07 |
| 2026-06-22 | P0-06 — PerformanceProfiler utility, ww_07 enemy baseline, debug overlay budget line, integration fps_profile_ww07 test |
| 2026-06-24 | STARTED: P0-09 — Expand automated tests (SaveManager, SpellManager, gate save/load) |
| 2026-06-24 | P0-09 — Unit tests for SpellManager save round-trip, SaveManager JSON round-trip/corrupt/version mismatch, ability-gate cleared state persistence |

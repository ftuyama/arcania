# Arcania — Developer Guide

Technical reference for contributing to or building **Arcania**, a dark fantasy 2D Metroidvania in **Godot 4**.

Player-facing controls and playable content: **[README.md](README.md)**

---

## Vision

**Arcania** is inspired by *Hollow Knight* but forges its own identity through a dual-purpose magic system. The player controls **Elara Veilmark**, a disgraced apprentice who awakens in the Ashen Threshold with fractured memory and a flickering Ember Sigil. She must traverse a semi-open interconnected world, unlocking spells that open new paths, solve environmental puzzles, and reshape combat.

Core pillars:

- **Dual-purpose magic** — every spell unlocks combat AND exploration
- **Curiosity rewarded** — secrets, optional bosses, environmental lore
- **Non-linear routes** — multiple viable progression paths
- **Dark fantasy tone** — decay, forgotten empires, dangerous knowledge
- **Tight craft** — hand-drawn silhouettes, readable telegraphs, responsive movement

---

## Documentation Index

| # | Document | Description |
|---|----------|-------------|
| 01 | [Game Design Document](docs/01-gdd.md) | Master GDD — pillars, combat, progression, audio overview |
| 02 | [World Design](docs/02-world-design.md) | 12 regions, map, gating, fast travel, secrets |
| 03 | [Art Bible](docs/03-art-bible.md) | Visual direction, palettes, AI image prompts |
| 04 | [Enemy Bible](docs/04-enemy-bible.md) | 40 normal + 15 elite enemies |
| 05 | [Boss Bible](docs/05-boss-bible.md) | 10 mini-bosses, 8 major bosses, final boss |
| 06 | [Magic System](docs/06-magic-system.md) | 14 spells, mana, relics, upgrades |
| 07 | [Narrative](docs/07-narrative.md) | Story, factions, NPCs, endings |
| 08 | [Technical Architecture](docs/08-technical-architecture.md) | Godot 4 folder structure, systems design |
| 09 | [Asset Production List](docs/09-asset-production-list.md) | Animation specs, audio prompts, asset checklist |
| 10 | [Development Roadmap](docs/10-development-roadmap.md) | Solo-dev phased plan |
| 11 | [Scoped Release Plan](docs/11-scoped-release.md) | Intentional 1.0 scope cut |
| 12 | [Improvements Backlog](docs/12-improvements-backlog.md) | Prioritized post-review improvement backlog |

---

## Quick Start (Solo Developer)

1. Read [01-gdd.md](docs/01-gdd.md) for the full picture.
2. Open `godot/project.godot` in **Godot 4.3+** and press Play (F5).
3. See [README.md — How to Play](README.md#how-to-play) for controls and the current playable build.
4. Follow [10-development-roadmap.md](docs/10-development-roadmap.md) — Phases 0–4 ✅ complete; **Phase 5 (Content Expansion)** is next.
5. Use [08-technical-architecture.md](docs/08-technical-architecture.md) as your code blueprint.

**Target engine:** Godot 4.3+ (project tested on Godot 4.7)  
**Target resolution:** 1920×1080 (viewport 960×540, pixel-perfect scaling)  
**Art base unit:** 64px tiles, characters ~48–64px tall

### Current Build (Phases 0–4)

| Area | Status |
|------|--------|
| **Boot flow** | Title screen → New Game / Continue / Load (3 slots) |
| **Regions** | Ashen Threshold (2 rooms) + Whisperwood Hollow (16 critical path + 3 secrets) |
| **Spells** | 6 of 14 — Ember Sigil, Ember Bolt, Veil Step, Rootbind, Arc Step, Rune Anchor |
| **Bosses** | Thornweft Matron (mini), Root Warden (major) |
| **Enemies** | Bramble Stalker + Mothling, Bark Wraith, Thornweft Larva, Canopy Hunter |
| **Systems** | Save/load, Focus Crucibles, Focus Shards, map fog-of-war, relics, quests, spell wheel, pause/settings, gamepad, dialogue |
| **Audio** | Title music, threshold ambient, SFX (footsteps, spells, UI) |

---

## Playable Build Details

### Critical path

```
at_01_threshold_hub → at_03_east_road (Veil Step shrine) → ww_01 … ww_16_post_warden
                              ↓
                    Thornweft Matron (ww_11) → Arc Step
                    Root Warden (ww_15) → Rune Anchor
```

**Save / load** — Press **Esc** for the pause menu (3 save slots), or stand at a **Focus Crucible** and press **E** for a quick save to slot 1.

### Phase 4 systems

| System | Key | Notes |
|--------|-----|-------|
| **Relics** | **I** | 6 Tier-I relics; equip from inventory. **Cinder Heart** (Threshold hub), **Thornseed Charm** (Spore Glen secret), **Iron Grip** (Ironroot Depths). Modifiers affect combat (e.g. +20% burn with Cinder Heart). |
| **Quests** | Pause → Quest Log | Act I: *Ashen Awakening* → *Peddler's Price*. Tracker shown bottom-left on HUD. |
| **Map** | **M** | Fog-of-war grid for Whisperwood; visited rooms fill in, adjacent rooms show faint outline. Press **E** while map is open to place a marker (3 max). |
| **Spell wheel** | **Tab** | 8-slot loadout; click a slot then pick a spell. Slots 1–4 sync to quick-cast keys. Persists through save/load. |

### Phase 2 systems (still active)

**Movement** — Walk, jump (with coyote time and jump buffer), and dash. Platforming feels tuned for a Metroidvania: responsive jumps, pixel-snapped movement, camera locked to room bounds.

**Melee** — Press **J** for a 3-hit combo. Each step has its own windup, active frames, and recovery. Chain hits before the combo timer expires (~0.55 s).

**Starter spells**

| Spell | Key | Mana | Effect |
|-------|-----|------|--------|
| **Ember Sigil** | 1 | 8 | Short-range fire burst in front of you. Lights ember braziers and opens ability gates. |
| **Ember Bolt** | 2 | 12 | Ranged fire projectile. Strong against nature enemies (Bramble Stalkers). |
| **Veil Step** | 3 / Shift | 15 | Phase dash with invincibility frames. Pass through thin barriers. |

**Mana & Overcast** — Mana regenerates slowly in combat (2/s after a 1.2 s delay). If you lack mana for a spell, **Overcast** lets you cast anyway by spending HP instead — but only while above 15% health. Watch the HUD for the overcast warning.

**Enemies** — The Combat Test Arena spawns **Bramble Stalkers** that patrol, chase, and melee attack. Defeat them with melee or Ember Bolt. They drop essence (tracked in the HUD).

**Ability Gates** — A **Brazier Gate** blocks the right side of the arena. Cast **Ember Sigil** near it (or hit it directly) to light the brazier and remove the blocker. This demonstrates the dual-purpose magic pillar: combat spell + exploration key.

**Room Transitions** — Walk through doorways at room edges to travel between areas:

```
combat_test_arena ──► test_room_02 ◄──► test_room_01
```

- **combat_test_arena** — Combat sandbox with enemies and a brazier gate (starting room).
- **test_room_01 / test_room_02** — Ashen Threshold movement rooms with platforms and decorative ash wisps. No enemies; good for testing jumps and room transitions.

**Dev rooms** — `combat_test_arena`, `test_room_01`, and `test_room_02` remain available via `RoomLoader` but are not the default start.

### Debug Overlay

Press **F3** to toggle an on-screen overlay showing FPS, frame-time averages, room physics budget, current room/region, and a quick control reference.

Run the automated ww_07 profile from the Godot project folder:

```bash
godot --headless --path godot --script res://tests/integration/fps_profile_ww07.gd
```

### Known Limitations (Phase 5+)

Per the [development roadmap](docs/10-development-roadmap.md), not yet in the playable build:

- **8 spells** beyond the current set of 6 (14 total in the GDD)
- **Full Whisperwood** — 16 slice rooms shipped; 42-room region and secrets deferred
- **Ashen Threshold** — hub + east road only (2 of 5–7 planned rooms)
- **Enemy variety** — E-03 Bramble Stalker only in slice rooms (Mothling, Bark Wraith, etc. pending)
- **3 relic resources** defined but not yet placed in-world (`mist_walker`, `frost_nail`, `gloom_lens`)
- **11 regions** beyond Whisperwood, 3 endings, fast travel (Waystones + Sigil Recall)
- **NPC dialogue**, cutscenes, region boss music, and full art/audio pass

---

## Project Structure

```
arcania/
├── docs/           # Design bibles (GDD, world, art, enemies, bosses, magic, narrative, tech, assets, roadmap)
├── docs/images/    # README screenshot and other repo images
├── godot/          # Godot 4 project — Phases 0–4 implemented
├── scripts/        # Export and release scripts (web, itch.io)
├── tools/          # Room and asset generation scripts
├── README.md       # Player-facing guide
└── DEVELOPER.md    # This file
```

---

## Export & Release

Web export and itch.io packaging:

```bash
./scripts/export-web.sh      # HTML5 build → builds/web/
./scripts/release-itch.sh    # ZIP for manual upload, or --push with butler
```

See script headers in `scripts/export-web.sh` and `scripts/release-itch.sh` for prerequisites (Godot Web export templates, butler API key).

---

## License

All design documents are proprietary to the Arcania project. Specify license before open-sourcing.

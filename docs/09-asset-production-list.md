# 09 — Asset Production List

> *"Every frame is a promise to the player — readable, intentional, on time."*
> — Production note, Arcania art lock

**Purpose:** Master checklist and production specs for all visual, audio, and UI assets in Arcania. Cross-reference [03-art-bible.md](03-art-bible.md) for style tokens, [04-enemy-bible.md](04-enemy-bible.md) for enemy IDs, [05-boss-bible.md](05-boss-bible.md) for boss phases, [06-magic-system.md](06-magic-system.md) for spell mechanics, and [02-world-design.md](02-world-design.md) for region context.

**Canonical counts:** 14 spells · 55 enemies · 19 bosses (10 mini + 8 major + 1 final) · 12 regions · Elara @ 56px body / 64×64 canvas

---

## Table of Contents

1. [Master Asset Checklist](#1-master-asset-checklist)
2. [Player Animations — Elara Veilmark](#2-player-animations--elara-veilmark)
3. [Enemy Animations](#3-enemy-animations)
4. [Boss Animations](#4-boss-animations)
5. [Environment Assets](#5-environment-assets)
6. [VFX Assets](#6-vfx-assets)
7. [UI Assets](#7-ui-assets)
8. [Audio Production](#8-audio-production)
9. [Music Production](#9-music-production)
10. [Production Priority Order](#10-production-priority-order)
11. [Naming Conventions](#11-naming-conventions)

---

## 1. Master Asset Checklist

### 1.1 Summary Counts

| Category | Subcategory | Count | Notes |
|----------|-------------|-------|-------|
| **Player** | Core locomotion clips | 11 | Idle through Interact |
| | Melee combo clips | 3 | Attack 1/2/3 |
| | Mobility variants | 2 | Veil Step dash, Spirit Form set |
| | Spell cast clips | 14 | One per spell ID |
| | Sprite sheets | 4 | `elara_core`, `elara_combat`, `elara_spells`, `elara_spirit` |
| **Enemies** | Unique enemy types | 55 | E-01–E-55 |
| | Animation clips (est.) | ~420 | ~7–8 clips per enemy avg. |
| | Sprite sheets | 55 | One folder per enemy ID |
| **Bosses** | Mini-bosses | 10 | MB-01–MB-10 |
| | Major bosses | 8 | BOSS-01–BOSS-08 |
| | Final boss | 1 | BOSS-FINAL |
| | Animation clips (est.) | ~190 | From [05-boss-bible.md](05-boss-bible.md) lists |
| **Environment** | Region tilesets | 12 | 64×64 grid each |
| | Parallax layer strips | 58 | 3–5 per region (avg 4.8) |
| | Prop sheets | 12 | Per-region destructibles + set dressing |
| | Waystone variants | 25 | Per [02-world-design.md](02-world-design.md) |
| **VFX** | Spell effect sheets | 14 | 128×128 cells |
| | Hit feedback | 5 | Light, heavy, spell, block, overcast |
| | Death dissolve variants | 4 | Standard, elite, boss, region-themed |
| | Ambient particle sets | 12 | One per region |
| **UI** | Screen layouts | 6 | HUD, map, inventory, spell wheel, waystone, main menu |
| | Icon sets | 4 grids | 16px HUD, 32px inventory, 48px spell wheel, resource icons |
| | Total UI PNG assets | ~85 | See §7 |
| **Audio SFX** | Spell sounds | 42 | 14 spells × 3 (cast/travel/impact) |
| | Ambient loops | 12 | One per region |
| | Enemy vocalization families | 8 | Shared across 55 enemies |
| | UI sounds | 12 | |
| | Boss SFX sets | 19 | One per boss ID |
| | Footstep surfaces | 8 | |
| | Player combat/movement | ~26 | Melee, hurt, overcast, dash |
| **Music** | Region exploration themes | 12 | |
| | Boss battle themes | 9 | 8 major + BOSS-FINAL |
| | Stingers | 3 | Main menu, death, victory |
| **Fonts** | TTF bundles | 2 | Serif (logo/headings) + sans (body) |

### 1.2 Deliverable Formats

| Asset Type | Format | Canvas / Grid |
|------------|--------|---------------|
| Sprites / UI | PNG RGBA 32-bit | Per [03-art-bible.md](03-art-bible.md) §14 |
| Tilesets | PNG | 64×64 tiles |
| Parallax | PNG | Height 540px; width = region tile width × 64 |
| VFX | PNG | 128×128 cells |
| Audio | OGG Vorbis | 44.1 kHz; loops seamless ±10 ms |
| Music | OGG Vorbis | Stems optional for combat crossfade |

---

## 2. Player Animations — Elara Veilmark

**Canvas:** 64×64 px (56px body height; 2px padding; hood/FX may extend to canvas edge)  
**Pivot:** Feet center-bottom `(32, 62)`  
**Direction:** Face-right default; engine mirrors for left  
**Global style:** 12 FPS sprite stepping at 60 FPS game tick unless noted; robe hem + hood lag 1 frame (secondary action)

### 2.1 Core Locomotion & States

| Clip ID | Frames | FPS | Duration (ms) | Key Poses | Enters From | Exits To | Sheet Row |
|---------|--------|-----|---------------|-----------|-------------|----------|-----------|
| `idle` | 8 | 10 | 800 | F1 breathe in · F3 neutral · F5 sigil pulse peak (`#FF6B35`) · F7 breathe out | any neutral | walk, run, jump, cast, interact | `elara_core` R0 |
| `walk` | 8 | 12 | 667 | F1 contact L · F3 passing · F5 contact R · F7 passing | idle, run decel | run, idle, jump | `elara_core` R0 |
| `run` | 8 | 14 | 571 | F1 lean forward 8° · F3 stride ext · F5 robe flare · F7 dust kick | walk (hold sprint) | walk, dash, jump | `elara_core` R0 |
| `jump` | 6 | 12 | 500 | F1–2 crouch squash 90% · F3 launch stretch 110% · F4–5 apex tuck · F6 transition to fall | ground | fall, double_jump | `elara_core` R1 |
| `double_jump` | 8 | 14 | 571 | F1–2 sigil burst under feet · F3–4 spin 90° · F5 peak glow · F6–8 robe billow settle | fall (mid-air, 1/charge) | fall | `elara_core` R1 |
| `fall` | 4 | 10 | 400 | F1 arms up · F2–3 hold · F4 pre-land stretch | jump apex, double_jump | land→idle (blend 2f) | `elara_core` R1 |
| `dash` | 6 | 18 | 333 | F1–2 tuck · F3–4 cyan after-image stretch · F5 pop-out · F6 recovery | run, idle | idle, run | `elara_core` R1 |
| `cast` | 10 | 14 | 714 | F1–2 palm draw-back · F3–6 trace arc · F7 release · F8–10 follow-through | idle, run | idle; spell VFX sync F7 | `elara_core` R2 |
| `hit` | 4 | 12 | 333 | F1 recoil −8px · F2 flash white 50% · F3 stagger · F4 recover | any (unless i-frames) | idle, death if HP=0 | `elara_core` R2 |
| `death` | 12 | 10 | 1200 | F1–3 stumble · F4–6 knee · F7–9 sigil dim `#4A4E69` · F10–12 collapse + fade | hit at 0 HP | game over | `elara_core` R2 |
| `interact` | 6 | 10 | 600 | F1–2 reach · F3–4 hold · F5–6 retract | idle near interactable | idle | `elara_core` R2 |

**Sprite sheet layout — `elara_core.png` (512×192):**

```
Row 0 (y=0):   [ idle ×8 | walk ×8 ]                          128×64 each strip segment
Row 1 (y=64):  [ jump ×6 | fall ×4 | dash ×6 | pad ×4 ]       pad = transparent
Row 2 (y=128): [ cast ×10 | hit ×4 | death ×12 | interact ×6 ]  death wraps; interact may clip to next atlas
```

*Production note:* If `death` + `interact` overflow one row, split to `elara_core_b.png` — keep 2px gutter between cells.

### 2.2 Melee Combo

| Clip ID | Frames | FPS | Duration (ms) | Key Poses | Chain Window | Sheet |
|---------|--------|-----|---------------|-----------|--------------|-------|
| `melee_1` | 6 | 14 | 429 | F1 wind-back · F3 slash arc low · F5 recovery | F4–F6 → melee_2 | `elara_combat` R0 |
| `melee_2` | 6 | 14 | 429 | F1 cross-body · F3 horizontal mid · F5 open guard | F4–F6 → melee_3 | `elara_combat` R0 |
| `melee_3` | 8 | 14 | 571 | F1–2 overhead wind-up · F4 heavy impact · F6–8 extended follow-through + dust | F8 → idle only | `elara_combat` R0 |

**Hitbox active frames:** melee_1 F3 · melee_2 F3 · melee_3 F4 (sync with white slash VFX)

### 2.3 Veil Step Dash Variant

| Clip ID | Frames | FPS | Duration (ms) | Key Poses | Notes | Sheet |
|---------|--------|-----|---------------|-----------|-------|-------|
| `veil_step` | 8 | 18 | 444 | F1–2 dissolve shrink 70% · F3–4 static tear `#9D4EDD` · F5 invisible (blank) · F6–8 reappear + vertical rip | i-frames F3–F6; overrides `dash` when spell active | `elara_combat` R1 |

**Transition:** Cancel from `run`/`idle` on spell input; on exit → `idle` facing dash direction; cannot chain into melee until F8.

### 2.4 Spirit Form Transform Set

| Clip ID | Frames | FPS | Duration (ms) | Key Poses | Sheet |
|---------|--------|-----|---------------|-----------|-------|
| `spirit_enter` | 10 | 12 | 833 | F1–3 desaturate body · F4–6 lower body wisp dissolve · F7–10 eyes white glow | `elara_spirit` R0 |
| `spirit_idle` | 6 | 10 | 600 | Loop; translucent blue-grey; wisp trail on F3 | `elara_spirit` R0 |
| `spirit_move` | 6 | 12 | 500 | Float glide; no foot contacts | `elara_spirit` R0 |
| `spirit_exit` | 8 | 12 | 667 | F1–4 reform legs · F5–8 color restore + Pale Echo AoE sync F5 | `elara_spirit` R0 |

### 2.5 Spell Cast Variants (14)

Each clip syncs VFX spawn on **release frame**; robe flare + left palm forward unless noted.

| Spell ID | Clip ID | Frames | FPS | ms | Key Poses | Release Frame | Sheet |
|----------|---------|--------|-----|-----|-----------|---------------|-------|
| `ember_sigil` | `cast_ember_sigil` | 8 | 14 | 571 | F3 trace ember rune · F5 palm thrust · F6 follow-through cinder | F5 | `elara_spells` R0 |
| `veil_step` | *(see §2.3)* | 8 | 18 | 444 | — | F5 | `elara_combat` |
| `rune_anchor` | `cast_rune_anchor` | 10 | 14 | 714 | F2–4 draw chain rune · F6 throw · F8–10 pull-back tension | F6 | `elara_spells` R0 |
| `crystal_bridge` | `cast_crystal_bridge` | 12 | 12 | 1000 | F1–3 stomp or palm-down · F5–8 crystal erupt · F9–12 hold hum pose | F5 | `elara_spells` R0 |
| `spirit_form` | *(see §2.4)* | 10 | 12 | 833 | — | F7 | `elara_spirit` |
| `ley_sight` | `cast_ley_sight` | 8 | 12 | 667 | F1–2 eyes closed · F3–5 gold scan lines from eyes · F6–8 hold gaze | F3 | `elara_spells` R1 |
| `temporal_echo` | `cast_temporal_echo` | 10 | 14 | 714 | F2–4 clock-hand gesture · F6 split afterimage · F8–10 rewind pose | F6 | `elara_spells` R1 |
| `shadow_blink` | `cast_shadow_blink` | 8 | 16 | 500 | F1–3 flatten to shadow · F4–5 streak · F6–8 erupt upward | F4 | `elara_spells` R1 |
| `arcane_bulwark` | `cast_arcane_bulwark` | 10 | 12 | 833 | F2–5 hex panels tessellate · F6–8 hold guard · F9–10 settle | F3 | `elara_spells` R1 |
| `frost_bind` | `cast_frost_bind` | 10 | 14 | 714 | F2–4 palm ice crystals · F6 spread gesture · F8–10 frost mist exhale | F6 | `elara_spells` R2 |
| `storm_lash` | `cast_storm_lash` | 8 | 16 | 500 | F1–2 focus item raise · F4 whip crack · F6–8 recoil | F4 | `elara_spells` R2 |
| `sigil_recall` | `cast_sigil_recall` | 10 | 12 | 833 | F2–5 stamp ground rune · F6–8 channel · F9–10 anchor pulse | F5 | `elara_spells` R2 |
| `unravel` | `cast_unravel` | 12 | 12 | 1000 | F1–4 pull thread gesture · F6–8 unspool · F9–12 release motes | F6 | `elara_spells` R2 |
| `world_thread` | `cast_world_thread` | 14 | 10 | 1400 | F1–4 grasp air · F6–9 pull seam · F10–14 walk thread barefoot | F8 | `elara_spells` R3 |

**Sprite sheet layout — `elara_spells.png` (768×256):**

```
R0: ember_sigil×8 | rune_anchor×10 | crystal_bridge×12 | pad×2
R1: ley_sight×8 | temporal_echo×10 | shadow_blink×8 | arcane_bulwark×10
R2: frost_bind×10 | storm_lash×8 | sigil_recall×10 | unravel×12
R3: world_thread×14 | pad×50
```

---

## 3. Enemy Animations

### 3.1 Standard Clip Set (Template)

Every enemy ships this minimum set unless noted in §3.3.

| Clip | Purpose | Loop |
|------|---------|------|
| `idle` | Neutral; telegraph-ready | Yes |
| `patrol` | Walk/float/hover cycle | Yes |
| `atk_windup` | Telegraph + family hue fill | No |
| `atk_active` | Hitbox active | No |
| `atk_recover` | Vulnerability window | No |
| `hit` | White flash overlay 50% | No |
| `death` | Desaturate → shatter (4–6f) | No |

**Optional clips (author when needed):** `spawn`, `burrow`, `fly`, `block`, `elite_aura` (gold ring loop, 4f)

### 3.2 Frame Counts by Family

Telegraph colors per [04-enemy-bible.md](04-enemy-bible.md) §Telegraph Standards. All enemy gameplay anims at **12 FPS** unless noted.

| Family | Idle | Patrol | Windup | Active | Recover | Hit | Death | FPS | Canvas |
|--------|------|--------|--------|--------|---------|-----|-------|-----|--------|
| **ash/undead** | 4 | 4 | 2 | 3 | 2 | 2 | 5 | 10 | 64×64 |
| **forest/thorn** | 6 | 6 | 3 | 4 | 2 | 2 | 6 | 12 | 64×64 |
| **water/marsh** | 4 | 5 | 2 | 3 | 3 | 2 | 5 | 10 | 64×64 |
| **crystal** | 4 | 4 | 3 | 4 | 2 | 2 | 6 | 12 | 64×64 |
| **archive/ghost** | 6 | 4 | 2 | 4 | 2 | 2 | 6 | 10 | 64×64 |
| **sky/wind** | 4 | 6 | 2 | 3 | 2 | 2 | 5 | 12 | 64×64 |
| **lab/construct** | 4 | 4 | 4 | 3 | 3 | 2 | 6 | 12 | 64×64 |
| **cathedral/holy-corrupted** | 4 | 4 | 3 | 3 | 2 | 2 | 6 | 10 | 64×64 |
| **underground/knight** | 6 | 4 | 4 | 3 | 3 | 2 | 8 | 10 | 96×96 |
| **dream/ethereal** | 6 | 5 | 2 | 5 | 2 | 2 | 6 | 12 | 64×64 |
| **void/unbound** | 4 | 4 | 2 | 4 | 2 | 2 | 8 | 12 | 64×64 |

**Elite modifier (E-41–E-55 + field-elite):** Add `elite_aura` 4f loop; death +2 frames ember burst in biome accent; canvas 96×96.

**Sprite sheet layout (standard enemy):**

```
Horizontal strip: [ idle | patrol | atk_windup | atk_active | atk_recover | hit | death ]
2px gutter · pivot feet center-bottom · 64×64 cells (96×96 for elites/knights)
```

### 3.3 Per-Enemy Assignment (55)

Primary family determines base frame counts; **exceptions** override specific clips.

#### Ash / Undead (E-01, E-02, E-04, E-06, E-08, E-09, E-11)

| ID | Name | Notes / Exceptions |
|----|------|-------------------|
| E-01 | Ash Wisp | No patrol — `float` 4f loop replaces patrol; death 3f (swarm pop) |
| E-02 | Bone Crawler | Patrol 6f (multi-segment ripple) |
| E-04 | Ember Moth | `fly` 4f replaces patrol; atk_active 2f (dive) |
| E-06 | Grave Lantern | Idle 6f pulse swell; death 8f (explosion telegraph payoff) |
| E-08 | Threshold Shade | Elite patrol 6f; atk_windup 3f |
| E-09 | Drowned Acolyte | `spawn` 8f rise from water; grab atk_active 5f |
| E-11 | Mosaic Serpent | Patrol 8f slither; no separate windup (windup merged into active 4f) |

#### Forest / Thorn (E-03, E-07, E-12, E-15, E-18, E-53)

| ID | Name | Notes |
|----|------|-------|
| E-03 | Bramble Stalker | `camouflage` 2f idle variant; reveal atk_windup +2f |
| E-07 | Mothling Swarm | Cluster sprite; use E-04 frames at 50% scale ×3 offset |
| E-12 | Bark Wraith | Tall 80px canvas; idle 8f sway |
| E-15 | Thornweft Larva | Patrol 4f inch; death 4f silk pop |
| E-18 | Canopy Hunter | Patrol 8f jump cycle; squash/stretch exaggerated |
| E-53 | Canopy Hunter Brood-Matriarch | Elite 96×96; spawn 12f egg lay; atk_active 6f |

#### Water / Marsh (E-05, E-10, E-13, E-16, E-19, E-22, E-50, E-54)

| ID | Name | Notes |
|----|------|-------|
| E-05 | Fen Leech | `burrow` 4f; atk_active 3f latch |
| E-10 | Will-o-Mire | Float idle 4f; no recover (hit-and-run) |
| E-13 | Bog Maw | Stationary — no patrol; `emerge` 6f + `chomp` 4f only |
| E-16 | Stilt Crawler | Patrol 8f high-step |
| E-19 | Memory Eel | Patrol 6f swim wave |
| E-22 | Fenbound Zealot | atk_windup 4f spit; platform variant no patrol |
| E-50 | Fen Colossus | Elite 128×128; all clips +50% frames; slow 8 FPS |
| E-54 | Fenbound Hierophant | Elite; ritual `channel` 8f loop |

#### Crystal (E-17, E-21, E-23, E-25, E-27, E-29)

| ID | Name | Notes |
|----|------|-------|
| E-17 | Crystal Crawler | `cling` 2f wall idle variant |
| E-21 | Prism Bat | Fly patrol 4f |
| E-23 | Shard Stalker | `trail` VFX on patrol F3 |
| E-25 | Lightcut Beam | Turret — `rotate` 4f loop + `beam_fire` 6f |
| E-27 | Gembound Miner | atk_windup 4f pick raise |
| E-29 | Prism Sentinel | Mini-boss scale 80px; block 4f |

#### Archive / Ghost (E-14, E-24, E-26, E-30, E-32, E-33)

| ID | Name | Notes |
|----|------|-------|
| E-14 | Urn Wraith | Float patrol; death urn crack 8f |
| E-24 | Page Swarm | 3-frame flutter loop (reuse E-24 sheet for swarm) |
| E-26 | Echo Scholar | **Copy Elara cast pose** on atk_active; 6f mimic |
| E-30 | Ink Elemental | `puddle` 4f idle + `rise` 4f transition |
| E-32 | Catalog Serpent | Patrol 8f drawer segments |
| E-33 | Binding Golem | Heavy — windup 4f, recover 4f |

#### Sky / Wind (E-28, E-31, E-34, E-36, E-37, E-55)

| ID | Name | Notes |
|----|------|-------|
| E-28 | Void Leaper | `teleport` 4f replaces windup |
| E-31 | Gravity Wraith | Inverted patrol 6f |
| E-34 | Debris Golem | Roll patrol 6f continuous loop |
| E-36 | Starfall Knight | 96×96; block 4f + lance atk 5f active |
| E-37 | Regent's Echo | Float idle 6f; orb orbit separate 4f layer |
| E-55 | Starfall Knight Praetorian | Elite 96×96; all knight frames +2 |

#### Lab / Construct (E-35, E-38, E-39, E-40)

| ID | Name | Notes |
|----|------|-------|
| E-35 | Slag Crawler | Molten trail on patrol F2,F4 |
| E-38 | Blueprint Phantom | `summon` 8f turret spawn |
| E-39 | Furnace Mouth | Stationary; `breath` 6f cone atk |
| E-40 | Anvil Thrall | Hammer atk_active 4f; heavy recover 4f |

#### Cathedral / Holy-Corrupted (E-20, E-41, E-52)

| ID | Name | Notes |
|----|------|-------|
| E-20 | Reliquary Guard | Shield block 4f; formation idle 4f |
| E-41 | Ashbound Zealot | `suicide_charge` 6f windup+active merged |
| E-52 | Threshold Shade Ascendant | Elite E-08 kit + holy lance 6f |

#### Underground / Knight (E-42, E-43, E-51)

| ID | Name | Notes |
|----|------|-------|
| E-42 | Spore Cavalry | Mount + rider 96×96; patrol 6f gallop |
| E-43 | Root Knight | Slow patrol 4f; cleave active 5f |
| E-51 | Crown Devourer | Vault elite 128×128; jaw atk 8f active |

#### Dream / Ethereal (E-44, E-45, E-46)

| ID | Name | Notes |
|----|------|-------|
| E-44 | Nightmare Fragment | **Procedural mask** — 3 region variants; idle 4f glitch |
| E-45 | Dream Leach | Drain tether VFX sync active F3 |
| E-46 | Rift Stalker | Teleport after-image 2f on patrol |

#### Void / Unbound (E-47, E-48, E-49)

| ID | Name | Notes |
|----|------|-------|
| E-47 | Ley Fragment | Orbit path — no patrol; `orbit` 4f loop |
| E-48 | Unbound Shard | Static idle 2f pulse |
| E-49 | Weave Remnant | Elite; element ring 4f loop overlay |

---

## 4. Boss Animations

**Canvas:** 256×256 px default; scale in-engine per [03-art-bible.md](03-art-bible.md).  
**FPS:** 12–15 gameplay; telegraph frames held +3–5 ticks at 60 FPS.  
**Naming:** `{boss_id}_{clip}` — e.g. `mb01_intro_emerge`

### 4.1 Mini-Bosses (MB-01 — MB-10)

| ID | Name | Clips (frames) | Scale | Notes |
|----|------|----------------|-------|-------|
| MB-01 | Thornweft Matron | `intro_emerge`(90), `idle_loom`(48 loop), `atk_vine_lash_l`(38), `atk_vine_lash_r`(38), `atk_root_snare`(55), `spawn_pillar`(45), `phase2_uproot`(120), `atk_canopy_rain`(70 loop), `stagger`(90), `death_unravel`(150) | 96px | Whisperwood |
| MB-02 | Reliquary Sentinel | `intro_activate`(60), `idle_guard`(40 loop), `atk_slam`(45), `atk_urn_lob`(50), `shield_rotate`(30 loop), `phase2_shatter`(90), `atk_beam_charge`(40), `atk_beam_fire`(35), `stagger`(60), `death_flood`(120) | 104px | Catacombs |
| MB-03 | Miremother | `intro_surface`(80), `idle_brood`(44 loop), `atk_sweep_l`(42), `atk_sweep_r`(42), `atk_lure`(50), `atk_pull`(55), `phase2_widen`(100), `atk_burst`(48), `stagger`(70), `death_drain`(130) | 112px | Bleakfen |
| MB-04 | Prism Warden | `intro_crystalize`(70), `idle_hum`(36 loop), `atk_beam`(50), `atk_volley`(45), `shield_mirror`(40), `phase2_crack`(85), `atk_split`(55), `stagger`(65), `death_shatter`(110) | 80px | Lumineth |
| MB-05 | Index Hydra | `intro_drawers`(75), `idle_heads`(40 loop), `atk_flurry`(60), `atk_bite_h1/h2/h3`(35 each), `atk_misfile`(50), `phase2_merge`(95), `atk_stamp`(45), `stagger`(70), `death_spill`(125) | 112px | Archive |
| MB-06 | Bridge Warden Kael | `intro_toll`(65), `idle_lean`(38 loop), `atk_lance`(48), `atk_bell`(55), `env_gust`(30), `phase2_collapse`(110), `summon_rod`(40), `stagger`(60), `death_fall`(140) | 96px | Skyfall |
| MB-07 | Anvil Ascendant | `intro_hammer`(70), `idle_forge`(42 loop), `atk_triplet`(55), `atk_reject`(50), `env_vent`(25), `phase2_melt`(100), `atk_afterimage`(45), `stagger`(65), `death_cool`(115) | 104px | Atelier |
| MB-08 | Ember Confessor | `intro_ash`(75), `idle_scribe`(40 loop), `atk_scroll`(48), `atk_lash`(42), `prompt_confess`(60 hold), `phase2_screen`(90), `atk_guilt`(52), `stagger`(68), `death_scatter`(120) | 136px | Sanctum |
| MB-09 | Ley Guardian — Static Warden | `intro_unamber`(80), `idle_static`(36 loop), `atk_blade`(50), `atk_suppress`(55), `atk_burst`(48), `stagger`(70), `death_crack`(100) | 128px | Ley Nexus |
| MB-10 | Ley Guardian — Weave Sentinel | `intro_weave`(85), `idle_rotate`(40 loop), `atk_element`(45), `atk_mimic_fire/frost/storm`(40 each), `phase2_dual`(110), `stagger`(75), `death_unravel`(105) | 128px | Ley Nexus |

### 4.2 Major Bosses (BOSS-01 — BOSS-08)

| ID | Name | Clips | Phase Intro | Spell Grant Clip |
|----|------|-------|-------------|------------------|
| BOSS-01 | The Root Warden | `intro_cocoon`(100), `idle_magister`(45 loop), `atk_pull`(55), `atk_spear`(50), `env_cart`(40), `phase2_merge`(120), `phase3_shaft`(130), `atk_mass_pull`(60), `stagger`(90), `death_root_release`(160), `spell_grant`(90) | phase2_merge | spell_grant |
| BOSS-02 | Archivist Phantom | `intro_stamp`(95), `idle_float`(42 loop), `atk_page`(48), `blink_misfile`(35), `trap_offer`(70), `phase2_audit`(115), `phase3_excision`(125), `stagger`(85), `death_unfile`(150), `spell_grant`(85) | phase2_audit | spell_grant |
| BOSS-03 | Crystal Leviathan | `intro_awaken`(110), `idle_drift`(50 loop), `atk_tail`(52), `atk_breath`(58), `env_quake`(45), `phase2_scroll`(120), `phase3_climb`(140), `atk_laser`(55), `stagger`(80), `death_settle`(170), `spell_grant`(90) | phase2_scroll | spell_grant |
| BOSS-04 | The Fallen Magister | `intro_descent`(105), `idle_hover`(44 loop), `atk_orb`(50), `atk_crush`(55), `atk_rail`(48), `phase2_charge`(110), `phase3_overload`(130), `stagger`(88), `death_engine_explode`(155), `spell_grant`(92) | phase2_charge | spell_grant |
| BOSS-05 | Subject IX | `intro_drip`(90), `idle_flicker`(40 loop), `atk_whip`(46), `atk_snap`(40), `atk_cage`(55), `phase2_hollow`(105), `phase3_merge`(120), `atk_possess`(50), `stagger`(82), `death_dissolve`(145), `spell_grant`(88) | phase2_hollow | spell_grant |
| BOSS-06 | Cardinal of Ash | `intro_ignite`(100), `idle_sermon`(46 loop), `atk_bolt`(48), `atk_wave`(52), `atk_chain`(50), `phase2_martyr`(115), `phase3_burn`(125), `stagger`(86), `death_ashfall`(160), `spell_grant`(90) | phase2_martyr | spell_grant |
| BOSS-07 | The Undercrown | `p0_champion_intro`(80), `p0_cleave`(45), `p0_death`(70), `intro_merge`(110), `atk_spikes`(50), `summon_knights`(60), `phase2_mist`(115), `atk_entomb`(55), `stagger`(90), `death_bury`(150), `spell_grant`(88) | phase2_mist | spell_grant |
| BOSS-08 | Somnium Weaver | `p0_mirror_intro`(75), `p0_cast`(40), `p0_shatter`(65), `intro_weave`(105), `atk_thread`(48), `atk_replay`(55), `trap_loop`(50), `phase2_reverse`(120), `phase3_epoch`(135), `stagger`(92), `death_unspool`(155), `spell_grant`(90) | phase2_reverse | spell_grant |

> **Phase 0 clips:** BOSS-07 includes Root Champion (`p0_*`); BOSS-08 includes Mirror Elara duel (`p0_*`) per [05-boss-bible.md](05-boss-bible.md) §3.1.

### 4.3 Final Boss — BOSS-FINAL

**The Unbound Conclave** · Ley Nexus · 256×256 (phase scale up to 320px)

| Clip | Frames | Notes |
|------|--------|-------|
| `intro_conclave_form` | 180 | Magisters + static merge |
| `idle_chorus` | 60 loop | Multi-face morph |
| `phase1_edict` | Container | Beam + circle attack sub-clips |
| `phase2_merge` | 120 | Static expansion; invuln |
| `phase2_barrage` | Per-boss mimic container | References major boss atk patterns |
| `phase3_thread` | Container | Thread Rip + platform scripts |
| `ending_repair` | 240 | Stitch ending |
| `ending_sever` | 240 | Cut ending |
| `ending_join` | 180 | Dissolve ending |
| `stagger` | 120 | All faces align; T4 window |
| `death_or_resolve` | 150 | Branch per ending |

**Boss sheet layout:** One PNG per boss minimum; clips ≥60 frames may be separate files `{boss_id}_{clip}.png` to keep under 4096px width.

---

## 5. Environment Assets

**Grid:** 64×64 px tiles · **Parallax height:** 540px · **Layers:** 3–5 per region (+ optional Layer 6 weather @ 30% opacity)

### 5.1 Parallax Stack (Standard)

| Layer | File Suffix | Scroll | Content |
|-------|-------------|--------|---------|
| 0 | `parallax_0_sky` | 0.2× | Sky / void / gradient |
| 1 | `parallax_1_far` | 0.4× | Far silhouettes |
| 2 | `parallax_2_midfar` | 0.6× | Architecture / trees / shelves |
| 3 | `parallax_3_mid` | 0.85× | Mid props |
| 4 | `parallax_4_fg` | 1.0× | Foreground occluders (optional) |
| 6 | `weather_overlay` | 1.0× | Full-screen weather (optional) |

### 5.2 Per-Region Deliverables

#### 01 — Ashen Threshold (Hub)

| Asset | Layers | Tileset Themes | Props |
|-------|--------|----------------|-------|
| `01_ashen_threshold/` | 4 (0–2 + fg fog) | Cracked ley pavement, collapsed arch stone, brazier base, hub Waystone platform | Broken pilgrim banners, faded Veilmark insignia wall, ember braziers (lit/unlit), collapsed bench, fog wisps, shortcut cliff vines (stub) |
| **Palette** | `#1A1A2E` `#2C2C34` `#4A4E69` `#8B4513` `#FF6B35` | | |

#### 02 — Whisperwood Hollow

| Asset | Layers | Tileset | Props |
|-------|--------|---------|-------|
| `02_whisperwood_hollow/` | 5 | Hollow bark, moss bridge, root tile, thorn hazard, spore floor | Woven bridges, moth nests, Thornbound totems, destructible thorn pillars, heartwood arena stump |
| **Palette** | `#081C15` `#1B4332` `#40916C` `#52B788` `#D8F3DC` | | |

#### 03 — Sunken Catacombs

| Asset | Layers | Tileset | Props |
|-------|--------|---------|-------|
| `03_sunken_catacombs/` | 4 (interior; no sky) | Wet slate floor, bone mosaic, flooded tile, urn niche, lantern hook | Ghost lanterns, reliquary urns, sunken shelves, drain valve, mosaic serpent floor patterns |
| **Palette** | `#0B090A` `#495867` `#5C677D` `#C9ADA7` `#B1FAFF` | | |

#### 04 — Bleakfen Marsh

| Asset | Layers | Tileset | Props |
|-------|--------|---------|-------|
| `04_bleakfen_marsh/` | 5 + weather fog | Stilt walk, peat water, cypress platform, rotting dock, dam mechanism | Dead cypress, stilt huts, will-o-wisp lures, bog maw holes, dam lever, memory stones |
| **Palette** | `#1A1A1D` `#4E5D5C` `#6B9080` `#AEC3B0` `#E8E8E8` | | |

#### 05 — Lumineth Caverns

| Asset | Layers | Tileset | Props |
|-------|--------|---------|-------|
| `05_lumineth_caverns/` | 5 | Crystal floor, prism wall, light-cut hazard, gem growth, vertical shaft | Crystal formations, miner silhouettes (embedded), prism mirrors, gravity well, bridge trial gaps |
| **Palette** | `#10002B` `#3C096C` `#7B2CBF` `#E0AAFF` `#FFD60A` | | |

#### 06 — Archive of Echoes

| Asset | Layers | Tileset | Props |
|-------|--------|---------|-------|
| `06_archive_of_echoes/` | 5 | Shelf wall, ink river edge, catalog drawer tile, candle pool, elevator platform | Floating pages, echo silhouette loops, card catalog heads, misfile trap aisles, Ley Well alcove |
| **Palette** | `#03045E` `#023E8A` `#0077B6` `#90E0EF` `#CAF0F8` | | |

#### 07 — Skyfall Ruins

| Asset | Layers | Tileset | Props |
|-------|--------|---------|-------|
| `07_skyfall_ruins/` | 5 + void gap | Floating platform, star-scar stone, bridge segment, inverted gravity zone, debris | Broken bridges, levitation orbs, void gaps, toll bell, rod summon points |
| **Palette** | `#0D0221` `#264653` `#2A9D8F` `#E9C46A` `#F4A261` | | |

#### 08 — Obsidian Atelier

| Asset | Layers | Tileset | Props |
|-------|--------|---------|-------|
| `08_obsidian_atelier/` | 4 + ash snow weather | Obsidian floor, molten channel, anvil station, vent grate, blueprint table | Furnaces, anvil golems (inactive), scorched blueprints, heat vents, forge hammer props |
| **Palette** | `#0A0A0A` `#370617` `#6A040F` `#DC2F02` `#FFBA08` | | |

#### 09 — Sanctum of Ash

| Asset | Layers | Tileset | Props |
|-------|--------|---------|-------|
| `09_sanctum_of_ash/` | 5 + indoor ash fall | Cathedral floor, melted glass window, pyre altar, ember statue, confession booth | Pyre altars, ash piles, melted stained glass props, ember confessor lectern |
| **Palette** | `#212529` `#6C757D` `#FFDDD2` `#F48C06` `#E5383B` | | |

#### 10 — Undercrown Kingdom

| Asset | Layers | Tileset | Props |
|-------|--------|---------|-------|
| `10_undercrown_kingdom/` | 5 | Fungal floor, throne root, spore palace wall, crown vault, highway tunnel | Bioluminescent mushrooms, insect cavalry pens, buried crown prop, ice entomb tiles |
| **Palette** | `#2B2D42` `#8D99AE` `#EDF2F4` `#EF233C` `#D90429` | | |

#### 11 — Somnium Rift

| Asset | Layers | Tileset | Props |
|-------|--------|---------|-------|
| `11_somnium_rift/` | 5 + static overlay | Memory platform, inverted color zone, floating text tile, loop seam, dream-self nexus | Floating text fragments, impossible geometry props, mirror arena frame, color-invert triggers |
| **Palette** | `#240046` `#5A189A` `#C77DFF` `#E0AAFF` `#FF6D00` | | |

#### 12 — Ley Nexus + The Unbound

| Asset | Layers | Tileset | Props |
|-------|--------|---------|-------|
| `12_ley_nexus/` | 4 + void | Ley strand bridge, geometric void, crystallized time shard, nexus core, gauntlet gate | Floating ley strands, guardian pedestals, weaveheart antechamber, Unbound silhouette backdrop |
| **Palette** | `#000000` `#7F00FF` `#00FFFF` `#FFFFFF` `#FF0099` | | |

### 5.3 Tileset Production Notes

- **Autotile:** 47-tile blob or Godot terrain peering per region (document in `08-technical-architecture.md`).
- **Collision:** Authored in TileSet editor, not baked into PNG.
- **Destructibles:** Separate `props_destructible.png` overlay per region (thorn pillars, urns, drawers).
- **Total unique tiles (est.):** ~120–180 per region · **~1,800 tiles project-wide**.

---

## 6. VFX Assets

**Cell size:** 128×128 px · **Rate:** 12 FPS VFX · **Grid:** 4×2 cells per sheet unless noted

### 6.1 Spell VFX (14 — canonical IDs from [06-magic-system.md](06-magic-system.md))

| Spell ID | Sheet File | Frames | Color | Shape Language |
|----------|------------|--------|-------|----------------|
| `ember_sigil` | `vfx_ember_sigil.png` | 8 | `#FF6B35`→`#FFD60A` | Streak + impact bloom + scorch decal |
| `veil_step` | `vfx_veil_step.png` | 8 | `#9D4EDD` + white | Vertical tear + static residue |
| `rune_anchor` | `vfx_rune_anchor.png` | 10 | Gold `#E9C46A` | Chain filaments + embed pulse |
| `crystal_bridge` | `vfx_crystal_bridge.png` | 12 | Frost white + `#E0AAFF` | Hex walkway bloom + water fractal |
| `spirit_form` | `vfx_spirit_form.png` | 10 | Pale blue-grey | Desaturate wash + wisp trail |
| `ley_sight` | `vfx_ley_sight.png` | 8 | Gold scan + cyan `#00FFFF` | Wireframe overlay + pulse ring |
| `temporal_echo` | `vfx_temporal_echo.png` | 12 | Amber + grey static | Afterimage split + clock ticks |
| `shadow_blink` | `vfx_shadow_blink.png` | 8 | Purple-black `#240046` | Flat shadow streak + sigil erupt |
| `arcane_bulwark` | `vfx_arcane_bulwark.png` | 10 | Blue-white `#CAF0F8` | Hex panel shatter |
| `frost_bind` | `vfx_frost_bind.png` | 10 | Ice `#90E0EF` | Crystal spread + shatter radial |
| `storm_lash` | `vfx_storm_lash.png` | 8 | Violet `#7B2CBF` | Chain arc + pool electrify |
| `sigil_recall` | `vfx_sigil_recall.png` | 12 | Cyan thread | Fold dissolve + anchor star |
| `unravel` | `vfx_unravel.png` | 10 | White + all accents | Thread sever + motes to black |
| `world_thread` | `vfx_world_thread.png` | 14 | Gold + nexus cyan | Seam rip + stardust trail |

**AI prompt (spell VFX batch):**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, game VFX sprite sheet frames, additive glow, 128x128 effect cells, ember sigil streak, veil step tear, rune anchor chain, crystal bridge hex, ley sight wireframe, transparent background, spell effect animation
```

### 6.2 Hit Effects

| File | Frames | Use |
|------|--------|-----|
| `vfx_hit_light.png` | 4 | Melee light |
| `vfx_hit_heavy.png` | 6 | Melee finisher / boss hit |
| `vfx_hit_spell.png` | 6 | Spell impact (tint per spell) |
| `vfx_hit_block.png` | 4 | Bulwark / parry |
| `vfx_hit_overcast.png` | 4 | Overcast self-damage |

### 6.3 Death Effects

| File | Frames | Use |
|------|--------|-----|
| `vfx_death_standard.png` | 6 | Normal enemies |
| `vfx_death_elite.png` | 8 | Elites + biome accent burst |
| `vfx_death_boss.png` | 12 | Boss phase end |
| `vfx_death_region_{01-12}.png` | 6 each | Optional regional variant (ink/crystal/ash) |

### 6.4 Ambient Particles (12)

| Region | File | Particles |
|--------|------|-----------|
| Ashen Threshold | `vfx_amb_01_ember.png` | Ember motes, ash flecks |
| Whisperwood | `vfx_amb_02_spore.png` | Spores, pollen, moth dust |
| Catacombs | `vfx_amb_03_drip.png` | Water drip, lantern drift |
| Bleakfen | `vfx_amb_04_fog.png` | Fog wisps, wisp orbs |
| Lumineth | `vfx_amb_05_crystal.png` | Crystal dust, light motes |
| Archive | `vfx_amb_06_page.png` | Page scraps, ink dots |
| Skyfall | `vfx_amb_07_debris.png` | Wind debris, star glints |
| Atelier | `vfx_amb_08_spark.png` | Spark showers, ash snow |
| Sanctum | `vfx_amb_09_ashfall.png` | Eternal ash fall |
| Undercrown | `vfx_amb_10_spore.png` | Spore drift |
| Somnium | `vfx_amb_11_static.png` | Static pixels, text fragments |
| Ley Nexus | `vfx_amb_12_ley.png` | Ley strands, void motes |

---

## 7. UI Assets

**Viewport:** 960×540 · **Safe margin:** 16px · **Style:** Hand-drawn flat; 1px `#2C2C34` outline on icons

### 7.1 HUD (960×540 overlay)

| Asset | Dimensions | Description |
|-------|------------|-------------|
| `ui_hud_hp_bar_bg.png` | 120×12 | Dark bg |
| `ui_hud_hp_bar_fill.png` | 116×8 | Bone-white `#FFDDD2` |
| `ui_hud_mana_bar_bg.png` | 120×12 | Dark bg |
| `ui_hud_mana_bar_fill.png` | 116×8 | Cyan `#00FFFF` |
| `ui_hud_overcast_edge.png` | 120×4 | Crimson bleed overlay |
| `ui_hud_minimap_frame.png` | 72×72 | Top-right; 64×64 map inset |
| `ui_hud_spell_slot_{1-4}.png` | 40×40 each | Quick-slot frames |
| `ui_hud_spell_slot_active.png` | 40×40 | Selected highlight |
| `ui_hud_shard_icon.png` | 16×16 | Focus shard counter |
| `ui_hud_relic_icon.png` | 16×16 | Relic indicator |
| `ui_hud_save_pulse.png` | 24×24 | Autosave sigil pulse (4f anim) |

### 7.2 Map Screen (full 960×540)

| Asset | Dimensions | Description |
|-------|------------|-------------|
| `ui_map_parchment_bg.png` | 960×540 | Aged parchment base |
| `ui_map_ink_blot.png` | 32×32 tile | Unexplored tile |
| `ui_map_player_marker.png` | 8×8 | Ember dot |
| `ui_map_waystone_icon.png` | 16×16 | Ley fracture circle |
| `ui_map_boss_skull.png` | 16×16 | Boss room marker |
| `ui_map_region_tint_{01-12}.png` | per region | 40% opacity overlays |

### 7.3 Inventory / Relic Screen

| Asset | Dimensions | Description |
|-------|------------|-------------|
| `ui_inv_panel_bg.png` | 800×480 | Parchment panel |
| `ui_inv_slot.png` | 36×36 | Grid cell |
| `ui_inv_slot_selected.png` | 36×36 | Cyan corner brackets |
| `ui_inv_relic_slot.png` | 64×64 | Center relic slot |
| `ui_inv_mannequin.png` | 128×200 | Robe tier display |
| `ui_inv_conflict_slash.png` | 32×32 | Focus/relic conflict overlay |

### 7.4 Spell Wheel

| Asset | Dimensions | Description |
|-------|------------|-------------|
| `ui_wheel_bg.png` | 320×320 | Stone circle frame |
| `ui_wheel_wedge_highlight.png` | 160×160 | Ember selection wedge |
| `ui_wheel_lock_rune.png` | 32×32 | Locked spell overlay |
| `ui_spell_icon_{spell_id}.png` | 48×48 ×14 | One per spell |
| `ui_spell_icon_locked.png` | 48×48 | Grey silhouette template |

### 7.5 Waystone Menu

| Asset | Dimensions | Description |
|-------|------------|-------------|
| `ui_waystone_circle.png` | 400×400 | Travel UI backdrop |
| `ui_waystone_node_active.png` | 24×24 | Active destination |
| `ui_waystone_node_inactive.png` | 24×24 | Desaturated |
| `ui_waystone_travel_dissolve.png` | 960×540 | 1.5s transition overlay (8f) |

### 7.6 Main Menu

| Asset | Dimensions | Description |
|-------|------------|-------------|
| `ui_menu_logo_arcane.png` | 480×120 | ARCANIA logo plate |
| `ui_menu_button.png` | 200×40 | Menu item |
| `ui_menu_button_hover.png` | 200×40 | Ember underline state |
| `ui_menu_bg_parallax_0-2.png` | 960×540 each | Ashen Threshold slow parallax |

### 7.7 Shared Icons (32×32 inventory / 16×16 HUD)

| Set | Count | IDs |
|-----|-------|-----|
| Resource icons | 8 | weave_silk, memory_shard, ley_residue, focus_shard, essence, null_thread, nexus_filament, consumable |
| Equipment icons | 5 | robe tiers 1–5 |
| Relic icons | 24 | Per [06-magic-system.md](06-magic-system.md) relic table |
| Status icons | 6 | smolder, freeze, shock, overcast, silence, spirit |

### 7.8 Dialogue & System

| Asset | Dimensions | Description |
|-------|------------|-------------|
| `ui_dialogue_box.png` | 880×120 | Bottom dialogue panel |
| `ui_dialogue_portrait_frame.png` | 96×96 | NPC portrait |
| `ui_pause_panel.png` | 400×300 | Pause menu |
| `ui_settings_slider.png` | 120×8 | Options |
| `ui_bench_prompt.png` | 64×32 | Crucible interact |
| `ui_game_over.png` | 960×540 | Death screen frame |
| `ui_victory.png` | 960×540 | Ending screen frame |

**Total UI PNG estimate:** ~85 assets + 14 spell icons + 24 relic icons = **~123 files**

---

## 8. Audio Production

### 8.1 Sound Design Guide

| Principle | Spec |
|-----------|------|
| **Layering** | Exploration bed (loop) + region one-shot accents (randomized 30–90s) + combat percussion stem (crossfade in) |
| **Reverb per region** | See table below; send all SFX through `SFX` bus with region snapshot |
| **Dynamic mixing** | Priority: telegraph > player hurt > spell impact > enemy attack > ambient > music |
| **Sidechain** | Duck music −3 dB on heavy impacts / boss phase shifts |
| **Overcast** | Low-pass sweep + heartbeat sub when HP drain active |
| **Format** | OGG Vorbis 44.1 kHz; seamless loops ±10 ms |

#### Reverb Presets by Region

| Region | Reverb Type | Decay | Notes |
|--------|-------------|-------|-------|
| Ashen Threshold | Plate | 1.2s | Open foggy hub |
| Whisperwood | Forest IR | 0.8s | Short early reflections |
| Sunken Catacombs | Hall | 2.5s | Wet tail |
| Bleakfen Marsh | Dark room | 1.5s | Muffled |
| Lumineth Caverns | Crystal | 3.0s | Bright pre-delay |
| Archive of Echoes | Long hall | 2.8s | Paper rustle dry |
| Skyfall Ruins | Outdoor void | 0.6s + wind | Open air |
| Obsidian Atelier | Factory | 1.0s | Metallic early refs |
| Sanctum of Ash | Cathedral | 4.0s | Organ tail |
| Undercrown Kingdom | Cave | 2.0s | Fungal damp |
| Somnium Rift | Reverse hall | 1.8s | Uncanny |
| Ley Nexus | Infinite | 5.0s + mod | Cosmic |

### 8.2 Ambient Loops (12)

| Region | File | Duration | AI SFX Prompt |
|--------|------|----------|---------------|
| Ashen Threshold | `amb_01_threshold.ogg` | 60s loop | "Dark fantasy ambient soundscape, sparse piano notes, distant wind through ruins, soft ember crackle, melancholic 60 BPM, no drums, hollow reverb, game exploration loop" |
| Whisperwood | `amb_02_whisperwood.ogg` | 60s | "Sentient forest ambient, cello harmonics, breathy flute, leaf rustle foley, bioluminescent spore chimes, organic acoustic, seamless loop" |
| Sunken Catacombs | `amb_03_catacombs.ogg` | 60s | "Submerged gothic ambient, low pipe organ drone, water drip percussion, distant reversed choir, waist-deep echo, dark burial city" |
| Bleakfen Marsh | `amb_04_bleakfen.ogg` | 60s | "Swamp ambient 50 BPM, detuned banjo fragments, foghorn synth, sluggish water lap, will-o-wisp shimmer, memory-sinking wetland" |
| Lumineth Caverns | `amb_05_lumineth.ogg` | 60s | "Crystal cave ambient, glass percussion ticks, arpeggiated synth pads, prismatic shimmer, beautiful dangerous cavern, 75 BPM" |
| Archive of Echoes | `amb_06_archive.ogg` | 60s | "Living library ambient, page-turn foley, soft harpsichord, whispered Latin-like vocals, ink river flow, candle crackle" |
| Skyfall Ruins | `amb_07_skyfall.ogg` | 60s | "Celestial tragedy ambient, soaring strings with silence gaps, wind howl, distant thunder, floating debris creaks, void exposure" |
| Obsidian Atelier | `amb_08_atelier.ogg` | 60s | "Industrial dark forge ambient, furnace roar bed, hammer distant strikes, molten bubble, ash snow hiss, 84 BPM mechanical" |
| Sanctum of Ash | `amb_09_sanctum.ogg` | 60s | "Sacred fire cathedral ambient, organ dirge low, eternal ash fall hiss, degraded Gregorian chant static, pyre crackle" |
| Undercrown Kingdom | `amb_10_undercrown.ogg` | 60s | "Subterranean fungal kingdom ambient, fungal bass pulse, distorted courtly waltz fragment, spore crackle, bioluminescent hum" |
| Somnium Rift | `amb_11_somnium.ogg` | 60s | "Dream rift wrong ambient, time signature shifts, reversed piano samples, corrupted lullaby, static pixel bursts, surreal" |
| Ley Nexus | `amb_12_nexus.ogg` | 60s | "Cosmic ley nexus ambient, silence as instrument, low ley hum baseline, geometric void resonance, all motifs fragmenting, infinite reverb" |

### 8.3 Spell Sounds (14 × 3 = 42 files)

Naming: `sfx_{spell_id}_{cast|travel|impact}.ogg`

| Spell ID | Cast Prompt | Travel/Loop Prompt | Impact Prompt |
|----------|-------------|-------------------|---------------|
| `ember_sigil` | "Short fire rune whoosh, ember crack, 0.3s, bright transient" | "Wavering ember projectile hum, cinder trail" | "Fire sigil bloom impact, sizzle, warm" |
| `veil_step` | "Static dissolve tear, cloth rip, grey-violet" | "Phase silence gap 0.2s" | "Vertical reappear pop, subtle cyan ping" |
| `rune_anchor` | "Golden chain rune throw, metallic clink" | "Chain rattle tension loop" | "Anchor embed thunk + pulse" |
| `crystal_bridge` | "Crystal eruption crack, frost harmonic" | "Hex walkway hum loop" | "Bridge solidify shimmer" |
| `spirit_form` | "Ectoplasm dissolve, sigh" | "Ghostly wisp loop, low" | "Spirit exit pop / barrier pass whisper" |
| `ley_sight` | "Gold scan line activate, glass tone" | "Wireframe pulse loop" | "Reveal chime on secret found" |
| `temporal_echo` | "Clock wind, reverse tick" | "Amber timeline ripple loop" | "Rewind snap + mechanism clunk" |
| `shadow_blink` | "Shadow flatten slap" | "Ground streak whoosh" | "Erupt upward burst, purple" |
| `arcane_bulwark` | "Hex panel tessellate, harmonic chord" | "Shield hum loop" | "Glass shatter on block" |
| `frost_bind` | "Ice crystal grow crack" | "Frost spread crunch loop" | "Freeze shatter radial" |
| `storm_lash` | "Coil charge whine" | "Lightning arc crackle loop" | "Chain fork zap + pool electrify" |
| `sigil_recall` | "Recall rune stamp, thread ping" | "Fold dissolve weave sound" | "Anchor arrival star chime" |
| `unravel` | "Silk tear, thread pull" | "Unspool loop" | "Ward collapse motes fade" |
| `world_thread` | "Cosmic seam rip, low boom" | "Stardust walk loop" | "Thread attach lock, nexus tone" |

### 8.4 Enemy Vocalization Families (8)

Shared pools — 3–5 variants each: `telegraph`, `attack`, `hurt`, `death`

| Family | IDs (representative) | Vocal Character | AI Prompt |
|--------|---------------------|-----------------|-----------|
| Ash/undead | E-01–E-11 | Hollow whisper, ember hiss | "Undead creature vocalizations, hollow whispers, ash hiss, no gore, dark fantasy game SFX pack" |
| Forest/thorn | E-03,E-07,E-12,E-15,E-18 | Chitin skitter, sap pop | "Forest creature skitters, chitin clicks, sap pops, thorn snaps, organic insectoid" |
| Water/marsh | E-05,E-10,E-13,E-19,E-22 | Bubbling gurgle, wet slap | "Swamp creature gurgles, mud bubbles, water slaps, drowned moans muffled" |
| Crystal/archive | E-17,E-21,E-24,E-30 | Glass ping, page flutter | "Crystal chimed hits, glass stress, paper flutter, ink splash" |
| Sky/lab | E-28,E-34,E-35,E-38 | Wind shriek, metal clang | "Wind creature shrieks, metal clang impacts, forge clangs, mechanical strain" |
| Cathedral | E-20,E-41,E-52 | Chant fragment, chain rattle | "Corrupted holy chant snippets, chain armor, pyre roar" |
| Underground/knight | E-42,E-43,E-51,E-55 | Heavy plate, horn muffled | "Armored knight grunts, plate footsteps, muffled horn, root crunch" |
| Dream/void | E-44–E-49 | Reverse speech, static burst | "Dream creature reversed speech glitches, static bursts, void hum, unsettling" |

### 8.5 UI Sounds (12)

| File | Trigger |
|------|---------|
| `ui_menu_open.ogg` | Pause / menu open |
| `ui_menu_close.ogg` | Resume |
| `ui_menu_select.ogg` | Cursor move |
| `ui_menu_confirm.ogg` | Confirm |
| `ui_map_open.ogg` | Map screen |
| `ui_map_close.ogg` | Map close |
| `ui_inventory_open.ogg` | Inventory |
| `ui_relic_equip.ogg` | Relic slot |
| `ui_spell_wheel_open.ogg` | Spell wheel |
| `ui_spell_select.ogg` | Spell highlight |
| `ui_waystone_travel.ogg` | Fast travel start |
| `ui_shard_pickup.ogg` | Focus shard / pickup |

### 8.6 Boss Sounds (19 sets)

Each boss: `{id}_intro`, `{id}_phase_shift`, `{id}_stagger`, `{id}_death` + per-attack SFX from [05-boss-bible.md](05-boss-bible.md) Music/SFX notes.

| ID | Signature SFX |
|----|---------------|
| MB-01 | Sap hiss lash, root creak, Thornbound choir note death |
| MB-02 | Ceramic crack, urn splash, beam harmonic |
| MB-03 | Mud bubble, whisper lure, drain suck |
| MB-04 | Crystal ping beam, shatter cascade |
| MB-05 | Drawer slam, card slice, book spine crack |
| MB-06 | Bridge creak, bell toll, fall whistle |
| MB-07 | Anvil ring, vent whoosh, cool hiss |
| MB-08 | Quill scratch, fire roar, scatter whisper |
| MB-09 | Static crackle, null harmonic |
| MB-10 | Element-specific; unravel string snap |
| BOSS-01 | Chain clink, root snap, rune lock grant |
| BOSS-02 | Page flip, stamp thud, glass sight grant |
| BOSS-03 | Whale moan, ice crack, bridge hum |
| BOSS-04 | Coil whine, thunder crack, overload siren |
| BOSS-05 | Ectoplasm drip, snap click, dissolve sigh |
| BOSS-06 | Sermon verbals, shield harmonic, ashfall hush |
| BOSS-07 | Root crunch, ice crystallize, bury thud |
| BOSS-08 | Thread snap, clock tick, unspool reverse cymbal |
| BOSS-FINAL | Conclave chorus merge, thread rip, ending branch stingers |

### 8.7 Footstep Surfaces (8)

| Surface ID | Regions | File | AI Prompt |
|------------|---------|------|-----------|
| `footstep_ash` | Ashen Threshold, Sanctum | `sfx_footstep_ash_{1-4}.ogg` | "Soft ash footstep crunches, 4 variations, dark fantasy" |
| `footstep_stone` | Catacombs, Archive, Skyfall | `sfx_footstep_stone_{1-4}.ogg` | "Stone footstep clacks, wet and dry variants" |
| `footstep_wood` | Whisperwood, Bleakfen stilts | `sfx_footstep_wood_{1-4}.ogg` | "Creaky wood plank footsteps, hollow" |
| `footstep_moss` | Whisperwood, Undercrown | `sfx_footstep_moss_{1-4}.ogg` | "Muffled moss soft steps" |
| `footstep_water` | Catacombs flooded, Bleakfen | `sfx_footstep_water_{1-4}.ogg` | "Shallow water wading splashes" |
| `footstep_crystal` | Lumineth | `sfx_footstep_crystal_{1-4}.ogg` | "Crystal tile glassy taps" |
| `footstep_metal` | Atelier, Skyfall bridges | `sfx_footstep_metal_{1-4}.ogg` | "Metal grating footsteps" |
| `footstep_void` | Somnium, Ley Nexus | `sfx_footstep_void_{1-4}.ogg` | "Ethereal muted steps, reverse reverb tail" |

### 8.8 Player Combat SFX (supplement)

| Category | Files | Count |
|----------|-------|-------|
| Melee whoosh | `sfx_melee_swish_{1-3}.ogg` | 3 |
| Melee impact | `sfx_melee_hit_{1-3}.ogg` | 3 |
| Player hurt | `sfx_player_hurt_{1-3}.ogg` | 3 |
| Overcast | `sfx_overcast_{heartbeat,snap,gasp}.ogg` | 3 |
| Dash | `sfx_dash.ogg` | 1 |
| Death | `sfx_player_death.ogg` | 1 |

---

## 9. Music Production

### 9.1 Style Guide — Chiptune-Orchestral Hybrid

| Element | Direction |
|---------|-----------|
| **Foundation** | NES-style pulse + triangle bass lines (chiptune) at low mix (−12 dB) |
| **Orchestration** | Live strings, solo voice, glass harmonica, cello — primary melody carriers |
| **Harmony** | Minor keys; modal interchange; region leitmotifs share 4-note "Weave" motif (C–Eb–F–G) |
| **Combat** | Stem layers: `drums`, `bass`, `melody`, `accent` — crossfade 0.5s on aggro |
| **Boss Phase 2** | Add dissonant counter-melody + detuned chip layer per [01-gdd.md](01-gdd.md) |
| **Tempo range** | Exploration 50–80 BPM · Combat 90–120 BPM · Boss variable |
| **Export** | OGG + optional WAV stems for Godot `AudioStreamPlaylist` |

### 9.2 Region Themes (12) — Suno/Udio Prompts

| # | Region | File | Tempo | Key | Instrumentation | Arc |
|---|--------|------|-------|-----|-----------------|-----|
| 01 | Ashen Threshold | `mus_01_threshold.ogg` | 60 | D minor | Sparse piano, distant wind, sub pad, chip triangle | Opens lone piano → wind layer → faint choir at 0:45 (post-Ley Sight callback) |
| 02 | Whisperwood | `mus_02_whisperwood.ogg` | 72 | A minor | Cello harmonics, breathy flute, rustle foley, soft strings | Organic swell → combat staccato strings at 1:00 → resolve to solo flute |
| 03 | Sunken Catacombs | `mus_03_catacombs.ogg` | 66 | E minor | Pipe organ drone, glass marimba, reversed choir pad | Submerged intro → clockwork motif 0:30 → gothic peak → drip outro |
| 04 | Bleakfen Marsh | `mus_04_bleakfen.ogg` | 50 | G minor | Detuned banjo, foghorn synth, heartbeat bass, sluggish drums | Blues ambient → Miremother heartbeat layer → whisper peak → fade to fog |
| 05 | Lumineth Caverns | `mus_05_lumineth.ogg` | 75 | F# minor | Glass percussion, arp synth, strings, chip arpeggio | Crystalline build → sharp staccato combat middle → shimmer decay |
| 06 | Archive of Echoes | `mus_06_archive.ogg` | 76 | C minor | Harpsichord, whisper vocals, page-turn percussion, strings | Library calm → polyrhythm chaos mid → stampede percussion → harpsichord solo outro |
| 07 | Skyfall Ruins | `mus_07_skyfall.ogg` | 68 | B minor | Soaring strings, silence gaps, thunder, brass stabs | Celestial theme → void silence breaks → orchestra peak → hub motif inversion |
| 08 | Obsidian Atelier | `mus_08_atelier.ogg` | 84→130 | D minor | Hammer percussion, distorted brass, chip noise, industrial drums | Forge rhythm → tempo escalation 90→130 → cool-down anvil outro |
| 09 | Sanctum of Ash | `mus_09_sanctum.ogg` | 72 | G minor | Organ, ash hiss sample, degraded chant, choir | Organ dirge → dynamic swells → silence vs choir duel → ember resolve |
| 10 | Undercrown Kingdom | `mus_10_undercrown.ogg` | 58 | E minor | Fungal bass, distorted waltz, spore crackle, horns | Courtly waltz → organic percussion → two-phase human/alien motif shift |
| 11 | Somnium Rift | `mus_11_somnium.ogg` | Variable | Ab minor | Wrong-time jazz, reversed hub theme, solo piano, static | Lullaby corrupt → Mirror Elara piano duel section → full distortion climax |
| 12 | Ley Nexus | `mus_12_nexus.ogg` | Free | Chromatic | Ley hum, all region motifs fragmented, silence, cosmic pad | Motif collage → tear apart → void → post-victory solo violin tag |

**Example Suno/Udio block (Region 01):**
```
[Style: dark fantasy chiptune orchestral hybrid, metroidvania exploration]
[Tempo: 60 BPM] [Key: D minor]
[Instruments: sparse felt piano, distant wind, NES triangle bass soft, cello pad]
[Arc: melancholic opening 30s, add wind layer 30s, subtle choir callback 45s, loop seamless]
[Mood: safe hub, ember fog, pilgrim ruins, not combat]
```

### 9.3 Boss Themes (9)

| File | Boss | Tempo | Key | Notes |
|------|------|-------|-----|-------|
| `mus_boss_01_root_warden.ogg` | BOSS-01 | 68 | D minor | Deep drum + chain rhythm; Phase III choir of trapped names |
| `mus_boss_02_archivist.ogg` | BOSS-02 | 76 | C minor | Harpsichord + tape hiss; offer motif = induction theme |
| `mus_boss_03_leviathan.ogg` | BOSS-03 | 64 | F# minor | Glass orchestra swell; Phase III full choir |
| `mus_boss_04_magister.ogg` | BOSS-04 | 82 | B minor | Thunder percussion unstable; Phase III no downbeat |
| `mus_boss_05_subject_ix.ogg` | BOSS-05 | 62 | E minor | Heartbeat bass + reversed speech |
| `mus_boss_06_cardinal.ogg` | BOSS-06 | 72 | G minor | Organ + fire; Phase III full organ chord |
| `mus_boss_07_undercrown.ogg` | BOSS-07 | 58 | E minor | Fungal drone + regal horn; Phase 0 martial snare |
| `mus_boss_08_somnium.ogg` | BOSS-08 | Variable | Ab minor | Dream jazz wrong; Mirror duel piano; Weaver distortion |
| `mus_boss_final_unbound.ogg` | BOSS-FINAL | Free | Chromatic | All leitmotifs 8-bar rotation; Phase II polyphony clash; phase-synced to player casts |

Mini-bosses use region combat stem + boss SFX; no dedicated full tracks except optional 30s intro stingers (`mus_mb_{id}_intro.ogg`).

### 9.4 Stingers

| File | Duration | Prompt |
|------|----------|--------|
| `mus_stinger_main_menu.ogg` | 15s | "ARCANIA title stinger, ember motif, solo violin + chip chime, dark fantasy logo reveal" |
| `mus_stinger_death.ogg` | 8s | "Player death stinger, sigil dim, piano drop D minor, thread snap, no hope" |
| `mus_stinger_victory.ogg` | 12s | "Victory stinger, hub theme restored fragment, solo violin rise, weave motif resolved" |

---

## 10. Production Priority Order

Build order aligned with vertical slice → early → mid → late → endgame. **Phase 0–3 first** (below); Phases 4–5 deferred.

### Phase 0 — Vertical Slice (Playable Demo)

| Priority | Assets |
|----------|--------|
| P0.1 | Elara: `idle`, `walk`, `run`, `jump`, `fall`, `hit`, `death`, `melee_1`, `cast_ember_sigil`, `dash` |
| P0.2 | Spell VFX + SFX: `ember_sigil` only |
| P0.3 | Enemies: E-01, E-02, E-04, E-08 (full clip sets) |
| P0.4 | Region 01 environment: tileset + parallax 0–2 + props core |
| P0.5 | UI: HUD bars, minimap frame, spell slot ×1, dialogue box |
| P0.6 | Audio: `amb_01_threshold`, footstep_ash, footstep_stone, core UI confirm/select |
| P0.7 | Music: `mus_01_threshold`, `mus_stinger_main_menu` |
| P0.8 | MB-01 Thornweft Matron (arena + boss clips + music stinger) |

### Phase 1 — Early Game (Regions 02–04)

| Priority | Assets |
|----------|--------|
| P1.1 | Elara: remaining core locomotion, `veil_step`, `melee_2/3`, `interact` |
| P1.2 | Spells: `veil_step`, `rune_anchor`, `crystal_bridge`, `frost_bind` cast clips + VFX + SFX |
| P1.3 | Regions 02–04: full environment packs |
| P1.4 | Enemies: E-03, E-05–E-07, E-09–E-16, E-18, E-19, E-22 (Whisperwood/Catacombs/Bleakfen roster) |
| P1.5 | Mini-bosses: MB-01–MB-03 complete |
| P1.6 | Major boss: BOSS-01 Root Warden |
| P1.7 | UI: spell wheel, map screen, waystone menu |
| P1.8 | Music: regions 02–04 + `mus_boss_01` |
| P1.9 | Footsteps: wood, moss, water |

### Phase 2 — Mid Game (Regions 05–08)

| Priority | Assets |
|----------|--------|
| P2.1 | Spells: `spirit_form`, `ley_sight`, `temporal_echo`, `shadow_blink`, `arcane_bulwark`, `storm_lash`, `sigil_recall` |
| P2.2 | Elara: `elara_spirit` set, all spell cast clips |
| P2.3 | Regions 05–08 environments |
| P2.4 | Enemies: E-17, E-20–E-21, E-23–E-40 (mid-region roster) |
| P2.5 | Mini-bosses: MB-04–MB-07 |
| P2.6 | Major bosses: BOSS-02–BOSS-05 |
| P2.7 | UI: inventory/relic screen, full icon sets |
| P2.8 | Music: regions 05–08 + boss tracks 02–05 |
| P2.9 | All hit/death VFX + enemy vocalization families 1–5 |

### Phase 3 — Late / Endgame (Regions 09–12)

| Priority | Assets |
|----------|--------|
| P3.1 | Spells: `unravel`, `world_thread` |
| P3.2 | Regions 09–12 environments |
| P3.3 | Enemies: E-41–E-55 (elites + endgame) |
| P3.4 | Mini-bosses: MB-08–MB-10 |
| P3.5 | Major bosses: BOSS-06–BOSS-08 |
| P3.6 | BOSS-FINAL full clip set + ending sequences |
| P3.7 | Music: regions 09–12 + boss tracks 06–09 + victory/death stingers |
| P3.8 | Remaining UI (game over, victory), all relic icons |
| P3.9 | Vocalization families 6–8, all boss SFX sets |

### Phase 4 — Polish (Post-Content Complete)

Variant skins, regional enemy remix tints, accessibility palette swaps, 2× UI export, optional region death VFX variants.

### Phase 5 — Launch Buffer

Performance LOD parallax, audio mix pass, missing one-shot foley, achievement icons, marketing key art exports.

---

## 11. Naming Conventions

### 11.1 General Rules

- **Lowercase snake_case** for all file names
- **IDs match design docs:** enemy `e{nn}_`, boss `mb{nn}_` / `boss_{nn}_` / `boss_final_`, spell = magic system ID
- **No spaces or special characters** except underscore
- **Frame indices:** zero-padded 2 digits: `_01`, `_02`
- **Side suffix** where needed: `_l`, `_r`
- **Source + Godot resource:** co-locate `*.png` + `*.tres` (e.g. `elara_sheet.png` + `elara_sheet.tres`)

### 11.2 Path Templates

```
assets/
  characters/elara/
    elara_core.png
    elara_core.tres
    elara_combat.png
    elara_spells.png
    elara_spirit.png
  enemies/e{nn}_{snake_name}/
    e{nn}_sheet.png
    e{nn}_sheet.tres
  bosses/{boss_id}_{snake_name}/
    {boss_id}_{clip}.png          # large clips separate
    {boss_id}_sheet.tres
  environments/{rr}_{region_snake}/
    tileset.png
    props.png
    props_destructible.png
    parallax_{layer}_{name}.png
  vfx/spells/vfx_{spell_id}.png
  vfx/hits/vfx_hit_{type}.png
  vfx/ambient/vfx_amb_{rr}_{name}.png
  ui/hud/ui_hud_{element}.png
  ui/icons/ui_spell_icon_{spell_id}.png
  ui/icons/ui_relic_{relic_snake}.png
  audio/amb/amb_{rr}_{name}.ogg
  audio/sfx/spells/sfx_{spell_id}_{phase}.ogg
  audio/sfx/boss/{boss_id}_{event}.ogg
  audio/music/mus_{category}_{name}.ogg
  fonts/{name}.ttf
```

### 11.3 Examples

| Asset | Filename |
|-------|----------|
| Elara run frame 3 | `elara_core.png` atlas region or `elara_run_03.png` |
| Ash Wisp death | `e01_ash_wisp/e01_sheet.png` clip `death` |
| Thornweft Matron vine lash | `mb01_thornweft_matron/mb01_atk_vine_lash_l.png` |
| Root Warden | `boss_01_root_warden/boss_01_phase2_merge.png` |
| Whisperwood parallax | `02_whisperwood_hollow/parallax_2_midfar_canopy.png` |
| Ember Sigil VFX | `vfx/spells/vfx_ember_sigil.png` |
| Spell icon | `ui/icons/ui_spell_icon_ember_sigil.png` |
| Region 04 ambient | `audio/amb/amb_04_bleakfen.ogg` |

### 11.4 Animation Clip IDs (Godot `SpriteFrames`)

Pattern: `{entity}_{action}` — e.g. `elara_idle`, `e01_patrol`, `mb01_atk_vine_lash_l`, `boss_01_spell_grant`

**Speed scale:** `animation_fps / game_step_fps` — e.g. 12 FPS anim on 60 FPS game = `speed_scale` 1.0 with 5 tick hold per frame.

---

## Appendix — Cross-Document References

| Topic | Document |
|-------|----------|
| Visual style & export | [03-art-bible.md](03-art-bible.md) |
| Enemy stats & AI | [04-enemy-bible.md](04-enemy-bible.md) |
| Boss phases & attacks | [05-boss-bible.md](05-boss-bible.md) |
| Spell mechanics | [06-magic-system.md](06-magic-system.md) |
| Region lore & room counts | [02-world-design.md](02-world-design.md) |
| Godot audio buses & import | [08-technical-architecture.md](08-technical-architecture.md) |
| GDD audio summary | [01-gdd.md](01-gdd.md) §10 |

---

*Document version 1.0 — production-ready asset list for Arcania solo development.*

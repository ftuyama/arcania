# 04 — Enemy Bible

> *"Every creature in Arcania is a sentence the world forgot to finish."*
> — Index marginalia, Archive of Echoes

This document defines all **55 standard enemy types** in Arcania: **40 normal enemies (E-01–E-40)** and **15 elite enemies (E-41–E-55)**. IDs, names, and regional roles match [02-world-design.md](02-world-design.md). Stats assume Elara at region-appropriate power; see [06-magic-system.md](06-magic-system.md) for spell counters.

**Cross-references:** Boss phases → [05-boss-bible.md](05-boss-bible.md) · Art palettes → [03-art-bible.md](03-art-bible.md) · AI implementation → [08-technical-architecture.md](08-technical-architecture.md)

---

## Table of Contents

1. [Design Philosophy](#design-philosophy)
2. [Telegraph Standards](#telegraph-standards)
3. [Elite Modifier Rules](#elite-modifier-rules)
4. [Normal Enemies (E-01–E-40)](#normal-enemies-e-01e-40)
5. [Elite Enemies (E-41–E-55)](#elite-enemies-e-41e-55)
6. [Appendix — Regional Distribution](#appendix--regional-distribution)

---

## Design Philosophy

Arcania enemies exist to **teach, test, and texture** — never to inflate HP bars. Each family reinforces a region's fantasy and introduces a combat verb the player will need later at higher fidelity.

| Principle | Implementation |
|-----------|----------------|
| **Readability first** | Silhouette distinct at 48px; one primary attack color per family |
| **Dual-purpose counters** | Every enemy weak to ≥1 spell the region teaches or rewards |
| **Ambient vs. combat** | Swarm/fodder enemies (E-01, E-07, E-24) chip and crowd; solo enemies telegraph heavily |
| **Regional remix** | Shared IDs (E-02, E-14, E-17) gain variant stats/attacks in new biomes — same ID, new `variant` flag |
| **Poise economy** | Normals stagger at 30% HP; elites use poise meter (see Elite Rules) |
| **Lore through behavior** | Undead repeat last action; dream enemies mirror player inputs; void enemies ignore physics |

**Enemy families:** ash/undead · forest/thorn · water/marsh · crystal · archive/ghost · sky/wind · lab/construct · cathedral/holy-corrupted · underground/knight · dream/ethereal · void/unbound

**Spawn density:** Early regions 2–4 enemies per room; mid 3–5; late 4–6; Nexus corridors 1 elite + 2 normals max (clarity over chaos).

---

## Telegraph Standards

All attacks use a **three-layer telegraph** so players can learn once and apply everywhere.

| Layer | Visual | Audio | Timing |
|-------|--------|-------|--------|
| **Intent** | Eye glow / posture shift | 880 Hz ping | T−0.5s (fast) / T−0.8s (slow) |
| **Commit** | Wind-up color fill (family hue) | Rising tone | T−0.3s |
| **Strike** | White flash + hitbox active | Impact stinger | T−0 |

**Wind-up colors by family:**

| Family | Color | Hex |
|--------|-------|-----|
| Ash/undead | Ember orange | `#FF6B35` |
| Forest/thorn | Moss green | `#52B788` |
| Water/marsh | Fen cyan | `#B1FAFF` |
| Crystal | Prism violet | `#E0AAFF` |
| Archive/ghost | Ink blue | `#90E0EF` |
| Sky/wind | Star gold | `#E9C46A` |
| Lab/construct | Forge red | `#DC2F02` |
| Cathedral/holy-corrupted | Blood ember | `#E5383B` |
| Underground/knight | Crown crimson | `#D90429` |
| Dream/ethereal | Dream pink | `#C77DFF` |
| Void/unbound | Ley magenta | `#FF0099` |

**Floor markers:** Melee = arc wedge; line = lunge/beam; circle = AoE; dashed = feint (no damage).

**Timing tiers:** **Quick** 0.3s · **Medium** 0.5s · **Heavy** 0.8s · **Ultimate** 1.2s (elites/bosses only).

**Dodge window:** i-frames from Veil Step/Arc Step overlap commit frame; designed so Medium telegraphs are fair on 60 FPS with 8-frame input buffer.

---

## Elite Modifier Rules

Elites (E-41–E-55) and **field-elite spawns** (golden aura on any normal) share these rules:

| Modifier | Value |
|----------|-------|
| HP multiplier | ×2.5 (normals) / custom table (named elites) |
| Damage multiplier | ×1.35 |
| XP / Essence | ×2.5 (named elites ×3) |
| Poise | 100 (stagger only after full poise break) |
| Aura | Rotating gold ring + family color core |
| Extra attack | +1 unique pattern not in normal kit |
| Drop bonus | +15% relic shard chance (where applicable) |

**Field-elite spawn:** 1 per designated loop in world doc (e.g., E-08 Threshold Shade patrol). Respawns on rest.

**Named elite IDs (E-41–E-55):** Fixed encounters, optional arenas, or secret-zone guards. Do not randomize.

**World-design elevation map** (normal ID → elite ID for optional hunts):

| Normal | Elite counterpart |
|--------|-------------------|
| E-08 Threshold Shade | E-52 Threshold Shade Ascendant |
| E-18 Canopy Hunter | E-53 Canopy Hunter Brood-Matriarch |
| E-22 Fenbound Zealot | E-54 Fenbound Hierophant |
| E-36 Starfall Knight | E-55 Starfall Knight Praetorian |
| E-28 Void Leaper (regional) | E-50 Fen Colossus (marsh/underground) |
| E-35 Slag Crawler (regional) | E-51 Crown Devourer (underground) |

---

## Normal Enemies (E-01–E-40)

---

### E-01 — Ash Wisp

| Field | Detail |
|-------|--------|
| **ID** | E-01 |
| **Name** | Ash Wisp |
| **Region(s)** | Ashen Threshold |
| **Family** | ash/undead |

**Concept:** Floating ember motes that swarm the hub fog, teaching dodge timing without lethal pressure.

**Lore:** When the Ashbound immolated at the Sundering scar edge, their final breaths did not rise — they pooled in the Threshold fog as hungry sparks. Ash Wisps are not souls; they are *heat with habit*, circling braziers they once tended. They attack anything warmer than the fog.

**Behavior (AI states):** `Drift` → `Cluster` (near player) → `Flicker` (wind-up) → `Lunge` → `Scatter` (on hit) → return `Drift`.

**Attack patterns:**
1. **Ember Nip** — Quick lunge 1 tile; T−0.3s orange pinprick flash. 8 dmg.
2. **Swarm Cloud** (3+ wisps) — Medium AoE pulse; T−0.5s fog thickens. 5 dmg/tick × 3.
3. **Heat Seek** — Slow homing drift; no telegraph; 4 contact dmg/sec.

**Weaknesses:** Ember Bolt (1-shot), Kindling Ward aura (repel 2 tiles), melee swipe (low poise).

**Visual design:** 16px core `#FF6B35`, trailing ash particles `#4A4E69`, faint Veilmark sigil in core (barely visible).

**Animation requirements:**

| State | Frames @ 12fps loop |
|-------|---------------------|
| Idle | 6 |
| Patrol (drift) | 8 |
| Attack | 4 |
| Hit | 2 |
| Death | 8 (dissolve upward) |

**Stats:**

| HP | Damage | Speed | XP | Essence |
|----|--------|-------|-----|---------|
| 12 | 4–8 | 1.2 | 5 | 2 |

**Elemental affinity:** Fire (absorb 50% fire, weak to water ×1.5)

---

### E-02 — Bone Crawler

| Field | Detail |
|-------|--------|
| **ID** | E-02 |
| **Name** | Bone Crawler |
| **Region(s)** | Ashen Threshold, Sunken Catacombs (water variant) |
| **Family** | ash/undead |

**Concept:** Quadruped rib-cage beast patrolling ground routes; teaches melee timing and spacing.

**Lore:** Catacomb ossuaries collapsed into the Threshold during the Sundering, spilling catalogued bones whose memory-tags fused with stray ley. Bone Crawlers reassemble wrong — too many ribs, too few skulls — and patrol as if still guarding aisles that no longer exist.

**Behavior:** `Patrol` → `Alert` (player in range) → `Skitter` → `Snap` or `Pounce` → `Recoil` (armored front) → `Patrol`.

**Attack patterns:**
1. **Jaw Snap** — Medium bite forward 1.5 tiles; T−0.5s jaw unhinge glow. 14 dmg.
2. **Rib Rush** — Heavy dash 3 tiles; T−0.8s spine arch `#FF6B35`. 18 dmg + knockback.
3. **Water Lunge** *(Catacombs variant)* — Rises from water; T−1.0s ripple ring. 16 dmg + grab (0.5s).

**Weaknesses:** Rear flank ×1.5 dmg, Gleamflare reveals weak skull joint, Rootbind stops rush.

**Visual design:** Low horizontal silhouette; wet variant drips `#B1FAFF` algae; eye sockets = lantern cyan pinpoints.

**Animation requirements:**

| State | Frames |
|-------|--------|
| Idle | 6 |
| Patrol | 10 |
| Attack (snap/rush) | 8 / 12 |
| Hit | 3 |
| Death | 10 (collapse to pile) |

**Stats:** Threshold 40 HP / 14–18 dmg / 1.4 speed / 12 XP / 5 Essence · Catacombs 48 HP / 16 dmg / 1.8 speed / 15 XP / 6 Essence

**Elemental affinity:** Necrotic (immune bleed; weak holy/fire ×1.25)

---

### E-03 — Bramble Stalker

| Field | Detail |
|-------|--------|
| **ID** | E-03 |
| **Name** | Bramble Stalker |
| **Region(s)** | Whisperwood Hollow |
| **Family** | forest/thorn |

**Concept:** Bark-skinned ambusher camouflaged against trees; punishes inattentive pathing.

**Lore:** Thornweft gardeners bred Stalkers to cull invasive moths. When the Coven fell, the forest kept the breeding cycle — Stalkers now hatch from hollow bark without handlers, attacking anything that does not smell of sap.

**Behavior:** `Camouflage` (static, bark texture) → `Unfold` (trigger proximity) → `Stalk` → `Lunge` / `Thorn Whip` → `Re-Camouflage` (if lost LOS 3s).

**Attack patterns:**
1. **Ambush Unfold** — Quick claw swipe; T−0.3s bark crack SFX. 16 dmg surprise (+10 if from camouflage).
2. **Thorn Whip** — Medium 2-tile line; T−0.5s green `#52B788` vine glow. 12 dmg + slow 1s.
3. **Bark Shield** — Heavy block stance; T−0.8s; reflects one projectile; 0 dmg.

**Weaknesses:** Fire (Ember Bolt breaks shield), rear attacks during `Stalk`, Echo Sense reveals while camouflaged.

**Visual design:** 56px tall; indistinguishable from background until eyes open (`#95D5B2` bioluminescent slits).

**Animation requirements:**

| State | Frames |
|-------|--------|
| Idle (camouflaged) | 4 |
| Patrol | 8 |
| Attack | 10 |
| Hit | 3 |
| Death | 12 (splinters) |

**Stats:** 55 HP · 12–16 dmg · 1.3 speed · 18 XP · 8 Essence

**Elemental affinity:** Nature (weak fire ×1.5, resistant physical 0.8×)

---

### E-04 — Ember Moth

| Field | Detail |
|-------|--------|
| **ID** | E-04 |
| **Name** | Ember Moth |
| **Region(s)** | Ashen Threshold |
| **Family** | ash/undead |

**Concept:** Flying harasser drawing player upward into fog hazards; weak to Ember Bolt tutorial.

**Lore:** Moths drawn to Threshold braziers absorbed ember ash until their wings became kindling. They circle heat sources endlessly, mistaking Elara's Ember Sigil for a mating flare.

**Behavior:** `Orbit` (brazier/ player) → `Dive` → `Powder Scatter` → `Retreat Up`.

**Attack patterns:**
1. **Dive Bomb** — Medium diagonal dive; T−0.5s wing flare orange. 10 dmg + ignite 2 dmg/2s.
2. **Ash Powder** — Quick 1-tile cloud; T−0.3s; blinds 0.5s (screen edge vignette). 0 dmg.
3. **Contact Burn** — Passive while flying; 4 dmg/sec.

**Weaknesses:** Ember Bolt (instant kill), melee up-air, Kindling Ward blocks ignite.

**Visual design:** `#FF6B35` wing edges, charcoal body, ember dust trail particles.

**Animation requirements:** Idle 6 · Patrol 8 · Attack 6 · Hit 2 · Death 8

**Stats:** 18 HP · 4–10 dmg · 1.6 (air) · 8 XP · 3 Essence

**Elemental affinity:** Fire (absorb 25% fire; ×2 water)

---

### E-05 — Fen Leech

| Field | Detail |
|-------|--------|
| **ID** | E-05 |
| **Name** | Fen Leech |
| **Region(s)** | Bleakfen Marsh |
| **Family** | water/marsh |

**Concept:** Surface-skimming leech that latches and slows — introduces swim/wade movement tax.

**Lore:** Fen Leechs are the resurrection spell's failed vessels: they absorb memory instead of blood. A latched leech whispers a stranger's regret at 3 AM volume inside the victim's skull.

**Behavior:** `Skim` (water surface) → `Latch` (jump to wading player) → `Drain` → `Drop` (if hit) → `Skim`.

**Attack patterns:**
1. **Surface Skim** — Contact 6 dmg; no telegraph; applies slow 10%.
2. **Leap Latch** — Medium jump; T−0.5s water bulge. 8 dmg + latch (slow 40%, −2 mana/sec).
3. **Memory Spit** *(latched)* — Quick; T−0.3s; 5 dmg + screen desaturate 1s.

**Weaknesses:** Tidecaller drains spawn pools, Ember Bolt dries (kill), melee while latched (self-harm risk: 2 dmg to player if mistimed).

**Visual design:** Oil-slick black `#1A1A1D`, pale underbelly `#E8E8E8`, single white eye.

**Animation requirements:** Idle 4 · Patrol 6 · Attack 8 · Hit 2 · Death 6

**Stats:** 25 HP · 5–8 dmg · 1.5 water / 2.0 leap · 10 XP · 4 Essence

**Elemental affinity:** Water (weak lightning ×1.5 — Storm Lash if acquired late; fire ×1.25)

---

### E-06 — Grave Lantern

| Field | Detail |
|-------|--------|
| **ID** | E-06 |
| **Name** | Grave Lantern |
| **Region(s)** | Sunken Catacombs |
| **Family** | ash/undead |

**Concept:** Floating memory-orb that explodes on proximity — teaches spacing and ranged clearing.

**Lore:** Archivists stored final thoughts in ceramic lanterns. When urns cracked, memories leaked into the oil — lanterns now drift seeking bodies warm enough to receive a dead scholar's last sentence, then detonate when rejected.

**Behavior:** `Float` → `Approach` → `Pulse` (wind-up) → `Detonate` or `Flee` (if player retreats 4 tiles).

**Attack patterns:**
1. **Proximity Burst** — Heavy AoE 2 tiles; T−0.8s cyan `#B1FAFF` brightening. 22 dmg fire.
2. **Memory Beam** — Medium line 4 tiles; T−0.5s. 12 dmg + 1 Silence stack if hit during cast.
3. **Lantern Drift** — Contact 8 dmg; no telegraph.

**Weaknesses:** Kindling Ward blocks burst chip, Gleamflare stuns 1s, destroy at range before Pulse.

**Visual design:** Bone cage orb, cyan flame core, trailing whisper glyphs ( illegible at gameplay scale).

**Animation requirements:** Idle 8 · Patrol 10 · Attack 10 · Hit 2 · Death 14 (shatter + ink splash)

**Stats:** 30 HP · 8–22 dmg · 0.9 float · 14 XP · 6 Essence

**Elemental affinity:** Ghost/fire hybrid (weak Unravel ×1.5)

---

### E-07 — Mothling Swarm

| Field | Detail |
|-------|--------|
| **ID** | E-07 |
| **Name** | Mothling Swarm |
| **Region(s)** | Whisperwood Hollow |
| **Family** | forest/thorn |

**Concept:** Air-denial flock blocking jumps and spell arcs; weak to fire AoE.

**Lore:** Mothlings are pollinators the forest weaponized — spore carriers that choke sky paths. The Whisperwood directs swarms toward intruders by vibrating root-hum at mating frequency.

**Behavior:** `Swarm Idle` (single entity, 8–12 moths) → `Engulf` (surround player) → `Nibble` → `Scatter` (AoE hit) → reform.

**Attack patterns:**
1. **Engulf** — Medium; T−0.5s spore cloud; obscures 30% screen edge. 3 dmg/tick.
2. **Spore Dump** — Heavy downward; T−0.8s; ground puddle slow 2s. 10 dmg.
3. **Contact Cloud** — Passive in engulf; 5 dmg/sec max stack.

**Weaknesses:** Ember Bolt (scatter all), Kindling Ward, vertical escape (swarm slow to follow up shafts).

**Visual design:** `#D8F3DC` pale green motes, `#40916C` spore trails; reads as cloud not individual at distance.

**Animation requirements:** Idle 6 (loop) · Patrol 8 · Attack 6 · Hit 2 · Death 10 (dispersal)

**Stats:** 35 HP (swarm pool) · 3–10 dmg · 1.7 · 16 XP · 7 Essence

**Elemental affinity:** Nature (×2 fire, ×0.5 physical per hit — must scatter)

---

### E-08 — Threshold Shade

| Field | Detail |
|-------|--------|
| **ID** | E-08 |
| **Name** | Threshold Shade |
| **Region(s)** | Ashen Threshold, Sanctum of Ash (ember variant) |
| **Family** | ash/undead |

**Concept:** Elite-tier normal patrolling hub loops; tests full combo chains and dodge commitment.

**Lore:** Shades are oath-echoes — mages who died mid-vow at the Threshold. They repeat the last sword-form of their unfinished pledge, targeting anyone carrying a sigil that smells like broken promises (Veilmark blood).

**Behavior:** `Patrol` → `Challenge` (face player) → `Combo Chain` (2–3 hits) → `Phase Back` → `Special` → repeat. Sanctum variant leaves ember trail in `Phase Back`.

**Attack patterns:**
1. **Oath Slash** — Quick 1.5 tiles; T−0.3s blade orange trace. 16 dmg.
2. **Veil Thrust** — Medium lunge 2.5 tiles; T−0.5s silhouette solidifies. 20 dmg.
3. **Ember Wake** *(Sanctum)* — Heavy trail 3 tiles; T−0.8s; DoT 6/sec for 2s on path.

**Weaknesses:** Combo interruption stagger, Gleamflare reveals true position during phase, Arc Step through thrust.

**Visual design:** Semi-transparent charcoal, ember sword `#FF6B35`, Sanctum variant adds ash crown.

**Animation requirements:** Idle 8 · Patrol 10 · Attack 12 (3-hit chain) · Hit 3 · Death 14

**Stats:** Threshold 90 HP · 16–20 dmg · 1.5 · 35 XP · 15 Essence · Sanctum 110 HP · 18–24 dmg · 40 XP · 18 Essence

**Elemental affinity:** Shadow (weak Gleamflare ×1.5; see E-52 for true elite form)

---

### E-09 — Drowned Acolyte

| Field | Detail |
|-------|--------|
| **ID** | E-09 |
| **Name** | Drowned Acolyte |
| **Region(s)** | Sunken Catacombs |
| **Family** | ash/undead |

**Concept:** Rising grab from water — punishes wading without reading ripple telegraphs.

**Lore:** Acolytes who drowned during the water-table shift still perform immersion rites, pulling living flesh below to "complete the baptism." Their hymns bubble up before they strike.

**Behavior:** `Submerged` (hidden) → `Rise` → `Grab` → `Drown Hold` → `Submerge` (if broken) / `Slam` (if successful 1.5s).

**Attack patterns:**
1. **Rising Grab** — Heavy 1-tile grab; T−1.0s ripple + hymn ping. 12 dmg + hold 1.5s.
2. **Drown Slam** — Ultimate follow-up; T−0.3s after hold; 28 dmg if not broken.
3. **Bubble Spit** — Medium ranged; T−0.5s; 10 dmg + wet debuff (lightning vuln).

**Weaknesses:** Jump over ripple, Kindling Ward shortens hold, attack during rise (2× dmg window T−0.2s to T−0).

**Visual design:** Waterlogged robes `#495867`, glowing hymn-o `#B1FAFF` mouth, moss hair.

**Animation requirements:** Idle 4 (bubbles only) · Patrol N/A · Attack 14 · Hit 3 · Death 12 (sink)

**Stats:** 50 HP · 10–28 dmg · 1.2 rise · 20 XP · 9 Essence

**Elemental affinity:** Water/necrotic (weak lightning ×1.5)

---

### E-10 — Will-o-Mire

| Field | Detail |
|-------|--------|
| **ID** | E-10 |
| **Name** | Will-o-Mire |
| **Region(s)** | Bleakfen Marsh |
| **Family** | water/marsh |

**Concept:** Lure enemy leading player into hazards before detonating — tests discipline vs. curiosity.

**Lore:** Will-o-Mires are fermented regret-gas given flickering shape by fen methane. They mimic safe-path lantern light, leading travelers into deep pools where the marsh harvests another year of memory.

**Behavior:** `Lure` (retreat from player) → `Hover` (at hazard edge) → `Detonate` if player within 2 tiles of hazard OR `Flee` if attacked.

**Attack patterns:**
1. **Lure Pulse** — No dmg; bright flash attracts; psychological telegraph only.
2. **Mire Burst** — Heavy AoE 2.5 tiles; T−0.8s white core. 24 dmg + memory fog 2s.
3. **Afterimage** — Quick fake split; T−0.3s; 0 dmg; tests reaction.

**Weaknesses:** Mistveil reveals true path, ignore lure (no aggro if player doesn't follow 4 tiles), ranged kill before burst.

**Visual design:** `#E8E8E8` core, `#6B9080` corona, reflection wrong in water ( upside-down).

**Animation requirements:** Idle 6 · Patrol 8 (drift) · Attack 10 · Hit 2 · Death 8 (pop + fog)

**Stats:** 28 HP · 0–24 dmg · 1.3 · 18 XP · 8 Essence

**Elemental affinity:** Ghost/water (weak Gleamflare ×1.5)

---

### E-11 — Mosaic Serpent

| Field | Detail |
|-------|--------|
| **ID** | E-11 |
| **Name** | Mosaic Serpent |
| **Region(s)** | Sunken Catacombs |
| **Family** | ash/undead |

**Concept:** Corridor sweeper with long telegraphed lunge — teaches line-clearing and vertical dodge.

**Lore:** Catacomb floors were bone-mosaic art until ley fracture animated the patterns. Serpents are living tile arrangements — killing one scatters tiles that reassemble elsewhere over minutes (off-screen respawn).

**Behavior:** `Coiled` (blocks corridor) → `Track` (head follows player X) → `Lunge` → `Recoil` → `Coiled`.

**Attack patterns:**
1. **Corridor Lunge** — Heavy 5-tile line; T−0.8s mosaic glow `#C9ADA7`. 22 dmg.
2. **Tail Sweep** — Medium 180° arc behind; T−0.5s; 14 dmg (if player flanks).
3. **Tile Spit** — Quick projectile; T−0.3s; 8 dmg × 3 shards.

**Weaknesses:** Jump over lunge (i-frames), destroy head tile (Gleamflare ×1.5), Rootbind during recoil.

**Visual design:** Segmented bone hex tiles, cyan grout lines, head = urn fragment skull.

**Animation requirements:** Idle 6 · Patrol 4 (slide) · Attack 12 · Hit 3 · Death 16 (tile scatter)

**Stats:** 65 HP · 8–22 dmg · 1.0 coil / 2.5 lunge · 22 XP · 10 Essence

**Elemental affinity:** Earth/bone (weak blunt ×1.25 — third melee hit)

---

### E-12 — Bark Wraith

| Field | Detail |
|-------|--------|
| **ID** | E-12 |
| **Name** | Bark Wraith |
| **Region(s)** | Whisperwood Hollow |
| **Family** | forest/thorn |

**Concept:** Phasing enemy moving through trees — teaches tracking and prediction without constant vision.

**Lore:** Wraiths are gardeners who merged with bark during the Sundering to survive ley drain. They maintain the forest's grief-cycles, pruning intruders through trunks as if branches.

**Behavior:** `Phase` (inside tree) → `Emerge` → `Strike` → `Re-Phase` (to nearest tree within 5 tiles) → loop.

**Attack patterns:**
1. **Emergence Claw** — Quick 1-tile; T−0.3s bark burst. 14 dmg.
2. **Phase Lunge** — Medium through tree line; T−0.5s tree shudder warning. 18 dmg.
3. **Sap Bind** — Heavy root grab; T−0.8s; 10 dmg + root 1s.

**Weaknesses:** Echo Sense shows phase destination tree glow, Ember Bolt on emerge window, Rootbind punishes re-phase.

**Visual design:** Humanoid bark `#1B4332`, hollow eye holes with spore glow; visible as silhouette inside tree (darker patch).

**Animation requirements:** Idle 6 · Patrol 8 (phase travel) · Attack 10 · Hit 3 · Death 12

**Stats:** 58 HP · 10–18 dmg · 1.6 phase · 24 XP · 11 Essence

**Elemental affinity:** Nature/ghost (weak fire ×1.5)

---

### E-13 — Bog Maw

| Field | Detail |
|-------|--------|
| **ID** | E-13 |
| **Name** | Bog Maw |
| **Region(s)** | Bleakfen Marsh |
| **Family** | water/marsh |

**Concept:** Pit-trap predator — floor chomp from hidden mouth; teaches floor reading.

**Lore:** Bog Maws are not creatures but *places* — fen stomachs that grew teeth. Petrified Hollow Heart roots feed them regrets; they yawn when heavy memory crosses above.

**Behavior:** `Hidden` (floor texture) → `Tremor` → `Chomp` → `Chew` (multi-hit if standing) → `Close` → cooldown 4s.

**Attack patterns:**
1. **Ground Chomp** — Heavy 2-tile circle; T−0.8s mud bubble. 26 dmg.
2. **Chew** — Quick ticks; T−0.3s each; 8 dmg × 3 if not escaped.
3. **Spit Residue** — Medium after chew; T−0.5s; slow pool 3s. 0 dmg.

**Weaknesses:** Jump during Tremor, Stoneheart breaks floor anchor (kill), Tidecaller drains pit.

**Visual design:** Matches peat `#1A1A1D` until open — ring of teeth `#AEC3B0`, throat black.

**Animation requirements:** Idle 4 (closed) · Patrol N/A · Attack 10 · Hit 2 · Death 8

**Stats:** 70 HP · 8–26 dmg · 0 (static) · 25 XP · 12 Essence

**Elemental affinity:** Earth/water (weak pierce — down-thrust melee)

---

### E-14 — Urn Wraith

| Field | Detail |
|-------|--------|
| **ID** | E-14 |
| **Name** | Urn Wraith |
| **Region(s)** | Sunken Catacombs, Archive of Echoes (ink variant) |
| **Family** | ash/undead / archive/ghost |

**Concept:** Ranged memory-shard thrower; Archive variant adds ink splash slowing shelves.

**Lore:** When an urn shatters without its memory being archived, the leftover impression haunts the nearest ceramic. Urn Wraiths throw pieces of themselves — each shard a sentence that cuts.

**Behavior:** `Float` → `Aim` → `Throw` → `Retreat` → `Summon Shard` (regenerate 1 projectile every 5s).

**Attack patterns:**
1. **Memory Shard** — Medium arc projectile; T−0.5s arm glow. 12 dmg.
2. **Shard Burst** — Heavy 3-way spread; T−0.8s. 10 dmg × 3.
3. **Ink Splash** *(Archive)* — Medium pool; T−0.5s; 8 dmg + slow 2s + mana −5.

**Weaknesses:** Shield/Bulwark reflect, close pressure (slow melee), Gleamflare reveals aim true origin.

**Visual design:** Floating cracked urn torso, cyan memory wisps, Archive variant drips `#0077B6` ink.

**Animation requirements:** Idle 8 · Patrol 6 · Attack 8 · Hit 3 · Death 12

**Stats:** Catacombs 45 HP · 10–12 dmg · 0.8 · 18 XP · 8 Essence · Archive 52 HP · 8–10 dmg · 22 XP · 10 Essence

**Elemental affinity:** Ghost (weak Unravel ×1.5)

---

### E-15 — Thornweft Larva

| Field | Detail |
|-------|--------|
| **ID** | E-15 |
| **Name** | Thornweft Larva |
| **Region(s)** | Whisperwood Hollow |
| **Family** | forest/thorn |

**Concept:** Ranged silk spitter applying slow — sets up Canopy Hunter encounters.

**Lore:** Larvae are living Thornweft thread spools, bred to bind invasive species. Without Coven songs to command them, they bind everything that moves — storing wrapped prey in canopy pods for the Matron.

**Behavior:** `Crawl` (ceiling/floor) → `Anchor` → `Spit` → `Retreat` → `Pod Call` (alerts nearby E-18 if present).

**Attack patterns:**
1. **Silk Spit** — Medium 4-tile; T−0.5s throat swell green. 8 dmg + slow 30% 2s.
2. **Web Patch** — Heavy floor AoE; T−0.8s; 0 dmg + root 1.5s.
3. **Bite** — Quick melee if cornered; T−0.3s. 12 dmg.

**Weaknesses:** Fire clears webs, Arc Step out of patch, kill before Pod Call.

**Visual design:** Segmented caterpillar `#40916C`, silk `#D8F3DC` strands, visible pod sac on back.

**Animation requirements:** Idle 6 · Patrol 8 · Attack 8 · Hit 2 · Death 10

**Stats:** 40 HP · 8–12 dmg · 1.1 · 16 XP · 7 Essence

**Elemental affinity:** Nature (×1.5 fire)

---

### E-16 — Stilt Crawler

| Field | Detail |
|-------|--------|
| **ID** | E-16 |
| **Name** | Stilt Crawler |
| **Region(s)** | Bleakfen Marsh |
| **Family** | water/marsh |

**Concept:** Elevated patrol on rotting docks — forces platforming under ranged pressure.

**Lore:** Fenbound cultists who refused to leave their stilt-villages fused with their walking stilts during the memory-sink event. They patrol empty boardwalks, offering drowned prayers to the Miremother.

**Behavior:** `Stilt Walk` (elevated path) → `Spear Down` → `Stilt Kick` (if player below) → `Reposition`.

**Attack patterns:**
1. **Downward Spear** — Medium vertical 3 tiles; T−0.5s spear tip glint. 16 dmg.
2. **Stilt Stomp** — Heavy AoE below; T−0.8s board crack. 20 dmg + platform damage.
3. **Curse Spit** — Quick ranged; T−0.3s. 8 dmg + curse stack (slow 5% per stack, max 5).

**Weaknesses:** Rootbind stilts, destroy platform (enemy falls ×2 dmg), Mistveil clears curse.

**Visual design:** Long-legged `#4E5D5C` body, fen lantern mask, stilts = petrified wood.

**Animation requirements:** Idle 6 · Patrol 10 · Attack 10 · Hit 3 · Death 12

**Stats:** 55 HP · 8–20 dmg · 1.2 · 20 XP · 9 Essence

**Elemental affinity:** Water/curse (weak holy ×1.25 — Kindling Ward cleanses stacks)

---

### E-17 — Crystal Crawler

| Field | Detail |
|-------|--------|
| **ID** | E-17 |
| **Name** | Crystal Crawler |
| **Region(s)** | Lumineth Caverns, Undercrown Kingdom (fungal hybrid) |
| **Family** | crystal / underground |

**Concept:** Wall/ceiling mobility enemy — teaches 3D plane awareness in 2D space.

**Lore:** Solidified spell-residue insects that never completed their cast. Crawlers skitter along any surface, following ley warmth. Undercrown hybrids grow fungal caps that spore on death.

**Behavior:** `Surface Crawl` (any solid) → `Drop` → `Shard Bite` → `Climb` → reposition.

**Attack patterns:**
1. **Drop Attack** — Medium vertical; T−0.5s crystal crack sound. 18 dmg.
2. **Shard Bite** — Quick melee; T−0.3s jaw prism flash. 14 dmg + bleed 3 dmg/2s.
3. **Spore Burst** *(Undercrown)* — Death-trigger OR Heavy; T−0.8s; poison cloud 3s. 10 dmg.

**Weaknesses:** Weightless evade drop, blunt melee shatters carapace (×1.5), Ember Bolt melts small ones.

**Visual design:** `#7B2CBF` crystal legs, `#E0AAFF` refraction highlights; fungal variant adds `#8D99AE` cap.

**Animation requirements:** Idle 6 · Patrol 10 (multi-surface) · Attack 8 · Hit 3 · Death 10

**Stats:** Lumineth 60 HP · 14–18 dmg · 1.8 · 28 XP · 12 Essence · Undercrown 72 HP · 16–20 dmg · 32 XP · 14 Essence

**Elemental affinity:** Crystal (weak sonic/stun — third combo hit; ×1.5 Unravel)

---

### E-18 — Canopy Hunter

| Field | Detail |
|-------|--------|
| **ID** | E-18 |
| **Name** | Canopy Hunter |
| **Region(s)** | Whisperwood Hollow |
| **Family** | forest/thorn |

**Concept:** Elite-tier jumper mini-boss prelude; aggressive aerial predator guarding canopy nest.

**Lore:** Hunters are Thornweft Larvae that survived three molts without binding prey — the forest promotes them to apex status. The Canopy Nest optional fight (world doc) features one alpha Hunter brooding a pod of Veilmark-era artifacts.

**Behavior:** `Perch` → `Leap` → `Slash Combo` (2 hits) → `Wall Kick` → `Perch` (high). Enters `Enrage` below 40% HP (+speed).

**Attack patterns:**
1. **Canopy Leap** — Heavy 4-tile arc; T−0.8s wing spread. 22 dmg landing shockwave.
2. **Double Slash** — Medium ×2; T−0.5s each. 16 dmg per hit.
3. **Pod Summon** — Ultimate; T−1.2s; spawns 2× E-15 at 50% HP once per fight.

**Weaknesses:** Arc Step dodge leap, attack during wall kick recovery, fire on pod summon interrupt.

**Visual design:** Mantis-thorn hybrid 64px, `#1B4332` carapace, scythe limbs `#52B788`; larger than Larva.

**Animation requirements:** Idle 8 · Patrol 10 (leap) · Attack 14 · Hit 4 · Death 16

**Stats:** 120 HP · 16–22 dmg · 2.0 · 45 XP · 22 Essence

**Elemental affinity:** Nature (×1.5 fire; see E-53 Brood-Matriarch for true elite)

---

### E-19 — Memory Eel

| Field | Detail |
|-------|--------|
| **ID** | E-19 |
| **Name** | Memory Eel |
| **Region(s)** | Bleakfen Marsh |
| **Family** | water/marsh |

**Concept:** Mana-stealing underwater threat — punishes spell spam in wade zones.

**Lore:** Memory Eels are the resurrection spell's synapses — eel-shaped currents that carry stolen thoughts to the Hollow Heart. Each bite pulls a spell from Elara's fingers as if remembering it for someone else.

**Behavior:** `Circle` (subsurface) → `Strike` → `Coil` (if hit) → `Drain Mana` → `Flee Deep`.

**Attack patterns:**
1. **Lightning Strike** — Quick upward bite; T−0.3s water flash. 12 dmg + steal 15 mana.
2. **Mana Coil** — Medium grab; T−0.5s; 6 dmg/sec + 10 mana/sec drain.
3. **Memory Shock** — Heavy AoE if drain completes; T−0.8s; 20 dmg + Silence 2s.

**Weaknesses:** Tidecaller exposes, melee on surface circle, don't cast during coil (reduces steal).

**Visual design:** Eel = translucent `#6B9080` with floating memory glyphs inside body.

**Animation requirements:** Idle 4 (ripple) · Patrol 8 · Attack 10 · Hit 2 · Death 10

**Stats:** 48 HP · 6–20 dmg · 2.2 water · 22 XP · 10 Essence

**Elemental affinity:** Water/arcane (weak grounding — Rootbind ×1.5)

---

### E-20 — Reliquary Guard

| Field | Detail |
|-------|--------|
| **ID** | E-20 |
| **Name** | Reliquary Guard |
| **Region(s)** | Sunken Catacombs, Sanctum of Ash (ash-armor variant) |
| **Family** | ash/undead / cathedral/holy-corrupted |

**Concept:** Shield-formation support enemy; mini-boss adds for Reliquary Sentinel encounter.

**Lore:** Ceramic-and-bone constructs built to protect urn vaults. Sanctum variants were re-coated in Ashbound pyre ash, giving them holy-corruption counters to fire magic they once feared.

**Behavior:** `Formation` (2+ link shields) → `Advance` → `Shield Bash` / `Spear Thrust` → `Reform`.

**Attack patterns:**
1. **Shield Bash** — Medium; T−0.5s shield glow. 14 dmg + stagger.
2. **Spear Thrust** — Quick through shield gap; T−0.3s. 16 dmg.
3. **Formation Wall** — Passive; 90% frontal damage reduction until flanked or Unravel.

**Weaknesses:** Flank / Shadow Blink behind, Unravel breaks formation, Stoneheart shatters shield (Sanctum).

**Visual design:** Urn-shaped torso shield, bone spear, Sanctum variant ash-caked `#6C757D`.

**Animation requirements:** Idle 6 · Patrol 8 · Attack 10 · Hit 4 (armored) · Death 12

**Stats:** Catacombs 75 HP · 14–16 dmg · 0.9 · 30 XP · 14 Essence · Sanctum 95 HP · 16–20 dmg · 35 XP · 16 Essence

**Elemental affinity:** Holy-corrupted in Sanctum (absorb fire 25%; weak void ×1.5 late-game)

---

### E-21 — Prism Bat

| Field | Detail |
|-------|--------|
| **ID** | E-21 |
| **Name** | Prism Bat |
| **Region(s)** | Lumineth Caverns |
| **Family** | crystal |

**Concept:** Flying enemy reflecting player projectiles at wrong angles — teaches spell discipline.

**Lore:** Bats roosting in crystal vents absorbed prismatic ley until their wings became mirrors. They do not hunt flesh — they hunt *intent*, returning spells to sender with interest.

**Behavior:** `Roost` (ceiling) → `Swoop` → `Mirror Wing` (reflect window) → `Screech` → `Retreat`.

**Attack patterns:**
1. **Swoop Slash** — Medium arc; T−0.5s wing prism flash. 16 dmg.
2. **Reflect Pulse** — Passive during T−0.3s wing spread; returns next projectile at 80% dmg to player.
3. **Sonic Screech** — Heavy cone; T−0.8s; 10 dmg + disorient (invert left/right 1s).

**Weaknesses:** Melee during swoop recovery, don't cast during reflect window, Weightless dodge screech.

**Visual design:** `#E0AAFF` translucent wings, `#FFD60A` refraction specks, small 32px body.

**Animation requirements:** Idle 6 · Patrol 8 · Attack 8 · Hit 2 · Death 8

**Stats:** 35 HP · 10–16 dmg · 1.9 · 20 XP · 9 Essence

**Elemental affinity:** Crystal (immune projectiles during reflect; weak blunt melee ×1.5)

---

### E-22 — Fenbound Zealot

| Field | Detail |
|-------|--------|
| **ID** | E-22 |
| **Name** | Fenbound Zealot |
| **Region(s)** | Bleakfen Marsh, Undercrown Kingdom (spore cult variant) |
| **Family** | water/marsh / underground |

**Concept:** Ranged curse-spitter elite-tier normal; gatekeeps cult altar (Tidecaller spell).

**Lore:** Zealots surrendered grief to the marsh until their names dissolved. They spit fermented curse-water that stacks slow — the Fenbound believed drowning in memory was mercy. Undercrown variants worship Mycelis, spore replacing fen water.

**Behavior:** `Pray` → `Spit` → `Circle` → `Curse Burst` (3 stacks) → `Pray`.

**Attack patterns:**
1. **Curse Spit** — Medium 5-tile; T−0.5s mouth bulge `#6B9080`. 10 dmg + curse stack.
2. **Curse Burst** — Heavy at 3 stacks; T−0.8s; 24 dmg AoE 2 tiles + memory fog 3s.
3. **Spore Hymn** *(Undercrown)* — Medium; T−0.5s; poison 4 dmg/sec 3s.

**Weaknesses:** Close rush, Kindling Ward clears curse, Mistveil filters spore hymn.

**Visual design:** Hooded `#4E5D5C` robes, mask = drowned face, Undercrown variant fungal veil.

**Animation requirements:** Idle 8 · Patrol 6 · Attack 10 · Hit 3 · Death 12

**Stats:** Marsh 85 HP · 10–24 dmg · 1.0 · 38 XP · 18 Essence · Undercrown 100 HP · 12–26 dmg · 42 XP · 20 Essence

**Elemental affinity:** Curse/water (see E-54 Hierophant for true elite)

---

### E-23 — Shard Stalker

| Field | Detail |
|-------|--------|
| **ID** | E-23 |
| **Name** | Shard Stalker |
| **Region(s)** | Lumineth Caverns |
| **Family** | crystal |

**Concept:** Leaves glass shard trail AoE — area denial in crystal corridors.

**Lore:** Stalkers are failed Prism Warden prototypes — hunter-killer crystals that shattered and reformed with predatory subroutines. Each footstep sheds live glass that cuts for hours unless melted.

**Behavior:** `Stalk` → `Shard Trail` (passive while moving) → `Pounce` → `Shard Burst` → `Reform`.

**Attack patterns:**
1. **Shard Trail** — Passive; 6 dmg/sec standing on trail; trail fades 5s.
2. **Crystal Pounce** — Heavy 3-tile; T−0.8s body glow violet. 20 dmg + bleed.
3. **Shard Burst** — Medium 360°; T−0.5s; 12 dmg + trail expands 2 tiles.

**Weaknesses:** Ember Bolt melts trail, jump over pounce, Void Mirror reflects burst (late).

**Visual design:** Wolf-shaped crystal `#3C096C` core, `#E0AAFF` edge refraction, trail = white `#FFD60A` glints.

**Animation requirements:** Idle 6 · Patrol 10 · Attack 12 · Hit 3 · Death 14 (shatter)

**Stats:** 68 HP · 6–20 dmg · 1.7 · 30 XP · 13 Essence

**Elemental affinity:** Crystal (×1.5 fire; immune bleed)

---

### E-24 — Page Swarm

| Field | Detail |
|-------|--------|
| **ID** | E-24 |
| **Name** | Page Swarm |
| **Region(s)** | Archive of Echoes |
| **Family** | archive/ghost |

**Concept:** Flying paper-cut flock — air denial in shelf mazes, weak to fire/wind.

**Lore:** When Thessaly's transfer spell copied books, the disagreements between duplicates became razor pages hunting readers who notice contradictions.

**Behavior:** `Swarm` → `Cut` → `Reform` → `Quote` (audio distraction) → repeat.

**Attack patterns:**
1. **Paper Cut** — Quick contact; T−0.3s paper edge flash. 6 dmg × stack.
2. **Contradiction Burst** — Medium; T−0.5s; 3 projectiles 8 dmg each conflicting directions.
3. **Blinding Flurry** — Heavy; T−0.8s; screen paper overlay 1s + 10 dmg total.

**Weaknesses:** Ember Bolt (burn swarm), Arc Step through, Kindling Ward repels briefly.

**Visual design:** `#CAF0F8` pages with `#023E8A` ink text (illegible), swarm reads as white cloud.

**Animation requirements:** Idle 6 · Patrol 8 · Attack 6 · Hit 2 · Death 10

**Stats:** 32 HP (swarm) · 6–10 dmg · 1.8 · 18 XP · 8 Essence

**Elemental affinity:** Paper/ghost (×2 fire, ×0.5 slash)

---

### E-25 — Lightcut Beam

| Field | Detail |
|-------|--------|
| **ID** | E-25 |
| **Name** | Lightcut Beam |
| **Region(s)** | Lumineth Caverns, Skyfall Ruins (extended range variant) |
| **Family** | crystal / sky/wind |

**Concept:** Environmental rotating laser enemy — puzzle-combat hybrid teaching timing.

**Lore:** Crystallized sunlight trapped when the core cracked; beams are sentences of light too sharp to read. Skyfall variants draw power from star-scars, extending range across void gaps.

**Behavior:** `Rotate` (fixed pivot) → `Charge` → `Fire Beam` → `Cooldown` → repeat. Sky variant adds `Track` (slow player follow ±30°).

**Attack patterns:**
1. **Cut Beam** — Heavy line 6 tiles (Sky: 10); T−0.8s `#FFD60A` line telegraph on floor. 28 dmg/sec contact.
2. **Pulse Burst** — Medium at rotation end; T−0.5s; 14 dmg AoE at emitter.
3. **Blind Flash** — Quick; T−0.3s when damaged; 0 dmg, disorient 0.5s.

**Weaknesses:** Weightless float over (Lumineth), Ley Anchor stabilizes safe zone, destroy emitter crystal (Gleamflare weak point).

**Visual design:** Prism emitter `#7B2CBF`, beam `#FFD60A`/`#E0AAFF` gradient; Sky variant star-gold core.

**Animation requirements:** Idle 4 (rotate loop) · Patrol N/A · Attack continuous · Hit 2 · Death 8

**Stats:** 50 HP (emitter) · 14–28 dmg · rotate 15°/s · 25 XP · 11 Essence

**Elemental affinity:** Light/crystal (Void Mirror reflect; ×1.5 void late)

---

### E-26 — Echo Scholar

| Field | Detail |
|-------|--------|
| **ID** | E-26 |
| **Name** | Echo Scholar |
| **Region(s)** | Archive of Echoes, Somnium Rift (double-cast variant) |
| **Family** | archive/ghost / dream/ethereal |

**Concept:** Copies one player spell cast — teaches spell sequencing and baiting.

**Lore:** Echo Scholars are archivists who merged with their cataloguing tools during the transfer catastrophe. They mirror the last spell they witness, believing repetition is preservation.

**Behavior:** `Observe` → `Mirror Cast` (1:1 copy last player spell at 70% power) → `Scribe` (wind-up original) → `Fade`.

**Attack patterns:**
1. **Mirror Cast** — Variable telegraph = copied spell telegraph; dmg = 70% of spell base.
2. **Ink Bolt** — Medium default if no spell observed; T−0.5s. 14 dmg.
3. **Double Cast** *(Somnium)* — Heavy; T−0.8s; copies last 2 spells in sequence.

**Weaknesses:** Bait weak spell then punish during cooldown, melee rush (low HP), Unravel dispels mirror buff.

**Visual design:** Translucent robed `#90E0EF`, quill hand, face worn smooth (featureless).

**Animation requirements:** Idle 8 · Patrol 6 · Attack varies · Hit 3 · Death 12 (fade to ink)

**Stats:** Archive 55 HP · 10–14 dmg · 0.9 · 26 XP · 12 Essence · Somnium 70 HP · 12–20 dmg · 32 XP · 15 Essence

**Elemental affinity:** Arcane/echo (×1.5 Unravel)

---

### E-27 — Gembound Miner

| Field | Detail |
|-------|--------|
| **ID** | E-27 |
| **Name** | Gembound Miner |
| **Region(s)** | Lumineth Caverns, Obsidian Atelier (heat aura variant) |
| **Family** | crystal / lab/construct |

**Concept:** Undead miner combo attacker — pickaxe patterns with crystal embedding.

**Lore:** Atelier workers sent to mine Lumineth never returned; ley vents crystalized them mid-swing. Forge variants were retrieved and reforged with obsidian plates, still swinging out of muscle memory.

**Behavior:** `Mine` (idle anim) → `Approach` → `Pick Combo` (3-hit) → `Crystal Toss` → `Mine`.

**Attack patterns:**
1. **Pick Combo** — Quick/Medium/Heavy; T−0.3/0.5/0.8s; 12/14/18 dmg.
2. **Crystal Toss** — Medium arc; T−0.5s. 16 dmg + embed (slow 1s).
3. **Heat Aura** *(Atelier)* — Passive 4 dmg/sec within 1 tile; forge orange shimmer.

**Weaknesses:** Dodge third pick hit (heavy), Water spell quenches heat aura, headshot ×1.5 (no helmet Lumineth).

**Visual design:** Crystal-embedded flesh `#495867`, pickaxe `#7B2CBF` blade; Atelier obsidian plate `#0A0A0A`.

**Animation requirements:** Idle 6 · Patrol 8 · Attack 14 (combo) · Hit 4 · Death 12

**Stats:** Lumineth 70 HP · 12–18 dmg · 1.1 · 28 XP · 12 Essence · Atelier 85 HP · 14–22 dmg · 32 XP · 14 Essence

**Elemental affinity:** Crystal/earth (×1.25 fire Atelier)

---

### E-28 — Void Leaper

| Field | Detail |
|-------|--------|
| **ID** | E-28 |
| **Name** | Void Leaper |
| **Region(s)** | Skyfall Ruins |
| **Family** | sky/wind |

**Concept:** Inter-platform jumper chasing player across void gaps — mobility exam.

**Lore:** Leapers were levitation-engine fragments given feral hunger when Skyfall crashed. They jump not to hunt but because they still believe the next platform is sky.

**Behavior:** `Perch` → `Leap` (gap cross) → `Slam` → `Double Jump` (enrage) → repeat.

**Attack patterns:**
1. **Void Leap** — Heavy arc 5 tiles; T−0.8s `#E9C46A` trail. 20 dmg landing.
2. **Midair Slash** — Quick during leap; T−0.3s. 14 dmg.
3. **Platform Slam** — Medium; T−0.5s; cracks platform (environmental hazard).

**Weaknesses:** Ley Anchor stabilizes platform, Arc Step through leap, attack landing recovery.

**Visual design:** `#264653` stone body, void-purple `#0D0221` interior cracks, gold star dust trail.

**Animation requirements:** Idle 6 · Patrol 12 (leap) · Attack 10 · Hit 3 · Death 14

**Stats:** 80 HP · 14–20 dmg · 2.3 · 35 XP · 16 Essence

**Elemental affinity:** Wind/void (×1.5 Rootbind anchor; see E-50 Fen Colossus for marsh elite counterpart in secret zone)

---

### E-29 — Prism Sentinel

| Field | Detail |
|-------|--------|
| **ID** | E-29 |
| **Name** | Prism Sentinel |
| **Region(s)** | Lumineth Caverns |
| **Family** | crystal / lab/construct |

**Concept:** Heavy crystal construct sharing kit with mini-boss **Prism Warden**; appears as add and patrol elite.

**Lore:** Sentinels are Warden-class golems minus the command core — "Do not let anyone reach the spire" burned into facet logic. Mini-boss encounter uses full Warden chassis; field Sentinels are stripped prototypes.

**Behavior:** `Guard` → `Reflect Shield` → `Facet Beam` → `Rotate` → `Guard`.

**Attack patterns:**
1. **Reflect Shield** — Medium stance; T−0.5s; reflects projectiles 2s window.
2. **Facet Beam** — Heavy line; T−0.8s prism charge. 22 dmg beam 3s sweep.
3. **Shard Volley** — Quick 3 shards; T−0.3s each. 8 dmg × 3.

**Weaknesses:** Flank during shield, Unravel disables reflect, melee only during rotate gap.

**Visual design:** Humanoid crystal `#7B2CBF`, rotating chest facet `#FFD60A`, 64px tall.

**Animation requirements:** Idle 8 · Patrol 6 · Attack 14 · Hit 4 (armored) · Death 16

**Stats:** 100 HP · 8–22 dmg · 0.8 · 40 XP · 18 Essence

**Elemental affinity:** Crystal (×1.5 Unravel; immune bleed)

---

### E-30 — Ink Elemental

| Field | Detail |
|-------|--------|
| **ID** | E-30 |
| **Name** | Ink Elemental |
| **Region(s)** | Archive of Echoes |
| **Family** | archive/ghost |

**Concept:** Spawns ink pools slowing movement — area control in shelf combat rooms.

**Lore:** Concentrated disagreement from duplicate books coalesced into ambulatory ink. Elementals seek readers to rewrite — drowning them in contradictory footnotes.

**Behavior:** `Pool Form` → `Rise` → `Slam` / `Spit Pool` → `Submerge` → migrate.

**Attack patterns:**
1. **Ink Slam** — Heavy AoE 2 tiles; T−0.8s `#023E8A` rise. 18 dmg + slow pool.
2. **Spit Pool** — Medium 4-tile arc; T−0.5s; 0 dmg + slow 40% 3s.
3. **Drown Grasp** — Quick in pool; T−0.3s; 10 dmg + root if already slowed.

**Weaknesses:** Ember Bolt evaporates pool, Weightless float above, stay on shelves (high ground).

**Visual design:** Amorphous `#03045E` body, `#0077B6` highlights, white page fragments floating inside.

**Animation requirements:** Idle 6 (bubble) · Patrol 8 (flow) · Attack 10 · Hit 2 · Death 12 (splatter)

**Stats:** 75 HP · 0–18 dmg · 1.0 · 30 XP · 14 Essence

**Elemental affinity:** Ink/water (×2 fire, ×0.5 physical — must evaporate)

---

### E-31 — Gravity Wraith

| Field | Detail |
|-------|--------|
| **ID** | E-31 |
| **Name** | Gravity Wraith |
| **Region(s)** | Skyfall Ruins, Somnium Rift (inverted physics) |
| **Family** | sky/wind / dream/ethereal |

**Concept:** Local gravity inverter — teaches Weightless/Ley Anchor counterplay.

**Lore:** Wraiths are mages who died mid-levitation when Skyfall inverted. They haunt zones where gravity still cannot decide direction. Somnium variants invert controls instead of gravity.

**Behavior:** `Float` → `Invert Field` (3-tile aura) → `Throw Debris` → `Phase`.

**Attack patterns:**
1. **Invert Field** — Heavy aura; T−0.8s `#E9C46A` ring; flips gravity 3s in zone.
2. **Debris Throw** — Medium; T−0.5s; 16 dmg projectile (direction varies with gravity).
3. **Control Invert** *(Somnium)* — Quick pulse; T−0.3s; swaps left/right 2s.

**Weaknesses:** Weightless negates fall damage, Ley Anchor personal gravity, kill before invert in tight platforms.

**Visual design:** Upside-down silhouette `#264653`, star particles orbit feet (which are head).

**Animation requirements:** Idle 8 · Patrol 8 (float) · Attack 10 · Hit 3 · Death 12

**Stats:** Skyfall 65 HP · 0–16 dmg · 1.2 · 32 XP · 15 Essence · Somnium 80 HP · 0–18 dmg · 38 XP · 17 Essence

**Elemental affinity:** Gravity/arcane (×1.5 Ley Anchor burst)

---

### E-32 — Catalog Serpent

| Field | Detail |
|-------|--------|
| **ID** | E-32 |
| **Name** | Catalog Serpent |
| **Region(s)** | Archive of Echoes |
| **Family** | archive/ghost |

**Concept:** Index Hydra body segment; independent snake in stacks, coordinates in pairs.

**Lore:** Each drawer of the Index Hydra can detach as a Catalog Serpent — card-catalog spines given teeth. They alphabetize prey by bone density before the Hydra consumes the filing.

**Behavior:** `Shelf Crawl` → `Lunge` / `Coil` → `Catalog Screech` (call ally) → repeat.

**Attack patterns:**
1. **Drawer Lunge** — Medium 4-tile; T−0.5s drawer handle glint. 16 dmg.
2. **Catalog Coil** — Heavy grab; T−0.8s; 12 dmg + squeeze 8 dmg/sec.
3. **Screech Call** — Quick; T−0.3s; summons second E-32 if alone 8s+.

**Weaknesses:** Kill before pair, fire on coil, Hydra fight = don't kill segments unnecessarily (respawn).

**Visual design:** Wooden drawer segments `#023E8A`, brass label tabs as scales, ink tongue.

**Animation requirements:** Idle 6 · Patrol 8 · Attack 12 · Hit 3 · Death 10

**Stats:** 60 HP · 12–16 dmg · 1.4 · 28 XP · 12 Essence

**Elemental affinity:** Wood/ghost (×1.5 fire)

---

### E-33 — Binding Golem

| Field | Detail |
|-------|--------|
| **ID** | E-33 |
| **Name** | Binding Golem |
| **Region(s)** | Archive of Echoes, Obsidian Atelier (anvil chain variant) |
| **Family** | archive/ghost / lab/construct |

**Concept:** Triggers shelf/anvil collapse; environmental hazard enabler.

**Lore:** Golems were shelf-stabilizers bound with chain-spells. Atelier variants bind molten chains instead of books — same logic, hotter failure mode.

**Behavior:** `Anchor` → `Pull Chain` → `Collapse Trigger` (environment) → `Rebind`.

**Attack patterns:**
1. **Chain Whip** — Medium 3-tile; T−0.5s chain rattle. 18 dmg.
2. **Shelf Collapse** — Heavy; T−0.8s; 25 dmg AoE if under shelf (room scripted).
3. **Anvil Hook** *(Atelier)* — Heavy pull; T−0.8s; drags player 2 tiles toward hazard. 14 dmg.

**Weaknesses:** Cut chain weak point (Gleamflare), don't stand under marked shelves (red `#DC2F02` dots), Stoneheart breaks anchor.

**Visual design:** Book-stack body Archive; anvil-chain torso Atelier `#0A0A0A` + `#FFBA08` hot links.

**Animation requirements:** Idle 6 · Patrol 4 · Attack 12 · Hit 5 · Death 14

**Stats:** 90 HP · 14–25 dmg · 0.7 · 34 XP · 16 Essence

**Elemental affinity:** Construct (×1.5 Unravel / Stoneheart)

---

### E-34 — Debris Golem

| Field | Detail |
|-------|--------|
| **ID** | E-34 |
| **Name** | Debris Golem |
| **Region(s)** | Skyfall Ruins |
| **Family** | sky/wind |

**Concept:** Rolling boulder enemy — platform edge hazard, physics-driven path.

**Lore:** Animated rubble from the three-day fall, still tumbling because ley locks never released kinetic intent. Golems roll until they find something softer than themselves to crush.

**Behavior:** `Roll` (constant until wall) → `Crash` → `Reassemble` (3s) → `Roll`.

**Attack patterns:**
1. **Roll Over** — Heavy contact; T−0.8s rumble + dust. 24 dmg + knockdown.
2. **Crash Splinter** — On wall impact; T−0.3s; 3 shards 8 dmg each forward cone.
3. **Edge Push** — Passive; pushes player off platform if pinned to edge.

**Weaknesses:** Jump over roll, Rootbind stops briefly, Ley Anchor creates barrier.

**Visual design:** `#264653` stone chunks, `#E9C46A` ley-lock veins, dust trail.

**Animation requirements:** Idle N/A · Patrol roll loop 8 · Attack 6 · Hit 3 · Death 16 (collapse)

**Stats:** 110 HP · 8–24 dmg · 2.0 roll · 36 XP · 17 Essence

**Elemental affinity:** Earth (×1.5 Rootbind; immune stagger while rolling)

---

### E-35 — Slag Crawler

| Field | Detail |
|-------|--------|
| **ID** | E-35 |
| **Name** | Slag Crawler |
| **Region(s)** | Obsidian Atelier |
| **Family** | lab/construct |

**Concept:** Leaves molten trail — forge corridor denial; pairs with Furnace Mouth.

**Lore:** Failed spell-ingots given legs by residual forge heat. Crawlers seek the central anvil to die properly; until then they melt footprints into permanent hazards.

**Behavior:** `Crawl` → `Trail Leave` → `Molten Spit` → `Harden` (defensive shell) → repeat.

**Attack patterns:**
1. **Molten Trail** — Passive; 8 dmg/sec; cools to solid block after 10s.
2. **Spit Glob** — Medium arc; T−0.5s `#FFBA08`. 16 dmg + ignite 4 dmg/2s.
3. **Harden Shell** — Heavy; T−0.8s; 90% dmg reduction 3s, immobile.

**Weaknesses:** Kindling Ward on trail, Water/Tidecaller extinguishes (if available), attack from behind during crawl.

**Visual design:** `#DC2F02` molten core through `#0A0A0A` slag shell, dripping `#FFBA08`.

**Animation requirements:** Idle 4 · Patrol 8 · Attack 8 · Hit 4 · Death 10 (cool + crack)

**Stats:** 78 HP · 8–16 dmg · 1.0 · 30 XP · 14 Essence

**Elemental affinity:** Fire/construct (×2 water; see E-51 Crown Devourer for underground elite)

---

### E-36 — Starfall Knight

| Field | Detail |
|-------|--------|
| **ID** | E-36 |
| **Name** | Starfall Knight |
| **Region(s)** | Skyfall Ruins, Sanctum of Ash (flame lance variant) |
| **Family** | sky/wind / cathedral/holy-corrupted |

**Concept:** Elite-tier shield+lance patrol; Regent's garrison remnant.

**Lore:** Knights of the sky-city guard who fused with levitation armor rather than fall. Sanctum variants traded star-lances for pyre-flames — Ashbound conscription after death.

**Behavior:** `March` → `Shield Wall` → `Lance Thrust` / `Star Bolt` → `Reform`.

**Attack patterns:**
1. **Lance Thrust** — Medium 3-tile; T−0.5s `#E9C46A` lance glow. 20 dmg.
2. **Shield Bash** — Quick; T−0.3s; 14 dmg + stagger if blocked forward.
3. **Star Bolt** / **Flame Lance** *(Sanctum)* — Heavy ranged; T−0.8s. 22 dmg + burn 4 dmg/3s.

**Weaknesses:** Shadow Blink behind shield, Unravel vs Sanctum flame, aerial hit during march (Weightless).

**Visual design:** `#264653` plate, star-gold `#E9C46A` trim; Sanctum = charred `#E5383B` flame lance.

**Animation requirements:** Idle 8 · Patrol 10 · Attack 12 · Hit 4 · Death 14

**Stats:** Skyfall 95 HP · 14–22 dmg · 1.2 · 42 XP · 20 Essence · Sanctum 115 HP · 16–26 dmg · 48 XP · 22 Essence

**Elemental affinity:** Holy/star (see E-55 Praetorian for true elite)

---

### E-37 — Regent's Echo

| Field | Detail |
|-------|--------|
| **ID** | E-37 |
| **Name** | Regent's Echo |
| **Region(s)** | Skyfall Ruins, Somnium Rift (corrupted boss echo) |
| **Family** | sky/wind / dream/ethereal |

**Concept:** Boss-add levitation orb caster; Somnium variant uses corrupted Regent patterns.

**Lore:** When the Starfall Regent fused with his engine, splinters of his will became Echoes — mages who look like him but aren't. Somnium corrupts them further until they believe they *are* the Regent, at 40% power.

**Behavior:** `Hover` → `Orb Summon` → `Levitation Pulse` → `Echo Cast` (mini Regent spell) → repeat.

**Attack patterns:**
1. **Levitation Orb** — Medium spawn; T−0.5s; orb contact 12 dmg + float 1s.
2. **Pulse Push** — Heavy radial; T−0.8s; pushback 3 tiles, 10 dmg wall slam.
3. **Regent's Shard** *(Somnium)* — Ultimate; T−1.2s; 28 dmg line beam (corrupted).

**Weaknesses:** Destroy orbs first, Ley Anchor self against push, Unravel dispels float.

**Visual design:** Translucent regal armor `#F4A261`, void face, orbiting `#2A9D8F` levitation orbs.

**Animation requirements:** Idle 8 · Patrol 6 (hover) · Attack 12 · Hit 3 · Death 14

**Stats:** Ruins 70 HP · 10–28 dmg · 1.0 hover · 38 XP · 18 Essence · Somnium 95 HP · 14–32 dmg · 50 XP · 24 Essence

**Elemental affinity:** Arcane/wind (×1.5 void/Unravel)

---

### E-38 — Blueprint Phantom

| Field | Detail |
|-------|--------|
| **ID** | E-38 |
| **Name** | Blueprint Phantom |
| **Region(s)** | Obsidian Atelier, Sanctum of Ash (ritual variant) |
| **Family** | lab/construct / cathedral/holy-corrupted |

**Concept:** Ranged summoner deploying turret constructs — priority target in forge rooms.

**Lore:** Phantoms are scorched spell-blueprints given half-life by forge heat. They project turrets from lines on paper that burn into reality. Sanctum variants draw Ashbound sigils instead — turrets fire curse bolts.

**Behavior:** `Sketch` → `Summon Turret` (max 2) → `Blueprint Bolt` → `Phase Shift`.

**Attack patterns:**
1. **Summon Turret** — Heavy; T−0.8s ground circle `#FFBA08`. Turret 8 dmg/sec beam.
2. **Blueprint Bolt** — Medium; T−0.5s. 14 dmg projectile.
3. **Ash Ritual** *(Sanctum)* — Medium; T−0.5s; curse turret 6 dmg + stack.

**Weaknesses:** Kill phantom first (turrets fade), Ember Bolt ignites sketch interrupt, Gleamflare reveals phase location.

**Visual design:** Paper-flat `#370617` body, `#FFBA08` blueprint lines, floating quill.

**Animation requirements:** Idle 6 · Patrol 6 · Attack 10 · Hit 2 · Death 10 (burn away)

**Stats:** 55 HP · 6–14 dmg · 0.9 · 28 XP · 13 Essence (+ turret 30 HP separate)

**Elemental affinity:** Construct/ghost (×1.5 fire)

---

### E-39 — Furnace Mouth

| Field | Detail |
|-------|--------|
| **ID** | E-39 |
| **Name** | Furnace Mouth |
| **Region(s)** | Obsidian Atelier |
| **Family** | lab/construct |

**Concept:** Stationary breath attacker guarding forge lanes — area denial anchor.

**Lore:** Furnace Mouths are literal forge openings animated by Ilmen's last binding spell. They breathe spell-slag at intruders, still executing "maintain temperature" directives three centuries later.

**Behavior:** `Idle Heat` → `Charge Breath` → `Cone Breath` (3s) → `Cooldown` → track player angle slowly.

**Attack patterns:**
1. **Forge Breath** — Heavy cone 5 tiles; T−0.8s red `#DC2F02` mouth glow. 20 dmg/sec × 3s.
2. **Slag Burp** — Quick; T−0.3s between breaths; 12 dmg glob sticky.
3. **Heat Zone** — Passive 1 tile; 4 dmg/sec ambient.

**Weaknesses:** Kindling Ward blocks breath chip, Arc Step behind mouth (weak back plate ×2), Stoneheart silences 5s.

**Visual design:** Wall-mounted obsidian maw `#0A0A0A`, `#DC2F02`/`#FFBA08` interior gradient.

**Animation requirements:** Idle 4 (heat shimmer) · Patrol N/A · Attack 12 · Hit 3 · Death 10 (crack + dim)

**Stats:** 85 HP · 4–20 dmg · 0 (rotates 20°/s) · 32 XP · 15 Essence

**Elemental affinity:** Fire (immune; ×2 water/Tidecaller if used)

---

### E-40 — Anvil Thrall

| Field | Detail |
|-------|--------|
| **ID** | E-40 |
| **Name** | Anvil Thrall |
| **Region(s)** | Obsidian Atelier, Sanctum of Ash (ember hammer variant) |
| **Family** | lab/construct / cathedral/holy-corrupted |

**Concept:** Hammer combo add for Anvil Ascendant mini-boss; Sanctum variant ember-coated.

**Lore:** Thralls are forge-workers who volunteered for binding into tool-form — living hammers. Sanctum Ashbound recovered several and re-blessed them with pyre hammers to guard reliquary passages.

**Behavior:** `Stand By Anvil` → `Hammer Combo` (3-hit) → `Ground Slam` → `Recharge`.

**Attack patterns:**
1. **Hammer Combo** — Quick/Medium/Heavy; T−0.3/0.5/0.8s; 14/16/22 dmg.
2. **Ground Slam** — Heavy AoE 2 tiles; T−0.8s; 26 dmg + shockwave knockup.
3. **Ember Strike** *(Sanctum)* — Adds 6 fire dmg/tick 2s on third hit.

**Weaknesses:** Dodge third hammer (long endlag), jump slam shockwave, Unravel breaks binding (stun 2s).

**Visual design:** Humanoid fused with hammer `#6A040F`, `#FFBA08` heated head; Sanctum ember glow `#F48C06`.

**Animation requirements:** Idle 6 · Patrol 6 · Attack 16 (combo) · Hit 5 · Death 12

**Stats:** Atelier 88 HP · 14–26 dmg · 0.9 · 34 XP · 16 Essence · Sanctum 105 HP · 16–30 dmg · 40 XP · 18 Essence

**Elemental affinity:** Fire/construct (×1.5 water; ×1.25 void Sanctum)

---

## Elite Enemies (E-41–E-55)

Elites use [Elite Modifier Rules](#elite-modifier-rules). Each entry includes a unique attack beyond its normal counterpart where applicable.

---

### E-41 — Ashbound Zealot

| Field | Detail |
|-------|--------|
| **ID** | E-41 |
| **Name** | Ashbound Zealot |
| **Region(s)** | Sanctum of Ash |
| **Family** | cathedral/holy-corrupted |

**Concept:** Late-game suicide rusher embodying Ashbound martyrdom — high risk, high damage.

**Lore:** Zealots who survived the immolation by burning halfway — ash from the waist down, flesh above, still preaching. They rush intruders to share the pyre, believing Elara's Veilmark blood must burn to complete the containment field.

**Behavior:** `Sermon` → `Rush` → `Self-Immolate Wind-up` → `Detonate` OR `Melee Combo` if interrupted.

**Attack patterns:**
1. **Ash Rush** — Heavy dash 4 tiles; T−0.8s `#E5383B` trail. 24 dmg contact.
2. **Pyre Combo** — Medium ×3; T−0.5s each. 18 dmg + burn stack.
3. **Martyr Detonate** — Ultimate at 25% HP or 6s rush; T−1.2s; 40 dmg AoE 3 tiles (kills self).

**Weaknesses:** Kill before detonate, Void Mirror reflects burn stacks late, Kindling Ward reduces burn.

**Visual design:** Half-charcoal body, `#FFDDD2` ash fall from torso, ember crucifix `#F48C06`.

**Animation requirements:** Idle 8 · Patrol 10 · Attack 14 · Hit 4 · Death 16 (ash collapse)

**Stats:** 220 HP · 18–40 dmg · 1.8 rush · 95 XP · 45 Essence

**Elemental affinity:** Fire/holy-corrupted (absorb fire 50%; ×2 void)

---

### E-42 — Spore Cavalry

| Field | Detail |
|-------|--------|
| **ID** | E-42 |
| **Name** | Spore Cavalry |
| **Region(s)** | Undercrown Kingdom |
| **Family** | underground/knight |

**Concept:** Mounted charge elite — tests dodge timing and Rootbind mount separation.

**Lore:** Undercrown knights bonded with giant spore-beetles when Morvain sealed the court. Cavalry still patrol fungal highways, charging anything without crown-spore pheromones — including Elara.

**Behavior:** `Patrol Mount` → `Charge Wind-up` → `Full Charge` → `Dismount Fight` (if beetle killed) → `Recall Mount` (10s).

**Attack patterns:**
1. **Spore Charge** — Ultimate line 6 tiles; T−1.2s hoof tremor. 32 dmg + poison 5 dmg/3s.
2. **Lance Down** — Medium during charge; T−0.5s. 22 dmg.
3. **Dismounted Slash** — Quick ×2 if beetle dies; T−0.3s. 16 dmg (rider only).

**Weaknesses:** Rootbind beetle (dismount), jump over charge (tight timing), Mistveil filters poison.

**Visual design:** `#2B2D42` knight, `#EF233C` crown crest, beetle mount `#8D99AE` bioluminescent.

**Animation requirements:** Idle 8 · Patrol 12 · Attack 16 · Hit 4 · Death 18 (rider + mount separate)

**Stats:** 250 HP (combined) · 16–32 dmg · 2.5 charge · 100 XP · 48 Essence

**Elemental affinity:** Poison/nature (×1.5 fire; ×1.25 holy)

---

### E-43 — Root Knight

| Field | Detail |
|-------|--------|
| **ID** | E-43 |
| **Name** | Root Knight |
| **Region(s)** | Undercrown Kingdom |
| **Family** | underground/knight |

**Concept:** Heavy poise boss-guard; Rootbind vulnerable — teaches spell counter on elite.

**Lore:** Morvain's honor guard entombed in root-armor, still defending vault approaches. Armor is living wood symbiote — cutting the knight hurts the kingdom's nervous system, which is the point.

**Behavior:** `Root Stance` → `Heavy Swing` → `Root Spike` (floor) → `Guard Break Recovery`.

**Attack patterns:**
1. **Root Cleave** — Heavy 180° arc; T−0.8s `#D90429` axe glow. 28 dmg.
2. **Floor Spike** — Medium 3-tile line from ground; T−0.5s; 20 dmg + root 1s.
3. **Crown Guard** — Passive frontal 70% reduction unless Rootbind breaks roots (stun 3s).

**Weaknesses:** Rootbind (mandatory stun window), rear attacks, Ember Bolt burns root armor (−30% HP threshold once).

**Visual design:** `#2B2D42` plate over `#EDF2F4` fungal root growth, `#D90429` crown visor.

**Animation requirements:** Idle 8 · Patrol 8 · Attack 14 · Hit 5 · Death 16

**Stats:** 280 HP · 20–28 dmg · 0.85 · 105 XP · 50 Essence

**Elemental affinity:** Nature/earth (×2 Rootbind; ×1.5 fire)

---

### E-44 — Nightmare Fragment

| Field | Detail |
|-------|--------|
| **ID** | E-44 |
| **Name** | Nightmare Fragment |
| **Region(s)** | Somnium Rift, Ley Nexus (ley-touched variant) |
| **Family** | dream/ethereal / void/unbound |

**Concept:** Procedural region-themed elite remixing prior biome attacks — memory combat exam.

**Lore:** Shards of Elara's unresolved dreams given teeth. Each Fragment wears a different region's skin — Whisperwood thorns one moment, forge slag the next — because the Rift cannot decide which trauma to replay.

**Behavior:** `Shift Form` (every 8s) → `Region Attack Set` → `Nightmare Pulse` → repeat.

**Attack patterns:**
1. **Form Shift** — Medium transition; T−0.5s color invert; next attack = random prior region kit at +20% dmg.
2. **Nightmare Pulse** — Heavy AoE; T−0.8s `#C77DFF`; 22 dmg + random debuff (slow/ burn/ curse/ silence).
3. **Memory Loop** — Ultimate; T−1.2s; repeats last player spell against player at 90% power.

**Weaknesses:** Unbind severs form mid-shift, Gleamflare stabilizes color (prevents debuff roulette), aggressive DPS during shift vulnerability (1s).

**Visual design:** Silhouette constantly glitching region palettes; Ley variant adds `#FF0099` strand trails.

**Animation requirements:** Idle 6 (glitch) · Patrol 8 · Attack varies · Hit 2 · Death 14 (shatter into pages)

**Stats:** 200 HP · 12–28 dmg · 1.5 · 110 XP · 52 Essence

**Elemental affinity:** Dream (all elements 0.75× except Unbind ×2)

---

### E-45 — Dream Leach

| Field | Detail |
|-------|--------|
| **ID** | E-45 |
| **Name** | Dream Leach |
| **Region(s)** | Somnium Rift, Ley Nexus (core parasite) |
| **Family** | dream/ethereal / void/unbound |

**Concept:** Persistent mana-drain aura elite — punishes spell-heavy builds in Rift/Nexus.

**Lore:** Dream Leaches attach to mages who slept through the Sundering, feeding on cast intent. Nexus variants burrow into ley strands, draining anyone who casts within line-of-sight of the core.

**Behavior:** `Drift Toward Caster` → `Attach Aura` → `Dream Siphon` → `Phase Out` (if broken) → repeat.

**Attack patterns:**
1. **Siphon Aura** — Passive 2-tile; −12 mana/sec + 8 dmg/sec while inside.
2. **Dream Latch** — Heavy; T−0.8s; 18 dmg + Silence 3s if attach completes.
3. **Core Burrow** *(Nexus)* — Ultimate; T−1.2s; submerges, reappears under player; 26 dmg + drain 50 mana.

**Weaknesses:** Melee rush (low poise), stop casting inside aura, Rift Tear creates dead-zone bubble 4s.

**Visual design:** Translucent `#240046` worm, `#C77DFF` dream-glyph organs visible, Nexus variant `#00FFFF` ley veins.

**Animation requirements:** Idle 6 · Patrol 8 (float) · Attack 10 · Hit 2 · Death 12

**Stats:** 180 HP · 8–26 dmg · 1.3 · 100 XP · 48 Essence

**Elemental affinity:** Arcane/dream (×1.5 physical melee; immune mana drain reflected)

---

### E-46 — Rift Stalker

| Field | Detail |
|-------|--------|
| **ID** | E-46 |
| **Name** | Rift Stalker |
| **Region(s)** | Somnium Rift, Ley Nexus (final corridor guard) |
| **Family** | dream/ethereal / void/unbound |

**Concept:** Teleport ambush mini-boss-tier elite — guards Unbind chamber approach.

**Lore:** Stalkers are Somnium Warden's severed shadows, hunting casters who remember too much. They blink through Rift geometry because they *are* the gaps between rooms.

**Behavior:** `Unseen` → `Mark` (telegraph on player tile) → `Ambush` → `Combo` → `Escape Blink`.

**Attack patterns:**
1. **Mark & Strike** — Heavy; T−0.8s floor `#FF6D00` ring on player tile; 30 dmg if not moved.
2. **Blink Combo** — Medium ×4; T−0.5s between; 16 dmg per hit (tracks aggressively).
3. **Rift Tear** — Ultimate; T−1.2s; pulls player 3 tiles into hazard zone. 20 dmg + disorient.

**Weaknesses:** Move on mark, Arc Step invuln through combo start, Echo Sense reveals next blink origin 0.5s early.

**Visual design:** `#5A189A` humanoid void, `#FF6D00` nightmare claws, only visible 0.5s before strike without Echo Sense.

**Animation requirements:** Idle 4 · Patrol 6 (blink) · Attack 16 · Hit 2 · Death 14

**Stats:** 240 HP · 16–30 dmg · 2.4 blink · 120 XP · 55 Essence

**Elemental affinity:** Void (×1.5 Gleamflare; ×1.5 Unbind)

---

### E-47 — Ley Fragment

| Field | Detail |
|-------|--------|
| **ID** | E-47 |
| **Name** | Ley Fragment |
| **Region(s)** | Ley Nexus / The Unbound |
| **Family** | void/unbound |

**Concept:** Orbiting hazard enemy circling ley strands — spatial puzzle under combat pressure.

**Lore:** When the knot tore, fragments of the weave became predatory — hungry geometry that orbit raw ley because they miss being part of a pattern. They attack anything that tries to re-weave.

**Behavior:** `Orbit Strand` → `Split` (2 fragments) → `Converge` (player) → `Rejoin`.

**Attack patterns:**
1. **Orbit Contact** — Quick; T−0.3s; 14 dmg + ley burn 4 dmg/sec 2s.
2. **Converge Burst** — Heavy; T−0.8s; fragments rush player; 26 dmg AoE 2 tiles.
3. **Strand Cut** — Medium line along ley; T−0.5s; 20 dmg environmental + fall risk.

**Weaknesses:** Weightless avoids orbit plane, Ley Anchor creates safe orbit gap, Unravel disperses split fragments 3s.

**Visual design:** `#7F00FF`/`#00FFFF` geometric polyhedra, `#FFFFFF` core flash on attack.

**Animation requirements:** Idle 4 (orbit) · Patrol continuous · Attack 8 · Hit 2 · Death 10 (dissolve to strands)

**Stats:** 160 HP (per fragment; splits once) · 14–26 dmg · 2.0 orbit · 90 XP · 42 Essence

**Elemental affinity:** Ley/raw magic (×1.5 all spell types when converging; immune physical 0.5×)

---

### E-48 — Unbound Shard

| Field | Detail |
|-------|--------|
| **ID** | E-48 |
| **Name** | Unbound Shard |
| **Region(s)** | Ley Nexus / The Unbound |
| **Family** | void/unbound |

**Concept:** Boss phase add for The Unbound — entropy incarnate in mobile form.

**Lore:** Shards are splinters of the Unbound principle given momentary shape so the core can test intruders. Each Shard removes one spell slot's effectiveness (suppression aura) until destroyed.

**Behavior:** `Spawn` (boss phase) → `Suppress Aura` (1 spell type) → `Entropy Beam` → `Dissolve`.

**Attack patterns:**
1. **Suppress Field** — Passive 3-tile; disables one random equipped spell while inside.
2. **Entropy Beam** — Heavy line; T−0.8s `#FF0099`; 24 dmg + max mana −10 temporary.
3. **Unmake** — Ultimate on death; T−1.0s; 18 dmg AoE + clears one player buff.

**Weaknesses:** Destroy quickly (low HP), don't fight inside suppression field, Unbind reverses Unmake.

**Visual design:** Black `#000000` silhouette with `#FF0099` fracture lines, shape never consistent frame-to-frame.

**Animation requirements:** Idle 4 (glitch) · Patrol 6 · Attack 10 · Hit 1 · Death 8 (implosion)

**Stats:** 120 HP · 18–24 dmg · 1.6 · 85 XP · 40 Essence (add; ×3 spawn in boss P2)

**Elemental affinity:** Void/entropy (immune debuffs; ×2 Unbind)

---

### E-49 — Weave Remnant

| Field | Detail |
|-------|--------|
| **ID** | E-49 |
| **Name** | Weave Remnant |
| **Region(s)** | Ley Nexus / The Unbound |
| **Family** | void/unbound |

**Concept:** All-element rotation elite — final exam before Unbound arena; rotates weakness every 6s.

**Lore:** Remnants are the last loyal threads of the old knot, corrupted into guardians that test whether a mage deserves to touch the core. They cycle through every elemental affinity the empire ever named — a living spell wheel.

**Behavior:** `Rotate Element` (6s cycle) → `Element Attack` → `Weave Shield` → `Rotate`.

**Attack patterns:**
1. **Element Bolt** — Medium; T−0.5s; 20 dmg typed to current element (color telegraph).
2. **Weave Shield** — Heavy; T−0.8s; immune to current element 3s; weak to opposite (chart in [06-magic-system.md](06-magic-system.md)).
3. **Pattern Burst** — Ultimate every 3 rotations; T−1.2s; 8-hit combo 12 dmg each mixed types.

**Weaknesses:** Read rotation color, hit with opposite element during shield (poise break), all 14 spells deal neutral during Pattern Burst wind-up.

**Visual design:** Humanoid woven `#FFFFFF` threads, core cycles elemental hues, `#7F00FF` outline.

**Animation requirements:** Idle 8 · Patrol 8 · Attack 18 · Hit 3 · Death 20 (unravel)

**Stats:** 320 HP · 12–24 dmg (burst higher) · 1.1 · 150 XP · 70 Essence

**Elemental affinity:** All (rotating — see weakness wheel in magic doc)

---

### E-50 — Fen Colossus

| Field | Detail |
|-------|--------|
| **ID** | E-50 |
| **Name** | Fen Colossus |
| **Region(s)** | Bleakfen Marsh (Hollow Heart secret), Undercrown Kingdom, Sunken Catacombs (Tidecaller elite encounter) |
| **Family** | water/marsh / underground |

**Concept:** Secret-zone colossus guarding Hollow Heart; world doc elite E-28 reference for marsh variant.

**Lore:** When the resurrection spell failed, its mass collapsed into the fen and walked. The Colossus is that mass — a hill that learned to hate. Catacomb ossuary water hides a smaller cast-off (Tidecaller encounter hook); Undercrown roots feed it spore armor late-game.

**Behavior:** `Slumber` → `Wake` (player enters arena) → `Stomp` / `Fen Pull` → `Memory Wail` → `Slumber` (phase at 50%).

**Attack patterns:**
1. **Colossus Stomp** — Ultimate AoE 4 tiles; T−1.2s ground crack. 36 dmg + slow 3s.
2. **Fen Pull** — Heavy; T−0.8s; drag player 2 tiles toward center; 22 dmg + memory fog.
3. **Memory Wail** — Medium cone; T−0.5s; 18 dmg + −20 max mana temporary 10s.

**Weaknesses:** Tidecaller drains arena (disables Pull), strike legs during wail (×2), Hollow Heart relic slot reward on kill.

**Visual design:** 128px tall peat golem `#1A1A1D`, `#6B9080` moss, glowing `#AEC3B0` memory faces in torso.

**Animation requirements:** Idle 8 · Patrol 4 (slow) · Attack 20 · Hit 6 · Death 24 (sink into fen)

**Stats:** 450 HP · 18–36 dmg · 0.6 · 180 XP · 85 Essence

**Elemental affinity:** Water/memory (×1.5 lightning; ×1.5 Tidecaller)

---

### E-51 — Crown Devourer

| Field | Detail |
|-------|--------|
| **ID** | E-51 |
| **Name** | Crown Devourer |
| **Region(s)** | Undercrown Kingdom (King's Hollow / royal vault) |
| **Family** | underground/knight |

**Concept:** Royal vault elite; world doc optional elite E-35 reference — consumes crown-spore to heal.

**Lore:** Devourers were Morvain's failsafe — throne guardians that eat royal regalia to absorb ley keys. Mycelis repurposed them to protect King's Hollow. Each crown consumed heals the Devourer and mutters a dead king's decree.

**Behavior:** `Devour Crown` (heal 15%) → `Roar` (summon E-42) → `Bite` / `Tail Sweep` → repeat.

**Attack patterns:**
1. **Royal Bite** — Heavy; T−0.8s; 30 dmg + bleed 6 dmg/3s.
2. **Tail Sweep** — Medium 360°; T−0.5s; 22 dmg knockback.
3. **Crown Devour** — Ultimate; T−1.2s; heals 15% HP, +10% dmg stack (max 3).

**Weaknesses:** Interrupt devour (Gleamflare stun), kill adds before Roar stacks, fire prevents heal on third devour.

**Visual design:** Bestial `#2B2D42` worm-knight hybrid, `#D90429` crowns embedded in back, `#EDF2F4` spore saliva.

**Animation requirements:** Idle 10 · Patrol 8 · Attack 18 · Hit 5 · Death 22

**Stats:** 400 HP · 22–30 dmg · 1.2 · 170 XP · 80 Essence

**Elemental affinity:** Royal curse (×1.5 fire; ×1.25 Unravel)

---

### E-52 — Threshold Shade Ascendant

| Field | Detail |
|-------|--------|
| **ID** | E-52 |
| **Name** | Threshold Shade Ascendant |
| **Region(s)** | Ashen Threshold (patrol), Sanctum of Ash |
| **Family** | ash/undead / cathedral/holy-corrupted |

**Concept:** True elite form of E-08; hub loop optional hunt + Sanctum gate guard.

**Lore:** Ascendants are Shades that remembered their full oath — and the name of the mage who broke it. They hunt Veilmarks specifically, believing killing Elara completes the Threshold's unfinished ritual.

**Behavior:** `Phase Walk` → `Oath Combo` (4-hit) → `Ascendant Burst` → `Teleport` → repeat.

**Attack patterns:**
1. **Oath Combo IV** — Mixed Quick/Medium; T−0.3–0.5s; 16 dmg ×4.
2. **Ascendant Burst** — Heavy AoE; T−0.8s ember nova. 28 dmg + burn 8 dmg/3s.
3. **Phase Strike** — Ultimate from teleport; T−1.0s; 32 dmg backstab if facing wrong.

**Weaknesses:** Same as E-08 amplified; Gleamflare mandatory for teleport read; combo break on stagger (poise 100).

**Visual design:** Solid ember `#FF6B35` silhouette, Veilmark sigil scar on chest, two ghost blades.

**Animation requirements:** Idle 8 · Patrol 12 · Attack 18 · Hit 4 · Death 16

**Stats:** 200 HP · 16–32 dmg · 1.7 · 90 XP · 42 Essence

**Elemental affinity:** Shadow/fire (×1.5 Gleamflare; ×1.5 water)

---

### E-53 — Canopy Hunter Brood-Matriarch

| Field | Detail |
|-------|--------|
| **ID** | E-53 |
| **Name** | Canopy Hunter Brood-Matriarch |
| **Region(s)** | Whisperwood Hollow (Canopy Nest optional) |
| **Family** | forest/thorn |

**Concept:** True elite E-18; optional canopy nest fight guarding relic fragment.

**Lore:** Matriarchs are Hunters that consumed an entire Thornweft Coven circle — they wear silk robes made of gardener faces. The Canopy Nest Matriarch guards a Veilmark pod because the forest misidentified Elara as its offspring.

**Behavior:** `Nest Guard` → `Leap Combo` → `Silk Prison` (web cage) → `Summon Larvae` (3× E-15) once.

**Attack patterns:**
1. **Brood Leap** — Heavy; T−0.8s; 26 dmg + shockwave 2 tiles.
2. **Silk Prison** — Ultimate; T−1.2s; cage 4 tiles 4s; 10 dmg/sec inside unless burned.
3. **Scythe Frenzy** — Medium enrage below 40%; T−0.5s ×6. 14 dmg per hit.

**Weaknesses:** Ember Bolt burns prison, kill before larva summon at 50%, Arc Step out of shockwave.

**Visual design:** 80px E-18 scale ×1.25, silk veil of faces `#D8F3DC`, `#1B4332` blood-thorn limbs.

**Animation requirements:** Idle 10 · Patrol 12 · Attack 20 · Hit 5 · Death 18

**Stats:** 280 HP · 14–26 dmg · 2.2 · 130 XP · 60 Essence

**Elemental affinity:** Nature (×2 fire; weak vertical attacks — up-air ×1.5)

---

### E-54 — Fenbound Hierophant

| Field | Detail |
|-------|--------|
| **ID** | E-54 |
| **Name** | Fenbound Hierophant |
| **Region(s)** | Bleakfen Marsh (cult altar), Undercrown (spore variant) |
| **Family** | water/marsh / underground |

**Concept:** True elite E-22; guards Tidecaller altar inscription.

**Lore:** Hierophants drank the marsh's center and lived — their blood is black water that speaks prophecies while they fight. The cult believed Hierophants would become the Miremother's voice; instead they became her alarm.

**Behavior:** `Prophesy` (debuff roulette) → `Curse Volley` → `Drown Field` (water rise) → `Pray`.

**Attack patterns:**
1. **Curse Volley** — Medium ×5; T−0.5s staggered. 12 dmg + curse stack each.
2. **Drown Field** — Heavy; T−0.8s; raises water 2 tiles in arena 6s; 15 dmg/sec wading.
3. **Prophesy** — Ultimate opening; T−1.2s; random debuff: slow / silence / mana drain / invert controls 4s.

**Weaknesses:** Tidecaller counters Drown Field, Mistveil on Prophesy, rush during Pray (long vulnerable window).

**Visual design:** `#1A1A1D` robed, `#B1FAFF` water veins glowing, mask = inverted Miremother face.

**Animation requirements:** Idle 10 · Patrol 6 · Attack 16 · Hit 4 · Death 18 (dissolve to water)

**Stats:** 260 HP · 12–24 dmg · 0.95 · 125 XP · 58 Essence

**Elemental affinity:** Curse/water (×1.5 holy/Kindling; ×1.5 Tidecaller)

---

### E-55 — Starfall Knight Praetorian

| Field | Detail |
|-------|--------|
| **ID** | E-55 |
| **Name** | Starfall Knight Praetorian |
| **Region(s)** | Skyfall Ruins (Regent tower approach) |
| **Family** | sky/wind |

**Concept:** True elite E-36; Regent's personal guard before boss arena.

**Lore:** Praetorians were the Regent's levitation honor guard — mages who fused armor to skin before the crash. Only three "survived" as Echo-knights; one patrols the tower still, executing orders from a master who no longer remembers their name.

**Behavior:** `Formation Stand` → `Star Lance` / `Gravity Hold` → `Shield Wall` (invuln front) → `Levitation Burst`.

**Attack patterns:**
1. **Star Lance** — Heavy line 5 tiles; T−0.8s `#E9C46A`. 30 dmg pierce.
2. **Gravity Hold** — Medium; T−0.5s; float player 2s helpless; 0 dmg setup.
3. **Levitation Burst** — Ultimate after Hold; T−1.0s; slam down 34 dmg AoE 3 tiles.

**Weaknesses:** Ley Anchor self during Hold, break shield wall flank (Shadow Blink), interrupt Burst during T−0.3s slam wind-up.

**Visual design:** Full `#264653` star-plate, `#F4A261` cape frozen mid-fall, levitation `#2A9D8F` underglow.

**Animation requirements:** Idle 10 · Patrol 10 · Attack 18 · Hit 5 · Death 20 (fall apart upward)

**Stats:** 300 HP · 18–34 dmg · 1.3 · 140 XP · 65 Essence

**Elemental affinity:** Star/gravity (×1.5 Ley Anchor; ×1.5 void late)

---

## Appendix — Regional Distribution

| Region | Normal IDs | Elite IDs |
|--------|------------|-----------|
| Ashen Threshold | E-01, E-02, E-04, E-08 | E-52 |
| Whisperwood Hollow | E-03, E-07, E-12, E-15, E-18 | E-53 |
| Sunken Catacombs | E-02, E-06, E-09, E-11, E-14, E-20 | E-50 (ossuary) |
| Bleakfen Marsh | E-05, E-10, E-13, E-16, E-19, E-22 | E-50, E-54 |
| Lumineth Caverns | E-17, E-21, E-23, E-25, E-27, E-29 | — |
| Archive of Echoes | E-14, E-24, E-26, E-30, E-32, E-33 | — |
| Skyfall Ruins | E-25, E-28, E-31, E-34, E-36, E-37 | E-55 |
| Obsidian Atelier | E-27, E-33, E-35, E-38, E-39, E-40 | — |
| Sanctum of Ash | E-08, E-20, E-36, E-38, E-40 | E-41, E-52 |
| Undercrown Kingdom | E-17, E-22, E-28†, E-35† | E-42, E-43, E-50, E-51 |
| Somnium Rift | E-26, E-31, E-37, E-44, E-45, E-46 | — |
| Ley Nexus / Unbound | E-44, E-45, E-46, E-47, E-48, E-49 | E-47–E-49 (primary) |

†Undercrown uses fungal/crown variants of IDs also listed elsewhere; see per-enemy variant notes.

### ID Quick Reference (E-01–E-55)

| ID | Name | Tier |
|----|------|------|
| E-01 | Ash Wisp | Normal |
| E-02 | Bone Crawler | Normal |
| E-03 | Bramble Stalker | Normal |
| E-04 | Ember Moth | Normal |
| E-05 | Fen Leech | Normal |
| E-06 | Grave Lantern | Normal |
| E-07 | Mothling Swarm | Normal |
| E-08 | Threshold Shade | Normal (elite-tier stats) |
| E-09 | Drowned Acolyte | Normal |
| E-10 | Will-o-Mire | Normal |
| E-11 | Mosaic Serpent | Normal |
| E-12 | Bark Wraith | Normal |
| E-13 | Bog Maw | Normal |
| E-14 | Urn Wraith | Normal |
| E-15 | Thornweft Larva | Normal |
| E-16 | Stilt Crawler | Normal |
| E-17 | Crystal Crawler | Normal |
| E-18 | Canopy Hunter | Normal (mini-boss tier) |
| E-19 | Memory Eel | Normal |
| E-20 | Reliquary Guard | Normal |
| E-21 | Prism Bat | Normal |
| E-22 | Fenbound Zealot | Normal (elite-tier stats) |
| E-23 | Shard Stalker | Normal |
| E-24 | Page Swarm | Normal |
| E-25 | Lightcut Beam | Normal |
| E-26 | Echo Scholar | Normal |
| E-27 | Gembound Miner | Normal |
| E-28 | Void Leaper | Normal |
| E-29 | Prism Sentinel | Normal |
| E-30 | Ink Elemental | Normal |
| E-31 | Gravity Wraith | Normal |
| E-32 | Catalog Serpent | Normal |
| E-33 | Binding Golem | Normal |
| E-34 | Debris Golem | Normal |
| E-35 | Slag Crawler | Normal |
| E-36 | Starfall Knight | Normal (elite-tier stats) |
| E-37 | Regent's Echo | Normal |
| E-38 | Blueprint Phantom | Normal |
| E-39 | Furnace Mouth | Normal |
| E-40 | Anvil Thrall | Normal |
| E-41 | Ashbound Zealot | Elite |
| E-42 | Spore Cavalry | Elite |
| E-43 | Root Knight | Elite |
| E-44 | Nightmare Fragment | Elite |
| E-45 | Dream Leach | Elite |
| E-46 | Rift Stalker | Elite |
| E-47 | Ley Fragment | Elite |
| E-48 | Unbound Shard | Elite |
| E-49 | Weave Remnant | Elite |
| E-50 | Fen Colossus | Elite |
| E-51 | Crown Devourer | Elite |
| E-52 | Threshold Shade Ascendant | Elite |
| E-53 | Canopy Hunter Brood-Matriarch | Elite |
| E-54 | Fenbound Hierophant | Elite |
| E-55 | Starfall Knight Praetorian | Elite |

---

*End of Enemy Bible. Boss encounter details: [05-boss-bible.md](05-boss-bible.md)*



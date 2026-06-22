# 03 — Art Bible

**Project:** Arcania  
**Genre:** Dark Fantasy 2D Metroidvania  
**Engine:** Godot 4.3+  
**Protagonist:** Elara Veilmark  
**Document version:** 1.0  
**Status:** Production-ready visual spec

> *"The weave is torn. You are the last thread."*

This document is the single source of truth for Arcania's visual identity: style pillars, color systems, character sheets, environment mood boards, UI/UX, VFX, animation principles, and asset export specs. Cross-reference [02-world-design.md](02-world-design.md) for region lore, [07-narrative.md](07-narrative.md) for NPC details, and [06-magic-system.md](06-magic-system.md) for spell VFX hooks.

---

## Table of Contents

1. [Visual Philosophy & Style Pillars](#1-visual-philosophy--style-pillars)
2. [Global Style Token (AI Prompts)](#2-global-style-token-ai-prompts)
3. [Color Philosophy](#3-color-philosophy)
4. [Biome Palettes — All 12 Regions](#4-biome-palettes--all-12-regions)
5. [Elara Veilmark — Design Sheet](#5-elara-veilmark--design-sheet)
6. [NPC Concept Sheets (12)](#6-npc-concept-sheets-12)
7. [Enemy Silhouette Gallery (E-01–E-55)](#7-enemy-silhouette-gallery-e-01e-55)
8. [Boss Concept Sheets (9)](#8-boss-concept-sheets-9)
9. [Environment Mood Boards (12 Regions)](#9-environment-mood-boards-12-regions)
10. [UI/UX Visual Spec](#10-uiux-visual-spec)
11. [VFX Style Guide](#11-vfx-style-guide)
12. [Typography & Icon Style](#12-typography--icon-style)
13. [Animation Style Principles](#13-animation-style-principles)
14. [Asset Export Specs](#14-asset-export-specs)

---

## 1. Visual Philosophy & Style Pillars

### Core Aesthetic

Arcania reads as **hand-drawn 2D dark fantasy** at **64px tile scale**, with player characters at **48–64px** height. The reference touchstone is **Hollow Knight**: strong silhouettes, limited palettes, clean ink-like lines, and combat readability over ornamental detail. Every frame must communicate **threat, mood, and interactability** before beauty.

### Six Style Pillars

| # | Pillar | Rule | Anti-Pattern |
|---|--------|------|--------------|
| 1 | **Silhouette First** | Every character, enemy, and interactable must read at 1× zoom (960×540 viewport). Test in greyscale before color pass. | Busy texture that breaks outline |
| 2 | **Palette Discipline** | Max 5–7 hues per screen; 1 accent color per biome. UI uses global neutrals + cyan mana accent. | Rainbow gradients, photoreal lighting |
| 3 | **Line Weight Hierarchy** | Outer contour: 2px. Inner detail: 1px. VFX glow: no hard outline. Background: softer, thinner strokes. | Uniform line weight everywhere |
| 4 | **Depth via Parallax** | 3–5 parallax layers per region: far (0.2×), mid-far (0.4×), mid (0.6×), near (0.85×), foreground occluders (1.0×). | Flat single-layer backgrounds |
| 5 | **Decay as Beauty** | Erosion, ash, water-stain, and bioluminescent corruption are the visual language — not pristine high fantasy. | Clean marble castles, bright skies |
| 6 | **Telegraph Clarity** | Enemy wind-ups use standardized warm accent (`#FF6B35` ember) + floor marker + 2-frame anticipation squash. | Invisible or frame-perfect attacks |

### Camera & Composition

- **Side-view** with slight vertical freedom (±2 tiles above/below center).
- **Safe zone:** Keep Elara within center third during combat; parallax shifts subtly toward movement direction.
- **Foreground framing:** Use 10–15% screen edge occlusion (vines, pillars, fog) to sell depth without blocking gameplay tiles.

### Parallax Layer Stack (Standard)

```
Layer 5 — Foreground occluders (leaves, chains, fog wisps)     scroll 1.0×
Layer 4 — Gameplay plane (tiles, platforms, entities)          scroll 1.0×
Layer 3 — Mid props (statues, broken furniture, roots)         scroll 0.85×
Layer 2 — Mid-far architecture (walls, distant trees, shelves) scroll 0.6×
Layer 1 — Far silhouettes (mountains, skyline, cavern ceiling) scroll 0.4×
Layer 0 — Sky / void / gradient backdrop                       scroll 0.2×
```

Regions may omit Layer 0 (interior) or add a Layer 6 (full-screen weather overlay at 1.0× with 30% opacity).

---

## 2. Global Style Token (AI Prompts)

**Reuse this prefix on every AI generation prompt in this document and in production:**

```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly
```

### Prompt Suffix Variants

Append one suffix depending on asset type:

| Asset Type | Suffix |
|------------|--------|
| Character / NPC | `, character design sheet, front view, side view, 48-64px scale reference, dark robes, expressive pose` |
| Enemy | `, enemy sprite, readable silhouette, telegraph pose, game enemy design, single creature` |
| Boss | `, large boss creature, dramatic scale 128-256px tall, phase-ready design, arena centerpiece` |
| Environment | `, side-scrolling game background, parallax layers separated, 64px tile grid, moody atmosphere` |
| UI | `, game UI element, flat hand-drawn icons, minimal detail, high contrast, pixel-aligned` |
| VFX | `, game VFX sprite sheet frames, additive glow, 2D particles, spell effect` |

### Negative Prompt (Universal)

```
photorealistic, 3D render, anime, chibi, bright saturated colors, lens flare, bloom overload, text watermark, blurry, noisy gradients, stock photo
```

---

## 3. Color Philosophy

### Global Rules

1. **Shadows are cool, accents are warm.** Base shadows lean blue-grey (`#1A1A2E`–`#2C2C34`); combat accents and Ember Sigil effects use warm orange (`#FF6B35`).
2. **One scream color per screen.** Each biome has a single high-chroma accent (ember orange, lantern cyan, ley magenta) used sparingly for interactables, telegraphs, and spell hits.
3. **Desaturation = danger.** Memory fog, Somnium zones, and low-HP states reduce saturation 20–40% before applying damage tint.
4. **Mana = cyan, Health = bone-white, Overcast = crimson.** These three UI/VFX colors never appear as large environment fills.
5. **Faction color keys** (for NPC silhouettes and graffiti):
   - Veiled Conclave: null-white `#E8E8E8` + ink-black `#0B090A`
   - Thornbound: moss green `#52B788` + bark brown `#3E2723`
   - Archive Keepers: candle blue `#0077B6` + parchment `#CAF0F8`
   - Undercrown Loyalists: crown red `#D90429` + pale stone `#EDF2F4`
   - Unbound: static magenta `#FF0099` + void `#000000`

### Material Vocabulary

| Material | Treatment |
|----------|-----------|
| Stone | Flat fill + 1px crack lines; no texture photos |
| Wood / bark | Horizontal grain strokes, 2-tone |
| Water | 2-frame shimmer loop; darker than sky |
| Metal | Sharp highlight wedge (1–2px), desaturated |
| Magic / ley | Additive glow, 2–3 color ramp max |
| Ash / fog | Soft dithered edges, 40–60% opacity overlay |

---

## 4. Biome Palettes — All 12 Regions

Each region uses **5 core hex codes**. Accent is the "scream color" for interactables and telegraphs.

### 01 — Ashen Threshold (Hub)

| Role | Hex | Name |
|------|-----|------|
| Shadow | `#1A1A2E` | Deep shadow |
| Base | `#2C2C34` | Charcoal stone |
| Mid | `#4A4E69` | Twilight slate |
| Warm | `#8B4513` | Burnt umber |
| Accent | `#FF6B35` | Ember orange |

**Mood:** Melancholic waystation — perpetual ember fog, faded insignia, pilgrim ruins. Safe but sad.

---

### 02 — Whisperwood Hollow

| Role | Hex | Name |
|------|-----|------|
| Shadow | `#081C15` | Root black |
| Base | `#1B4332` | Deep pine |
| Mid | `#40916C` | Canopy mid |
| Light | `#52B788` | Moss green |
| Accent | `#D8F3DC` | Spore glow |

**Mood:** Grieving organism — bioluminescent spores, woven bark bridges, moth swarms.

---

### 03 — Sunken Catacombs

| Role | Hex | Name |
|------|-----|------|
| Shadow | `#0B090A` | Void black |
| Base | `#495867` | Wet slate |
| Mid | `#5C677D` | Flood stone |
| Neutral | `#C9ADA7` | Bone dust |
| Accent | `#B1FAFF` | Lantern cyan |

**Mood:** Drowned Gothic — waist-deep water, bone mosaics, ghost lanterns seeking their urns.

---

### 04 — Bleakfen Marsh

| Role | Hex | Name |
|------|-----|------|
| Shadow | `#1A1A1D` | Peat black |
| Base | `#4E5D5C` | Moss grey |
| Mid | `#6B9080` | Fen green |
| Mist | `#AEC3B0` | Dead mist |
| Accent | `#E8E8E8` | Wisp white |

**Mood:** Memory-sinking wetland — stagnant water, dead cypress, rotting docks, regret made liquid.

---

### 05 — Lumineth Caverns

| Role | Hex | Name |
|------|-----|------|
| Shadow | `#10002B` | Deep amethyst |
| Base | `#3C096C` | Cavern shadow |
| Mid | `#7B2CBF` | Crystal violet |
| Light | `#E0AAFF` | Pale prism |
| Accent | `#FFD60A` | Reflected gold |

**Mood:** Beautiful and lethal — prismatic crystals, light that cuts, embedded miner silhouettes.

---

### 06 — Archive of Echoes

| Role | Hex | Name |
|------|-----|------|
| Shadow | `#03045E` | Ink navy |
| Base | `#023E8A` | Shelf dark |
| Mid | `#0077B6` | Candle blue |
| Light | `#90E0EF` | Page white-blue |
| Accent | `#CAF0F8` | Echo pale |

**Mood:** Living library — infinite shelves, ink rivers, translucent echo silhouettes on loop.

---

### 07 — Skyfall Ruins

| Role | Hex | Name |
|------|-----|------|
| Shadow | `#0D0221` | Void purple |
| Base | `#264653` | Teal stone |
| Mid | `#2A9D8F` | Sky jade |
| Warm | `#E9C46A` | Star gold |
| Accent | `#F4A261` | Dawn orange |

**Mood:** Celestial tragedy — floating debris, inverted gravity, a city frozen mid-collapse.

---

### 08 — Obsidian Atelier

| Role | Hex | Name |
|------|-----|------|
| Shadow | `#0A0A0A` | Obsidian black |
| Base | `#370617` | Deep crimson |
| Mid | `#6A040F` | Cooling ember |
| Hot | `#DC2F02` | Forge orange |
| Accent | `#FFBA08` | Molten yellow |

**Mood:** Forbidden forge — weaponized magic, molten channels, ash snow indoors.

---

### 09 — Sanctum of Ash

| Role | Hex | Name |
|------|-----|------|
| Shadow | `#212529` | Ash charcoal |
| Base | `#6C757D` | Cinder grey |
| Mid | `#FFDDD2` | Ash white |
| Warm | `#F48C06` | Pyre orange |
| Accent | `#E5383B` | Blood ember |

**Mood:** Cathedral of the last burn — eternal indoor ash-fall, melted stained glass, pyre altars.

---

### 10 — Undercrown Kingdom

| Role | Hex | Name |
|------|-----|------|
| Shadow | `#2B2D42` | Deep earth |
| Base | `#8D99AE` | Fungal grey |
| Light | `#EDF2F4` | Spore white |
| Royal | `#EF233C` | Crown red |
| Accent | `#D90429` | Royal crimson |

**Mood:** Subterranean monarchy — bioluminescent mushrooms, throne roots, insect cavalry, buried crown.

---

### 11 — Somnium Rift

| Role | Hex | Name |
|------|-----|------|
| Shadow | `#240046` | Dream purple |
| Base | `#5A189A` | Rift violet |
| Mid | `#C77DFF` | Dream pink |
| Light | `#E0AAFF` | Pale unreal |
| Accent | `#FF6D00` | Nightmare accent |

**Mood:** Wound in dreaming — impossible geometry, color-inverted zones, floating text platforms.

---

### 12 — Ley Nexus + The Unbound

| Role | Hex | Name |
|------|-----|------|
| Shadow | `#000000` | Void |
| Base | `#7F00FF` | Ley magenta |
| Mid | `#00FFFF` | Nexus cyan |
| Pure | `#FFFFFF` | Pure weave |
| Accent | `#FF0099` | Corruption pink |

**Mood:** Torn heart of the Weave — raw ley strands, geometric void, reality thin as glass.

---

## 5. Elara Veilmark — Design Sheet

### Identity Summary

| Field | Detail |
|-------|--------|
| **Age** | 19 (appears 22 post-stasis) |
| **Build** | Lean, medium height; 56px in-game (64px with hood) |
| **Faction origin** | Veiled Conclave apprentice — **Veilmarked** (disgraced) |
| **Signature feature** | **Ember Sigil** — orange glow on **left palm**, visible through fingerless glove |
| **Silhouette hook** | Tattered asymmetric robe hem + left-hand glow + optional hood horn |

### Costume — Veiled Conclave Apprentice Garb

- **Robe:** Layered dark charcoal (`#2C2C34`) with threadbare edges; Conclave geometric trim faded to `#4A4E69`.
- **Hood:** Optional in gameplay; up = narrower silhouette + mystery; down = visible dark hair, shoulder-length, messy.
- **Underlayer:** Deep plum tunic (`#3D1F47`), visible at tears.
- **Belt:** Null-thread wrap (grey `#8D99AE`) — Corin's bind marks from Act I.
- **Footwear:** Wrapped boots, mud-stained from Threshold/Marsh.
- **Hands:** Right hand gloved (combat); **left hand bare** for Sigil casting.

### Robe Tiers (Visual Progression)

Aligned with [06-magic-system.md](06-magic-system.md) equipment tiers. Each tier adds visible weave stitching and sigil embroidery.

| Tier | Name | Visual Changes |
|------|------|----------------|
| 1 | **Ash-Worn Novice** | Default tattered garb; single faded Veilmark insignia on chest (cracked) |
| 2 | **Threadbare Adept** | Patched elbows; thin cyan stitch line at cuffs (+mana hint) |
| 3 | **Ley-Stitched Mantle** | Glowing ley thread embroidery on hem; insignia partially restored |
| 4 | **Conclave Remnant** | Shoulder mantle added; null-white trim returns; hood lined with script |
| 5 | **Nexus Weaver** | Full constellation pattern on back; left palm glow extends to forearm; robe edge particles |

### Turnaround Notes

| View | Key Details |
|------|-------------|
| **Front** | Hood frames face; Sigil glow on left palm center; robe asymmetry (longer left hem) |
| **Side** | Hood point or hair bun; robe layers visible; hand glow reads as brightest point |
| **Back** | Veilmark insignia (tier-dependent); tattered cape split; no glow except Tier 5 forearm trace |

### Ember Sigil VFX

| State | Visual |
|-------|--------|
| **Idle** | 2-frame pulse on palm; `#FF6B35` core, `#FFD60A` outer 30% opacity |
| **Cast wind-up** | Glow intensifies; 3px ember particles rise from palm |
| **Cast release** | Radial flash 4px; projectile/spawn point |
| **Overcast** | Glow shifts crimson `#E5383B`; hair flicker shadow |
| **Low HP** | Pulse becomes irregular; static crackle on Sigil edge |
| **Sigil Recall** | Palm glow threads outward into floor rune circle |

### AI Generation Prompt — Elara Turnaround

```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, character design sheet, front view side view back view, young woman mage Elara Veilmark, dark tattered Veiled Conclave apprentice robes, optional hood, ember orange glow on left palm, fingerless right glove, faded geometric insignia on chest, charcoal and plum palette, 48-64px game character scale reference, dark fantasy metroidvania protagonist
```

---

## 6. NPC Concept Sheets (12)

Each NPC includes role, visual key, palette, and AI prompt. Sympathy/quest details in [07-narrative.md](07-narrative.md).

---

### 6.1 Magister Corin — Story / Mentor

| Field | Detail |
|-------|--------|
| **Location** | Ashen Threshold → Veil Crossing → Weaveheart |
| **Silhouette** | Tall, slight stoop; null-rope at belt; no hood |
| **Costume** | Faded Conclave magister coat (null-white `#E8E8E8` stained ash), ink-black `#0B090A` inner robe, cracked focus orb on chain |
| **Face** | Weathered, short grey beard, tired eyes; never fully smiles |
| **Prop** | Null-thread coils; field journal |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, NPC character design, elderly disgraced magister mentor, faded white and black Conclave robes, null-thread rope at belt, cracked orb pendant, weary posture, side view game sprite, dark fantasy
```

---

### 6.2 Sister Maelis — Story / Archive Keeper

| Field | Detail |
|-------|--------|
| **Location** | Sunken Archive scriptorium |
| **Silhouette** | Straight posture; bell-shaped shoulder outline |
| **Costume** | Blue-grey keeper robes `#0077B6`, bell motif brooch, ink-stained cuffs |
| **Face** | Sharp features, hair in tight knot; expression neutral |
| **Prop** | Ledger book, archive lens prototype |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, NPC character design, female archive keeper, blue-grey robes, bell motif brooch, precise stern posture, ink-stained hands, candle blue palette, side view game sprite
```

---

### 6.3 The Thornspeaker — Story / Thornbound Leader

| Field | Detail |
|-------|--------|
| **Location** | Whisperwood Heartwood Grove |
| **Silhouette** | Not human — bark effigy, 96px tall, antler-root crown |
| **Costume** | Living wood body, thorn vines, glowing moss eyes `#D8F3DC` |
| **Face** | Carved bark face; mouth doesn't move (voice from wood) |
| **Prop** | Thornseed cluster embedded in chest |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, NPC character design, ancient bark effigy druid collective, antler root crown, glowing moss eyes, thorn vines, large 96px tall tree spirit, Whisperwood green palette, side view game sprite
```

---

### 6.4 Peddler Ash — Merchant

| Field | Detail |
|-------|--------|
| **Location** | Ashen Threshold mobile camp |
| **Silhouette** | Hunched, oversized pack, wide hat brim |
| **Costume** | Patchwork scavenger coat `#8B4513`, rope belts, mismatched boots |
| **Face** | Scar across cheek, suspicious squint |
| **Prop** | Barter crate, map scraps |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, NPC merchant character, hunched scavenger trader, oversized backpack, wide brim hat, patchwork brown coat, gruff expression, side view game sprite, Ashen Threshold palette
```

---

### 6.5 Wraithmonger Vex — Black Market Merchant

| Field | Detail |
|-------|--------|
| **Location** | Catacombs hidden niche |
| **Silhouette** | Androgynous, long coat tails, floating relic orbs |
| **Costume** | Bone-white duster over black `#0B090A`, reliquary pins, face half-shadow |
| **Face** | Sharp smile; one eye covered by relic shard |
| **Prop** | Movable shelf lever, whisper skull |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, NPC merchant character, androgynous black market dealer, bone white long coat, reliquary pins, floating ghostly orbs, charming sinister pose, catacomb bone palette, side view game sprite
```

---

### 6.6 Elder Bryn — Trainer

| Field | Detail |
|-------|--------|
| **Location** | Whisperwood Root Altar |
| **Silhouette** | Compact, bark-armor shoulders, silent gesture hands |
| **Costume** | Thornbound bark pauldrons `#40916C`, root-wrapped arms, mute scarf |
| **Face** | Burn scars, intense eyes; communicates via root-sign |
| **Prop** | Root altar staff, Thornseed pouch |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, NPC trainer character, young Thornbound druid woman, bark armor shoulders, burn scars, gesturing hands root-sign language, moss green palette, stern patient expression, side view game sprite
```

---

### 6.7 The Hollow Scribe — Trainer

| Field | Detail |
|-------|--------|
| **Location** | Sunken Archive Flooded Annex |
| **Silhouette** | Hollow body — gap ribcage, oversized quill arm |
| **Costume** | Dissolving water-parchment strips draped on bone frame |
| **Face** | Smooth hollow mask; ink tears |
| **Prop** | Naming Quill, water-soluble spell scrolls |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, NPC character design, sapient Hollow creature, skeletal ribcage silhouette, oversized ink quill arm, water parchment strips, gentle melancholic pose, lantern cyan and bone palette, side view game sprite
```

---

### 6.8 Fenwick the Lost — Quest Giver

| Field | Detail |
|-------|--------|
| **Location** | Bleakfen Marsh lantern path |
| **Silhouette** | Translucent ferryman, pole in hand, 50% opacity legs |
| **Costume** | Waterlogged coat `#4E5D5C`, lantern at belt |
| **Face** | Cheerful unfocused eyes; doesn't notice he's dead |
| **Prop** | Ferry pole, manifest book |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, NPC ghost character, translucent ferryman, waterlogged grey coat, lantern at belt, cheerful lost expression, semi-transparent lower body, marsh fog palette, side view game sprite
```

---

### 6.9 Captain Rell — Quest Giver

| Field | Detail |
|-------|--------|
| **Location** | Undercrown Blockade Gate |
| **Silhouette** | Broad shoulders, pale stone armor, root-gold mosaic on chest |
| **Costume** | Pale Guard plate `#EDF2F4`, crown sigil `#D90429`, engineer's tools on hip |
| **Face** | Square jaw, grief lines; short cropped hair |
| **Prop** | Root-engineer's wrench-spear |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, NPC soldier character, broad shouldered captain, pale stone armor, red crown sigil mosaic on chest, blunt duty-bound posture, Undercrown fungal grey palette, side view game sprite
```

---

### 6.10 Dreamer Liora — Quest Giver

| Field | Detail |
|-------|--------|
| **Location** | Somnium border shrine |
| **Silhouette** | Split design — half solid, half dream-faded; student robes |
| **Costume** | Conclave student white `#E8E8E8` fading to dream violet `#C77DFF` |
| **Face** | Hopeful, young; one eye slightly glitched |
| **Prop** | Dream-silk spindle, shrine candles |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, NPC character design, young dream magic student, Conclave robes fading into purple dream mist, half body translucent, hopeful expression, Somnium violet palette, side view game sprite
```

---

### 6.11 The Last Page — Hidden NPC

| Field | Detail |
|-------|--------|
| **Location** | Archive restricted stacks (Archive Lens + midnight bell) |
| **Silhouette** | Floating parchment sheet with faint face |
| **Costume** | Yellowed codex page `#CAF0F8`, footnote text borders, ink face |
| **Face** | Sketched in margin ink; eyes are periods that blink |
| **Prop** | Excised text fragments orbiting |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, NPC character design, living floating book page with faint human face in ink, footnote text border, tragic erudite expression, parchment and navy palette, side view game sprite
```

---

### 6.12 The Unwritten Child — Hidden NPC

| Field | Detail |
|-------|--------|
| **Location** | Somnium looping classroom (4+ Memory Shards) |
| **Silhouette** | Child-shaped static void; edges glitch |
| **Costume** | Empty Conclave student uniform outline, no fill — static noise interior |
| **Face** | Sometimes young, sometimes ancient; features shift |
| **Prop** | Seventh empty desk, unnamed nameplate |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, NPC character design, child-shaped void silhouette, static glitch interior, empty Conclave uniform outline, contradictory ancient and childlike, magenta static accent, Somnium dream palette, side view game sprite
```

---

## 7. Enemy Silhouette Gallery (E-01–E-55)

Enemies grouped by primary biome. Stats and AI in [04-enemy-bible.md](04-enemy-bible.md) (planned). **10 representative enemies** include full AI prompts; remaining entries are silhouette briefs for batch generation.

### Design Rules (All Enemies)

- Height: **24–48px** standard; **48–72px** elite; readable at 1× zoom.
- **Telegraph color:** `#FF6B35` warm accent on wind-up frames.
- **Death:** 4–6 frame dissolve (not gore); palette desaturates then shatters.
- **Variant enemies** share base silhouette with palette swap + 1 unique accessory.

---

### 7.1 Ashen Threshold

| ID | Name | Silhouette Brief |
|----|------|------------------|
| E-01 | Ash Wisp | Small floating teardrop + trailing ash tail; swarm unit |
| E-02 | Bone Crawler | Low centipede of rib bones; 3-segment body |
| E-04 | Ember Moth | Wide wing V-shape; ember abdomen dot |
| E-08 | Threshold Shade | Humanoid void with ember eye slits; elite height 56px |

---

### 7.2 Whisperwood Hollow

| ID | Name | Silhouette Brief |
|----|------|------------------|
| E-03 | Bramble Stalker | Flattened against bark; reveals thorn limbs |
| E-07 | Mothling Swarm | Cluster of tiny E-04 shapes |
| E-12 | Bark Wraith | Tall tree-slim wraith; branch arms |
| E-15 | Thornweft Larva | Bulbous silk sac + needle mouth |
| E-18 | Canopy Hunter | Arachnid jumper; long jointed legs |

---

### 7.3 Sunken Catacombs

| ID | Name | Silhouette Brief |
|----|------|------------------|
| E-06 | Grave Lantern | Floating orb + chain tail; explosion telegraph swell |
| E-09 | Drowned Acolyte | Robed figure rising from water; grab arms up |
| E-11 | Mosaic Serpent | Flat serpent with tile-pattern back |
| E-14 | Urn Wraith | Floating urn + wispy arms |
| E-20 | Reliquary Guard | Shield-bearing skeleton; formation unit |

---

### 7.4 Bleakfen Marsh

| ID | Name | Silhouette Brief |
|----|------|------------------|
| E-05 | Fen Leech | Surface ripple + latch mouth |
| E-10 | Will-o-Mire | Small wisp `#E8E8E8`; lure glow |
| E-13 | Bog Maw | Ground trap jaws; only mouth visible |
| E-16 | Stilt Crawler | Long-legged insect on stilts |
| E-19 | Memory Eel | Serpentine eel + mana siphon spark |
| E-22 | Fenbound Zealot | Hooded cultist on platform; spit pose |

---

### 7.5 Lumineth Caverns

| ID | Name | Silhouette Brief |
|----|------|------------------|
| E-17 | Crystal Crawler | Gem-backed beetle; wall cling |
| E-21 | Prism Bat | Angular bat wings; prism chest |
| E-23 | Shard Stalker | Wolf-like; glass shard trail |
| E-25 | Lightcut Beam | Turret crystal + rotating beam emitter |
| E-27 | Gembound Miner | Hunched miner + pickaxe |
| E-29 | Prism Warden | Crystal golem; mini-boss 80px |

---

### 7.6 Archive of Echoes

| ID | Name | Silhouette Brief |
|----|------|------------------|
| E-24 | Page Swarm | Flying paper sheets; cut edges |
| E-26 | Echo Scholar | Translucent mage copy of Elara |
| E-30 | Ink Elemental | Puddle body + rising tendrils |
| E-32 | Catalog Serpent | Drawer-segment serpent body |
| E-33 | Binding Golem | Shelf-shaped torso; chain arms |

---

### 7.7 Skyfall Ruins

| ID | Name | Silhouette Brief |
|----|------|------------------|
| E-28 | Void Leaper | Lean jumper; void trail |
| E-31 | Gravity Wraith | Inverted silhouette; gravity ring |
| E-34 | Debris Golem | Rolling boulder with limb stubs |
| E-36 | Starfall Knight | Armored knight + lance + shield |
| E-37 | Regent's Echo | Floating mage + levitation orbs |

---

### 7.8 Obsidian Atelier

| ID | Name | Silhouette Brief |
|----|------|------------------|
| E-35 | Slag Crawler | Molten slug trail |
| E-38 | Blueprint Phantom | Flat schematic ghost + turret summon |
| E-39 | Furnace Mouth | Stationary furnace face; breath cone |
| E-40 | Anvil Thrall | Hammer-wielding forge thrall |

---

### 7.9 Sanctum of Ash

| ID | Name | Silhouette Brief |
|----|------|------------------|
| E-41 | Ashbound Zealot | Robed runner; self-destruct swell |

*(E-08, E-20, E-36, E-38, E-40 appear as regional variants)*

---

### 7.10 Undercrown Kingdom

| ID | Name | Silhouette Brief |
|----|------|------------------|
| E-28 | Fen Colossus | Massive fungal brute; secret zone elite |
| E-35 | Crown Devourer | Vault elite; crown-shaped jaw |
| E-42 | Spore Cavalry | Insect mount + rider silhouette |
| E-43 | Root Knight | Heavy root armor; slow wide stance |

---

### 7.11 Somnium Rift

| ID | Name | Silhouette Brief |
|----|------|------------------|
| E-44 | Nightmare Fragment | Procedural blob; region-themed mask |
| E-45 | Dream Leach | Floating leech + mana drain aura ring |
| E-46 | Rift Stalker | Teleport predator; after-image frames |

---

### 7.12 Ley Nexus

| ID | Name | Silhouette Brief |
|----|------|------------------|
| E-47 | Ley Fragment | Orbiting ley shard; hazard unit |
| E-48 | Unbound Shard | Boss add; static crystal |
| E-49 | Weave Remnant | Elite; rotating element rings |

---

### 7.13 Cross-Region / Faction (Reserved)

| ID | Name | Silhouette Brief |
|----|------|------------------|
| E-50 | Purifier Acolyte | Conclave null-white hood; purification blade |
| E-51 | Hollow Wretch | Generic Hollow; gap-torso scramble |
| E-52 | Static Crawler | Unbound insect; glitch legs |
| E-53 | Corruption Mote | Waystone node enemy; pulsing fracture |
| E-54 | Ley Serpent | Nexus corridor; strand-bodied serpent |
| E-55 | Weave Parasite | Final gauntlet elite; thread-wrapped orb core |

---

### 7.14 Representative Enemy AI Prompts (10)

**E-01 Ash Wisp:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, enemy sprite, small floating ash wisp creature, teardrop body trailing ember particles, simple readable silhouette, charcoal and ember orange palette, game enemy design, side view
```

**E-03 Bramble Stalker:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, enemy sprite, forest ambush predator camouflaged as bark, thorn limbs, Whisperwood green palette, camouflage reveal pose, game enemy design, side view
```

**E-09 Drowned Acolyte:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, enemy sprite, drowned robed acolyte rising from water, grab attack pose, wet slate and lantern cyan palette, catacomb enemy, side view
```

**E-13 Bog Maw:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, enemy sprite, marsh pit trap creature, giant jaws emerging from ground, peat black and fen green palette, telegraphed chomp pose, side view
```

**E-21 Prism Bat:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, enemy sprite, crystal cave bat, angular wings, prism chest gem, violet and gold palette, Lumineth cavern enemy, side view
```

**E-26 Echo Scholar:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, enemy sprite, translucent ghost mage echo, copying spell pose, ink navy and pale blue palette, archive enemy, side view
```

**E-34 Debris Golem:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, enemy sprite, rolling skyfall debris boulder golem, stone limbs, void purple and teal palette, Skyfall Ruins enemy, side view
```

**E-38 Blueprint Phantom:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, enemy sprite, schematic blueprint ghost, flat technical line body, forge orange and obsidian black palette, ranged summoner enemy, side view
```

**E-43 Root Knight:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, enemy sprite, heavy fungal root armored knight, wide stance, crown red accent, Undercrown Kingdom enemy, side view
```

**E-49 Weave Remnant:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, enemy elite sprite, rotating elemental rings around humanoid weave remnant, ley magenta and nexus cyan palette, Ley Nexus enemy, side view
```

---

## 8. Boss Concept Sheets (9)

Eight major bosses + final boss **The Unbound**. Scale: mini-bosses **80–96px**, major bosses **128–192px**, final boss **256px+** (arena-relative).

---

### 8.1 Thornweft Matron — Whisperwood Mini-Boss

| Field | Detail |
|-------|--------|
| **Arena** | Canopy heartwood chamber |
| **Silhouette** | Bloated silk moth body + thorn legs; 96px |
| **Phases** | Silk web / larva spawn / enraged flutter |
| **Palette** | `#1B4332`, `#D8F3DC`, `#40916C` |
| **VFX** | Silk strands, spore bursts, larva pods |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, large boss creature, bloated thorn silk moth matron, multiple thorn legs, silk web accents, spore glow, 96px game boss scale, Whisperwood green palette, dramatic side view, arena centerpiece
```

---

### 8.2 Index Hydra — Archive Mini-Boss

| Field | Detail |
|-------|--------|
| **Arena** | Central catalog chamber |
| **Silhouette** | Multi-headed card-catalog drawer serpent; 112px |
| **Phases** | Drawer bite / page storm / catalog collapse |
| **Palette** | `#03045E`, `#0077B6`, `#CAF0F8` |
| **VFX** | Flying index cards, ink splashes |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, large boss creature, index catalog hydra made of card catalog drawers, multiple drawer heads, ink navy and candle blue palette, 112px game boss, library archive boss, side view
```

---

### 8.3 Anvil Ascendant — Atelier Mini-Boss

| Field | Detail |
|-------|--------|
| **Arena** | Central forge |
| **Silhouette** | Hammer-golem fused to anvil torso; 104px |
| **Phases** | Hammer combo / forge blast / overheating |
| **Palette** | `#0A0A0A`, `#DC2F02`, `#FFBA08` |
| **VFX** | Spark showers, molten splash, ash snow |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, large boss creature, forge golem fused with anvil body, giant hammer arms, molten cracks, obsidian black and forge orange palette, 104px game boss, side view
```

---

### 8.4 Starfall Regent — Skyfall Main Boss

| Field | Detail |
|-------|--------|
| **Arena** | Highest intact tower platform |
| **Silhouette** | Mage fused with levitation engine; robes merge into metal; 144px |
| **Phases** | Orbiting debris / gravity invert / engine meltdown |
| **Palette** | `#0D0221`, `#E9C46A`, `#F4A261` |
| **VFX** | Levitation orbs, void gaps, star gold trails |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, large boss creature, mage fused with celestial levitation engine, robes merging into brass machinery, floating orbs, star gold accents, void purple palette, 144px game boss, Skyfall Ruins, dramatic side view
```

---

### 8.5 Pyre Cardinal Voss — Sanctum Main Boss

| Field | Detail |
|-------|--------|
| **Arena** | Pyre nave, eternal ash-fall |
| **Silhouette** | Ashbound shepherd; face obscured by ash cowl; ember staff; 136px |
| **Phases** | Curse pulse / pyre summon / ash consumption |
| **Palette** | `#212529`, `#E5383B`, `#F48C06` |
| **VFX** | Void Mirror reflect beams, pyre pillars, indoor ash |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, large boss creature, ashbound cardinal shepherd, ash obscured face, ember staff, pyre orange and blood ember palette, 136px game boss, cathedral fire boss, side view
```

---

### 8.6 Queen Mycelis — Undercrown Main Boss

| Field | Detail |
|-------|--------|
| **Arena** | Spore throne chamber |
| **Silhouette** | Humanoid queen with fungal crown symbiote; two-phase form shift; 128px → 160px |
| **Phases** | Royal human / spore spread / alien bloom |
| **Palette** | `#2B2D42`, `#D90429`, `#EDF2F4` |
| **VFX** | Spore clouds, root eruptions, crown fracture |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, large boss creature, fungal queen with symbiote crown, two phase design human and alien, spore palace palette, crimson crown accent, 128-160px game boss, Undercrown Kingdom, side view
```

---

### 8.7 Somnium Warden — Somnium Main Boss

| Field | Detail |
|-------|--------|
| **Arena** | Rift center, impossible geometry |
| **Silhouette** | Gatekeeper made of floating region fragments; 152px |
| **Phases** | Region remix shields / geometry shift / dream collapse |
| **Palette** | `#240046`, `#C77DFF`, `#FF6D00` |
| **VFX** | Platform rearrange, color invert wash, static tears |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, large boss creature, dream rift warden made of floating landscape fragments, impossible geometry, dream purple and nightmare orange palette, 152px game boss, Somnium Rift, side view
```

---

### 8.8 Mirror Elara — Somnium Mini-Boss

| Field | Detail |
|-------|--------|
| **Arena** | Reflective dream platform |
| **Silhouette** | Exact Elara mirror; inverted colors; 56px |
| **Phases** | Spell copy / sigil duel / shatter |
| **Palette** | Inverted Elara palette; static `#FF0099` edge |
| **VFX** | Mirror crack, spell reflection, piano duel particles |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, boss character, mirror duplicate of dark fantasy mage protagonist, inverted color palette, static glitch edge, ember sigil on left hand, dream purple background, 56px duel boss, side view
```

---

### 8.9 The Unbound — Final Boss

| Field | Detail |
|-------|--------|
| **Arena** | Ley Nexus core — geometric void |
| **Silhouette** | No fixed form — entropy silhouette; central eye of ley strands; 256px |
| **Phases** | 12 region corruptions (one per spell counter) / weave unravel / choice moment |
| **Palette** | `#000000`, `#7F00FF`, `#00FFFF`, `#FF0099`, `#FFFFFF` |
| **VFX** | All region leitmotif colors, spell-sequence triggers, re-weave finale |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, final boss creature, entropy principle given form, shifting void silhouette, ley magenta and nexus cyan strands, geometric void background, corruption pink accents, 256px epic scale, cosmic dark fantasy final boss, side view
```

---

## 9. Environment Mood Boards (12 Regions)

One AI prompt per region. Deliverables: **5 parallax layers** (PNG strips) + **64px tileset** + **prop sheet**.

---

### 9.1 Ashen Threshold

**Mood:** Collapsed pilgrim crossing, ember fog, cracked ley pavement, faded Veilmark insignia, brazier processional route.

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, side-scrolling game background parallax layers, ruined waystation hub, collapsed archways, ember fog, cracked ley stone pavement, charcoal and ember orange palette, 64px tile grid, melancholic dark fantasy atmosphere, separated parallax layers
```

---

### 9.2 Whisperwood Hollow

**Mood:** Sentient forest, hollow trees, bioluminescent spores, woven bark bridges, moth swarms.

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, side-scrolling game background parallax layers, grieving sentient forest, towering hollow trees, moss bridges, spore glow, deep pine and pale green palette, 64px tile grid, organic dark fantasy, separated parallax layers
```

---

### 9.3 Sunken Catacombs

**Mood:** Waist-deep water corridors, bone mosaics, sunken reliquaries, ghost lanterns.

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, side-scrolling game background parallax layers, drowned burial catacombs, flooded stone corridors, bone mosaic floors, ghost lantern cyan glow, wet slate palette, 64px tile grid, gothic dark fantasy, separated parallax layers
```

---

### 9.4 Bleakfen Marsh

**Mood:** Stagnant black water, dead cypress, fog banks, rotting stilt docks, will-o-wisps.

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, side-scrolling game background parallax layers, memory-sinking marsh wetland, dead cypress trees, rotting stilt docks, fog banks, peat black and wisp white palette, 64px tile grid, swamp dark fantasy, separated parallax layers
```

---

### 9.5 Lumineth Caverns

**Mood:** Prismatic crystal formations, light refraction, vertical shafts, embedded miner silhouettes.

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, side-scrolling game background parallax layers, crystal ley caverns, prismatic formations, sharp light beams, deep amethyst and violet palette, reflected gold accents, 64px tile grid, beautiful dangerous cave, separated parallax layers
```

---

### 9.6 Archive of Echoes

**Mood:** Infinite shelves, floating pages, ink rivers, echo silhouettes, candle pools.

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, side-scrolling game background parallax layers, living infinite library, towering bookshelves, ink rivers, floating pages, candle blue glow, ink navy palette, 64px tile grid, dark fantasy archive, separated parallax layers
```

---

### 9.7 Skyfall Ruins

**Mood:** Floating debris, inverted gravity zones, broken skybridges over void, star-scarred stone.

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, side-scrolling game background parallax layers, crashed celestial city ruins, floating platforms, void gaps, broken bridges, void purple and star gold palette, 64px tile grid, tragic sky dark fantasy, separated parallax layers
```

---

### 9.8 Obsidian Atelier

**Mood:** Obsidian furnaces, molten channels, anvil stations, scorched blueprints, indoor ash snow.

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, side-scrolling game background parallax layers, forbidden spell forge atelier, obsidian furnaces, molten channels, anvil stations, forge orange and molten yellow palette, 64px tile grid, industrial dark fantasy, separated parallax layers
```

---

### 9.9 Sanctum of Ash

**Mood:** Indoor eternal ash-fall, melted stained glass, pyre altars, ember statues.

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, side-scrolling game background parallax layers, ash cathedral sanctum, eternal falling ash indoors, melted stained glass, pyre altars, blood ember and pyre orange palette, 64px tile grid, sacred fire dark fantasy, separated parallax layers
```

---

### 9.10 Undercrown Kingdom

**Mood:** Bioluminescent mushroom palaces, throne roots, spore markets, buried crown vaults.

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, side-scrolling game background parallax layers, subterranean fungal kingdom, bioluminescent mushrooms, throne roots, spore palace, crown red accents, deep earth palette, 64px tile grid, dark fantasy underworld, separated parallax layers
```

---

### 9.11 Somnium Rift

**Mood:** Impossible geometry, memory fragment platforms, color-inverted zones, floating text.

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, side-scrolling game background parallax layers, dream rift impossible geometry, floating memory platforms, color inverted zones, floating text fragments, dream purple and nightmare orange palette, 64px tile grid, surreal dark fantasy, separated parallax layers
```

---

### 9.12 Ley Nexus + The Unbound

**Mood:** Floating ley strands, geometric void, crystallized time, Unbound silhouette at core.

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, side-scrolling game background parallax layers, torn ley nexus heart, floating ley strands, geometric void, crystallized time shards, ley magenta and nexus cyan palette, corruption pink accents, 64px tile grid, cosmic final dungeon, separated parallax layers
```

---

## 10. UI/UX Visual Spec

### Global UI Principles

- **Hand-drawn flat icons** — 1px outline, no gradients except mana/health bars.
- **Paper/parchment panels** for menus; **stone/ley circles** for in-world UI (Waystones).
- **Opacity:** HUD 85% background on bars only; icons fully opaque.
- **Safe margins:** 16px from viewport edge at 960×540.

### Color Tokens (UI)

| Token | Hex | Use |
|-------|-----|-----|
| `ui-bg-dark` | `#1A1A2E` | Panel fill |
| `ui-bg-light` | `#2C2C34` | Panel border |
| `ui-text` | `#E8E8E8` | Primary text |
| `ui-text-dim` | `#8D99AE` | Secondary text |
| `ui-accent` | `#00FFFF` | Mana, selected state |
| `ui-danger` | `#E5383B` | HP, overcast |
| `ui-warm` | `#FF6B35` | Ember/Sigil highlights |

---

### 10.1 HUD

**Layout (960×540):**
- **Top-left:** HP bar (bone-white fill `#FFDDD2`, dark bg), Mana bar below (cyan `#00FFFF`).
- **Top-right:** Mini-map corner (64×64), shard/relic icons.
- **Bottom-center:** Spell quick-slots (4 visible) + active spell name fade.
- **Bottom-left:** Overcast bleed indicator (crimson edge on mana bar).

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, game HUD overlay, health bar mana bar, minimal dark fantasy UI, cyan mana accent, bone white health, corner minimap frame, 960x540 layout reference, flat hand-drawn icons
```

---

### 10.2 Map Screen

- Full-screen parchment `#CAF0F8` aged to `#C9ADA7` at edges.
- Unexplored: ink blot `#0B090A`.
- Explored: region color at 40% opacity.
- Player marker: Ember Sigil dot `#FF6B35`.
- Waystones: ley fracture circle icon.
- Boss rooms: skull-outline in region accent.

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, game map screen UI, aged parchment map, ink blot unexplored areas, ember orange player marker, waystone circle icons, dark fantasy cartography, metroidvania map interface
```

---

### 10.3 Inventory / Relic Screen

- Grid layout: 6×4 slots; robe tier mannequin left; relic slot center-large.
- Items: 32×32 icons with 1px `#2C2C34` outline.
- Selected item: cyan `#00FFFF` corner brackets (not full box).
- Focus item + relic conflict shown with red slash overlay.

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, game inventory UI, parchment panel, item grid slots, relic large center slot, robe mannequin silhouette, dark fantasy item management screen, minimal icons
```

---

### 10.4 Spell Wheel

- Radial 8-direction layout; center = Ember Sigil icon.
- Locked spells: grey silhouette + lock rune.
- Selected wedge: warm ember highlight `#FF6B35`.
- Mana cost numeral in cyan below icon.

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, game spell wheel radial menu, eight spell directions, center ember sigil, dark stone circle frame, cyan mana cost numbers, dark fantasy magic selection UI
```

---

### 10.5 Waystone Menu

- Circular stone UI matching in-world Waystone; ley fractures radiate outward.
- Region names in `ui-text`; inactive stones desaturated.
- Travel transition: 1.5s dissolve — screen fills with ley cyan particles.

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, game fast travel menu UI, circular waystone stone circle, ley fracture lines radiating, region destination list, nexus cyan glow, dark fantasy teleport interface
```

---

### 10.6 Main Menu

- Background: animated slow-parallax Ashen Threshold (Layer 0–2 only).
- Logo: **ARCANIA** in custom serif (see §12); tagline below in dim text.
- Menu items: New Game / Continue / Options / Quit — vertical stack, ember hover underline.
- Elara silhouette idle animation behind fog (non-interactive).

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, game main menu screen, Ashen Threshold fog background, ARCANIA title logo space, vertical menu buttons, ember orange hover accent, Elara silhouette in fog, dark fantasy title screen
```

---

## 11. VFX Style Guide

### Global VFX Rules

- **Additive glow** for magic; **alpha fade** for physical particles.
- Frame count: **4–8 frames** per effect; loop where needed at 12 FPS VFX rate (game runs 60 FPS).
- Max 3 simultaneous full-screen tints; prefer localized effects.
- All VFX authored on **128×128 canvas** (scaled down) unless noted.

---

### 11.1 Spell VFX (14 Spells — Key Visuals)

| Spell | Color | Shape Language |
|-------|-------|----------------|
| Ember Bolt | `#FF6B35` → `#FFD60A` | Streak + impact bloom |
| Arc Step | `#00FFFF` + white | Horizontal tear + after-image |
| Kindling Ward | `#FF6B35` ring | Circular flame wall particles |
| Rootbind | `#52B788` | Vine growth from ground |
| Mistveil | `#AEC3B0` 50% | Soft fog wash on player |
| Tidecaller | `#B1FAFF` | Water level shimmer + splash ring |
| Stoneheart | `#6C757D` | Rock shard burst + crack lines |
| Gleamflare | `#CAF0F8` | Radial reveal flash + hidden outline |
| Weightless | `#E0AAFF` | Updraft spiral + float dust |
| Echo Sense | `#90E0EF` | Pulse ring + echo silhouette flash |
| Rift Tear | `#FF0099` | Planar rip + static edge |
| Ley Anchor | `#00FFFF` | Stabilize tether lines to ground |
| Void Mirror | `#7F00FF` | Reflective shield arc + beam bounce |
| Unbind | `#FFFFFF` + all colors | Thread sever + weave stitch |

**AI Prompt (Spell VFX Sheet):**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, game VFX sprite sheet frames, magic spell effects, ember bolt streak, arc step tear, root vine, ley anchor tether, additive glow particles, 128x128 effect cells, dark fantasy spell VFX
```

---

### 11.2 Hit Effects

| Type | Frames | Visual |
|------|--------|--------|
| Light hit | 4 | White slash `#FFFFFF` 60% + tiny sparks |
| Heavy hit | 6 | Larger slash + screen shake 2px |
| Spell hit | 4–6 | Spell-color bloom + enemy flash white 2 frames |
| Block/parry | 4 | Cyan flat ring `#00FFFF` |
| Overcast hit | 4 | Crimson crack on player `#E5383B` |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, game hit effect VFX sprite sheet, slash impact sparks, parry ring, 4-6 frame animation cells, combat feedback particles
```

---

### 11.3 Death Effects

- **Standard enemy:** Desaturate 2 frames → palette shatter into 6 particles → fade.
- **Elite:** + ember burst in biome accent color.
- **Boss phase:** Large ink-splash dissolve (Archive) / crystal shatter (Lumineth) / ash scatter (Sanctum) — region-themed variant on standard death.
- **No blood.** Decay particles only.

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, game enemy death dissolve VFX, pixel shatter particles, desaturation frames, dark fantasy decay not gore, 6 frame animation
```

---

### 11.4 Ambient Particles

| Region | Particle |
|--------|----------|
| Ashen Threshold | Ember motes, ash flecks |
| Whisperwood | Spores, pollen, moth dust |
| Catacombs | Water drip, lantern drift |
| Bleakfen | Fog wisps, wisp orbs |
| Lumineth | Crystal dust, light motes |
| Archive | Floating page scraps, ink dots |
| Skyfall | Wind debris, star glints |
| Atelier | Spark showers, ash snow |
| Sanctum | Eternal ash fall |
| Undercrown | Spore drift |
| Somnium | Static pixels, text fragments |
| Ley Nexus | Ley strands, void motes |

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, ambient particle sprite sheet, ember ash motes spore fog, small 8x8 to 16x16 particles, looping dark fantasy environment effects
```

---

## 12. Typography & Icon Style

### Typography

| Use | Font Direction | Spec |
|-----|----------------|------|
| **Logo / Title** | Custom serif with thread-like ligatures | "ARCANIA" — high contrast, slight erosion on terminals |
| **Headings** | Same serif, small caps | 18–24px at 108div viewport |
| **Body / Dialogue** | Humanist sans (e.g. Inter, Source Sans) | 14–16px; `#E8E8E8` on dark |
| **Lore / Archive** | Serif italic | Water-stain texture optional at 10% opacity |
| **Damage numbers** | Bold sans | 12px; pop up + fade; white physical, cyan spell |

**Implementation:** Bundle `.ttf` in `assets/fonts/`. Use Godot `Label` + `Theme` overrides; no system font fallback in shipping build.

### Icon Style

- **Size grid:** 16×16 (HUD), 32×32 (inventory), 48×48 (spell wheel).
- **Construction:** 1px outer stroke `#2C2C34`; flat fill; max 3 colors per icon.
- **Spell icons:** Glyph representing effect (bolt, tear, vine) — not literal character art.
- **Resource icons:** Weave Silk = thread spool; Memory Shard = fractured crystal; Ley Residue = droplet.

**AI Prompt:**
```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, game icon sheet 32x32 grid, spell icons resource icons, flat hand-drawn glyphs, ember cyan dark grey palette, minimal detail high contrast, RPG inventory icons
```

---

## 13. Animation Style Principles

### Frame Rate & Timing

- **Character gameplay animations:** 12 FPS sprite stepping at 60 FPS game tick (hold 5 frames).
- **Boss animations:** 12–15 FPS; telegraph frames **held extra 3–5 ticks**.
- **UI transitions:** 0.2–0.4 sec ease; Waystone dissolve 1.5 sec.
- **Ambient loops:** 6–8 frame cycles at 8 FPS.

### Core Principles

| Principle | Application in Arcania |
|-----------|------------------------|
| **Squash & Stretch** | Elara land squash 85% height; spell cast stretch 110% vertical; bouncy enemies (E-18) exaggerate |
| **Anticipation** | 2-frame wind-back before melee swing; enemy telegraphs use 2–4 frame anticipation with color shift |
| **Follow-Through** | Robe hem + hood lag 1 frame behind Elara stop; boss appendages settle after main body |
| **Overlapping Action** | Hair, sigil glow, and robe layers animate on offset keys |
| **Ease In/Out** | Arc Step blink: ease-in shrink → pop → ease-out expand |
| **Secondary Action** | Sigil palm glow pulses during idle; dust kicks on run stop |

### Elara Animation Set (Minimum)

| Animation | Frames | Notes |
|-----------|--------|-------|
| Idle | 8 | Subtle breathe; Sigil pulse every 4th loop |
| Run | 8 | Robe flow; no sliding feet |
| Jump / Fall | 4 each | Anticipation crouch 2 frames on jump |
| Melee 1/2/3 | 6 each | Combo chain; 3rd hit has extra follow-through |
| Cast (generic) | 6 | Left palm forward; robe flare |
| Hit / Death | 4 / 8 | Hit: recoil; Death: Sigil dim → collapse |
| Dodge | 4 | Invuln frames 2–3; after-image cyan |

### Enemy Animation Standards

- **Patrol:** 4–6 frames; readable foot placement.
- **Attack:** Anticipation (2) + Active (2–4) + Recovery (2).
- **Hitstun:** 2-frame flash white overlay at 50% opacity.
- **Death:** 4–6 frames (see §11.3).

---

## 14. Asset Export Specs

### File Format

| Asset Type | Format | Bit Depth |
|------------|--------|-----------|
| Sprites / UI | PNG | 32-bit RGBA |
| Tilesets | PNG | 32-bit RGBA |
| Parallax | PNG | 32-bit RGBA (no JPEG) |
| Fonts | TTF / OTF | — |

**No premultiplied alpha** in source files; Godot handles import.

---

### Resolution & Grid

| Asset | Spec |
|-------|------|
| **Tile grid** | 64×64 px |
| **Player (Elara)** | 48×56 px body; 64×64 px canvas with hood/FX padding |
| **Standard enemy** | 64×64 px canvas |
| **Elite enemy** | 96×96 px canvas |
| **Boss** | 256×256 px canvas (scale in-engine) |
| **UI icons** | 32×32 px (export @2x optional for crispness) |
| **Parallax layers** | Height 540px (viewport); width = region width in tiles × 64 |

---

### Sprite Sheet Layout

```
Standard character sheet (horizontal strip):
[ idle frames | run | jump | fall | attack1 | attack2 | attack3 | cast | hit | death ]

Enemy sheet:
[ idle | patrol | attack windup | attack active | attack recover | hit | death ]

VFX sheet (grid):
4 columns × 2 rows of 128×128 cells, top-left to right
```

- **Padding:** 2px transparent gutter between cells.
- **Naming:** `elara_run_01.png` or atlas `elara_sheet.png` with JSON/`.tres` frame data.
- **Pivot:** Feet center-bottom for characters; center for VFX.

---

### Godot 4 Import Settings

**Default for all PNG sprites:**

```ini
[remap]
importer="texture"
type="CompressedTexture2D"

[params]
compress/mode=0          # Lossless
mipmaps/generate=false
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
```

**Sprite2D / AnimatedSprite2D:**
- Filter: **Nearest** (pixel-perfect) for gameplay sprites.
- Repeat: Disabled.

**Parallax backgrounds:**
- Filter: **Linear** (optional; test per layer — far layers may use Nearest for style).
- Import as `Texture2D`; assign to `Parallax2D` layers with motion scale per §1.

**TileSet:**
- Texture region size: **64×64**.
- Physics collision authored in TileSet editor, not in art PNG.
- Terrain peering bits documented per region in `08-technical-architecture.md` (planned).

**AtlasTexture / SpriteFrames workflow:**
1. Import sheet PNG.
2. Slice in Godot SpriteFrames editor or use `AtlasTexture` with region rects.
3. Store `.tres` beside source PNG: `elara_sheet.tres`.

---

### Directory Convention

```
assets/
  characters/
    elara/
      elara_sheet.png
      elara_sheet.tres
  enemies/
    e01_ash_wisp/
  bosses/
    starfall_regent/
  environments/
    01_ashen_threshold/
      parallax_0_sky.png
      parallax_1_far.png
      ...
      tileset.png
  ui/
    hud/
    icons/
  vfx/
    spells/
    hits/
    ambient/
  fonts/
```

---

## Appendix — Cross-Document References

| Topic | Document |
|-------|----------|
| Region lore & room counts | [02-world-design.md](02-world-design.md) |
| NPC quests & dialogue | [07-narrative.md](07-narrative.md) |
| Spell mechanics & robe tiers | [06-magic-system.md](06-magic-system.md) |
| Enemy stats (planned) | [04-enemy-bible.md](04-enemy-bible.md) |
| Boss phases (planned) | [05-boss-bible.md](05-boss-bible.md) |
| Tilemap layers (planned) | [08-technical-architecture.md](08-technical-architecture.md) |

---

*Document version 1.0 — complete art bible for Arcania solo development.*

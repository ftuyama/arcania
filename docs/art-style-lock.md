# Art Style Lock — Screenshot North Star

**Status:** Locked for production  
**Visual target:** [images/screenshot.png](images/screenshot.png) (Ashen Threshold hub)  
**Parent bible:** [03-art-bible.md](03-art-bible.md)  
**Pipeline:** [art-pipeline.md](art-pipeline.md)

> Reconciles the Hollow Knight–inspired art bible with the hi-bit README screenshot.
> All new sprite batches must pass this lock before import.

---

## 1. Locked Rules (Screenshot-Derived)

| Dimension | Rule |
|-----------|------|
| **Readability first** | 2px outer contour, 1px inner detail. Greyscale silhouette must read at 960×540 (1× viewport). |
| **Dither placement** | Dither only on backgrounds, props, and stone fills — **never** on combat silhouettes (player/enemy body outlines stay clean). |
| **Palette** | Max 5–7 hues per screen. Enforce region hex tables from art bible §4. |
| **Ashen Threshold palette** | Shadow `#1A1A2E` · Base `#2C2C34` · Mid `#4A4E69` · Warm `#8B4513` · Accent `#FF6B35` |
| **Lighting** | Warm point lights on braziers (`#FF6B35`, low energy). Left-palm Ember Sigil is brightest character point. Subtle bloom only — no lens flare / bloom overload. |
| **Parallax (Region 01)** | Exactly **5 layers**: sky → far ruins → mid architecture (statue/arches) → mid fog → near occluders. |
| **Character scale** | Elara 48–56px body on 64×64 canvas; feet pivot `(32, 62)`. Standard enemies 64×64; elites 96×96. |
| **UI** | Corner clusters already match screenshot; do not redesign HUD chrome — only fill gaps (portrait, relic icon). |

---

## 2. AI Prompt Suffix (Production)

Prepend the global token from [03-art-bible.md §2](03-art-bible.md):

```
hi-bit pixel art 2D game sprite, dark fantasy metroidvania, screenshot-locked Ashen Threshold style, strong readable silhouette, textured stone and fabric detail, limited color palette, cool shadows warm ember accents, no photorealism, transparent background, sprite sheet friendly
```

**Append for all new batches:**

```
, 64px tile grid, limited 5-color palette {REGION_HEX_LIST}, side view facing right, transparent background, no text watermark, match docs/images/screenshot.png fidelity
```

**Negative (universal):**

```
photorealistic, 3D render, anime, chibi, bright saturated colors, lens flare, bloom overload, text watermark, blurry, noisy gradients, stock photo
```

### Region hex lists (for `{REGION_HEX_LIST}`)

| Region | Hex list |
|--------|----------|
| Ashen Threshold | `#1A1A2E #2C2C34 #4A4E69 #8B4513 #FF6B35` |
| Whisperwood Hollow | `#081C15 #1B4332 #40916C #52B788 #D8F3DC` |
| Sunken Catacombs | `#0B090A #495867 #5C677D #C9ADA7 #B1FAFF` |
| Bleakfen Marsh | See art bible §4.4 |

---

## 3. Palette Enforcement Checklist

Before marking a batch import-ready:

- [ ] Quantized to region 5-color table (±1 shade for highlight/shadow OK)
- [ ] Greyscale silhouette test at 960×540 — character/enemy readable
- [ ] Mana cyan / HP bone-white / Overcast crimson **not** used as large environment fills
- [ ] One scream accent only (Ashen = ember orange)
- [ ] Cell size matches export spec (64 / 96 / 128 / 540 height for parallax)
- [ ] 2px transparent gutter between sheet cells
- [ ] Co-located `.tres` SpriteFrames beside PNG
- [ ] Nearest filter, lossless import in Godot

---

## 4. Wave Exit Criteria (Reference)

| Wave | Exit when |
|------|-----------|
| 1 | `at_01_threshold_hub` screenshot-comparable; 4 unique Threshold enemies; Elara cast ≈ reference |
| 2 | Regions 02–04 packs + early enemy/boss sheets wired |
| 3 | Regions 05–08 + mid roster |
| 4 | Regions 09–12 + elites + final bosses |
| 5 | ColorRect fallbacks gone; trailer checklist done |

---

## 5. Related Docs

- [09-asset-production-list.md](09-asset-production-list.md) — frame counts & paths
- [12-improvements-backlog.md](12-improvements-backlog.md) — P0-03 tileset art pass
- [art-pipeline.md](art-pipeline.md) — AI → Aseprite → Godot workflow

# Art Pipeline — AI → Aseprite → Godot

**Style lock:** [art-style-lock.md](art-style-lock.md)  
**Export specs:** [03-art-bible.md §14](03-art-bible.md)  
**Naming:** [09-asset-production-list.md §11](09-asset-production-list.md)

---

## 1. Workflow (Every Batch)

```
1. Generate   → AI (Flux / Midjourney / etc.) with style-lock prompts
2. Normalize  → Aseprite: grid, pivot, gutter, palette quantize
3. Validate   → python3 tools/validate_sprite_imports.py
4. Import     → Godot: nearest + lossless; co-locate .tres
5. Wire       → Update SpriteFrames / scene refs if rects change
6. Verify     → Side-by-side vs docs/images/screenshot.png (Ashen)
```

### Generate

- Use prompts from art bible §§5–9 + style-lock suffix.
- Prefer turnaround sheets and **separate** parallax layer PNGs.
- Anchor scale: Elara idle at 56px body — all characters match that scale.

### Normalize (Aseprite)

| Asset | Canvas / cell | Pivot |
|-------|---------------|-------|
| Elara / NPC / standard enemy | 64×64 cells, 2px gutter | Feet `(32, 62)` |
| Elite enemy | 96×96 | Feet center-bottom |
| Boss | 96–256 cell (per bible) | Feet / arena center |
| Tileset | 64×64 tiles | — |
| Parallax | **960×540** | Top-left |
| Spell VFX | 128×128 cells | Center |
| UI icons | 16 / 32 / 48 | Center |

Palette: Index to region 5 colors. Greyscale-check silhouette at game resolution.

### Validate

```bash
python3 tools/validate_sprite_imports.py
python3 tools/validate_sprite_imports.py --strict   # fail on warnings
```

Checks: expected paths exist, PNG dimensions, `.tres` co-location, naming snake_case.

### Import (Godot)

```ini
compress/mode=0          # Lossless
mipmaps/generate=false
process/fix_alpha_border=true
```

- Gameplay sprites: **Nearest** filter.
- Far parallax: Nearest preferred; Linear only if seams look worse.

### Deprecation

`tools/generate_phase0_assets.py` is **emergency fallback / CI stub only**.
New production art goes through this pipeline (or `tools/generate_aligned_sprites.py` for interim hi-bit placeholders until AI batches land).

---

## 2. Prompt Library (Quick Copy)

### Global prefix

```
hand-drawn 2D game art, dark fantasy metroidvania, hollow knight inspired, strong silhouette, limited color palette, clean lines, no photorealism, transparent background, sprite sheet friendly, hi-bit pixel art, 64px tile grid
```

### Elara (Ashen)

```
[PREFIX], limited 5-color palette #1A1A2E #2C2C34 #4A4E69 #8B4513 #FF6B35, character design sheet side view facing right, young woman mage Elara Veilmark, dark tattered hooded robes gold orange trim, ember orange circular sigil on left palm, 48-64px game character scale
```

### Ashen parallax layer

```
[PREFIX], limited 5-color palette #1A1A2E #2C2C34 #4A4E69 #8B4513 #FF6B35, side-scrolling parallax layer only, {LAYER_DESC}, 960x540, tileable horizontally, transparent where empty
```

Layer descs: `purple-grey sky with distant spires and ember motes` | `silhouetted ruined city mountains` | `gothic arches dead trees hooded king statue` | `ember fog band` | `foreground pillars hanging roots brazier glow`

### Enemy

```
[PREFIX], enemy sprite readable silhouette telegraph pose, {SILHOUETTE_BRIEF}, single creature, side view facing right
```

---

## 3. Directory Targets

Keep existing Godot paths (avoid mass refactors):

```
godot/assets/sprites/
  player/elara_core.png + .tres
  player/elara_portrait_48.png
  enemies/e{nn}_{name}/e{nn}_sheet.png + .tres
  bosses/{id}/...
  tilesets/01_ashen_threshold/{tileset,parallax_*,props}.png
  vfx/spells/vfx_{spell}.png + .tres
  ui/hud/...
  world/...
```

---

## 4. Batch Checklist Template

```
Batch ID: ________  Wave: __  Region: ________
- [ ] Style-lock palette applied
- [ ] Aseprite export matches cell size
- [ ] validate_sprite_imports.py clean
- [ ] SpriteFrames .tres updated
- [ ] Scenes wired (no leftover modulate tint hacks)
- [ ] Screenshot / playtest note attached
```

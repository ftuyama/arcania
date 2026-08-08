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

---

## 5. Codex Image-Generation Workflow

Use this workflow when producing raster assets with Codex's built-in image generator. Generated images are **source art**, not import-ready sprite sheets.

### 5.1 Generate key poses, not final animation atlases

1. Provide [images/screenshot.png](images/screenshot.png) as the style reference.
2. Provide the current production asset as the identity/scale reference when replacing an existing character, enemy, or effect.
3. Request one subject per equal grid cell, consistent scale, a shared baseline, and an explicit pose order.
4. Use a flat `#00FF00` chroma-key background with no floor, shadows, labels, or overlapping poses.
5. Generate locomotion and combat/death poses separately when one sheet would contain more than 8–12 poses.

Character prompt scaffold:

```text
Asset type: production key-pose reference sheet for a 2D game sprite
Input images: screenshot = style reference; current sprite = identity reference
Subject: {CHARACTER_IDENTITY}; side view facing right; preserve costume, proportions, and handedness
Pose layout: {COLUMNS} by {ROWS} grid; {ORDERED_POSE_LIST}; one full-body pose per cell; feet on one baseline
Style: hand-drawn hi-bit pixel art; strong silhouette; crisp pixel clusters; clean combat outline
Palette: {REGION_HEX_LIST}; one scream accent only
Backdrop: perfectly flat solid #00FF00 chroma-key background
Constraints: identical scale; no overlap; no text; no labels; no watermark; no scenery; no cast shadow
Avoid: photorealism, 3D, anime, chibi, painterly gradients, inconsistent costume or handedness
```

For environment work, generate each depth role separately. Do not ask the model to deliver a finished five-layer parallax stack in one image.

### 5.2 Remove the chroma key

The generated green is often close to `#03F80C`, not exact `#00FF00`. White grid separators can also make automatic border sampling select white instead of green. Inspect the dominant background color and pass it explicitly:

```bash
uv run --with pillow python \
  "${CODEX_HOME:-$HOME/.codex}/skills/.system/imagegen/scripts/remove_chroma_key.py" \
  --input tmp/art_pass/source.png \
  --out tmp/art_pass/source_alpha.png \
  --key-color '#03f80c' \
  --auto-key none \
  --soft-matte \
  --transparent-threshold 18 \
  --opaque-threshold 150 \
  --despill \
  --edge-contract 1
```

Do not use automatic border sampling on a generated grid until confirming that the outer border is green.

### 5.3 Normalize for production

- Crop every grid cell before finding the subject bounds so separator lines cannot enter the alpha mask.
- Downscale with Lanczos, then quantize without dithering. Dither belongs on environment stone/fog, not combat silhouettes.
- Align character bodies independently of detached spell effects; otherwise a large sigil shifts the character away from `(32, 62)`.
- Apply an alpha threshold after resizing to remove green fringe and soft antialiasing.
- Assemble final atlases with 64×64 character/enemy cells or 128×128 VFX cells and 2px gutters.
- Preserve existing animation names and tune SpriteFrames speeds to existing gameplay state durations. Do not change combat timing merely to fit generated frame counts.
- Keep raw generations and disposable conversion scripts under `tmp/art_pass/<batch_id>/`. Only final PNGs and `.tres` resources belong under `godot/assets/`.

Raw files under `tmp/` are not durable project history. Record the prompt and decisions in this document or a batch note before ending a session.

---

## 6. Ashen Hero Benchmark — Current State

The first screenshot-quality benchmark established the following production assets:

| Area | Current result | Known limitation / next pass |
|------|----------------|------------------------------|
| Elara | `elara_core.png` uses 64px cells, 2px gutters, clean silhouettes, left-palm sigil, and clips for idle, walk, jump, fall, dash, melee 1–3, cast, hit, and death | Several frames are transformed/repeated key poses. Hand-author unique walk contacts, jump transitions, combo recoveries, and death in-betweens before final polish. |
| Ash Wisp | `e01_sheet.png` has idle, float, attack, hit, and death clips; the decor scene plays `float` | Combat AI is still out of scope; E-02, E-04, and E-08 still need production sheets for Wave 1. |
| Ember Bolt | `vfx_ember_bolt.png` separates a looping travel clip from a one-shot impact clip | Review apparent projectile size against the 12×8 hitbox during live play. |
| Focus Crucible | Low-energy orange point light, sprite pulse, and sparse rising embers | Keep the Sigil brighter than environmental fire sources. |
| Ashen background | Production sky/far-city plate and mid-architecture layer with arches, dead tree, and oath statue | `parallax_1_far_ruins`, `parallax_3_mid_fog`, and `parallax_4_near_occluders` remain placeholder-quality. The current sky plate includes the distant skyline as a benchmark shortcut. |
| Ashen tiles | 16-tile 64px strip replaces geometric placeholders; platform visuals repeat/crop tiles instead of stretching one tile | Add hand-cleaned edge, corner, damaged, and transition variants when rooms gain bespoke layouts. |

Room-only benchmark capture: [images/ashen_threshold_art_benchmark.png](images/ashen_threshold_art_benchmark.png).

### Current continuation priority

1. Replace the near-occluder layer with edge-framing pillars, roots, hanging chains, and braziers while keeping the center and HUD corners readable.
2. Split the distant skyline out of the base sky into a true far-ruins layer, then replace the placeholder fog band.
3. Produce E-02 Bone Crawler, E-04 Ember Moth, and E-08 Threshold Shade sheets to satisfy the Wave 1 four-enemy exit criterion.
4. Hand-clean Elara's in-betweens and verify every key pose in live gameplay, especially mirrored attacks and cast release timing.
5. Add Ashen props and bespoke platform edge/corner tiles; do not expand to another region until the benchmark room is coherent at 1×.

---

## 7. Discoveries and Failure Modes

### Inspect production assets, not `tmp/` previews

`tmp/scene_captures/ai_hub_v*.png` and similar files may show experiments that were never imported. Before planning an art pass, inspect the PNGs referenced by the actual `.tscn`, `.tres`, and backdrop configuration.

### Force a Godot re-import before visual capture

The screenshot helper starts a game script and may reuse stale imported PNGs. After changing raster assets, run:

```bash
./tools/godot.sh --headless --editor --path godot --quit-after 10
```

Confirm the output lists the changed PNGs under `(Re)Importing Assets` before capturing.

### The room capture is not a full gameplay capture

`./tools/capture_scene_screenshot.sh at_01_threshold_hub` instantiates the room with a debug camera. It does **not** include the player, HUD, or normal gameplay camera framing. Use it for environment comparison only; use a live gameplay capture to approve Elara scale, HUD-safe composition, and combat VFX.

### Do not stretch platform tiles

Scaling one 64px platform tile across an arbitrary width destroys masonry proportions. `styled_room_geometry.gd` now repeats full tiles and crops only the last horizontal slice. New platform tiles start at the top edge (`y=0`); the clean reusable cap is tile index 1.

### Parallax ratios require overscan-aware art

The nominal art-bible ratios (`0.2 / 0.4 / 0.6 / 0.85 / 1.0`) shifted focal architecture out of the current 960×540 paintings when the debug camera framed a 1024×768 room. The benchmark retains asset-calibrated scales (`0.1 / 0.25 / 0.4 / 0.55 / 0.7`) until every layer is regenerated with horizontal overscan and tested across the room bounds. Do not change ratios without a rendered before/after comparison.

### Environment and character generation need different treatment

- Characters/enemies: clean alpha, no dither, strict pivot and silhouette tests.
- VFX: centered 128px cells, a small color ramp, and separate travel/impact clips when behavior differs.
- Backgrounds: more shade steps and restrained dithering are acceptable; keep contrast below the gameplay plane.
- Tiles: generate a few strong modules, then create controlled variants; direct AI sheets are rarely grid-perfect.

---

## 8. Verification Runbook

Run these checks after every production batch:

```bash
uv run --with pillow python tools/validate_sprite_imports.py --strict
./tools/godot.sh --headless --editor --path godot --quit-after 10
./tools/godot.sh --headless --path godot --script res://tests/unit/test_runner.gd
./tools/godot.sh --headless --path godot --script res://tests/integration/fps_profile_ww07.gd
./tools/capture_scene_screenshot.sh at_01_threshold_hub
```

Then inspect at 1×:

- silhouette readability in greyscale;
- feet/pivot stability and mirrored facing;
- attack active pose, cast release, dash duration, and impact timing;
- one scream accent per screen;
- no green fringe or alpha-grid residue;
- no stretched tiles, visible parallax seams, or focal architecture under HUD-critical corners;
- 60 FPS target and no new resource/parser errors.

The unit suite intentionally exercises corrupt and version-mismatched saves, so those expected error/warning messages may appear even when the suite ends with `All unit tests passed`.

# Art Style Lock — Painted Realism

**Status:** Locked for production  
**Visual target:** [images/screenshot.png](images/screenshot.png)  
**Benchmark:** `at_03_east_road`  
**Pipeline:** [art-pipeline.md](art-pipeline.md)

## Locked Rules

| Dimension | Rule |
|-----------|------|
| Medium | High-resolution hand-painted 2D art; realistic weathered materials; never a 3D render or photograph. |
| Readability | Player, enemies, telegraphs, and interactables retain distinct silhouettes at 960×540. Texture detail must not break the outline. |
| Palette | Cool charcoal/slate shadows, muted violet atmosphere, burnt-orange ember accents. One high-chroma accent per region. |
| Character scale | Elara is approximately 112 logical pixels tall from a 256×256 source cell displayed at 0.5×. Physics collision remains deliberately tighter. |
| Filtering | Linear filtering, lossless import, mipmaps off, unsnapped visual transforms, physics interpolation on. |
| Animation | Generate coherent action sheets from one identity anchor. Never create frames by alpha-blending unrelated poses. |
| VFX | Body, blade arcs, sigils, projectiles, fog, and afterimages are separate assets/layers. |
| Environment | Five Ashen layers: sky, far ruins, mid architecture, fog, foreground occluders. No baked gameplay slab in parallax. |
| Platforms | Modular cap/body/end pieces repeat without stretching. Collision is independent from decorative overhangs. |
| UI | Painted blackened-iron and worn-bronze frames; all text and numbers remain native Godot controls. |

## Production Prompt Token

```text
high-resolution hand-painted 2D game art, dark fantasy metroidvania, screenshot-locked Ashen Threshold composition, realistic weathered stone, iron, leather and cloth, strong readable silhouettes, restrained charcoal and ember palette, cool shadows, warm point-light accents, production-ready separated game asset, no 3D render, no photograph, no text, no watermark
```

For opaque cutouts, generate on perfectly flat `#00ff00` (or `#ff00ff` for green subjects) with no shadow, floor, gradient, reflection, or background texture. Soft fog and additive VFX use black-backed sources converted deterministically to alpha.

## Quality Gate

- Exact manifest dimensions, frame count, FPS, pivot, and display scale.
- Transparent corners and no chroma fringe, embedded grid, labels, or watermark.
- Elara body height remains within 2% across accepted frames; grounded feet remain within one logical pixel.
- No duplicated limbs, cross-fade ghosts, clipped bodies, or VFX baked into character cells.
- No visible parallax seams, opaque fog bands, stretched platform textures, or foreground obstruction over critical gameplay.
- A failed asset remains staged; the playable fallback is not overwritten until the whole benchmark set passes.

## Benchmark Exit Criteria

- East Road is playable from both entrances with all current enemies, Ember Sigil, Veil Step, HUD, and room transitions.
- Captures at the west, center, barrier, and east positions match the target's scale, depth, Gothic material quality, and restrained lighting.
- Unit tests, strict asset validation, animation contact sheets, and the 60 FPS profile pass.

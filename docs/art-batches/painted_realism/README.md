# Painted Realism Benchmark Batch

This batch is the approved source set for the `at_03_east_road` visual benchmark. Runtime assets are rebuilt with `python3.11 tools/build_painted_benchmark.py`; source images are never edited in place.

## Generation Method

All source artwork was generated on 2026-08-08 with Codex's built-in image generation tool. Elara used the prior character sheet (`docs/art-batches/incoming/elara_core.png` at generation time) as an identity reference and `docs/images/screenshot.png` as the composition, scale, palette, and rendering reference. Other assets used the screenshot reference. Chroma-backed sources were matted with the installed `remove_chroma_key.py` helper using border auto-key, soft matte, despill, transparent threshold 12, and opaque threshold 220.

## Shared Prompt

```text
High-resolution hand-painted 2D game art for a dark-fantasy Metroidvania, matching the reference screenshot's grounded Gothic realism, strong readable silhouettes, weathered stone/iron/leather/cloth, cool charcoal and muted-violet atmosphere, restrained burnt-orange ember accents, orthographic side view, production-ready separated asset. No pixel art, 3D render, photograph, text, labels, watermark, interface mockup, embedded grid lines, or decorative border.
```

## Asset Prompts

- `ashen_sky.png`: one opaque 16:9 Ashen Threshold sky plate with storm clouds, mauve distant haze, subtle ember motes, and clear gameplay contrast; no foreground architecture.
- `ashen_far_ruins_chroma.png`: one wide far-distance ruined Gothic skyline layer on perfectly flat green, sparse silhouettes and broken towers, no floor or shadow.
- `ashen_mid_architecture_chroma.png`: one wide mid-distance layer of arches, towers, leafless trees, and ruined masonry on perfectly flat green, with open negative space behind play lanes.
- `ashen_fog_black.png`: one wide soft atmospheric fog veil and sparse ember particles on pure black for deterministic additive-alpha conversion.
- `ashen_foreground_chroma.png`: one wide foreground framing layer of edge-weighted broken masonry, chains, roots, and dead branches on perfectly flat green; center and traversal lanes unobstructed.
- `ashen_platform_kit_chroma.png`: exact 4×2 grid of eight modular side-view Gothic stone platform pieces on perfectly flat green; left cap, repeating bodies, right cap, underside/ledge variants; consistent top surface and no cast shadow.
- `elara_locomotion_chroma.png`: exact 4×3 grid of twelve full-body Elara locomotion key poses on perfectly flat green; one consistent hooded woman in black weathered coat with ember-orange seams, fixed side-facing identity, grounded feet, no weapon trail or VFX.
- `elara_combat_chroma.png`: exact 4×3 grid of twelve full-body Elara combat/casting/hit key poses on perfectly flat green; identity and costume locked to locomotion sheet, separate clean silhouettes, no baked blade arcs, sigils, projectiles, smoke, or afterimages.
- `east_road_enemies_chroma.png`: exact 4×3 grid on perfectly flat magenta; row one Bramble Stalker, row two Thornweft Larva, row three Mothling Swarm; four coherent animation keys per enemy and no effects or shadows.
- `combat_vfx_black.png`: exact 4×2 grid of isolated ember-orange spell effects on pure black: sigil growth, projectile, blade arc, and veil-step smoke; no character bodies.
- `phase_barrier_black.png`: one narrow vertical veil of torn violet-black smoke, subtle runic filaments, and sparse ember sparks on pure black; porous silhouette and no scenery.
- `hud_chroma.png`: exact 4×2 grid of eight isolated blackened-iron/worn-bronze HUD components on perfectly flat green; portrait frame, filled/empty health pips, mana frame, spell slot, active slot, minimap frame, and currency endcap; no text or numbers.

The generated source filenames, reviewed transparent mattes, manifest, builder, and runtime output paths are retained together so the pass is reproducible and auditable.

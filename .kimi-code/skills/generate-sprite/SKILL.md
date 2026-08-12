---
name: generate-sprite
description: Generate a production-ready Arcania sprite or art asset from the design bibles using the project's art-bible style.
---

# generate-sprite

Generate sprite art for Arcania that matches the visual style locked in `docs/03-art-bible.md`.

## Arguments

`for <Asset Name> [as <category>] [--region <01-12>]`

Categories: `character`, `npc`, `enemy`, `boss`, `spell`, `relic`, `ui`, `vfx`, `environment`, `world`, `tileset`.

## Workflow

1. **Parse** the asset name, optional category, and optional region id.
2. **Look up** the asset in the relevant design bible (`04` enemy, `05` boss, `06` spell/relic, `07` npc, `02`/`03` environment). If not found, build a description from the name and category.
3. **Read** `docs/03-art-bible.md` §2 for the global style token, asset-type suffix, and negative prompt. If a region id is given, read §4 for the palette.
4. **Compose** the prompt in this order: global style token → subject description → region palette keywords → size/scale → pose/state → asset-type suffix → negative prompt.
5. **Generate** the image using the available IDE/image-generation tool. Request transparent background unless the asset is an environment/tileset.
6. **Save** as `snake_case` under `godot/assets/sprites/<category>/` (use `ui/icons/` for UI, `tilesets/<region_id>_<region_name>/` for tilesets).
7. **Configure** import settings: **Filter: Nearest**, **Mipmaps: Off**.
8. **Report** the asset name, category, saved path, and final prompt.

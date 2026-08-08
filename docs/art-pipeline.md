# Art Pipeline — AI Sources to Godot

**Style lock:** [art-style-lock.md](art-style-lock.md)  
**Manifest:** [art-batches/painted_realism/manifest.json](art-batches/painted_realism/manifest.json)  
**Builder:** `tools/build_painted_benchmark.py`

## Workflow

1. Generate one asset or coherent animation sheet per prompt using the approved identity/style references.
2. Save immutable sources under `docs/art-batches/painted_realism/source/`.
3. Remove flat chroma backgrounds with the installed image-generation helper and save reviewed mattes under `processed/`.
4. Run `python3.11 tools/build_painted_benchmark.py` to slice, align, scale, pack, and validate the benchmark assets.
5. Import in Godot with lossless compression, linear filtering, and mipmaps disabled.
6. Run unit tests, animation contact-sheet capture, East Road screenshots, and the performance profile.

The builder never invents in-between frames by alpha blending. Repeated key poses are allowed; ghosted interpolation is not. Character bodies and VFX are always packed separately.

## Source Roles

| Source | Output |
|--------|--------|
| Elara locomotion/combat sheets | 256×256-cell `elara_core.png` and `SpriteFrames` |
| East Road enemy sheet | Separate Bramble Stalker, Thornweft Larva, and Mothling Swarm atlases |
| Sky/ruins/architecture/fog/foreground | Five 1536×540 Ashen parallax layers |
| Platform kit | 128×128 painted source modules displayed on the 64-unit grid |
| Combat VFX | 128×128 additive Ember Sigil, Ember Bolt, and Veil Step frames |
| HUD pack | Individual painted frames; text remains native Godot UI |

## Promotion Rules

- Sources and processed mattes are review artifacts; runtime PNGs and `.tres` files are generated outputs.
- Run the builder before Godot import. A nonzero exit means nothing is ready to promote.
- Allow one initial generation and at most three targeted regenerations per failed asset.
- If identity, alpha, scale, continuity, or composition still fails, stop and keep the current playable fallback.
- The retired `incoming/` batch and its rebuild scripts remain recoverable from Git history but are not part of this pipeline.

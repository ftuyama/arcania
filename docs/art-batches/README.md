# Art batch staging

Cursor AI generations land in the Cursor assets folder and are synced here.

```bash
# Preferred — preserves color fidelity (do NOT use old 10-color crush path)
python3.11 tools/rebuild_sprites_hq.py
python3.11 tools/validate_sprite_imports.py --strict
```

Final art lives under `godot/assets/sprites/`.

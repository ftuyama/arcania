# Arcania

Dark-fantasy 2D Metroidvania built with Godot 4.3+. The player is Elara Veilmark. Its core pillar is dual-purpose magic: every spell must serve both combat and exploration.

## Project layout

- `docs/`: design bibles; the source of truth for game design.
- `godot/`: Godot project and implementation.

## Before implementing

1. Check `docs/10-development-roadmap.md` for the current phase scope.
2. Follow `docs/08-technical-architecture.md` for code structure.
3. Cross-reference the relevant design bible before adding content.
4. Do not contradict locked design without flagging it.

The main documents are `01-gdd.md` (pillars), `02-world-design.md` (regions and gates), `03-art-bible.md` (visual tone), `04-enemy-bible.md`, `05-boss-bible.md`, `06-magic-system.md`, `07-narrative.md`, `08-technical-architecture.md`, `10-development-roadmap.md`, `11-scoped-release.md`, and `12-improvements-backlog.md`.

## Implementation defaults

- Godot 4.3+, Forward+, 2D physics.
- 960x540 viewport, 2x integer upscale; 64px tiles; target 60 FPS.
- Pixel-perfect rendering: nearest filtering and snapped transforms.
- Prefer minimal diffs; stubs are acceptable when the roadmap calls for them.

## Godot CLI and visual QA

- Do not assume `godot` is on `PATH`; use `./tools/godot.sh`.
- For unit tests: `./tools/godot.sh --headless --path godot --script res://tests/unit/test_runner.gd`.
- For FPS profiling: `./tools/godot.sh --headless --path godot --script res://tests/integration/fps_profile_ww07.gd`.
- For visual QA: `./tools/capture_scene_screenshot.sh <room_id>`, then inspect the generated PNG in `tmp/scene_captures/`.
- Do not pass `--headless` to screenshot capture; it needs a brief borderless window.
- Use `call_deferred` and `await process_frame` for multi-frame Godot 4.7 `SceneTree --script` debug scripts.

## When editing design documents

- `docs/01-gdd.md` is the design lock; other documents must not contradict it.
- Put technical details in `08-technical-architecture.md`; enemy/boss stats in `04`/`05`; spell mechanics in `06`.
- Use `snake_case` IDs and relative Markdown links.
- Maintain dark-fantasy tone: Elara is capable but haunted, never quippy.

## When editing Godot scenes (`godot/**/*.tscn`)

- Name scenes with `snake_case`.
- Reuse scenes from `scenes/components/`; keep scripts under `scripts/` and paths aligned.
- Use the component and state-machine patterns specified in `docs/08-technical-architecture.md`.
- Set physics layers and masks using the named `project.godot` layers.
- Preserve pixel-perfect rules: integer scale, nearest filtering, no gameplay sub-pixel camera smoothing.

## When editing GDScript (`godot/**/*.gd`)

- Use typed GDScript, `snake_case` files, `PascalCase` resource classes, and `StringName` IDs such as `&"ember_sigil"`.
- Use `EventBus` only for cross-domain signals; parent-child communication uses local signals. Always disconnect EventBus signals in `_exit_tree`.
- Use composition for components, `StateMachine` plus `State` children for behavior, and `.tres` resources for game data.
- Keep `event_bus.gd` to signals only. Use `push_error()` for invalid state transitions.
- Read gameplay constants from `project.godot`; round kinematic positions.
- Indent with tabs only. After editing, verify no newly added leading spaces appear in `.gd` files.

## Content additions

- Enemy: `docs/04-enemy-bible.md` → `resources/enemies/`, `scenes/enemies/{id}/`.
- Boss: `docs/05-boss-bible.md` → `resources/bosses/`, `scenes/bosses/{id}/`.
- Spell/relic: `docs/06-magic-system.md` → `resources/spells/` or `resources/relics/`.
- Region/room: `docs/02-world-design.md` → `resources/regions/`, `scenes/rooms/{region_id}/`.
- Quest/NPC: `docs/07-narrative.md` → `resources/quests/`.
- Every spell needs combat and exploration utility. Do not invent stats that contradict the design bibles.

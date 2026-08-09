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

<!-- rtk-instructions v2 -->
# RTK (Rust Token Killer) - Token-Optimized Commands

## Golden Rule

**Always prefix commands with `rtk`**. If RTK has a dedicated filter, it uses it. If not, it passes through unchanged. This means RTK is always safe to use.

**Important**: Even in command chains with `&&`, use `rtk`:
```bash
# ❌ Wrong
git add . && git commit -m "msg" && git push

# ✅ Correct
rtk git add . && rtk git commit -m "msg" && rtk git push
```

## RTK Commands by Workflow

### Build & Compile (80-90% savings)
```bash
rtk cargo build         # Cargo build output
rtk cargo check         # Cargo check output
rtk cargo clippy        # Clippy warnings grouped by file (80%)
rtk tsc                 # TypeScript errors grouped by file/code (83%)
rtk lint                # ESLint/Biome violations grouped (84%)
rtk prettier --check    # Files needing format only (70%)
rtk next build          # Next.js build with route metrics (87%)
```

### Test (60-99% savings)
```bash
rtk cargo test          # Cargo test failures only (90%)
rtk go test             # Go test failures only (90%)
rtk jest                # Jest failures only (99.5%)
rtk vitest              # Vitest failures only (99.5%)
rtk playwright test     # Playwright failures only (94%)
rtk pytest              # Python test failures only (90%)
rtk rake test           # Ruby test failures only (90%)
rtk rspec               # RSpec test failures only (60%)
rtk test <cmd>          # Generic test wrapper - failures only
```

### Git (59-80% savings)
```bash
rtk git status          # Compact status
rtk git log             # Compact log (works with all git flags)
rtk git diff            # Compact diff (80%)
rtk git show            # Compact show (80%)
rtk git add             # Ultra-compact confirmations (59%)
rtk git commit          # Ultra-compact confirmations (59%)
rtk git push            # Ultra-compact confirmations
rtk git pull            # Ultra-compact confirmations
rtk git branch          # Compact branch list
rtk git fetch           # Compact fetch
rtk git stash           # Compact stash
rtk git worktree        # Compact worktree
```

Note: Git passthrough works for ALL subcommands, even those not explicitly listed.

### GitHub (26-87% savings)
```bash
rtk gh pr view <num>    # Compact PR view (87%)
rtk gh pr checks        # Compact PR checks (79%)
rtk gh run list         # Compact workflow runs (82%)
rtk gh issue list       # Compact issue list (80%)
rtk gh api              # Compact API responses (26%)
```

### JavaScript/TypeScript Tooling (70-90% savings)
```bash
rtk pnpm list           # Compact dependency tree (70%)
rtk pnpm outdated       # Compact outdated packages (80%)
rtk pnpm install        # Compact install output (90%)
rtk npm run <script>    # Compact npm script output
rtk npx <cmd>           # Compact npx command output
rtk prisma              # Prisma without ASCII art (88%)
rtk uv run <cmd>        # Compact uv project command output
```

### Files & Search (60-75% savings)
```bash
rtk ls <path>           # Tree format, compact (65%)
rtk read <file>         # Code reading with filtering (60%)
rtk grep <pattern>      # Search grouped by file (75%). Format flags (-c, -l, -L, -o, -Z) run raw.
rtk find <pattern>      # Find grouped by directory (70%)
```

### Analysis & Debug (70-90% savings)
```bash
rtk err <cmd>           # Filter errors only from any command
rtk log <file>          # Deduplicated logs with counts
rtk json <file>         # JSON structure without values
rtk deps                # Dependency overview
rtk env                 # Environment variables compact
rtk summary <cmd>       # Smart summary of command output
rtk diff                # Ultra-compact diffs
```

### Infrastructure (85% savings)
```bash
rtk docker ps           # Compact container list
rtk docker images       # Compact image list
rtk docker logs <c>     # Deduplicated logs
rtk kubectl get         # Compact resource list
rtk kubectl logs        # Deduplicated pod logs
```

### Network (65-70% savings)
```bash
rtk curl <url>          # Compact HTTP responses (70%)
rtk wget <url>          # Compact download output (65%)
```

### Meta Commands
```bash
rtk gain                # View token savings statistics
rtk gain --history      # View command history with savings
rtk discover            # Analyze Claude Code sessions for missed RTK usage
rtk proxy <cmd>         # Run command without filtering (for debugging)
rtk init                # Add RTK instructions to CLAUDE.md
rtk init --global       # Add RTK to ~/.claude/CLAUDE.md
```

## Token Savings Overview

| Category | Commands | Typical Savings |
|----------|----------|-----------------|
| Tests | vitest, playwright, cargo test | 90-99% |
| Build | next, tsc, lint, prettier | 70-87% |
| Git | status, log, diff, add, commit | 59-80% |
| GitHub | gh pr, gh run, gh issue | 26-87% |
| Package Managers | pnpm, npm, npx | 70-90% |
| Files | ls, read, grep, find | 60-75% |
| Infrastructure | docker, kubectl | 85% |
| Network | curl, wget | 65-70% |

Overall average: **60-90% token reduction** on common development operations.
<!-- /rtk-instructions -->
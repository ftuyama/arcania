---
name: implement-godot-feature
description: Implement Arcania Godot 4 features following the technical architecture. Use for player systems, combat, spells, save/load, UI, enemies, bosses, rooms, or other work in godot/.
---

# Implement Godot Feature

Before coding, read the relevant section of `docs/08-technical-architecture.md`, confirm the feature is in scope in `docs/10-development-roadmap.md`, and inspect existing `godot/` code to extend its patterns.

Place files according to the architecture. Use `EventBus` for cross-system events, components as child nodes, `StateMachine`/`State` for behavior, resources for game data, named physics layers, and cleanup for signal connections. Keep changes minimal, pixel-perfect, and at the 60 FPS target. Stub deferred work with `pass` and a roadmap-phase comment.

Consult the matching architecture sections for player movement (§6), enemy AI (§7), bosses (§8), spells (§9), save/load (§10), inventory (§11), quests (§12), map (§13), ability gates (§14), EventBus (§16), state machine (§17), and tests (§19).

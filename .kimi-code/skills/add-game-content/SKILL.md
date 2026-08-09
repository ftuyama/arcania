---
name: add-game-content
description: Add Arcania game content from design bibles into Godot resources and scenes. Use for enemies, bosses, spells, regions, NPCs, quests, relics, or rooms.
---

# Add Game Content

Read the relevant bible first. Extract the ID, stats, behavior, exploration role, and art notes. Match existing Godot resource schemas, extend the correct base scene, register the content with its system, and emit the matching EventBus event.

Enemy content comes from `04-enemy-bible.md`; bosses from `05-boss-bible.md`; spells and relics from `06-magic-system.md`; regions and rooms from `02-world-design.md`; quests and NPCs from `07-narrative.md`; and visual direction from `03-art-bible.md`. Do not invent conflicting stats or add out-of-phase content without noting it. Every spell must have combat and exploration utility.

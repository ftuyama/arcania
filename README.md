# Arcania

A dark fantasy 2D Metroidvania where every spell opens new paths in combat and exploration.

> *"The weave is torn. You are the last thread."*

Play as **Elara Veilmark**, a disgraced apprentice who awakens in the Ashen Threshold with fractured memory and a flickering Ember Sigil. Traverse an interconnected world, unlock spells that reshape combat and clear environmental obstacles, and uncover the secrets of a decaying empire.

![Arcania — Elara in the Ashen Threshold](docs/images/screenshot.png)

---

## How to Play

### Requirements

- **[Godot 4.3+](https://godotengine.org/download)** (the project is tested on Godot 4.7)

### Launch

1. Clone or download this repository.
2. Open `godot/project.godot` in the Godot editor.
3. Press **F5** (Play). The title screen offers **New Game**, **Continue**, or **Load**.

### Controls

| Action | Key |
|--------|-----|
| Move left / right | **A** / **D** (or arrow keys) |
| Jump | **Space** |
| Melee attack (3-hit combo) | **J** |
| Quick spell slot 1 (default: Ember Sigil) | **1** |
| Quick spell slot 2 (default: Ember Bolt) | **2** |
| Quick spell slot 3 (default: Veil Step after shrine) | **3** or **Shift** *(East Road shrine — not at start)* |
| Quick spell slot 4 (default: Rootbind after pickup) | **4** *(after pickup in Whisperwood)* |
| Cast primary quick slot (gamepad) | **Y** / **Triangle** |
| Rest / save at Focus Crucible | **E** |
| Pause menu (save/load) | **Esc** |
| Map overlay | **M** |
| Inventory (relics) | **I** |
| Spell wheel (8-slot loadout) | **Tab** |
| Place map marker (while map open) | **E** |

Use **Tab** to assign spells to slots **1–4**. Hold an aim direction (arrow keys) before casting to fire spells upward, downward, or diagonally.

### Mobile browsers

The Web build supports landscape touch play. On touch devices, on-screen controls appear automatically: movement on the left; aim, jump, attack, cast, and dash on the right; utility and quick-spell buttons along the top. Rotate the device to landscape to play.

---

## Current Playable Content

This is an **in-development build** (Phases 0–4 complete). You can explore the Ashen Threshold and Whisperwood Hollow, fight bosses, collect relics, and use six spells.

**Story route**

```
Ashen Threshold hub → East Road (Veil Step shrine) → Whisperwood Hollow
                              ↓
                    Thornweft Matron → Arc Step
                    Root Warden → Rune Anchor
```

**Spells**

| Spell | How to get | Use |
|-------|------------|-----|
| **Ember Sigil** | Start | Short-range fire; lights braziers and opens ability gates |
| **Ember Bolt** | Start | Ranged fire projectile |
| **Veil Step** | Shrine on East Road | Phase dash with i-frames |
| **Rootbind** | Heartwood Chamber pickup | Grows vine platforms; clears vine gates |
| **Arc Step** | Defeat Thornweft Matron | Short blink with i-frames |
| **Rune Anchor** | Defeat Root Warden | Grapple to golden anchor rings |

**Systems**

- **Save / load** — Pause menu (**Esc**, 3 slots) or quick-save at a **Focus Crucible** (**E**).
- **Relics** — Press **I** to equip modifiers (e.g. Cinder Heart, Thornseed Charm, Iron Grip).
- **Quests** — Act I tracker on the HUD; full log in the pause menu.
- **Map** — Press **M** for fog-of-war; **E** while open to place markers (3 max).
- **Spell wheel** — Press **Tab** to assign spells to quick-cast slots.

**Mana & Overcast** — Mana regenerates slowly in combat. If you lack mana, **Overcast** lets you cast using HP instead (only above 15% health).

### HUD

- **Top-left** — HP pips and mana bar.
- **Overcast flash** — Appears when casting with HP instead of mana.
- **Boss bar** — During Thornweft Matron and Root Warden fights.
- **Quest tracker** — Bottom-left objective text.
- **Essence counter** — Tracks enemy defeats.

### What's Not in This Build Yet

- Remaining scoped 1.0 spells (**4 of 10 planned** for 1.0; 14 in the full GDD)
- Full Whisperwood region and most other world areas
- Fast travel MVP (Waystones exist in scenes; full Sigil Recall network pending)
- Full enemy roster, NPC dialogue, and final art/audio pass

See [DEVELOPER.md](DEVELOPER.md) and [docs/11-scoped-release.md](docs/11-scoped-release.md) for the full development status and 1.0 scope.

---

## For Developers

Design docs, architecture, debug tools, and solo-dev setup: **[DEVELOPER.md](DEVELOPER.md)**

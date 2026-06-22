class_name RelicData
extends Resource
## Passive modifier item. See docs/08-technical-architecture.md §11.

enum RelicTier { I, II, III, IV }

@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""
@export var description: String = ""
@export var tier: RelicTier = RelicTier.I
@export var icon: Texture2D
@export var icon_color: Color = Color(0.85, 0.55, 0.2, 1.0)

@export_group("Modifiers")
@export var modifiers: Array[ModifierEntry] = []
@export var unique_tag: StringName = &""
@export var is_consumable: bool = false

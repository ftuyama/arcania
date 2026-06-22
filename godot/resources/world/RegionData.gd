class_name RegionData
extends Resource
## Region map grid layout. See docs/08-technical-architecture.md §13.


@export var region_id: StringName = &""
@export var display_name: String = ""
@export var grid_width: int = 4
@export var grid_height: int = 4
@export var room_layout: Array[String] = []
@export var room_connections: Dictionary = {}
@export var total_secrets: int = 2
@export var total_bosses: int = 2

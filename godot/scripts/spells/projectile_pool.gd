extends Node
## Object pool for spell projectiles.


const PROJECTILE_SCENE := preload("res://scenes/spells/spell_projectile.tscn")

var _available: Array[SpellProjectile] = []
var _active: Array[SpellProjectile] = []


func spawn(from: Vector2, aim: Vector2, spell: SpellData, owner: Node2D = null) -> SpellProjectile:
	var projectile := _get_projectile()
	var container := _resolve_spawn_container(owner)
	container.add_child(projectile)
	projectile.launch(from, aim, spell)
	_active.append(projectile)
	return projectile


func release(projectile: SpellProjectile) -> void:
	if projectile in _active:
		_active.erase(projectile)
	if projectile.get_parent() == self:
		remove_child(projectile)
	_available.append(projectile)


func _get_projectile() -> SpellProjectile:
	if _available.is_empty():
		return PROJECTILE_SCENE.instantiate() as SpellProjectile
	return _available.pop_back()


func _resolve_spawn_container(owner: Node2D) -> Node:
	if owner == null:
		return self
	var game_world := owner.get_parent()
	if game_world == null:
		return self
	var room_container := game_world.get_node_or_null("RoomContainer") as Node
	if room_container == null or room_container.get_child_count() == 0:
		return self
	return room_container.get_child(room_container.get_child_count() - 1)

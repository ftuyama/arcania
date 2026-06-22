extends Node
## Object pool for spell projectiles.


const PROJECTILE_SCENE := preload("res://scenes/spells/spell_projectile.tscn")

var _available: Array[SpellProjectile] = []
var _active: Array[SpellProjectile] = []


func spawn(from: Vector2, aim: Vector2, spell: SpellData) -> SpellProjectile:
	var projectile := _get_projectile()
	add_child(projectile)
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

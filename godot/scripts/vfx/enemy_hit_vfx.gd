class_name EnemyHitVFX
extends Node2D
## Brief particle burst when an enemy or boss is struck.


const LIFETIME := 0.42

const PHYSICAL_SPARK := Color(0.72, 0.12, 0.14, 1.0)
const PHYSICAL_RING := Color(0.85, 0.35, 0.28, 0.85)
const FIRE_SPARK := Color(1.0, 0.55, 0.18, 1.0)
const FIRE_RING := Color(1.0, 0.78, 0.35, 0.9)


static func spawn(parent: Node, world_pos: Vector2, away_dir: Vector2, damage_type: StringName = &"physical") -> void:
	if parent == null:
		return
	var fx := EnemyHitVFX.new()
	parent.add_child(fx)
	fx.global_position = world_pos
	fx._play(away_dir, damage_type)


static func resolve_damage_type(source: Node) -> StringName:
	if source == null:
		return &"physical"
	var typed := _read_damage_type(source)
	if typed != &"":
		return typed
	for child in source.get_children():
		typed = _read_damage_type(child)
		if typed != &"":
			return typed
	var melee := source.get_node_or_null("MeleeHitbox")
	if melee:
		typed = _read_damage_type(melee)
		if typed != &"":
			return typed
	return &"physical"


static func _read_damage_type(node: Node) -> StringName:
	var value: Variant = node.get("damage_type")
	if typeof(value) != TYPE_STRING_NAME and typeof(value) != TYPE_STRING:
		return &""
	return value as StringName


func _play(away_dir: Vector2, damage_type: StringName) -> void:
	if away_dir.length_squared() < 0.01:
		away_dir = Vector2.RIGHT
	away_dir = away_dir.normalized()

	var is_fire := damage_type == &"fire"
	var spark_color := FIRE_SPARK if is_fire else PHYSICAL_SPARK
	var ring_color := FIRE_RING if is_fire else PHYSICAL_RING

	var sparks := CPUParticles2D.new()
	sparks.one_shot = true
	sparks.explosiveness = 1.0
	sparks.amount = 12 if is_fire else 10
	sparks.lifetime = 0.24
	sparks.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	sparks.emission_sphere_radius = 3.0
	sparks.direction = away_dir
	sparks.spread = 78.0
	sparks.gravity = Vector2(0, 40.0) if is_fire else Vector2(0, 220.0)
	sparks.initial_velocity_min = 80.0
	sparks.initial_velocity_max = 150.0
	sparks.angular_velocity_min = -280.0
	sparks.angular_velocity_max = 280.0
	sparks.scale_amount_min = 1.8
	sparks.scale_amount_max = 3.2
	sparks.color = spark_color
	add_child(sparks)

	var ring := Line2D.new()
	ring.width = 2.0
	ring.default_color = ring_color
	ring.points = _make_ring_points(5.0)
	ring.closed = true
	add_child(ring)

	sparks.emitting = true

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(ring, "scale", Vector2(2.2, 2.2), 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(ring, "modulate:a", 0.0, 0.18).set_delay(0.03).set_trans(Tween.TRANS_QUAD)

	get_tree().create_timer(LIFETIME).timeout.connect(queue_free, CONNECT_ONE_SHOT)


func _make_ring_points(radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var segments := 12
	for i in segments:
		var angle := TAU * float(i) / float(segments)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points

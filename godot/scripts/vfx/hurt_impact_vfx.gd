class_name HurtImpactVFX
extends Node2D
## Brief crimson spark burst at the point where the player is struck.


const LIFETIME := 0.42

const SPARK_COLOR := Color(0.95, 0.32, 0.24, 1.0)
const RING_COLOR := Color(1.0, 0.72, 0.58, 0.9)


static func spawn(parent: Node, world_pos: Vector2, away_dir: Vector2) -> void:
	if parent == null:
		return
	var fx := HurtImpactVFX.new()
	parent.add_child(fx)
	fx.global_position = world_pos
	fx._play(away_dir)


func _play(away_dir: Vector2) -> void:
	if away_dir.length_squared() < 0.01:
		away_dir = Vector2.RIGHT
	away_dir = away_dir.normalized()

	var sparks := CPUParticles2D.new()
	sparks.one_shot = true
	sparks.explosiveness = 1.0
	sparks.amount = 10
	sparks.lifetime = 0.22
	sparks.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	sparks.emission_sphere_radius = 3.0
	sparks.direction = away_dir
	sparks.spread = 72.0
	sparks.gravity = Vector2(0, 180)
	sparks.initial_velocity_min = 90.0
	sparks.initial_velocity_max = 160.0
	sparks.angular_velocity_min = -240.0
	sparks.angular_velocity_max = 240.0
	sparks.scale_amount_min = 2.0
	sparks.scale_amount_max = 3.5
	sparks.color = SPARK_COLOR
	add_child(sparks)

	var ring := Line2D.new()
	ring.width = 2.0
	ring.default_color = RING_COLOR
	ring.points = _make_ring_points(6.0)
	ring.closed = true
	add_child(ring)

	sparks.emitting = true

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(ring, "scale", Vector2(2.4, 2.4), 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(ring, "modulate:a", 0.0, 0.2).set_delay(0.04).set_trans(Tween.TRANS_QUAD)

	get_tree().create_timer(LIFETIME).timeout.connect(queue_free, CONNECT_ONE_SHOT)


func _make_ring_points(radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var segments := 12
	for i in segments:
		var angle := TAU * float(i) / float(segments)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points

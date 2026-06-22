class_name PerformanceProfiler
extends RefCounted
## Frame-time sampler and room budget checks for the 60 FPS target.


const TARGET_FPS := 60
const TARGET_FRAME_MS := 1000.0 / float(TARGET_FPS)
const MAX_PHYSICS_BODIES := 40
const MAX_DRAW_CALLS := 120
const DEFAULT_SAMPLE_WINDOW := 120
const WARMUP_FRAMES := 30

const WW07_ROOM_PATH := "res://scenes/rooms/whisperwood_hollow/ww_07_heartwood_chamber.tscn"
const WW07_MIN_ENEMIES := 4

static var _samples: PackedFloat32Array = PackedFloat32Array()
static var _sample_window: int = DEFAULT_SAMPLE_WINDOW


static func reset(window: int = DEFAULT_SAMPLE_WINDOW) -> void:
	_sample_window = maxi(window, 1)
	_samples = PackedFloat32Array()


static func record_frame(delta: float) -> void:
	if delta <= 0.0:
		return
	var frame_ms := delta * 1000.0
	_samples.append(frame_ms)
	if _samples.size() > _sample_window:
		_samples.remove_at(0)


static func get_summary() -> Dictionary:
	if _samples.is_empty():
		return {
			"sample_count": 0,
			"avg_ms": 0.0,
			"min_ms": 0.0,
			"max_ms": 0.0,
			"p95_ms": 0.0,
			"avg_fps": 0.0,
			"meets_target": false,
		}

	var sorted := _samples.duplicate()
	sorted.sort()
	var total := 0.0
	for sample in _samples:
		total += sample
	var count := _samples.size()
	var avg_ms := total / float(count)
	var p95_index := mini(int(ceil(float(count) * 0.95)) - 1, count - 1)
	p95_index = maxi(p95_index, 0)

	return {
		"sample_count": count,
		"avg_ms": avg_ms,
		"min_ms": sorted[0],
		"max_ms": sorted[count - 1],
		"p95_ms": sorted[p95_index],
		"avg_fps": 1000.0 / avg_ms if avg_ms > 0.0 else 0.0,
		"meets_target": avg_ms <= TARGET_FRAME_MS,
	}


static func count_physics_bodies(root: Node) -> int:
	if root == null:
		return 0
	var count := 0
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is PhysicsBody2D or node is PhysicsBody3D:
			count += 1
		for child in node.get_children():
			stack.append(child)
	return count


static func count_enemies(room: Node) -> int:
	var enemies := room.get_node_or_null("Entities/Enemies")
	if enemies == null:
		return 0
	return enemies.get_child_count()


static func get_draw_calls() -> int:
	return int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))


static func evaluate_room_budget(room: Node) -> Dictionary:
	var physics_bodies := count_physics_bodies(room)
	var enemies := count_enemies(room)
	var draw_calls := get_draw_calls()
	return {
		"physics_bodies": physics_bodies,
		"enemy_count": enemies,
		"draw_calls": draw_calls,
		"physics_ok": physics_bodies <= MAX_PHYSICS_BODIES,
		"enemies_ok": enemies >= WW07_MIN_ENEMIES,
		"draw_calls_ok": draw_calls <= MAX_DRAW_CALLS or draw_calls == 0,
	}


static func meets_frame_budget(summary: Dictionary) -> bool:
	return bool(summary.get("meets_target", false))


static func format_overlay_line(room: Node) -> String:
	var summary := get_summary()
	var budget := evaluate_room_budget(room)
	var fps := Engine.get_frames_per_second()
	var avg_ms := float(summary.get("avg_ms", 0.0))
	var p95_ms := float(summary.get("p95_ms", 0.0))
	var status := "OK" if meets_frame_budget(summary) else "SLOW"
	return (
		"Perf [%s] FPS %d | avg %.1f ms | p95 %.1f ms\n"
		+ "Bodies %d/%d | Draw %d/%d | Enemies %d"
		% [
			status,
			fps,
			avg_ms,
			p95_ms,
			int(budget.get("physics_bodies", 0)),
			MAX_PHYSICS_BODIES,
			int(budget.get("draw_calls", 0)),
			MAX_DRAW_CALLS,
			int(budget.get("enemy_count", 0)),
		]
	)

extends Node2D

@export var LineDrawer: PackedScene

@onready var _tween: Tween = $Tween


func setup(_vertex_positions: Array, _indices: Array, _culled_indices: Array) -> void:
	for i in range(0, _indices.size(), 3):
		var i1: int = _indices[i]
		var i2: int = _indices[i + 1]
		var i3: int = _indices[i + 2]
		
		var v1: Vector2 = _vertex_positions[i1]
		var v2: Vector2 = _vertex_positions[i2]
		var v3: Vector2 = _vertex_positions[i3]

		var line_drawer := LineDrawer.instantiate()
		line_drawer.setup(_tween, [v1, v2, v3], i1 in _culled_indices)
		add_child(line_drawer)


func do_draw() -> void:
	var anim_time := 0.5
	for i in range(1, get_child_count()):
		var c := get_child(i)
		await c.do_draw(anim_time).completed
		if i == 3:
			anim_time = 0.3
		if i == 8:
			anim_time = 0.15


func do_cull() -> void:
	for c in get_children():
		if not c is Tween and c.will_cull:
			c.do_cull()
	await _tween.tween_all_completed

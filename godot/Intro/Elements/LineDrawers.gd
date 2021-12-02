extends Node2D

export var LineDrawer: PackedScene

onready var _tween: Tween = $Tween


func setup(_vertex_positions: Array, _indices: Array, _culled_indices: Array) -> void:
	for i in range(0, _indices.size(), 3):
		var indice_slice = _indices.slice(i, i + 2)
		var vertex_slice = []
		for _i in indice_slice:
			vertex_slice.append(_vertex_positions[_i])

		var line_drawer := LineDrawer.instance()
		line_drawer.setup(_tween, vertex_slice, _indices[i] in _culled_indices)
		add_child(line_drawer)


func do_draw() -> void:
	var anim_time := 0.5
	for i in range(1, get_child_count()):
		var c := get_child(i)
		yield(c.do_draw(anim_time), "completed")
		if i == 3:
			anim_time = 0.3
		if i == 8:
			anim_time = 0.15


func do_cull() -> void:
	for c in get_children():
		if not c is Tween and c.will_cull:
			c.do_cull()
	yield(_tween, "tween_all_completed")

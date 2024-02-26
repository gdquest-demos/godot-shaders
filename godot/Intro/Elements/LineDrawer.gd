extends Node2D

var vertex_positions := []

var length := 0.0
var color_mod := 1.0
var culled_color: Color
var tween: Tween
var cull: bool
var will_cull: bool


func setup(_tween: Tween, _vertex_positions: Array, _will_cull: bool) -> void:
	vertex_positions = _vertex_positions
	will_cull = _will_cull

	tween = _tween


func do_draw(anim_time: float) -> void:
	#warning-ignore: return_value_discarded
	tween.interpolate_method(self, "_do_draw_update", 0, 1, anim_time, 0, 2, anim_time)
	#warning-ignore: return_value_discarded
	tween.start()
	await tween.tween_all_completed


func do_cull() -> void:
	cull = true
	#warning-ignore: return_value_discarded
	tween.interpolate_method(self, "_do_cull_color_update", Color.SKY_BLUE, Color.RED, 1)
	#warning-ignore: return_value_discarded
	tween.start()
	await tween.tween_all_completed
	#warning-ignore: return_value_discarded
	tween.interpolate_method(self, "_do_cull_update", 1, 0, 1)
	#warning-ignore: return_value_discarded
	tween.start()
	await tween.tween_all_completed


func _do_draw_update(value: float) -> void:
	length = value
	update()


func _do_cull_color_update(value: Color) -> void:
	culled_color = value
	update()


func _do_cull_update(value: float) -> void:
	color_mod = value
	update()


func _draw() -> void:
	var v1: Vector2 = vertex_positions[0]
	var v2: Vector2 = vertex_positions[1]
	var v3: Vector2 = vertex_positions[2]

	var color_mod_actual := 1.0
	var color := Color.SKY_BLUE

	if cull and will_cull:
		color = culled_color
		color_mod_actual = color_mod

	color *= color_mod_actual

	var lerped_v1_to_v2 = (v1).lerp(v2, length)
	var lerped_v2_to_v3 = (v2).lerp(v3, length)
	var lerped_v3_to_v1 = (v3).lerp(v1, length)

	draw_line(v1, lerped_v1_to_v2, color, 1.25)
	draw_line(v2, lerped_v2_to_v3, color, 1.25)
	draw_line(v3, lerped_v3_to_v1, color, 1.25)

	if length != 0 and length < 1.0:
		draw_circle(lerped_v1_to_v2, 5, color * 1.2)
		draw_circle(lerped_v2_to_v3, 5, color * 1.2)
		draw_circle(lerped_v3_to_v1, 5, color * 1.2)

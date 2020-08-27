extends Spatial

onready var blended_cube := $BlendedCube
onready var clipped_cube := $ClippedCube
onready var main_cube := $MainCube
onready var tween := $Tween
onready var light1 := $DirectionalLight
onready var light2 := $DirectionalLight2
onready var camera := $Camera

onready var clipped_start_color: Color = clipped_cube.get_surface_material(0).albedo_color
onready var blended_start_color: Color = blended_cube.get_surface_material(0).albedo_color
onready var main_start_color: Color = main_cube.get_surface_material(0).albedo_color


func setup() -> void:
	blended_cube.get_surface_material(0).albedo_color = Color.transparent
	clipped_cube.get_surface_material(0).albedo_color = Color.transparent
	main_cube.get_surface_material(0).albedo_color = Color.transparent


func show_clipped_cube() -> void:
	tween.interpolate_property(
		clipped_cube.get_surface_material(0),
		"albedo_color",
		Color.transparent,
		clipped_start_color,
		1
	)
	tween.start()
	yield(tween, "tween_all_completed")


func show_blended_cube() -> void:
	tween.interpolate_property(
		blended_cube.get_surface_material(0),
		"albedo_color",
		Color.transparent,
		blended_start_color,
		1
	)
	tween.start()
	yield(tween, "tween_all_completed")


func show_main_cube() -> void:
	tween.interpolate_property(
		main_cube.get_surface_material(0), "albedo_color", Color.transparent, main_start_color, 1
	)
	tween.start()
	yield(tween, "tween_all_completed")
	main_cube.get_surface_material(0).flags_transparent = false

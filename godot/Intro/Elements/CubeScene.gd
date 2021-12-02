extends Spatial

onready var blended_cube: MeshInstance = $BlendedCube
onready var clipped_cube: MeshInstance = $ClippedCube
onready var main_cube: MeshInstance = $MainCube
onready var _tween: Tween = $Tween
onready var light1: DirectionalLight = $DirectionalLight
onready var light2: DirectionalLight = $DirectionalLight2
onready var _camera: Camera = $Camera

onready var clipped_start_color: Color = clipped_cube.get_surface_material(0).albedo_color
onready var blended_start_color: Color = blended_cube.get_surface_material(0).albedo_color
onready var main_start_color: Color = main_cube.get_surface_material(0).albedo_color


func setup() -> void:
	blended_cube.get_surface_material(0).albedo_color = Color.transparent
	clipped_cube.get_surface_material(0).albedo_color = Color.transparent
	main_cube.get_surface_material(0).albedo_color = Color.transparent


func show_clipped_cube() -> void:
	_tween.interpolate_property(
		clipped_cube.get_surface_material(0),
		"albedo_color",
		Color.transparent,
		clipped_start_color,
		1
	)
	_tween.start()


func show_blended_cube() -> void:
	_tween.interpolate_property(
		blended_cube.get_surface_material(0),
		"albedo_color",
		Color.transparent,
		blended_start_color,
		1
	)
	_tween.start()


func show_main_cube() -> void:
	_tween.interpolate_property(
		main_cube.get_surface_material(0), "albedo_color", Color.transparent, main_start_color, 1
	)
	_tween.start()
	yield(_tween, "tween_all_completed")
	main_cube.get_surface_material(0).flags_transparent = false

extends Spatial

onready var _blended_cube: MeshInstance = $BlendedCube
onready var _clipped_cube: MeshInstance = $ClippedCube
onready var _main_cube: MeshInstance = $MainCube
onready var _tween: Tween = $Tween
onready var _camera: Camera = $Camera

onready var clipped_start_color: Color = _clipped_cube.get_surface_material(0).albedo_color
onready var blended_start_color: Color = _blended_cube.get_surface_material(0).albedo_color
onready var main_start_color: Color = _main_cube.get_surface_material(0).albedo_color


func setup() -> void:
	_blended_cube.get_surface_material(0).albedo_color = Color.transparent
	_clipped_cube.get_surface_material(0).albedo_color = Color.transparent
	_main_cube.get_surface_material(0).albedo_color = Color.transparent


func show_clipped_cube() -> void:
	_tween.interpolate_property(
		_clipped_cube.get_surface_material(0),
		"albedo_color",
		Color.transparent,
		clipped_start_color,
		1
	)
	_tween.start()


func show_blended_cube() -> void:
	_tween.interpolate_property(
		_blended_cube.get_surface_material(0),
		"albedo_color",
		Color.transparent,
		blended_start_color,
		1
	)
	_tween.start()


func show_main_cube() -> void:
	_tween.interpolate_property(
		_main_cube.get_surface_material(0), "albedo_color", Color.transparent, main_start_color, 1
	)
	_tween.start()
	yield(_tween, "tween_all_completed")
	_main_cube.get_surface_material(0).flags_transparent = false

tool
extends ViewportContainer

export var shockwave_duration := 1.0
export var mask_path := NodePath()

var torus_radius := -0.25 setget _set_torus_radius

onready var _tween: Tween = $Tween
onready var _preview_mask: ColorRect = get_node(mask_path)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		blast()


func blast() -> void:
	_tween.interpolate_property(
		self, "torus_radius", -0.25, 2.0, shockwave_duration, Tween.TRANS_LINEAR, Tween.EASE_OUT
	)
	_tween.start()


func _set_torus_radius(value: float) -> void:
	torus_radius = value
	if not is_inside_tree():
		yield(self, "ready")

	synchronize_materials("torus_radius", torus_radius)


func synchronize_materials(parameter_name: String, parameter_value: float) -> void:
	material.set_shader_param(parameter_name, parameter_value)
	_preview_mask.material.set_shader_param(parameter_name, parameter_value)

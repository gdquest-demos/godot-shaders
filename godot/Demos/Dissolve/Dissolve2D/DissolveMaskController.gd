tool
extends Sprite

var debug_dissolve_control := 0.0 setget _set_debug_control

var frame_count := 0

onready var tween := $Tween


func dissolve() -> void:
	tween.interpolate_method(self, "dissolve_amount", 0, 1, 3.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()


func dissolve_amount(value: float) -> void:
	material.set_shader_param("dissolve_amount", value)


func _set_debug_control(value: float) -> void:
	debug_dissolve_control = value
	if Engine.editor_hint:
		dissolve_amount(value)

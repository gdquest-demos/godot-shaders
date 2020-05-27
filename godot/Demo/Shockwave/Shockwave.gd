tool
extends TextureRect

export var shockwave_duration := 0.75

onready var tween := $Tween


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		blast()


func blast() -> void:
	tween.interpolate_method(
		self, "shockwave", -0.1, 2.0, shockwave_duration, Tween.TRANS_LINEAR, Tween.EASE_OUT
	)
	tween.start()


func shockwave(value: float) -> void:
	material.set_shader_param("radius", value)

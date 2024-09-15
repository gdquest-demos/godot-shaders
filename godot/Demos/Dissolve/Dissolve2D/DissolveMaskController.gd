@tool
extends Sprite2D

var debug_dissolve_control := 0.0: set = _set_debug_control

@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func dissolve() -> void:
	_animation_player.play("Dissolve")


func _set_debug_control(value: float) -> void:
	debug_dissolve_control = value
	if Engine.is_editor_hint():
		material.set_shader_parameter("dissolve_amount", value)

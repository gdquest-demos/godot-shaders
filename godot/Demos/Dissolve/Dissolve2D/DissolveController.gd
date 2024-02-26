@tool
extends Sprite2D

@export var emission_color: Gradient = Gradient.new(): set = _set_gradient

var debug_dissolve_control := 0.0: set = _set_debug_control

@onready var _tween: Tween = $Tween
@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if Engine.is_editor_hint():
		emission_color.connect("changed", Callable(self, "_gradient_changed"))


func dissolve() -> void:
	_animation_player.play("Dissolve")
	_tween.interpolate_method(self, "dissolve_color", 0, 1, 3.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_tween.start()


func dissolve_color(value: float) -> void:
	material.set_shader_parameter("burn_color", emission_color.sample(value))


func _set_debug_control(value: float) -> void:
	debug_dissolve_control = value
	if Engine.is_editor_hint():
		material.set_shader_parameter("dissolve_amount", value)
		dissolve_color(value)


func _set_gradient(value: Gradient) -> void:
	emission_color = value
	if Engine.is_editor_hint():
		material.set_shader_parameter("burn_color", emission_color.sample(debug_dissolve_control))


func _gradient_changed() -> void:
	if Engine.is_editor_hint():
		print(debug_dissolve_control)
		material.set_shader_parameter("burn_color", emission_color.sample(debug_dissolve_control))

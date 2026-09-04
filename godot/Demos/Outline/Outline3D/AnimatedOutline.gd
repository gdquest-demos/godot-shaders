class_name AnimatedOutline
extends RefCounted

# Godot 4 tweens are not nodes anymore: they are created on demand from a node
# in the tree, so we keep a reference to that node instead of to a Tween node.
var host: Node
var tween: Tween
var material: ShaderMaterial
var thickness_min: float
var thickness_max: float

var thickness: float
var animation_duration: float


func _init(
	_host: Node,
	_material: ShaderMaterial,
	_animation_duration: float,
	_thickness_max: float,
	_thickness_min := 0.0
) -> void:
	host = _host
	material = _material
	thickness_min = _thickness_min
	thickness_max = _thickness_max
	thickness = _thickness_min
	animation_duration = _animation_duration


func pop_in() -> void:
	_animate_to(thickness_max, Tween.EASE_OUT)


func pop_out() -> void:
	_animate_to(thickness_min, Tween.EASE_IN)


func _animate_to(target_thickness: float, easing: Tween.EaseType) -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = host.create_tween()
	tween.tween_method(_animate_outline, thickness, target_thickness, animation_duration).set_trans(Tween.TRANS_SINE).set_ease(easing)


func _animate_outline(value: float) -> void:
	material.set_shader_parameter("thickness", value)
	thickness = value

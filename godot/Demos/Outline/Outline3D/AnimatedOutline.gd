class_name AnimatedOutline
extends Reference


var tween: Tween
var material: ShaderMaterial
var thickness_min: float
var thickness_max: float

var thickness: float
var animation_duration: float


func _init(_tween: Tween, _material: ShaderMaterial, var _animation_duration: float, _thickness_max: float, _thickness_min := 0.0) -> void:
	tween = _tween
	material = _material
	thickness_min = _thickness_min
	thickness_max = _thickness_max
	thickness = _thickness_min
	animation_duration = _animation_duration


func pop_in() -> void:
	tween.stop_all()
	tween.interpolate_method(self, "_animate_outline", thickness, thickness_max, animation_duration, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()


func pop_out() -> void:
	tween.stop_all()
	tween.interpolate_method(self, "_animate_outline", thickness, thickness_min, animation_duration, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()


func _animate_outline(value: float) -> void:
	material.set_shader_param("thickness", value)
	thickness = value

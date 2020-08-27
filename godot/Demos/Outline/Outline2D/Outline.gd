extends Sprite

export var line_color := Color.white

var _alpha := 0.0

onready var tween := $Tween


func _ready() -> void:
	$Area2D.connect("mouse_entered", self, "_on_Area2D_mouse_entered")
	$Area2D.connect("mouse_exited", self, "_on_Area2D_mouse_exited")
	line_color.a = 0


func _on_Area2D_mouse_entered() -> void:
	tween.interpolate_method(
		self, "outline_alpha", _alpha, 1.0, 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT
	)
	tween.start()


func _on_Area2D_mouse_exited() -> void:
	tween.interpolate_method(
		self, "outline_alpha", _alpha, 0.0, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	tween.start()


func outline_alpha(value: float) -> void:
	_alpha = value
	line_color.a = value
	material.set_shader_param("line_color", line_color)

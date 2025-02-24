extends Sprite2D

@export var line_color := Color.WHITE

@onready var _area: Area2D = $Area2D


func _ready() -> void:
	_area.connect("mouse_entered", Callable(self, "_on_Area2D_mouse_entered"))
	_area.connect("mouse_exited", Callable(self, "_on_Area2D_mouse_exited"))
	line_color.a = 0


func _on_Area2D_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_method(outline_alpha, line_color.a, 1.0, 0.25).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)


func _on_Area2D_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_method(outline_alpha, line_color.a, 0.0, 0.25).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)


func outline_alpha(value: float) -> void:
	line_color.a = value
	material.set_shader_parameter("line_color", line_color)

# Camera offset by the mouse cursor
extends Camera2D

var factor := 0.4


func _process(_delta: float) -> void:
	offset = get_local_mouse_position() * factor

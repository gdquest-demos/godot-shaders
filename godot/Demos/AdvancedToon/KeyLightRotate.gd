extends Node3D


func _process(delta: float) -> void:
	rotate_y(deg_to_rad(45) * delta)

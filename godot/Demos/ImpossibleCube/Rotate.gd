extends MeshInstance3D


func _process(delta: float) -> void:
	rotate_y(deg_to_rad(45) * delta)
	rotate_z(deg_to_rad(-10) * delta)
	rotate_x(deg_to_rad(10) * delta)

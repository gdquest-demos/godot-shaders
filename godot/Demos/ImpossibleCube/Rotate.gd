extends MeshInstance


func _process(delta: float) -> void:
	rotate_y(deg2rad(45) * delta)
	rotate_z(deg2rad(-10) * delta)
	rotate_x(deg2rad(10) * delta)

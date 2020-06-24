extends DirectionalLight


func _process(delta: float) -> void:
	rotate_y(deg2rad(45) * delta)

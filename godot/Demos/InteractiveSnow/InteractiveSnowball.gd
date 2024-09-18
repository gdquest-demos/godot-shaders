extends MeshInstance3D

@export var move_speed := 5.0
@export var rotate_speed := PI

@export var snow_size := Vector2(1.0, 1.0)

func _process(delta: float) -> void:
	var move_dir = Vector2()
	move_dir.x = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	move_dir.y = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	rotate_y(move_dir.x * rotate_speed * delta)
	global_transform.origin += -global_transform.basis.z * move_speed * delta * move_dir.y
	global_transform.origin = Vector3(
			clamp(global_transform.origin.x, -snow_size.x, snow_size.x), 
			global_transform.origin.y, 
			clamp(global_transform.origin.z, -snow_size.y, snow_size.y))

# ANCHOR: all
extends MeshInstance

export var move_speed := 5.0
export var rotate_speed := PI


func _process(delta: float) -> void:
	var move_dir = Vector2()
	move_dir.x = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	move_dir.y = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	rotate_y(move_dir.x * rotate_speed * delta)
	global_transform.origin += -global_transform.basis.z * move_speed * delta * move_dir.y
# END: all

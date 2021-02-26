extends MeshInstance

export var move_speed = 5.0
export var rotate_speed = 180.0
export var trail_sprite_path: NodePath = ".."
export var interactive_snow_plane_path: NodePath = "../InteractiveSnowPlane/Plane"
export var snow_plane_size = Vector2(64,64)

func _process(delta):
	var move_dir = Vector2()
	move_dir.x = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	move_dir.y = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	rotate_y(move_dir.x * deg2rad(rotate_speed) * delta)
	global_transform.origin += -global_transform.basis.z * move_speed * delta * move_dir.y
	


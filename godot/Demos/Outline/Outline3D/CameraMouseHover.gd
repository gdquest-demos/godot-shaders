extends Camera3D

const MOUSE_RANGE := 10000
var last_target: Node3D

@onready var _ray: RayCast3D = $RayCast3D
@onready var view := get_tree().root

func _physics_process(_delta: float) -> void:
	# Cast a ray straight out from the camera through the current mouse position
	var mouse_position := view.get_mouse_position()
	_ray.target_position = project_local_ray_normal(mouse_position) * MOUSE_RANGE
	_ray.force_raycast_update()
	
	if _ray.is_colliding():
		var target: Area3D = _ray.get_collider()
		if last_target and last_target != target:
			last_target.pop_out()
		last_target = target
		target.pop_in()
	elif last_target:
		last_target.pop_out()
		last_target = null

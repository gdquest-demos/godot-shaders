extends Camera

const MOUSE_RANGE := 10000
var last_target: Spatial

onready var _ray: RayCast = $RayCast
onready var view := get_tree().root

func _physics_process(_delta: float) -> void:
	# Cast a ray straight out from the camera through the current mouse position
	var mouse_position := view.get_mouse_position()
	_ray.cast_to = project_local_ray_normal(mouse_position) * MOUSE_RANGE
	_ray.force_raycast_update()
	
	if _ray.is_colliding():
		var target: Area = _ray.get_collider()
		if last_target and last_target != target:
			last_target.pop_out()
		last_target = target
		target.pop_in()
	elif last_target:
		last_target.pop_out()
		last_target = null

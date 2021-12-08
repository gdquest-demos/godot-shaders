extends Camera

const MOUSE_RANGE := 10000
var last_target: Spatial

onready var ray: RayCast = $RayCast


func _physics_process(_delta: float) -> void:
	# Cast a ray straight out from the camera through the current mouse position
	var mouse_position := get_viewport().get_mouse_position()
	ray.cast_to = project_local_ray_normal(mouse_position) * MOUSE_RANGE
	ray.force_raycast_update()
	
	if ray.is_colliding():
		var target: Area = ray.get_collider()
		if last_target and last_target != target:
			last_target.pop_out()
		last_target = target
		target.pop_in()
	elif last_target:
		last_target.pop_out()
		last_target = null

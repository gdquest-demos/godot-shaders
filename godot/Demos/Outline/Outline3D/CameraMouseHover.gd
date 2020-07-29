extends Camera


var last_target: Spatial

onready var ray := $RayCast
onready var view := get_tree().root


func _physics_process(delta: float) -> void:
	var mouse_position := view.get_mouse_position()
	ray.cast_to = project_local_ray_normal(mouse_position) * 10000
	
	ray.force_raycast_update()
	if ray.is_colliding():
		if last_target:
			var target: Area = ray.get_collider()
			if last_target != target:
				last_target.pop_out()
				last_target = target
				target.pop_in()
		else:
			last_target = ray.get_collider()
			last_target.pop_in()
	else:
		if last_target:
			last_target.pop_out()
			last_target = null

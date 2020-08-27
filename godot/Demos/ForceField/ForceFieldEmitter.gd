extends RigidBody

var thrown := false


func _unhandled_input(event: InputEvent) -> void:
	if not thrown and event.is_action_pressed("ui_accept"):
		gravity_scale = 1
		apply_central_impulse(Vector3(0, 4, -6))
		thrown = true

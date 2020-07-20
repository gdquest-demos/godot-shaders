extends RigidBody


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("ui_accept"):
		gravity_scale = 1
		apply_central_impulse(Vector3(0, 2, -3))

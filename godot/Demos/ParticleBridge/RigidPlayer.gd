# ANCHOR: all
extends RigidBody

func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	var input = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
	state.apply_central_impulse(Vector3(input.y, 0, input.x))
# END: all

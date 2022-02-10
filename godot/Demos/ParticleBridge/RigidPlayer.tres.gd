# ANCHOR: all
extends RigidBody

func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	var y_axis = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down") 
	var x_axis = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	state.apply_central_impulse(Vector3(y_axis, 0, x_axis))
# END: all

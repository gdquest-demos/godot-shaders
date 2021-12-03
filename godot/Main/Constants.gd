class_name Constants

enum MovementSchemes {NONE, TOPDOWN_2D, PLATFORMER_2D, PLATFORMER_3D, WALKING_SIMULATOR}

const MOVEMENT_KEY_MAPPINGS:= {
	MovementSchemes.NONE: [],
	MovementSchemes.TOPDOWN_2D: ["move_left", "move_right", "move_up", "move_down"],
	MovementSchemes.PLATFORMER_2D: ["move_left", "move_right", "jump"],
	MovementSchemes.PLATFORMER_3D: ["move_left", "move_right", "move_up", "move_down", "jump_3d"],
	MovementSchemes.WALKING_SIMULATOR: ["move_left", "move_right", "move_up", "move_down"],
}

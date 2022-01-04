extends HBoxContainer

const UIKeyboardKey := preload("UIKeyboardKey.tscn")

onready var _label := $Label
onready var _keys := $Keys

const MOUSE_BUTTON_MAP := {
	BUTTON_LEFT: "LMB",
	BUTTON_RIGHT: "RMB",
	BUTTON_MIDDLE: "MMB",
	BUTTON_WHEEL_UP: "WUP",
	BUTTON_WHEEL_DOWN: "WDN"
}

# `keys`: array of InputEvent
func setup(action: String) -> void:
	if not is_inside_tree():
		yield(self, "ready")

	var action_inputs := InputMap.get_action_list(action)
	_label.text = action.rstrip("_3d").capitalize()

	for input in action_inputs:
		var key_display: Label = UIKeyboardKey.instance()
		if input is InputEventMouseButton:
			key_display.text = MOUSE_BUTTON_MAP[input.button_index]
		if input is InputEventJoypadMotion:
			continue
		elif input is InputEventJoypadButton:
			continue
		elif input is InputEventKey:
			key_display.text = OS.get_scancode_string(input.get_scancode_with_modifiers())
			key_display.text = key_display.text.replace("Control", "Ctrl")

		_keys.add_child(key_display)

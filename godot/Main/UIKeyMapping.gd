extends HBoxContainer

const UIKeyboardKey := preload("UIKeyboardKey.tscn")

@onready var _label := $Label
@onready var _keys := $Keys

const MOUSE_BUTTON_MAP := {
	MOUSE_BUTTON_LEFT: "LMB",
	MOUSE_BUTTON_RIGHT: "RMB",
	MOUSE_BUTTON_MIDDLE: "MMB",
	MOUSE_BUTTON_WHEEL_UP: "WUP",
	MOUSE_BUTTON_WHEEL_DOWN: "WDN"
}

# `keys`: array of InputEvent
func setup(action: String) -> void:
	if not is_inside_tree():
		await self.ready

	var action_inputs := InputMap.action_get_events(action)
	_label.text = action.rstrip("_3d").capitalize()

	for input in action_inputs:
		var key_display: Label = UIKeyboardKey.instantiate()
		if input is InputEventMouseButton:
			key_display.text = MOUSE_BUTTON_MAP[input.button_index]
		if input is InputEventJoypadMotion:
			continue
		elif input is InputEventJoypadButton:
			continue
		elif input is InputEventKey:
			key_display.text = OS.get_keycode_string(input.get_keycode_with_modifiers())
			key_display.text = key_display.text.replace("Control", "Ctrl")

		_keys.add_child(key_display)

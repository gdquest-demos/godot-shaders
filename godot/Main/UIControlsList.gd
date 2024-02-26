@tool
extends Control

const UIKeyMapping := preload("UIKeyMapping.tscn")

@export var is_foldable := true: set = set_is_foldable
@export var title := "": set = set_title
@export var controls: Array[String] = []

@onready var _controls_table := find_child("ControlsTable")
@onready var _toggle_button := find_child("ToggleButton")
@onready var _toggle_button_container := $MarginContainer
@onready var _controls_panel := find_child("ControlsPanel")
@onready var _title_label := find_child("TitleLabel")


func _ready() -> void:
	_toggle_button.connect("toggled", Callable(self, "toggle_panel"))
	_toggle_button.focus_mode = Control.FOCUS_NONE
	if controls and not Engine.is_editor_hint():
		setup(controls)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_controls_visible"):
		toggle_panel(not _toggle_button.pressed)


func setup(input_actions: Array, movement_scheme: int = Constants.MovementSchemes.NONE) -> void:
	for action in input_actions:
		add_control_from_input_action(action)
	add_controls_from_scheme(movement_scheme)

	if not input_actions and movement_scheme == Constants.MovementSchemes.NONE:
		toggle_panel(false)


# Generates an array of instanced control rows from one of the supported scheme.
# See the ControlScheme enum to see supported schemes.
func add_controls_from_scheme(scheme: int) -> void:
	var actions: Array = Constants.MOVEMENT_KEY_MAPPINGS[scheme]
	for action in actions:
		add_control_from_input_action(action)


func add_control_from_input_action(action: String) -> void:
	assert(InputMap.has_action(action), "Action '%s' does not exist. Can't add it to the controls panel" % action)
	var key_mapping := UIKeyMapping.instantiate()
	key_mapping.setup(action)
	_controls_table.add_child(key_mapping)


func toggle_panel(is_visible: bool) -> void:
	_toggle_button.text = "<" if is_visible else ">"
	_toggle_button.button_pressed = is_visible
	_controls_panel.visible = is_visible


func set_is_foldable(value: bool) -> void:
	is_foldable = value
	if not is_inside_tree():
		await self.ready
	_toggle_button_container.visible = is_foldable


func set_title(value: String) -> void:
	title = value
	if not is_inside_tree():
		await self.ready

	if value != "":
		_title_label.text = value

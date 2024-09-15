extends Button

signal demo_requested

@export var demo_name := "": set = set_demo_name
@export var demo_icon: Texture2D: set = set_demo_icon


@onready var _label :Label= $HBoxContainer/Label
@onready var _icon : TextureRect= $HBoxContainer/Icon


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and event.double_click and get_viewport().gui_get_focus_owner() == self:
		emit_signal("demo_requested")
	elif event.is_action_pressed("ui_accept") and get_viewport().gui_get_focus_owner() == self:
		emit_signal("demo_requested")


func set_demo_name(value: String) -> void:
	demo_name = value
	if not is_inside_tree():
		await self.ready
	_label.text = demo_name


func set_demo_icon(value: Texture2D) -> void:
	demo_icon = value
	if not is_inside_tree():
		await self.ready
	_icon.texture = value
	_icon.visible = value != null

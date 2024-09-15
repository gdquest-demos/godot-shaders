@tool
extends Node

@export (float, 0, 1) var debug_dissolve_control := 0.0: set = _set_debug_control

@onready var mask := owner.get_node("MaskView/SubViewport/RobiMask")
@onready var robi := owner.get_node("Robi")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		mask.dissolve()
		robi.dissolve()


func _set_debug_control(value: float) -> void:
	debug_dissolve_control = value
	if not is_inside_tree():
		await self.ready

	if Engine.is_editor_hint():
		mask.debug_dissolve_control = value
		robi.debug_dissolve_control = value

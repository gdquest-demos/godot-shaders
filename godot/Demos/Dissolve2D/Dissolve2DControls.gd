tool
extends Node

export (float, 0, 1) var debug_dissolve_control := 0.0 setget _set_debug_control

onready var mask := get_parent().get_node("MaskView/RobiMask")
onready var robi := get_parent().get_node("Robi")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		mask.dissolve()
		robi.dissolve()


func _set_debug_control(value: float) -> void:
	debug_dissolve_control = value
	if not is_inside_tree():
		yield(self, "ready")

	if Engine.editor_hint:
		mask.debug_dissolve_control = value
		robi.debug_dissolve_control = value

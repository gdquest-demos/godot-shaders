tool
extends Node2D

export (float, 0, 1) var debug_dissolve_control := 0.0 setget _set_debug_control

onready var mask := $MaskView/RobiMask
onready var robi := $Robi


func _set_debug_control(value: float) -> void:
	debug_dissolve_control = value
	if Engine.editor_hint:
		mask.debug_dissolve_control = value
		robi.debug_dissolve_control = value

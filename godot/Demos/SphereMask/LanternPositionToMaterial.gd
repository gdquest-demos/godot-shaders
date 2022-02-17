# ANCHOR: all
tool
extends Node

onready var _bridge_body: MeshInstance = $BridgeBody
onready var _lantern: MeshInstance = $Lantern


func _process(_delta: float) -> void:
	_bridge_body.material_override.set_shader_param("mask_center", _lantern.global_transform.origin)

# END: all

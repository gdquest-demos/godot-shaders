@tool
# ANCHOR: all
extends Node

@onready var _bridge_body: MeshInstance3D = $BridgeBody
@onready var _lantern: MeshInstance3D = $Lantern


func _process(_delta: float) -> void:
	_bridge_body.material_override.set_shader_parameter("mask_center", _lantern.global_transform.origin)

# END: all

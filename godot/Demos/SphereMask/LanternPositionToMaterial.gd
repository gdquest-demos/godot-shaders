extends Node
tool

onready var _bridge_body: MeshInstance = $BridgeBody
onready var _lantern: MeshInstance = $Lantern


func _process(_delta: float) -> void:
	_bridge_body.get_surface_material(0).set_shader_param("mask_center", _lantern.global_transform.origin)

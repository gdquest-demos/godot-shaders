extends Node
tool

func _process(delta):
	$BridgeBody.get_surface_material(0).set_shader_param("mask_center", $Lantern.global_transform.origin)

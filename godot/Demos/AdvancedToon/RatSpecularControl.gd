tool
extends Spatial

export var specular_material: SpatialMaterial setget _set_specular_material

onready var _body: MeshInstance = $body1
onready var _head: MeshInstance = $head1
onready var _teeth: MeshInstance = $teeth1
onready var _eyes: MeshInstance = $eyes1


func _set_specular_material(value: SpatialMaterial) -> void:
	specular_material = value
	if not is_inside_tree():
		yield(self, "ready")
	_body.set_surface_material(0, specular_material)
	_head.set_surface_material(0, specular_material)
	_teeth.set_surface_material(0, specular_material)
	_eyes.set_surface_material(0, specular_material)

tool
extends Spatial

export var material: ShaderMaterial setget _set_material
export var body_texture: Texture setget _set_body_texture
export var head_texture: Texture setget _set_head_texture

onready var _body: MeshInstance = $body1
onready var _eyes: MeshInstance = $eyes1
onready var _teeth: MeshInstance = $teeth1
onready var _head: MeshInstance = $head1
onready var camera: Camera = get_parent().get_node("Camera")


func _set_material(value: ShaderMaterial) -> void:
	if material:
		material.disconnect("changed", self, "_on_material_changed")
	material = value
	if not is_inside_tree():
		yield(self, "ready")
	if material:
		material.connect("changed", self, "_on_material_changed")
		material.set_shader_param(
			"world_camera_position", camera.global_transform.origin
		)
	_body.set_surface_material(0, material.duplicate())
	_head.set_surface_material(0, material.duplicate())
	_teeth.set_surface_material(0, material.duplicate())
	_eyes.set_surface_material(0, material.duplicate())
	_eyes.get_surface_material(0).set_shader_param("specular_softness", 0.0)
	_eyes.get_surface_material(0).set_shader_param("specular_size", 1.0)


func _set_body_texture(value: Texture) -> void:
	body_texture = value
	if not is_inside_tree():
		yield(self, "ready")
	_body.get_surface_material(0).set_shader_param(
		"base_color_texture", body_texture
	)


func _set_head_texture(value: Texture) -> void:
	head_texture = value
	if not is_inside_tree():
		yield(self, "ready")
	_head.get_surface_material(0).set_shader_param(
		"base_color_texture", head_texture
	)
	_teeth.get_surface_material(0).set_shader_param(
		"base_color_texture", head_texture
	)
	_eyes.get_surface_material(0).set_shader_param(
		"base_color_texture", head_texture
	)


func _on_material_changed() -> void:
	_body.set_surface_material(0, material.duplicate())
	_head.set_surface_material(0, material.duplicate())
	_teeth.set_surface_material(0, material.duplicate())
	_eyes.set_surface_material(0, material.duplicate())
	_eyes.get_surface_material(0).set_shader_param("specular_softness", 0.0)
	_eyes.get_surface_material(0).set_shader_param("specular_size", 1.0)
	_set_body_texture(body_texture)
	_set_head_texture(head_texture)

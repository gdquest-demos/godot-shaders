tool
extends Spatial

export var body_material: ShaderMaterial setget _set_body_material
export var eyes_material: ShaderMaterial setget _set_eyes_material
export var head_material: ShaderMaterial setget _set_head_material
export var teeth_material: ShaderMaterial setget _set_teeth_material
export var light_data: ViewportTexture setget _set_light_data

onready var _body: MeshInstance = $body1
onready var _eyes: MeshInstance = $eyes1
onready var _teeth: MeshInstance = $teeth1
onready var _head: MeshInstance = $head1
onready var camera: Camera = get_parent().get_node("Camera")


func _process(delta: float) -> void:
	body_material.set_shader_param(
		"world_camera_position", camera.global_transform.origin
	)
	eyes_material.set_shader_param("world_camera_position", camera.global_transform.origin)
	head_material.set_shader_param("world_camera_position", camera.global_transform.origin)
	teeth_material.set_shader_param("world_camera_position", camera.global_transform.origin)


func _set_body_material(value: ShaderMaterial) -> void:
	body_material = value
	if not is_inside_tree():
		yield(self, "ready")
	_body.set_surface_material(0, body_material)


func _set_eyes_material(value: ShaderMaterial) -> void:
	eyes_material = value
	if not is_inside_tree():
		yield(self, "ready")
	_eyes.set_surface_material(0, eyes_material)


func _set_head_material(value: ShaderMaterial) -> void:
	head_material = value
	if not is_inside_tree():
		yield(self, "ready")
	_head.set_surface_material(0, head_material)


func _set_teeth_material(value: ShaderMaterial) -> void:
	teeth_material = value
	if not is_inside_tree():
		yield(self, "ready")
	_teeth.set_surface_material(0, teeth_material)


func _set_light_data(value: ViewportTexture) -> void:
	light_data = value
	if not is_inside_tree():
		yield(self, "ready")
	if body_material:
		body_material.set_shader_param("light_data", light_data)
	if eyes_material:
		eyes_material.set_shader_param("light_data", light_data)
	if head_material:
		head_material.set_shader_param("light_data", light_data)
	if teeth_material:
		teeth_material.set_shader_param("light_data", light_data)

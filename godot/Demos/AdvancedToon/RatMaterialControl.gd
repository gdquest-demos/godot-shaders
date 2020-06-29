tool
extends Spatial

export var material: ShaderMaterial setget _set_material

export var flesh_color: Color setget _set_flesh_color
export var eye_color: Color setget _set_eye_color
export var teeth_color: Color setget _set_teeth_color
export var claws_color: Color setget _set_claws_color

export var body_flesh_mask: Texture setget _set_body_flesh_mask
export var head_flesh_mask: Texture setget _set_head_flesh_mask

export var body_claws_mask: Texture setget _set_body_claws_mask
export var head_teeth_mask: Texture setget _set_head_teeth_mask
export var head_eyes_mask: Texture setget _set_head_eyes_mask

onready var _body: MeshInstance = $body1
onready var _eyes: MeshInstance = $eyes1
onready var _teeth: MeshInstance = $teeth1
onready var _head: MeshInstance = $head1
onready var camera: Camera = get_parent().get_node("Camera")

var disco_mode := false
var elapsed_time := 0.0
onready var original_flesh_color: Color = flesh_color


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		disco_mode = not disco_mode
		if not disco_mode:
			self.flesh_color = original_flesh_color


func _process(delta: float) -> void:
	if disco_mode:
		elapsed_time += delta
		if elapsed_time > 0.2:
			elapsed_time = 0.0
			self.flesh_color = Color(
				rand_range(0, 1), rand_range(0, 1), rand_range(0, 1)
			)


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
	var head_mat := material.duplicate()
	_head.set_surface_material(0, head_mat)
	_teeth.set_surface_material(0, head_mat)
	_eyes.set_surface_material(0, head_mat)


func _set_body_flesh_mask(value: Texture) -> void:
	body_flesh_mask = value
	if not is_inside_tree():
		yield(self, "ready")
	_body.get_surface_material(0).set_shader_param(
		"paint_mask1", body_flesh_mask
	)


func _set_flesh_color(value: Color) -> void:
	flesh_color = value
	if not is_inside_tree():
		yield(self, "ready")
	_body.get_surface_material(0).set_shader_param("paint_color1", flesh_color)
	_head.get_surface_material(0).set_shader_param("paint_color1", flesh_color)


func _set_head_flesh_mask(value: Texture) -> void:
	head_flesh_mask = value
	if not is_inside_tree():
		yield(self, "ready")
	_head.get_surface_material(0).set_shader_param(
		"paint_mask1", head_flesh_mask
	)


func _set_head_teeth_mask(value: Texture) -> void:
	head_teeth_mask = value
	if not is_inside_tree():
		yield(self, "ready")
	_head.get_surface_material(0).set_shader_param(
		"paint_mask2", head_teeth_mask
	)


func _set_head_eyes_mask(value: Texture) -> void:
	head_eyes_mask = value
	if not is_inside_tree():
		yield(self, "ready")
	_head.get_surface_material(0).set_shader_param(
		"paint_mask3", head_eyes_mask
	)


func _set_eye_color(value: Color) -> void:
	eye_color = value
	if not is_inside_tree():
		yield(self, "ready")
	_head.get_surface_material(0).set_shader_param("paint_color3", eye_color)


func _set_teeth_color(value: Color) -> void:
	teeth_color = value
	if not is_inside_tree():
		yield(self, "ready")
	_head.get_surface_material(0).set_shader_param("paint_color2", teeth_color)


func _on_material_changed() -> void:
	_body.set_surface_material(0, material.duplicate())

	var head_mat := material.duplicate()
	_head.set_surface_material(0, head_mat)
	_teeth.set_surface_material(0, head_mat)
	_eyes.set_surface_material(0, head_mat)

	_set_body_flesh_mask(body_flesh_mask)
	_set_head_flesh_mask(head_flesh_mask)
	_set_head_eyes_mask(head_eyes_mask)
	_set_head_teeth_mask(head_teeth_mask)
	_set_body_claws_mask(body_claws_mask)
	_set_flesh_color(flesh_color)
	_set_eye_color(eye_color)
	_set_teeth_color(teeth_color)
	_set_claws_color(claws_color)


func _set_body_claws_mask(value: Texture) -> void:
	body_claws_mask = value
	if not is_inside_tree():
		yield(self, "ready")
	_body.get_surface_material(0).set_shader_param(
		"paint_mask2", body_claws_mask
	)


func _set_claws_color(value: Color) -> void:
	claws_color = value
	if not is_inside_tree():
		yield(self, "ready")
	_body.get_surface_material(0).set_shader_param("paint_color2", claws_color)

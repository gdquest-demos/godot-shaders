tool
class_name ToonInspector
extends EditorInspectorPlugin

var connect_button: Button


func can_handle(object: Object) -> bool:
	return object is ToonSceneBuilder


func parse_category(object: Object, category: String) -> void:
	if object is ToonSceneBuilder:
		if not connect_button:
			connect_button = Button.new()
			connect_button.text = "Connect ViewportTextures"
			connect_button.connect(
				"button_down", self, "_on_Connect_Button_down", [object]
			)
			add_custom_control(connect_button)


func _on_Connect_Button_down(builder: ToonSceneBuilder) -> void:
	var light_data: Viewport = builder.light_data
	var specular_data: Viewport = builder.specular_data
	var rim_data: Viewport = builder.rim_data

	var top_parent := (Engine.get_main_loop() as SceneTree).edited_scene_root
	var light_texture := light_data.get_texture()
	var specular_texture := specular_data.get_texture()
	var rim_texture: ViewportTexture
	if rim_data:
		rim_texture = rim_data.get_texture()

	light_texture.viewport_path = top_parent.get_path_to(light_data)
	specular_texture.viewport_path = top_parent.get_path_to(specular_data)
	if rim_data:
		rim_texture.viewport_path = top_parent.get_path_to(rim_data)
	_set_materials(top_parent, light_texture, specular_texture, rim_texture)


func _set_materials(
	parent: Node, light_data: ViewportTexture, specular_data: ViewportTexture, rim_data: ViewportTexture
) -> void:
	if parent is MeshInstance:
		for mat in range(parent.get_surface_material_count()):
			var material: Material = parent.get_surface_material(mat)
			if material and material is ShaderMaterial:
				material.set_shader_param("light_data", light_data.duplicate())
				material.set_shader_param(
					"specular_data", specular_data.duplicate()
				)
				material.set_shader_param("rim_data", rim_data.duplicate() if rim_data else null)
	for child in parent.get_children():
		_set_materials(child, light_data, specular_data, rim_data)

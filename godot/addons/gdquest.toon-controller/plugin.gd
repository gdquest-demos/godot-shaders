tool
extends EditorPlugin

var light_camera: Camera
var specular_camera: Camera
var main_camera: Camera

var light_viewport: Viewport
var specular_viewport: Viewport

var editor_viewport: Control
var preview_checkbox: CheckBox

var plugin: EditorInspectorPlugin


func _enter_tree() -> void:
	plugin = preload("ToonInspector.gd").new()
	add_inspector_plugin(plugin)


func _exit_tree() -> void:
	if preview_checkbox:
		preview_checkbox.disconnect("pressed", self, "_on_Preview_pressed")


func handles(object: Object) -> bool:
	if (
		object == get_tree().edited_scene_root
		and _find_toon_scene_builder(object)
	):
		return _initialize_camera_control(object, get_editor_interface())
	else:
		return false


func forward_spatial_gui_input(camera: Camera, event: InputEvent) -> bool:
	_set_camera_and_viewports(camera.global_transform)
	return false


func _on_Preview_pressed() -> void:
	var camera := get_editor_interface().get_edited_scene_root().get_viewport().get_camera()
	_set_camera_and_viewports(camera.global_transform)


func _set_camera_and_viewports(transform: Transform) -> void:
	if light_camera:
		light_camera.global_transform = transform
		light_viewport.size = editor_viewport.rect_size
	if specular_camera:
		specular_camera.global_transform = transform
		specular_viewport.size = editor_viewport.rect_size


func _initialize_camera_control(object: Object, interface: EditorInterface) -> bool:
	var toon_builder: ToonSceneBuilder = _find_toon_scene_builder(object)
	main_camera = object.get_parent().get_camera()

	light_viewport = toon_builder.light_data
	if light_viewport:
		light_camera = light_viewport.get_camera()

	specular_viewport = toon_builder.specular_data
	if specular_viewport:
		specular_camera = specular_viewport.get_camera()

	if light_camera or specular_camera:
		return _set_and_connect_cameras(interface)
	else:
		return false


func _find_toon_scene_builder(parent: Node) -> ToonSceneBuilder:
	for child in parent.get_children():
		if child is ToonSceneBuilder:
			return child
		else:
			var result := _find_toon_scene_builder(child)
			if result:
				return result
	return null


func _set_and_connect_cameras(interface: EditorInterface) -> bool:
	set_input_event_forwarding_always_enabled()
	var editor_root := interface.get_editor_viewport()

	editor_viewport = _find_by_type_name(editor_root, "SpatialEditorViewport")

	preview_checkbox = _find_by_type_name(editor_viewport, "CheckBox")

	if not preview_checkbox.is_connected(
		"pressed", self, "_on_Preview_pressed"
	):
		preview_checkbox.connect("pressed", self, "_on_Preview_pressed")

	if light_viewport:
		light_viewport.size = editor_viewport.rect_size
	if specular_viewport:
		specular_viewport.size = editor_viewport.rect_size

	return true


func _find_by_type_name(parent: Node, type_name: String) -> Node:
	for child in parent.get_children():
		if child.get_class() == type_name:
			return child
		else:
			var result: Node = _find_by_type_name(child, type_name)
			if result:
				return result
	return null

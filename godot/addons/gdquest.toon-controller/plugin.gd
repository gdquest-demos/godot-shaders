tool
extends EditorPlugin

var light_camera: Camera
var specular_camera: Camera
var main_camera: Camera

var light_viewport: Viewport
var specular_viewport: Viewport

var editor_viewport: Control
var preview_checkbox: CheckBox


func _enter_tree() -> void:
	pass


func _exit_tree() -> void:
	if preview_checkbox:
		preview_checkbox.disconnect("pressed", self, "_on_Preview_pressed")


func handles(object: Object) -> bool:
	var interface := get_editor_interface()
	if object == get_tree().edited_scene_root and object.get_child(0) is ToonSceneBuilder:
		return _initialize_camera_control(object, interface)
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
	var toon_builder: ToonSceneBuilder = object.get_child(0)
	main_camera = object.get_parent().get_camera()

	light_viewport = toon_builder.light_data
	if light_viewport:
		light_camera = light_viewport.get_camera()
	specular_viewport = toon_builder.specular_data
	if specular_viewport:
		specular_camera = specular_viewport.get_camera()

	if light_camera or specular_camera:
		set_input_event_forwarding_always_enabled()
		var editor_root := interface.get_editor_viewport()
		editor_viewport = _get_child_in_sequence(editor_root, [1, 1, 0, 0, 0])

		preview_checkbox = _get_child_in_sequence(editor_viewport, [1, 0, 1])

		if not preview_checkbox.is_connected(
			"pressed", self, "_on_Preview_pressed"
		):
			preview_checkbox.connect("pressed", self, "_on_Preview_pressed")

		if light_viewport:
			light_viewport.size = editor_viewport.rect_size
		if specular_viewport:
			specular_viewport.size = editor_viewport.rect_size
		return true
	else:
		return false

func _get_child_in_sequence(parent: Node, sequence: Array) -> Node:
	for i in sequence:
		parent = parent.get_child(i)
	return parent

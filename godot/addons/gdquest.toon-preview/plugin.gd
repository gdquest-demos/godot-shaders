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
	if object is Spatial and interface.get_edited_scene_root() == object:
		main_camera = object.get_parent().get_camera()

		light_viewport = object.find_node("LightData").get_child(0)
		light_camera = light_viewport.get_node("Camera")
		specular_viewport = object.find_node("SpecularData").get_child(0)
		specular_camera = specular_viewport.get_node("Camera")

		if light_camera or specular_camera:
			set_input_event_forwarding_always_enabled()
			var editor_root := interface.get_editor_viewport()
			editor_viewport = editor_root.get_child(1).get_child(1).get_child(0).get_child(0).get_child(
				0
			)

			preview_checkbox = editor_viewport.get_child(1).get_child(0).get_child(
				1
			)

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

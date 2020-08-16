tool
extends EditorPlugin


var Popup := preload("SetLayerDialog.tscn")
var popup: WindowDialog
var render_value := 0xFFFFF


func _exit_tree() -> void:
	remove_tool_menu_item("Set Editor Camera Render Layer")
	popup.free()


func handles(object: Object) -> bool:
	if object == get_tree().edited_scene_root:
		popup = Popup.instance()
		add_child(popup)
		
		popup.connect("flag_changed", self, "_on_RenderLayer_flag_changed")
		
		set_input_event_forwarding_always_enabled()
		
		add_tool_menu_item("Set Editor Camera Render Layer", self, "_on_set_render_layer")
		
		return true
	return false


func forward_spatial_gui_input(camera: Camera, event: InputEvent) -> bool:
	camera.cull_mask = render_value
	return false


func _on_set_render_layer(userdata) -> void:
	popup.popup_centered()


func _on_RenderLayer_flag_changed(value: int) -> void:
	render_value = value

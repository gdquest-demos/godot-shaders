tool
extends Sprite


func _ready() -> void:
	connect("item_rect_changed", self, "_on_item_rect_changed")
	if not Engine.editor_hint:
		set_process(false)


func _process(delta: float) -> void:
	update_zoom(get_viewport().global_canvas_transform.y.y)


func update_zoom(value: float) -> void:
	material.set_shader_param("zoom_y", value)


func _on_item_rect_changed() -> void:
	material.set_shader_param("scale_y", scale.y)

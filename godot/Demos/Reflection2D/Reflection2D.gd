# Forwards the Y zoom and Y scale values to the mirror shader
tool
extends Sprite

func _ready() -> void:
	connect("item_rect_changed", self, "_on_item_rect_changed")


func _process(_delta: float) -> void:
	update_zoom(get_viewport_transform().y.y)


func update_zoom(value: float) -> void:
	material.set_shader_param("zoom_y", value)


func _on_item_rect_changed() -> void:
	material.set_shader_param("scale_y", scale.y)

@tool
# Forwards the Y zoom and Y scale values to the mirror shader
extends Sprite2D

func _ready() -> void:
	connect("item_rect_changed", Callable(self, "_on_item_rect_changed"))


func _process(_delta: float) -> void:
	update_zoom(get_viewport_transform().y.y)


func update_zoom(value: float) -> void:
	material.set_shader_parameter("zoom_y", value)


func _on_item_rect_changed() -> void:
	material.set_shader_parameter("scale_y", scale.y)

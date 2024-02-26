@tool
extends Sprite2D


func _ready() -> void:
	connect("item_rect_changed", Callable(self, "_on_item_rect_changed"))
	get_viewport().transparent_bg = true
	_on_item_rect_changed()


func _on_item_rect_changed() -> void:
	material.set_shader_parameter("aspect_ratio", scale.y / scale.x)

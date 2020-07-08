# Sets water shader parameters
tool
extends Sprite


func _ready() -> void:
	connect("item_rect_changed", self, "update_scale")
	connect("texture_changed", self, "update_aspect_ratio")

	update_aspect_ratio()
	update_zoom()
	update_scale()


func _process(delta: float) -> void:
	update_zoom()


func update_scale() -> void:
	material.set_shader_param("scale", scale)


# Sets the canvas zoom level
func update_zoom() -> void:
	material.set_shader_param("zoom_y", get_viewport_transform().y.y)


# Sets the aspect ratio of the texture
func update_aspect_ratio() -> void:
	var size: Vector2 = texture.get_size()
	material.set_shader_param("aspect_ratio", size.x / size.y)

class_name DebugViewer
extends Control

export (float, 0.1, 1, 0.025) var size_multiplier = 0.125
export var enabled := true setget _set_enabled


func _ready() -> void:
	anchor_bottom = 1
	anchor_left = 0
	anchor_right = 0
	anchor_top = 0
	refresh_viewports()


func refresh_viewports() -> void:
	var width: int = ProjectSettings.get_setting("display/window/size/width") * size_multiplier
	var height: int = ProjectSettings.get_setting("display/window/size/height") * size_multiplier

	var vbox := VBoxContainer.new()
	vbox.anchor_bottom = 1
	var viewports := _get_viewports()
	for viewport in viewports:
		var _texture_rect := TextureRect.new()

		_texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
		_texture_rect.expand = true

		_texture_rect.rect_min_size = Vector2(width, height)
		_texture_rect.texture = viewport.get_texture()

		vbox.add_child(_texture_rect)
	add_child(vbox)


func _get_viewports() -> Array:
	var viewports := []
	var children := get_tree().root.get_children()

	while children.size() > 0:
		var child: Node = children.pop_back()
		if child is Viewport:
			viewports.append(child)
		children += child.get_children()

	return viewports


func _set_enabled(value: bool) -> void:
	enabled = value
	visible = enabled

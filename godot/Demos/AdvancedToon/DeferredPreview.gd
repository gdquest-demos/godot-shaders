tool
extends Control


func _ready() -> void:
	var width: int = ProjectSettings.get_setting("display/window/size/width")
	var height: int = ProjectSettings.get_setting("display/window/size/height")

	var viewport := get_tree().root
	var cam: Camera = get_parent().get_node("Camera")
	print("%s vs %s" % [get_tree().root.get_camera(), cam])
	#$TextureRect.texture = get_tree().root.get_texture()
	#$TextureRect.rect_size = Vector2(width * 0.33, height * 0.33)

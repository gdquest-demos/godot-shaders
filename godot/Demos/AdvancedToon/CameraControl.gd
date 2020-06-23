tool
extends RemoteTransform


func _ready() -> void:
	if Engine.editor_hint:
		update_position = false
		update_rotation = false
		update_scale = false

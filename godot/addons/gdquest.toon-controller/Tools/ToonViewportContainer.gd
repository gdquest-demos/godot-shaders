@tool
class_name ToonViewportContainer
extends SubViewportContainer


func _enter_tree() -> void:
	stretch = not Engine.is_editor_hint()

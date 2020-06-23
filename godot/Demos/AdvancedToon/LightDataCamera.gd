tool
extends Camera

var editor_camera: Camera


func _ready() -> void:
	if Engine.editor_hint:
		var remote_transform := RemoteTransform.new()
		remote_transform.remote_path = get_path()
		editor_camera = get_tree().get_edited_scene_root().get_parent().get_camera()


func _process(delta: float) -> void:
	if Engine.editor_hint:
		global_transform = editor_camera.global_transform

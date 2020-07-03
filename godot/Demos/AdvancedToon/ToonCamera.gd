tool
class_name ToonCamera
extends Camera


var original_transform: Transform


func _ready() -> void:
	toggle_remotes()


func toggle_remotes() -> void:
	var is_game := not Engine.editor_hint

	var light_remote: RemoteTransform = find_node("LightRemote")
	if light_remote:
		light_remote.update_position = is_game
		light_remote.update_rotation = is_game
		light_remote.update_scale = is_game

	var specular_remote: RemoteTransform = find_node("SpecularRemote")
	if specular_remote:
		specular_remote.update_position = is_game
		specular_remote.update_rotation = is_game
		specular_remote.update_scale = is_game

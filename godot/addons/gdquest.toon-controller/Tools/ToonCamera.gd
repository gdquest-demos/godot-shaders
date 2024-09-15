@tool
class_name ToonCamera
extends Camera3D


func _ready() -> void:
	toggle_remotes()


# Sets the remote transform's activation on or off depending on if project is in Editor
func toggle_remotes() -> void:
	var is_game := not Engine.is_editor_hint()

	var light_remote: RemoteTransform3D = find_child("LightRemote")
	if light_remote:
		light_remote.update_position = is_game
		light_remote.update_rotation = is_game
		light_remote.update_scale = is_game

	var specular_remote: RemoteTransform3D = find_child("SpecularRemote")
	if specular_remote:
		specular_remote.update_position = is_game
		specular_remote.update_rotation = is_game
		specular_remote.update_scale = is_game

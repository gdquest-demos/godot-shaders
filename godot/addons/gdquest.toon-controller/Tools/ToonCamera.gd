tool
class_name ToonCamera
extends Camera


func _ready() -> void:
	toggle_remotes()


# Sets the remote transform's activation on or off depending on if project is in Editor
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
	
	var rim_remote: RemoteTransform = find_node("RimRemote")
	if rim_remote:
		rim_remote.update_position = is_game
		rim_remote.update_rotation = is_game
		rim_remote.update_scale = is_game

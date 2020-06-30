tool
extends Camera


var original_transform: Transform


func _ready() -> void:
	var is_game := not Engine.editor_hint

	var light_remote: RemoteTransform = $LightRemote
	light_remote.update_position = is_game
	light_remote.update_rotation = is_game
	light_remote.update_scale = is_game

	var specular_remote: RemoteTransform = $SpecularRemote
	specular_remote.update_position = is_game
	specular_remote.update_rotation = is_game
	specular_remote.update_scale = is_game
	
